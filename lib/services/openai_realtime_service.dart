import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'audio_service.dart';
import 'aia_api_service.dart';

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

  // Estado de conversação com agentes especializados
  String? _activeAgentId;           // Qual agente está ativo (gmail_agent, calendar_agent)
  String? _activeSessionId;         // ID da sessão com o agente
  bool _isInAgentConversation = false;  // Se está em conversa com agente

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
      debugPrint('[OpenAI Realtime] Já existe uma conexão em andamento');
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

      debugPrint('[OpenAI Realtime] Criando conexão WebRTC...');
      _peerConnection = await createPeerConnection(_configuration);

      // Configurar eventos de conexão
      _configurarEventosDeConexao();

      // Configurar canal de dados para eventos
      await _configurarCanalDeDados();

      // Capturar e adicionar áudio local
      final success = await _configurarAudioLocal();
      if (!success) {
        debugPrint('[OpenAI Realtime] Falha ao configurar áudio local');
        _isProcessingConnection = false;
        return false;
      }

      // Criar e enviar oferta SDP
      final success2 = await _criarEEnviarOferta();
      if (!success2) {
        debugPrint('[OpenAI Realtime] Falha ao criar e enviar oferta SDP');
        _isProcessingConnection = false;
        return false;
      }

      _isConnected = true;
      _isProcessingConnection = false;
      onListeningStarted?.call();
      return true;
    } catch (e) {
      debugPrint("[OpenAI Realtime] Erro ao iniciar conexão WebRTC: $e");
      _isProcessingConnection = false;
      return false;
    }
  }

  void _configurarEventosDeConexao() {
    _peerConnection!.onIceConnectionState = (RTCIceConnectionState state) {
      debugPrint('[OpenAI Realtime] ICE Connection State: ${state.toString()}');
      
      if (state == RTCIceConnectionState.RTCIceConnectionStateConnected) {
        debugPrint('[OpenAI Realtime] WebRTC conectado com sucesso');
      } else if (state == RTCIceConnectionState.RTCIceConnectionStateFailed ||
                state == RTCIceConnectionState.RTCIceConnectionStateDisconnected ||
                state == RTCIceConnectionState.RTCIceConnectionStateClosed) {
        debugPrint('[OpenAI Realtime] WebRTC desconectado: ${state.toString()}');
        _isConnected = false;
      }
    };

    _peerConnection!.onIceCandidate = (RTCIceCandidate candidate) {
      debugPrint('[OpenAI Realtime] ICE Candidate: ${candidate.candidate}');
    };

    _peerConnection!.onTrack = (RTCTrackEvent event) {
      debugPrint('[OpenAI Realtime] Faixa remota recebida: ${event.track.kind}');
      
      if (event.track.kind == 'audio') {
        _remoteStream = event.streams[0];
        debugPrint('[OpenAI Realtime] Áudio remoto recebido e configurado para reprodução');
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
      debugPrint('[OpenAI Realtime] Estado do canal de dados: ${state.toString()}');
      
      if (state == RTCDataChannelState.RTCDataChannelOpen) {
        debugPrint('[OpenAI Realtime] Canal de dados aberto, enviando configuração');
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
        debugPrint('[OpenAI Realtime] Falha ao obter stream de áudio local');
        return false;
      }

      for (var track in _localStream!.getAudioTracks()) {
        debugPrint('[OpenAI Realtime] Adicionando faixa de áudio: ${track.id}');
        await _peerConnection!.addTrack(track, _localStream!);
      }
      
      // Configurar volume máximo para o sistema
      AudioService.maximizeSystemVolume();
      debugPrint('[OpenAI Realtime] 🔊 Volume do sistema configurado para máximo');
      
      return true;
    } catch (e) {
      debugPrint('[OpenAI Realtime] Erro ao configurar áudio local: $e');
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
      
      debugPrint('[OpenAI Realtime] Oferta SDP criada: ${offer.sdp}');

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
        debugPrint('[OpenAI Realtime] Resposta SDP recebida com sucesso');
      } else {
        // Verificar se a resposta é um JSON de erro
        try {
          if (response.statusCode != 200) {
            debugPrint('[OpenAI Realtime] Erro HTTP: ${response.statusCode}');
            try {
              final errorJson = jsonDecode(responseBody);
              if (errorJson.containsKey('error')) {
                if (errorJson['error'] is Map) {
                  debugPrint('[OpenAI Realtime] Erro da API OpenAI: ${errorJson['error']['message']}');
                } else {
                  debugPrint('[OpenAI Realtime] Erro da API OpenAI: ${errorJson['error']}');
                }
              } else {
                debugPrint('[OpenAI Realtime] Erro ao obter SDP da OpenAI: $responseBody');
              }
            } catch (e) {
              // Se não for JSON, apenas exibir a resposta como está
              debugPrint('[OpenAI Realtime] Erro ao obter SDP da OpenAI: $responseBody');
            }
          } else {
            debugPrint('[OpenAI Realtime] Resposta inesperada da API: $responseBody');
          }
        } catch (e) {
          debugPrint('[OpenAI Realtime] Erro ao processar resposta: $e');
        }
        
        // Aguardar um pouco antes de tentar novamente
        await Future.delayed(Duration(seconds: 2));
        
        // Tentar novamente uma vez
        debugPrint('[OpenAI Realtime] Tentando reconectar após erro...');
        return await _tentarReconectar();
      }
      
      try {
        // Configurar resposta como descrição remota
        await _peerConnection!.setRemoteDescription(
          RTCSessionDescription(responseBody, 'answer'),
        );
        debugPrint('[OpenAI Realtime] Descrição remota configurada com sucesso');
        return true;
      } catch (e) {
        debugPrint('[OpenAI Realtime] Erro ao configurar descrição remota: $e');
        return false;
      }
    } catch (e) {
      debugPrint('[OpenAI Realtime] Erro ao criar e enviar oferta: $e');
      return false;
    }
  }

  void _processarMensagem(String rawData) {
    try {
      debugPrint('[OpenAI Realtime] Mensagem recebida: $rawData');
      final data = jsonDecode(rawData);
      final type = data['type'];

      switch (type) {
        case 'session.created':
          debugPrint('[OpenAI Realtime] Sessão criada, ID: ${data['session']['id']}');
          _enviarConfiguracao();
          break;
          
        case 'session.updated':
          debugPrint('[OpenAI Realtime] Sessão atualizada, pronta para ouvir');
          onListeningStarted?.call();
          break;
          
        case 'rate_limits.updated':
          debugPrint('[OpenAI Realtime] Limites de taxa atualizados');
          break;
          
        case 'input_audio_buffer.speech_started':
          debugPrint('[OpenAI Realtime] Usuário começou a falar');
          break;
          
        case 'input_audio_buffer.speech_stopped':
          debugPrint('[OpenAI Realtime] Usuário parou de falar');
          break;
          
        case 'output_audio_buffer.started':
          debugPrint('[OpenAI Realtime] IA começou a falar');
          break;
          
        case 'output_audio_buffer.stopped':
          debugPrint('[OpenAI Realtime] IA parou de falar');
          break;
          
        case 'response.audio.delta':
          final bytes = base64Decode(data['delta']);
          debugPrint('[OpenAI Realtime] Áudio delta recebido: ${bytes.length} bytes');
          onAudioResponse?.call(Uint8List.fromList(bytes));
          break;
          
        case 'response.audio.done':
          debugPrint('[OpenAI Realtime] Áudio da resposta concluído');
          break;
          
        case 'response.done':
          debugPrint('[OpenAI Realtime] Resposta concluída');
          onConversationDone?.call();
          break;
          
        case 'error':
          // Verificar se o erro tem uma mensagem
          if (data.containsKey('error') && data['error'] is Map && data['error'].containsKey('message')) {
            debugPrint('[OpenAI Realtime] Erro recebido: ${data['error']['message']}');
          } else if (data.containsKey('message')) {
            debugPrint('[OpenAI Realtime] Erro recebido: ${data['message']}');
          } else {
            debugPrint('[OpenAI Realtime] Erro recebido sem mensagem detalhada');
          }
          break;
          
        // Capturar transcrição do usuário (delta - em tempo real)
        case 'conversation.item.input_audio_transcription.delta':
          final delta = data['delta'] as String?;
          if (delta != null) {
            debugPrint('[OpenAI Realtime] Transcrição delta: "$delta"');
          }
          break;
          
        // Capturar transcrição do usuário (completa)
        case 'conversation.item.input_audio_transcription.completed':
          final transcript = data['transcript'] as String?;
          if (transcript != null && transcript.trim().isNotEmpty) {
            _currentUserMessage = transcript.trim();
            _currentExchangeStart = DateTime.now();
            debugPrint('[OpenAI Realtime] Fala do usuário: "$transcript"');
            
            // Verificar se está em conversa com agente
            if (_isInAgentConversation) {
              // Usuário está respondendo ao agente
              debugPrint('[OpenAI Realtime] 🔄 Continuando conversa com agente: $_activeAgentId');
              _continuarConversaComAgente(transcript);
            }
          }
          break;
          
        // Capturar chamadas de função
        case 'response.function_call_arguments.delta':
          debugPrint('[OpenAI Realtime] Function call delta: ${data['delta']}');
          break;
          
        case 'response.function_call_arguments.done':
          final functionName = data['name'] as String?;
          final arguments = data['arguments'] as String?;
          debugPrint('[OpenAI Realtime] Function call: $functionName com argumentos: $arguments');
          
          if (functionName == 'execute_task' && arguments != null) {
            try {
              final args = jsonDecode(arguments);
              final message = args['message'] as String?;
              if (message != null) {
                _executarTarefaViaAIA(message);
              }
            } catch (e) {
              debugPrint('[OpenAI Realtime] Erro ao processar argumentos da função: $e');
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
            debugPrint('[OpenAI Realtime] Resposta da IA: "$_currentIAResponse"');
            debugPrint('[OpenAI Realtime] Troca ${_exchangeCounter} adicionada à conversa');
            
            // Limpar para próxima troca
            _currentIAResponse = '';
            _currentUserMessage = '';
          }
          break;
          
        default:
          debugPrint("[OpenAI Realtime] Evento desconhecido: $type");
      }
    } catch (e) {
      debugPrint("[OpenAI Realtime] Erro ao processar evento: $e");
    }
  }

  void _enviarConfiguracao() async {
    if (_dataChannel?.state == RTCDataChannelState.RTCDataChannelOpen) {
      String instructions = '''
# Prompt - AIA (Assistente Principal Multi-Agente) - AIAPROJECT

## IDENTIDADE E CONTEXTO
Você é a **AIA**, uma assistente de IA conversacional que atua como coordenadora principal em um sistema multi-agente do AIAPROJECT. Você se comunica exclusivamente por áudio em português brasileiro, sendo a interface principal entre o usuário e 7 agentes especializados.

## AGENTES ESPECIALIZADOS DISPONÍVEIS

### 📧 **Gmail Agent** - Gerenciamento de Emails
- Enviar emails, buscar mensagens, gerenciar caixa de entrada
- **CONFIGURAÇÃO ESPECIAL**: TODOS os emails vão para `lucas.arais@inventu.ai`

### 📅 **Calendar Agent** - Gerenciamento de Agenda
- Criar eventos, agendar reuniões, consultar disponibilidade
- Suporte a linguagem natural para datas

### ✈️ **Travel Agent** - Planejamento de Viagens
- Busca de voos, reservas, informações de aeroportos
- Integração com Amadeus API para dados reais
- Previsão de atrasos com Machine Learning

### 🚗 **Vehicle Agent** - Informações Veiculares
- Consulta RENAVAM por placa, verificação de débitos
- Preços FIPE, informações de veículos brasileiros
- Suporte placas antigas (ABC1234) e Mercosul (ABC1D23)
- **EXEMPLO MOCKADO**: Para demonstração, use a placa DQQ1778

### ⏰ **Reminder Agent** - Gerenciamento de Lembretes ✨ (CORRIGIDO)
- Criar lembretes para datas importantes
- Configuração flexível de tempo (dias, minutos, segundos)
- Cancelamento e listagem de lembretes ativos
- Sistema de notificações aprimorado

### 📱 **WhatsApp Agent** - Automação WhatsApp ✨ (MELHORADO)
- Envio de mensagens, mídia e documentos
- Criação e gerenciamento completo de grupos
- Autenticação por QR code ou pareamento telefônico
- Reações, status de presença e localização
- Verificação de números e gestão de contatos
- Operações em lote controladas e boas práticas

### 🍕 **Food Delivery Agent** - iFood e Delivery 🆕 (NOVO!)
- Busca de restaurantes por tipo de comida e localização
- Integração com iFood (principal plataforma brasileira)
- Geração de deeplinks para apps móveis
- Informações de entrega, preços e avaliações
- Suporte a coordenadas GPS para busca precisa
- Foco no mercado brasileiro de delivery

## PRINCÍPIOS FUNDAMENTAIS
- **Conversa Natural**: Mantenha sempre um tom conversacional, empático e prestativo
- **Eficiência Inteligente**: Colete todas as informações necessárias ANTES de executar qualquer ação
- **Fluidez**: Faça perguntas naturais e orgânicas, evitando interrogatórios robóticos
- **Completude**: NUNCA execute uma ação sem ter 100% das informações obrigatórias

## INFORMAÇÕES OBRIGATÓRIAS POR CATEGORIA

### 📧 **EMAILS**
**Obrigatório coletar:**
- Assunto do email
- Conteúdo completo da mensagem
**SEMPRE informe**: "Vou enviar para o Lucas (lucas.arais@inventu.ai)"

### 📅 **REUNIÕES**
**Obrigatório coletar:**
- Participantes da reunião
- Data e horário
- Duração estimada
- Assunto/pauta da reunião

### ✈️ **VIAGENS**
**Obrigatório coletar:**
- Local de origem
- Destino
- Data e horário desejados
- Tipo de transporte preferido

### 🚗 **VEÍCULOS**
**Para consulta RENAVAM:**
- Placa do veículo (formato ABC1234 ou ABC1D23)
**Para preços FIPE:**
- Marca, modelo e ano do veículo

### ⏰ **LEMBRETES**
**Obrigatório coletar:**
- Evento/tarefa para lembrar
- Data e horário do lembrete
- Antecedência desejada (opcional)

### 📱 **WHATSAPP**
**Para envio de mensagens:**
- Número de telefone (formato +55XXXXXXXXXXX)
- Conteúdo da mensagem
**Para grupos:**
- Nome do grupo e participantes

### 🍕 **FOOD DELIVERY**
**Para busca de restaurantes:**
- Tipo de comida desejada (pizza, hambúrguer, sushi, etc.)
- Localização (coordenadas GPS ou endereço)
**Para pedidos:**
- Restaurante escolhido e itens do cardápio

## FERRAMENTAS DISPONÍVEIS

Você tem acesso a uma ferramenta chamada `execute_task` que permite executar ações específicas através de agentes especializados. Use esta ferramenta SOMENTE quando tiver TODAS as informações necessárias para completar uma tarefa.

### Quando usar execute_task:
- **Emails**: Quando tiver assunto E conteúdo completos
- **Reuniões**: Quando tiver participantes, data, horário E assunto
- **Viagens**: Quando tiver origem, destino, data E tipo de transporte
- **Veículos**: Quando tiver placa OU marca/modelo/ano
- **Lembretes**: Quando tiver evento E data/horário
- **WhatsApp**: Quando tiver número E mensagem OU dados do grupo
- **Food Delivery**: Quando tiver tipo de comida E localização

## REGRAS CRÍTICAS

1. **NUNCA** use execute_task sem ter TODAS as informações obrigatórias
2. **SEMPRE** colete informações primeiro, execute depois
3. **SEMPRE** informe que emails vão para lucas.arais@inventu.ai
4. **MANTENHA** a conversa natural e fluida, evite soar robótico
5. **RESPONDA** sempre pensando que será convertido em áudio
6. **SEJA** paciente e educado, mesmo se o usuário não fornecer informações claras
7. **IDENTIFIQUE** automaticamente qual agente usar baseado no contexto da solicitação

## EXEMPLOS DE USO

**Veículos**: "Consultar placa ABC1234" → Vehicle Agent
**Lembretes**: "Me lembre de pagar a conta amanhã às 9h" → Reminder Agent  
**WhatsApp**: "Enviar mensagem no WhatsApp para +5511999999999" → WhatsApp Agent
**Viagens**: "Quero um voo para São Paulo amanhã" → Travel Agent
**Emails**: "Enviar email sobre reunião" → Gmail Agent
**Agenda**: "Agendar reunião para quinta-feira" → Calendar Agent
**Food Delivery**: "Quero pedir pizza aqui perto" → Food Delivery Agent

Lembre-se: você é a coordenadora inteligente de 7 agentes especializados que garante que todas as ações sejam executadas corretamente, coletando informações de forma natural e conversacional.
''';

      // Personalizar com nome do usuário se disponível
      if (userName != null && userName!.isNotEmpty) {
        instructions = instructions.replaceAll('Usuário', userName!);
      }

      debugPrint('[OpenAI Realtime] 🔍 PROMPT SENDO USADO:');
      debugPrint('[OpenAI Realtime] 📝 Tamanho: ${instructions.length} chars');
      debugPrint('[OpenAI Realtime] 🎯 Contém Vehicle Agent: ${instructions.contains('Vehicle Agent')}');
      debugPrint('[OpenAI Realtime] 🎯 Contém Reminder Agent: ${instructions.contains('Reminder Agent')}');
      debugPrint('[OpenAI Realtime] 🎯 Contém WhatsApp Agent: ${instructions.contains('WhatsApp Agent')}');
      debugPrint('[OpenAI Realtime] 🎯 Contém Food Delivery Agent: ${instructions.contains('Food Delivery Agent')}');

      final settings = {
        "type": "session.update",
        "session": {
          "modalities": ["audio", "text"],
          "voice": "sage",
          "output_audio_format": "pcm16",
          "input_audio_format": "pcm16",
          "input_audio_transcription": {
            "model": "whisper-1",
          },
          "turn_detection": {
            "type": "server_vad",
            "threshold": 0.5,
            "silence_duration_ms": 500,
            "prefix_padding_ms": 200,
            "create_response": true
          },
          "temperature": 0.8,
          "max_response_output_tokens": "inf",
          "instructions": instructions,
          "tools": [
            {
              "type": "function",
              "name": "execute_task",
              "description": "Executa uma tarefa específica através de agentes especializados. Use SOMENTE quando tiver TODAS as informações necessárias.",
              "parameters": {
                "type": "object",
                "properties": {
                  "message": {
                    "type": "string",
                    "description": "Mensagem completa com todas as informações necessárias para executar a tarefa (ex: 'Enviar email com assunto X e conteúdo Y para lucas.arais@inventu.ai')"
                  }
                },
                "required": ["message"]
              }
            }
          ]
        }
      };
      
      debugPrint('[OpenAI Realtime] 🇧🇷 Configuração com idioma português forçado');

      final jsonString = jsonEncode(settings);
      debugPrint('[OpenAI Realtime] 📤 Enviando configuração para OpenAI...');
      debugPrint('[OpenAI Realtime] 📊 Tamanho da configuração: ${jsonString.length} chars');
      _dataChannel!.send(RTCDataChannelMessage(jsonString));
    } else {
      debugPrint("[OpenAI Realtime] ❌ Canal de dados não está pronto. Estado: ${_dataChannel?.state}");
    }
  }

  /// Inicia conversa contínua com agente especializado
  Future<void> _iniciarConversaComAgente(String message, String intent) async {
    try {
      debugPrint('[OpenAI Realtime] 🚀 Iniciando conversa com agente: $message');
      
      final result = await AIAApiService.executeTask(message, userId: userName);
      
      if (result != null && result['success'] == true) {
        final response = result['response'] as String? ?? result['message'] as String? ?? 'Tarefa iniciada';
        final agentUsed = result['agent_used'] as String? ?? 'unknown';
        final sessionId = result['session_id'] as String?;
        
        // Configurar estado da conversa apenas se há session_id
        if (sessionId != null) {
          _activeAgentId = agentUsed;
          _activeSessionId = sessionId;
          _isInAgentConversation = true;
          
          debugPrint('[OpenAI Realtime] 🔄 Conversa iniciada com agente: $agentUsed');
          debugPrint('[OpenAI Realtime] 📊 Session ID: $sessionId');
        } else {
          debugPrint('[OpenAI Realtime] ✅ Resposta direta do agente: $agentUsed');
          _finalizarConversaComAgente();
        }
        
        // Repassa resposta do agente para o usuário
        _enviarMensagemDoSistema(response);
        
      } else {
        debugPrint('[OpenAI Realtime] ❌ Falha ao iniciar conversa com agente');
        _enviarMensagemDoSistema('Não foi possível executar a tarefa solicitada no momento.');
      }
    } catch (e) {
      debugPrint('[OpenAI Realtime] ❌ Erro ao iniciar conversa com agente: $e');
      _enviarMensagemDoSistema('Ocorreu um erro ao tentar executar a tarefa.');
    }
  }

  /// Continua conversa com agente especializado
  Future<void> _continuarConversaComAgente(String userResponse) async {
    try {
      debugPrint('[OpenAI Realtime] 🔄 Continuando conversa com $_activeAgentId: $userResponse');
      
      final result = await AIAApiService.executeTask(
        userResponse, 
        userId: userName,
        sessionId: _activeSessionId,
      );
      
      if (result != null && result['success'] == true) {
        final response = result['message'] as String? ?? result['response'] as String? ?? 'Resposta recebida';
        final isCompleted = result['completed'] as bool? ?? false;
        
        if (isCompleted) {
          // Tarefa finalizada
          debugPrint('[OpenAI Realtime] ✅ Tarefa concluída com $_activeAgentId');
          _finalizarConversaComAgente();
          _enviarMensagemDoSistema('Tarefa concluída: $response');
        } else {
          // Agente precisa de mais informações
          debugPrint('[OpenAI Realtime] 🔄 Agente $_activeAgentId precisa de mais informações');
          _enviarMensagemDoSistema(response);
        }
        
      } else {
        debugPrint('[OpenAI Realtime] ❌ Erro na continuação da conversa');
        _finalizarConversaComAgente();
        _enviarMensagemDoSistema('Ocorreu um erro durante a execução da tarefa.');
      }
    } catch (e) {
      debugPrint('[OpenAI Realtime] ❌ Erro ao continuar conversa: $e');
      _finalizarConversaComAgente();
      _enviarMensagemDoSistema('Ocorreu um erro durante a conversa com o agente.');
    }
  }

  /// Finaliza conversa com agente especializado
  void _finalizarConversaComAgente() {
    debugPrint('[OpenAI Realtime] 🏁 Finalizando conversa com agente: $_activeAgentId');
    _activeAgentId = null;
    _activeSessionId = null;
    _isInAgentConversation = false;
  }

  /// Executa tarefa via API AIA (método legado para compatibilidade)
  Future<void> _executarTarefaViaAIA(String message, [String? intent]) async {
    // Redirecionar para o novo método
    _iniciarConversaComAgente(message, intent ?? 'general');
  }
  
  /// Envia mensagem do sistema para o OpenAI
  void _enviarMensagemDoSistema(String mensagem) {
    if (_dataChannel?.state == RTCDataChannelState.RTCDataChannelOpen) {
      final systemMessage = {
        "type": "conversation.item.create",
        "item": {
          "type": "message",
          "role": "system",
          "content": [
            {
              "type": "input_text",
              "text": mensagem
            }
          ]
        }
      };
      
      final jsonString = jsonEncode(systemMessage);
      debugPrint('[OpenAI Realtime] 📤 Enviando mensagem do sistema: $mensagem');
      _dataChannel!.send(RTCDataChannelMessage(jsonString));
      
      // Solicitar resposta
      final responseRequest = {
        "type": "response.create"
      };
      
      _dataChannel!.send(RTCDataChannelMessage(jsonEncode(responseRequest)));
    }
  }

  Future<bool> _tentarReconectar() async {
    try {
      debugPrint('[OpenAI Realtime] Tentando reconectar...');
      
      // Criar nova oferta SDP
      final offerOptions = <String, dynamic>{
        'offerToReceiveAudio': true,
        'offerToReceiveVideo': false,
        'voiceActivityDetection': true,
      };
      
      final offer = await _peerConnection!.createOffer(offerOptions);
      await _peerConnection!.setLocalDescription(offer);
      
      debugPrint('[OpenAI Realtime] Nova oferta SDP criada para reconexão');

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
        debugPrint('[OpenAI Realtime] Reconexão bem-sucedida');
        
        await _peerConnection!.setRemoteDescription(
          RTCSessionDescription(responseBody, 'answer'),
        );
        
        return true;
      } else {
        debugPrint('[OpenAI Realtime] Falha na reconexão: resposta inválida');
        return false;
      }
    } catch (e) {
      debugPrint('[OpenAI Realtime] Erro durante a reconexão: $e');
      return false;
    }
  }

  /// Muta o áudio do OpenAI Realtime
  void muteAudio() {
    try {
      if (_localStream != null) {
        for (var track in _localStream!.getAudioTracks()) {
          track.enabled = false;
        }
        debugPrint('[OpenAI Realtime] 🔇 Áudio mutado');
      }
      
      if (_remoteStream != null) {
        for (var track in _remoteStream!.getAudioTracks()) {
          track.enabled = false;
        }
      }
    } catch (e) {
      debugPrint('[OpenAI Realtime] Erro ao mutar áudio: $e');
    }
  }

  /// Desmuta o áudio do OpenAI Realtime
  void unmuteAudio() {
    try {
      if (_localStream != null) {
        for (var track in _localStream!.getAudioTracks()) {
          track.enabled = true;
        }
        debugPrint('[OpenAI Realtime] 🔊 Áudio desmutado');
      }
      
      if (_remoteStream != null) {
        for (var track in _remoteStream!.getAudioTracks()) {
          track.enabled = true;
        }
      }
    } catch (e) {
      debugPrint('[OpenAI Realtime] Erro ao desmutar áudio: $e');
    }
  }

  Future<void> encerrarConversa() async {
    debugPrint('[OpenAI Realtime] Encerrando conversa...');
    
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
      debugPrint('[OpenAI Realtime] Conversa encerrada com sucesso');
    } catch (e) {
      debugPrint('[OpenAI Realtime] Erro ao encerrar conversa: $e');
    }
  }
}
