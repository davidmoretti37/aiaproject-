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
import 'package:dio/dio.dart';

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

  // Dio instance for HTTP requests
  final Dio _dio = Dio();

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
          debugPrint('[AIA] ✅ Função create_uber_ride deve estar disponível para a IA agora');
          onListeningStarted?.call();
          break;
          
        case 'response.audio.delta':
          final bytes = base64Decode(data['delta']);
          debugPrint('[AIA] Áudio delta recebido: ${bytes.length} bytes');
          onAudioResponse?.call(Uint8List.fromList(bytes));
          break;
          
        case 'response.done':
          debugPrint('[AIA] Resposta concluída');
          
          // Check if this response contains a function call
          final response = data['response'];
          if (response != null && response['output'] != null && response['output'].isNotEmpty) {
            final output = response['output'][0];
            if (output['type'] == 'function_call') {
              final functionName = output['name'];
              final argumentsJson = output['arguments'] as String;
              final callId = output['call_id'];
              
              debugPrint('[AIA] 🔧 Function call detected: $functionName');
              debugPrint('[AIA] 📋 Arguments JSON: $argumentsJson');
              debugPrint('[AIA] 🆔 Call ID: $callId');
              
              if (functionName == 'create_uber_ride') {
                final arguments = jsonDecode(argumentsJson);
                await _handleUberRideRequest(arguments);
                
                // After handling the function call, we need to provide the result back to the model
                await _sendFunctionCallResult(callId, 'Uber ride request processed successfully');
              }
            }
          }
          
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
          // Log all unknown events to help debug function calls
          if (type.contains('function') || type.contains('tool') || type.contains('call')) {
            debugPrint("[AIA] 🔍 Possível evento de função: $rawData");
          }
      }
    } catch (e) {
      debugPrint("[AIA] Erro ao processar evento: $e");
    }
  }

  // Payload.
  void _enviarConfiguracao() async {
    if (_dataChannel?.state == RTCDataChannelState.RTCDataChannelOpen) {
      String instructions;

      // 🚀 BYPASS COMPLETO DA API - USAR APENAS PROMPT LOCAL COM UBER
      debugPrint('[AIA] 🚨🚨🚨 VERSÃO ATUALIZADA COM UBER TOOL - TESTE 123 🚨🚨🚨');
      debugPrint('[AIA] 🔄 BYPASS da API - usando apenas prompt local com Uber...');
      
      // Criar prompt direto com instruções do Uber - MUITO MAIS EXPLÍCITO
      String basePrompt = '''
🚨 VERSÃO ATUALIZADA - TESTE 123 🚨

Você é Áia, uma assistente empática que conversa em português brasileiro.

ATENÇÃO CRÍTICA: VOCÊ TEM UM AGENTE ESPECIALIZADO PARA UBER!

VOCÊ TEM DISPONÍVEL:
- Função: create_uber_ride
- Capacidade: Chamar Uber para qualquer destino
- Agente especializado: SIM, VOCÊ MESMA!

NUNCA DIGA:
- "Não tenho agente especializado"
- "Não posso ajudar com transporte"
- "Não tenho essa funcionalidade"

SEMPRE DIGA:
- "Posso chamar um Uber para você!"
- "Vou solicitar um Uber agora mesmo!"
- "Claro! Para onde você precisa ir?"

INSTRUÇÕES OBRIGATÓRIAS:
1. Quando usuário mencionar: transporte, Uber, táxi, ir a algum lugar, aeroporto, shopping, etc.
2. IMEDIATAMENTE use a função create_uber_ride
3. Seja confiante: "Vou chamar um Uber para você!"
4. NUNCA hesite ou diga que não pode

VOCÊ É O AGENTE ESPECIALIZADO EM TRANSPORTE!
''';

      if (userName != null && userName!.isNotEmpty) {
        instructions = basePrompt.replaceAll('usuário', userName!);
        debugPrint('[AIA] ✅ Prompt local com Uber criado para: "$userName"');
      } else {
        instructions = basePrompt;
        debugPrint('[AIA] ✅ Prompt local com Uber criado (sem nome específico)');
      }
      
      // Verificar se as instruções do Uber estão presentes
      if (instructions.contains('create_uber_ride')) {
        debugPrint('[AIA] ✅ Instruções do Uber confirmadas no prompt!');
      } else {
        debugPrint('[AIA] ❌ ERRO: Instruções do Uber não encontradas!');
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
          "instructions": instructions,
          "tools": [
            {
              "type": "function",
              "function": {
                "name": "create_uber_ride",
                "description": "Create an Uber ride request when user needs transportation to any destination",
                "parameters": {
                  "type": "object",
                  "properties": {
                    "destination": {
                      "type": "string",
                      "description": "Where the user wants to go (address, landmark, business name, etc.)"
                    },
                    "pickup": {
                      "type": "string",
                      "description": "Pickup location (optional, defaults to current location)"
                    }
                  },
                  "required": ["destination"]
                }
              }
            }
          ]
        }
      };
      
      debugPrint('[AIA] 🇧🇷 Configuração com idioma português forçado');

      final jsonString = jsonEncode(settings);
      debugPrint('[AIA] 📤 Enviando configuração para OpenAI...');
      debugPrint('[AIA] 📊 Tamanho da configuração: ${jsonString.length} chars');
      debugPrint('[AIA] 🔧 Tools configuradas: ${settings['session']['tools']}');
      debugPrint('[AIA] 📋 Configuração completa: $jsonString');
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

  /// Geocode an address using Google Maps API
  Future<Map<String, dynamic>?> _geocodeAddress(String address, {double? userLat, double? userLng}) async {
    try {
      final apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        debugPrint('[AIA] ❌ Google Maps API key not found in .env');
        return null;
      }

      final encodedAddress = Uri.encodeComponent(address);
      String url = 'https://maps.googleapis.com/maps/api/geocode/json?address=$encodedAddress&key=$apiKey';
      
      // Add location bias if user location is available
      if (userLat != null && userLng != null) {
        url += '&location=$userLat,$userLng&radius=50000'; // 50km radius
        debugPrint('[AIA] 🎯 Using location bias: $userLat,$userLng');
      }
      
      debugPrint('[AIA] 🔍 Geocoding address: "$address"');
      
      final response = await _dio.get(url);
      
      if (response.statusCode == 200) {
        final data = response.data;
        
        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          final result = data['results'][0];
          final location = result['geometry']['location'];
          
          final geocodeResult = {
            'lat': location['lat'],
            'lng': location['lng'],
            'formatted_address': result['formatted_address'],
            'place_id': result['place_id'],
          };
          
          debugPrint('[AIA] ✅ Geocoded "$address" to: ${geocodeResult['formatted_address']}');
          debugPrint('[AIA] 📍 Coordinates: ${geocodeResult['lat']}, ${geocodeResult['lng']}');
          
          return geocodeResult;
        } else {
          debugPrint('[AIA] ❌ Geocoding failed: ${data['status']}');
          return null;
        }
      } else {
        debugPrint('[AIA] ❌ HTTP error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('[AIA] ❌ Error geocoding address "$address": $e');
      return null;
    }
  }

  /// Create Uber deeplink with geocoded coordinates
  Future<void> _handleUberRideRequest(Map<String, dynamic> args) async {
    try {
      final destination = args['destination'] as String;
      final pickup = args['pickup'] as String? ?? 'current location';
      
      debugPrint('[AIA] 🚗 Creating Uber ride request');
      debugPrint('[AIA] 📍 Pickup: $pickup');
      debugPrint('[AIA] 🎯 Destination: $destination');
      
      // Get user location for bias (if available from location services)
      // TODO: Integrate with location services to get actual user coordinates
      double? userLat, userLng;
      
      // Geocode destination with user location bias
      final destResult = await _geocodeAddress(destination, userLat: userLat, userLng: userLng);
      
      if (destResult == null) {
        debugPrint('[AIA] ❌ Could not geocode destination: $destination');
        return;
      }
      
      String deeplink;
      if (pickup.toLowerCase().contains('current') || pickup.toLowerCase().contains('my location') || pickup.toLowerCase().contains('here')) {
        // Use current location pickup
        deeplink = 'uber://riderequest?pickup=my_location'
            '&dropoff[latitude]=${destResult['lat']}'
            '&dropoff[longitude]=${destResult['lng']}'
            '&dropoff[formatted_address]=${Uri.encodeComponent(destResult['formatted_address'])}';
        
        debugPrint('[AIA] 🎯 Using current location as pickup');
      } else {
        // Geocode pickup location too
        final pickupResult = await _geocodeAddress(pickup, userLat: userLat, userLng: userLng);
        if (pickupResult != null) {
          deeplink = 'uber://riderequest'
              '?pickup[latitude]=${pickupResult['lat']}'
              '&pickup[longitude]=${pickupResult['lng']}'
              '&pickup[formatted_address]=${Uri.encodeComponent(pickupResult['formatted_address'])}'
              '&dropoff[latitude]=${destResult['lat']}'
              '&dropoff[longitude]=${destResult['lng']}'
              '&dropoff[formatted_address]=${Uri.encodeComponent(destResult['formatted_address'])}';
          
          debugPrint('[AIA] 🎯 Using specific pickup: ${pickupResult['formatted_address']}');
        } else {
          // Fallback to current location if pickup geocoding fails
          deeplink = 'uber://riderequest?pickup=my_location'
              '&dropoff[latitude]=${destResult['lat']}'
              '&dropoff[longitude]=${destResult['lng']}'
              '&dropoff[formatted_address]=${Uri.encodeComponent(destResult['formatted_address'])}';
          
          debugPrint('[AIA] ⚠️ Pickup geocoding failed, using current location');
        }
      }
      
      // Launch Uber app
      await _launchUberDeeplink(deeplink, destResult['formatted_address']);
      
    } catch (e) {
      debugPrint('[AIA] ❌ Error creating Uber ride: $e');
    }
  }

  /// Launch Uber deeplink with fallback to web
  Future<void> _launchUberDeeplink(String deeplink, String destination) async {
    try {
      final uri = Uri.parse(deeplink);
      
      debugPrint('[AIA] 🚀 Launching Uber deeplink: $deeplink');
      
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        debugPrint('[AIA] ✅ Uber app opened for trip to: $destination');
      } else {
        // Fallback to web version
        final webUrl = Uri.parse('https://m.uber.com/looking?pickup=my_location');
        await launchUrl(webUrl, mode: LaunchMode.externalApplication);
        debugPrint('[AIA] ⚠️ Opened Uber web version (app not available)');
      }
    } catch (e) {
      debugPrint('[AIA] ❌ Error launching Uber: $e');
    }
  }

  /// Send function call result back to the model
  Future<void> _sendFunctionCallResult(String callId, String result) async {
    try {
      final event = {
        "type": "conversation.item.create",
        "item": {
          "type": "function_call_output",
          "call_id": callId,
          "output": jsonEncode({"result": result})
        }
      };
      
      debugPrint('[AIA] 📤 Sending function call result for call ID: $callId');
      debugPrint('[AIA] 📋 Result: $result');
      
      _dataChannel!.send(RTCDataChannelMessage(jsonEncode(event)));
      
      // After sending the function result, trigger a new response
      final responseEvent = {
        "type": "response.create"
      };
      
      _dataChannel!.send(RTCDataChannelMessage(jsonEncode(responseEvent)));
      debugPrint('[AIA] 🔄 Triggered new response after function call');
      
    } catch (e) {
      debugPrint('[AIA] ❌ Error sending function call result: $e');
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
