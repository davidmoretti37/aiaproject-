import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:calma_flutter/features/aia/services/audio_service.dart';
import 'package:calma_flutter/core/services/supabase_service.dart';
import 'package:calma_flutter/services/ai_prompt_service.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:url_launcher/url_launcher.dart';

class OpenAIRealtimeService {
  RTCPeerConnection? _peerConnection;
  RTCDataChannel? _dataChannel;
  MediaStream? _localStream;
  MediaStream? _remoteStream;

  final VoidCallback? onListeningStarted;
  final VoidCallback? onConversationDone;
  final void Function(Uint8List)? onAudioResponse;
  final String? userName;

  bool _isConnected = false;
  bool get isConnected => _isConnected;
  bool _isProcessingConnection = false;

  // Variável para acumular a resposta da IA
  String _currentIAResponse = '';
  
  // Variáveis para salvar conversa
  String _currentUserMessage = '';
  List<Map<String, dynamic>> _conversationExchanges = [];
  DateTime? _conversationStartTime;
  DateTime? _currentExchangeStart;
  int _exchangeCounter = 0;

  // Configuração de ICE servers para WebRTC
  final Map<String, dynamic> _configuration = {
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'},
      {'urls': 'stun:stun1.l.google.com:19302'},
    ],
    'sdpSemantics': 'unified-plan'
  };

  OpenAIRealtimeService({
    this.onListeningStarted,
    this.onConversationDone,
    this.onAudioResponse,
    this.userName,
  });

  Future<bool> iniciarConexaoComOpenAI() async {
    if (_isProcessingConnection) {
      debugPrint('[AIA] Já existe uma conexão em andamento');
      return false;
    }

    _isProcessingConnection = true;

    try {
      // Limpar qualquer conexão anterior
      await encerrarConversa();

      // Inicializar dados da conversa
      _conversationStartTime = DateTime.now();
      _conversationExchanges.clear();
      _exchangeCounter = 0;
      _currentUserMessage = '';
      _currentIAResponse = '';

      debugPrint('[AIA] Criando conexão WebRTC...');
      _peerConnection = await createPeerConnection(_configuration);

      // Configurar eventos de conexão
      _configurarEventosDeConexao();

      // Configurar canal de dados para eventos
      await _configurarCanalDeDados();

      // Capturar e adicionar áudio local
      final success = await _configurarAudioLocal();
      if (!success) {
        debugPrint('[AIA] Falha ao configurar áudio local');
        _isProcessingConnection = false;
        return false;
      }

      // Criar e enviar oferta SDP
      final success2 = await _criarEEnviarOferta();
      if (!success2) {
        debugPrint('[AIA] Falha ao criar e enviar oferta SDP');
        _isProcessingConnection = false;
        return false;
      }

      _isConnected = true;
      _isProcessingConnection = false;
      onListeningStarted?.call();
      return true;
    } catch (e) {
      debugPrint("[AIA] Erro ao iniciar conexão WebRTC: $e");
      _isProcessingConnection = false;
      return false;
    }
  }

  void _configurarEventosDeConexao() {
    _peerConnection!.onIceConnectionState = (RTCIceConnectionState state) {
      debugPrint('[AIA] ICE Connection State: ${state.toString()}');
      
      if (state == RTCIceConnectionState.RTCIceConnectionStateConnected) {
        debugPrint('[AIA] WebRTC conectado com sucesso');
      } else if (state == RTCIceConnectionState.RTCIceConnectionStateFailed ||
                state == RTCIceConnectionState.RTCIceConnectionStateDisconnected ||
                state == RTCIceConnectionState.RTCIceConnectionStateClosed) {
        debugPrint('[AIA] WebRTC desconectado: ${state.toString()}');
        _isConnected = false;
      }
    };

    _peerConnection!.onIceCandidate = (RTCIceCandidate candidate) {
      debugPrint('[AIA] ICE Candidate: ${candidate.candidate}');
    };

    _peerConnection!.onTrack = (RTCTrackEvent event) {
      debugPrint('[AIA] Faixa remota recebida: ${event.track.kind}');
      
      if (event.track.kind == 'audio') {
        _remoteStream = event.streams[0];
        debugPrint('[AIA] Áudio remoto recebido e configurado para reprodução');
      }
    };
  }

  Future<void> _configurarCanalDeDados() async {
    final dcInit = RTCDataChannelInit();
    dcInit.ordered = true;
    
    _dataChannel = await _peerConnection!.createDataChannel("oai-events", dcInit);
    
    _dataChannel!.onMessage = (RTCDataChannelMessage message) {
      _processarMensagem(message.text);
    };
    
    _dataChannel!.onDataChannelState = (RTCDataChannelState state) {
      debugPrint('[AIA] Estado do canal de dados: ${state.toString()}');
      
      if (state == RTCDataChannelState.RTCDataChannelOpen) {
        debugPrint('[AIA] Canal de dados aberto, enviando configuração');
        _enviarConfiguracao();
      }
    };
  }

  Future<bool> _configurarAudioLocal() async {
    try {
      final success = await AudioService.iniciarCapturaDeAudio((_) {});
      if (!success) return false;

      _localStream = AudioService.getMediaStream();
      if (_localStream == null) {
        debugPrint('[AIA] Falha ao obter stream de áudio local');
        return false;
      }

      for (var track in _localStream!.getAudioTracks()) {
        debugPrint('[AIA] Adicionando faixa de áudio: ${track.id}');
        await _peerConnection!.addTrack(track, _localStream!);
      }
      
      return true;
    } catch (e) {
      debugPrint('[AIA] Erro ao configurar áudio local: $e');
      return false;
    }
  }

  Future<bool> _criarEEnviarOferta() async {
    try {
      // Criar oferta SDP
      final offerOptions = <String, dynamic>{
        'offerToReceiveAudio': true,
        'offerToReceiveVideo': false,
        'voiceActivityDetection': true,
      };
      
      final offer = await _peerConnection!.createOffer(offerOptions);
      await _peerConnection!.setLocalDescription(offer);
      
      debugPrint('[AIA] Oferta SDP criada: ${offer.sdp}');

      // Enviar oferta para a OpenAI usando HttpClient para controle preciso dos cabeçalhos
      final client = HttpClient();
      final uri = Uri.parse("https://api.openai.com/v1/realtime?model=gpt-4o-realtime-preview-2024-12-17");
      final request = await client.postUrl(uri);
      
      // Configurar cabeçalhos exatamente como a API espera
      request.headers.set('Authorization', 'Bearer ${dotenv.env['OPENAI_API_KEY']}');
      request.headers.set('Content-Type', 'application/sdp');
      
      // Enviar o corpo da requisição
      request.write(offer.sdp);
      
      // Obter resposta
      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      
      // Verificar se a resposta começa com "v=0", que é o início de um SDP válido
      if (responseBody.trim().startsWith('v=0')) {
        debugPrint('[AIA] Resposta SDP recebida com sucesso');
      } else {
        // Verificar se a resposta é um JSON de erro
        try {
          if (response.statusCode != 200) {
            debugPrint('[AIA] Erro HTTP: ${response.statusCode}');
            try {
              final errorJson = jsonDecode(responseBody);
              if (errorJson.containsKey('error')) {
                if (errorJson['error'] is Map) {
                  debugPrint('[AIA] Erro da API OpenAI: ${errorJson['error']['message']}');
                } else {
                  debugPrint('[AIA] Erro da API OpenAI: ${errorJson['error']}');
                }
              } else {
                debugPrint('[AIA] Erro ao obter SDP da OpenAI: $responseBody');
              }
            } catch (e) {
              // Se não for JSON, apenas exibir a resposta como está
              debugPrint('[AIA] Erro ao obter SDP da OpenAI: $responseBody');
            }
          } else {
            debugPrint('[AIA] Resposta inesperada da API: $responseBody');
          }
        } catch (e) {
          debugPrint('[AIA] Erro ao processar resposta: $e');
        }
        
        // Aguardar um pouco antes de tentar novamente
        await Future.delayed(Duration(seconds: 2));
        
        // Tentar novamente uma vez
        debugPrint('[AIA] Tentando reconectar após erro...');
        return await _tentarReconectar();
      }
      
      try {
        // Configurar resposta como descrição remota
        await _peerConnection!.setRemoteDescription(
          RTCSessionDescription(responseBody, 'answer'),
        );
        debugPrint('[AIA] Descrição remota configurada com sucesso');
        return true;
      } catch (e) {
        debugPrint('[AIA] Erro ao configurar descrição remota: $e');
        return false;
      }
    } catch (e) {
      debugPrint('[AIA] Erro ao criar e enviar oferta: $e');
      return false;
    }
  }

  void _processarMensagem(String rawData) {
    try {
      debugPrint('[AIA] Mensagem recebida: $rawData');
      final data = jsonDecode(rawData);
      final type = data['type'];

      switch (type) {
        case 'session.created':
          debugPrint('[AIA] Sessão criada, ID: ${data['session']['id']}');
          _enviarConfiguracao();
          break;
          
        case 'session.updated':
          debugPrint('[AIA] Sessão atualizada, pronta para ouvir');
          onListeningStarted?.call();
          break;
          
        case 'response.audio.delta':
          final bytes = base64Decode(data['delta']);
          debugPrint('[AIA] Áudio delta recebido: ${bytes.length} bytes');
          onAudioResponse?.call(Uint8List.fromList(bytes));
          break;
          
        case 'response.done':
          debugPrint('[AIA] Resposta concluída');
          onConversationDone?.call();
          break;
          
        case 'error':
          // Verificar se o erro tem uma mensagem
          if (data.containsKey('error') && data['error'] is Map && data['error'].containsKey('message')) {
            debugPrint('[AIA] Erro recebido: ${data['error']['message']}');
          } else if (data.containsKey('message')) {
            debugPrint('[AIA] Erro recebido: ${data['message']}');
          } else {
            debugPrint('[AIA] Erro recebido sem mensagem detalhada');
          }
          break;
          
        // Capturar transcrição do usuário
        case 'conversation.item.input_audio_transcription.completed':
          final transcript = data['transcript'] as String?;
          if (transcript != null && transcript.trim().isNotEmpty) {
            _currentUserMessage = transcript.trim();
            _currentExchangeStart = DateTime.now();
            debugPrint('[AIA] Fala do usuário: "$transcript"');
            
            // Verificar se o usuário solicitou o Airbnb
            if (_currentUserMessage.toLowerCase().contains('quero um airbnb')) {
              debugPrint('[AIA] Detectada solicitação de Airbnb, abrindo deeplink...');
              _abrirAirbnb();
            }
          }
          break;

        // Capturar resposta da IA em texto (delta)
        case 'response.audio_transcript.delta':
          final delta = data['delta'] as String?;
          if (delta != null) {
            _currentIAResponse += delta;
          }
          break;
          
        // Capturar resposta da IA em texto (completa)
        case 'response.audio_transcript.done':
          if (_currentIAResponse.trim().isNotEmpty && _currentUserMessage.isNotEmpty) {
            _exchangeCounter++;
            
            final exchange = {
              "exchange_id": _exchangeCounter,
              "timestamp": _currentExchangeStart?.toIso8601String(),
              "user_message": _currentUserMessage,
              "ai_response": _currentIAResponse,
              "duration_ms": DateTime.now().difference(_currentExchangeStart ?? DateTime.now()).inMilliseconds
            };
            
            _conversationExchanges.add(exchange);
            debugPrint('[AIA] Resposta da IA: "$_currentIAResponse"');
            debugPrint('[AIA] Troca ${_exchangeCounter} adicionada à conversa');
            
            // Limpar para próxima troca
            _currentIAResponse = '';
            _currentUserMessage = '';
          }
          break;
          
        default:
          debugPrint("[AIA] Evento desconhecido: $type");
      }
    } catch (e) {
      debugPrint("[AIA] Erro ao processar evento: $e");
    }
  }

  // Payload.
  void _enviarConfiguracao() async {
    if (_dataChannel?.state == RTCDataChannelState.RTCDataChannelOpen) {
      String instructions;

      try {
        // 🚀 NOVA INTEGRAÇÃO: Buscar prompt do banco de dados
        debugPrint('[AIA] 🔄 Buscando prompt do banco de dados...');
        instructions = await AiPromptService.getActivePrompt(userName: userName);
        
        debugPrint('[AIA] ✅ Prompt carregado do banco (${instructions.length} chars)');
        debugPrint('[AIA] userName processado: "${userName ?? 'não disponível'}"');
        
        // Log do início do prompt para verificação
        final previewLength = instructions.length > 300 ? 300 : instructions.length;
        debugPrint('[AIA] Início do prompt: ${instructions.substring(0, previewLength)}...');
        
        // Verificar se ainda há placeholders não substituídos
        if (instructions.contains('[PREFERRED_NAME]')) {
          debugPrint('[AIA] ⚠️ ATENÇÃO: [PREFERRED_NAME] ainda presente no prompt!');
        } else {
          debugPrint('[AIA] ✅ Prompt processado com sucesso');
        }
        
      } catch (e, stackTrace) {
        debugPrint('[AIA] ❌ Erro ao buscar prompt do banco: $e');
        debugPrint('[AIA] 📍 Stack: $stackTrace');
        
        // Fallback para arquivo local se o banco falhar
        try {
          debugPrint('[AIA] 🔄 Tentando fallback para arquivo local...');
          String xmlContent = await rootBundle.loadString('assets/aia_instructions.xml');
          
          if (userName != null && userName!.isNotEmpty) {
            instructions = xmlContent.replaceAll('[PREFERRED_NAME]', userName!);
            debugPrint('[AIA] ✅ Fallback local com nome: "$userName"');
          } else {
            instructions = xmlContent.replaceAll('[PREFERRED_NAME]', 'você');
            debugPrint('[AIA] ⚠️ Fallback local sem nome');
          }
        } catch (e2) {
          debugPrint('[AIA] ❌ Erro no fallback local: $e2');
          instructions = 'Você é Áia, uma assistente empática que conversa em português brasileiro.';
        }
      }

      final settings = {
        "type": "session.update",
        "session": {
          "modalities": ["audio", "text"],
          "voice": "sage",
          "output_audio_format": "pcm16",
            "input_audio_transcription": {
            "model": "whisper-1",
          },
          "turn_detection": {
            "type": "server_vad",
            "threshold": 0.5,
            "silence_duration_ms": 500,
            "prefix_padding_ms": 200,
            "create_response":true
          },
          "temperature": 0.8,
          "max_response_output_tokens": "inf",
          "instructions": instructions
        }
      };
      
      debugPrint('[AIA] 🇧🇷 Configuração com idioma português forçado');

      final jsonString = jsonEncode(settings);
      debugPrint('[AIA] 📤 Enviando configuração para OpenAI...');
      debugPrint('[AIA] 📊 Tamanho da configuração: ${jsonString.length} chars');
      _dataChannel!.send(RTCDataChannelMessage(jsonString));
    } else {
      debugPrint("[AIA] ❌ Canal de dados não está pronto. Estado: ${_dataChannel?.state}");
    }
  }

  Future<void> _salvarConversaCompleta() async {
    if (_conversationExchanges.isEmpty) {
      debugPrint('[AIA] Nenhuma conversa para salvar');
      return;
    }
    
    try {
      final now = DateTime.now();
      
      final conversationData = {
        "session_info": {
          "start_time": _conversationStartTime?.toIso8601String(),
          "end_time": now.toIso8601String(),
          "total_exchanges": _conversationExchanges.length,
          "user_name": userName,
          "ai_model": "gpt-4o-realtime-preview-2024-12-17",
          "voice": "sage",
          "session_duration_ms": now.difference(_conversationStartTime ?? now).inMilliseconds
        },
        "conversation": _conversationExchanges
      };

      // Salvar na tabela call_sessions (sem duration_sec - é calculado automaticamente)
      await SupabaseService.client
          .from('call_sessions')
          .insert({
        'user_id': SupabaseService.client.auth.currentUser?.id,
        'started_at': _conversationStartTime?.toIso8601String(),
        'ended_at': now.toIso8601String(),
        'conversation_data': conversationData,
      });
      
      debugPrint('[AIA] ✅ Conversa salva em call_sessions: ${_conversationExchanges.length} trocas');
      
      // Limpar dados após salvar
      _conversationExchanges.clear();
      _exchangeCounter = 0;
      
    } catch (e) {
      debugPrint('[AIA] ❌ Erro ao salvar em call_sessions: $e');
    }
  }

  Future<bool> _tentarReconectar() async {
    try {
      debugPrint('[AIA] Tentando reconectar...');
      
      // Criar nova oferta SDP
      final offerOptions = <String, dynamic>{
        'offerToReceiveAudio': true,
        'offerToReceiveVideo': false,
        'voiceActivityDetection': true,
      };
      
      final offer = await _peerConnection!.createOffer(offerOptions);
      await _peerConnection!.setLocalDescription(offer);
      
      debugPrint('[AIA] Nova oferta SDP criada para reconexão');

      // Enviar oferta para a OpenAI
      final client = HttpClient();
      final uri = Uri.parse("https://api.openai.com/v1/realtime?model=gpt-4o-realtime-preview-2024-12-17");
      final request = await client.postUrl(uri);
      
      request.headers.set('Authorization', 'Bearer ${dotenv.env['OPENAI_API_KEY']}');
      request.headers.set('Content-Type', 'application/sdp');
      
      request.write(offer.sdp);
      
      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      
      if (responseBody.trim().startsWith('v=0')) {
        debugPrint('[AIA] Reconexão bem-sucedida');
        
        await _peerConnection!.setRemoteDescription(
          RTCSessionDescription(responseBody, 'answer'),
        );
        
        return true;
      } else {
        debugPrint('[AIA] Falha na reconexão: resposta inválida');
        return false;
      }
    } catch (e) {
      debugPrint('[AIA] Erro durante a reconexão: $e');
      return false;
    }
  }

  /// Abre o aplicativo Airbnb com um deeplink específico para um quarto
  Future<void> _abrirAirbnb() async {
    try {
      // Deeplink para o Airbnb com ID específico do quarto
      final Uri url = Uri.parse('airbnb://rooms/1358731300179127707');
      
      debugPrint('[AIA] Tentando abrir deeplink: ${url.toString()}');
      
      // Verificar se o aplicativo pode ser aberto
      if (await canLaunchUrl(url)) {
        debugPrint('[AIA] Abrindo deeplink do Airbnb...');
        await launchUrl(
          url,
          mode: LaunchMode.externalApplication,
        );
        debugPrint('[AIA] Deeplink do Airbnb aberto com sucesso');
      } else {
        // Fallback para abrir a URL web do Airbnb
        debugPrint('[AIA] Não foi possível abrir o app Airbnb, tentando abrir a versão web...');
        final Uri webUrl = Uri.parse('https://www.airbnb.com/rooms/1358731300179127707');
        await launchUrl(webUrl, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('[AIA] Erro ao abrir Airbnb: $e');
    }
  }

  Future<void> encerrarConversa() async {
    debugPrint('[AIA] Encerrando conversa...');
    
    // Salvar conversa ANTES de limpar recursos
    if (_conversationExchanges.isNotEmpty) {
      await _salvarConversaCompleta();
    }
    
    try {
      await AudioService.pararCapturaDeAudio();
      
      if (_dataChannel != null) {
        await _dataChannel!.close();
        _dataChannel = null;
      }
      
      if (_localStream != null) {
        _localStream!.getTracks().forEach((track) => track.stop());
        await _localStream!.dispose();
        _localStream = null;
      }
      
      if (_remoteStream != null) {
        _remoteStream!.getTracks().forEach((track) => track.stop());
        await _remoteStream!.dispose();
        _remoteStream = null;
      }
      
      if (_peerConnection != null) {
        await _peerConnection!.close();
        _peerConnection = null;
      }
      
      _isConnected = false;
      debugPrint('[AIA] Conversa encerrada com sucesso');
    } catch (e) {
      debugPrint('[AIA] Erro ao encerrar conversa: $e');
    }
  }
}
