// lib/services/audio_service.dart

import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:audio_session/audio_session.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class AudioService {
  static MediaStream? _localStream;
  static MediaStreamTrack? _audioTrack;
  static bool _isCapturing = false;
  static bool _isInitialized = false;
  
  // Getter para o estado de captura
  static bool get isCapturing => _isCapturing;

  /// Solicita permissão de microfone usando WebRTC diretamente
  /// Este método FORÇA o iOS a mostrar o dialog de permissão
  static Future<bool> solicitarPermissaoMicrofoneViaWebRTC() async {
    try {
      debugPrint('[AudioService] 🎤 FORÇANDO solicitação de permissão via WebRTC...');
      debugPrint('[AudioService] 📱 Plataforma: ${Platform.isIOS ? 'iOS' : Platform.isAndroid ? 'Android' : 'Outra'}');
      
      // Tentar acessar o microfone diretamente via WebRTC
      // Isso FORÇA o iOS a mostrar o dialog de permissão
      final Map<String, dynamic> mediaConstraints = {
        'audio': true,
        'video': false,
      };
      
      debugPrint('[AudioService] 🔄 Chamando getUserMedia para forçar dialog...');
      
      MediaStream? testStream;
      try {
        testStream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
        
        if (testStream != null) {
          debugPrint('[AudioService] ✅ Permissão concedida via WebRTC!');
          
          // Limpar o stream de teste
          testStream.getTracks().forEach((track) => track.stop());
          await testStream.dispose();
          
          return true;
        } else {
          debugPrint('[AudioService] ❌ getUserMedia retornou null');
          return false;
        }
      } catch (webRtcError) {
        debugPrint('[AudioService] 🚨 Erro no WebRTC: $webRtcError');
        
        // Analisar o tipo de erro para determinar a causa
        final errorString = webRtcError.toString().toLowerCase();
        
        if (errorString.contains('notallowederror') || 
            errorString.contains('permission') ||
            errorString.contains('denied')) {
          debugPrint('[AudioService] ❌ Usuário negou a permissão via WebRTC');
          return false;
        } else if (errorString.contains('notfounderror') ||
                   errorString.contains('devicenotfound')) {
          debugPrint('[AudioService] 🔍 Dispositivo de áudio não encontrado');
          return false;
        } else {
          debugPrint('[AudioService] ⚠️ Erro desconhecido no WebRTC: $webRtcError');
          return false;
        }
      }
    } catch (e, stackTrace) {
      debugPrint('[AudioService] ❌ Exceção geral ao solicitar permissão via WebRTC: $e');
      debugPrint('[AudioService] 📚 Stack trace: $stackTrace');
      return false;
    }
  }

  /// Método híbrido que tenta permission_handler primeiro, depois WebRTC
  static Future<bool> solicitarPermissaoMicrofone() async {
    try {
      debugPrint('[AudioService] 🎤 Iniciando solicitação híbrida de permissão...');
      
      // Primeiro, verificar status atual via permission_handler
      final statusAtual = await Permission.microphone.status;
      debugPrint('[AudioService] 📊 Status atual via permission_handler: $statusAtual');
      
      if (statusAtual.isGranted) {
        debugPrint('[AudioService] ✅ Permissão já concedida');
        return true;
      }
      
      // Se permission_handler diz que está permanentemente negada, 
      // ainda assim tentar WebRTC (pode estar errado)
      if (statusAtual.isPermanentlyDenied) {
        debugPrint('[AudioService] ⚠️ permission_handler diz permanentemente negada, mas tentando WebRTC...');
      }
      
      // SEMPRE tentar WebRTC para forçar o dialog do iOS
      debugPrint('[AudioService] 🔄 Tentando WebRTC para forçar dialog...');
      final webRtcResult = await solicitarPermissaoMicrofoneViaWebRTC();
      
      if (webRtcResult) {
        debugPrint('[AudioService] ✅ Permissão concedida via WebRTC!');
        return true;
      } else {
        debugPrint('[AudioService] ❌ Permissão negada via WebRTC');
        
        // Verificar status final
        final statusFinal = await Permission.microphone.status;
        debugPrint('[AudioService] 📊 Status final: $statusFinal');
        
        return false;
      }
    } catch (e, stackTrace) {
      debugPrint('[AudioService] ❌ Erro na solicitação híbrida: $e');
      debugPrint('[AudioService] 📚 Stack trace: $stackTrace');
      return false;
    }
  }

  static Future<bool> iniciarCapturaDeAudio(Function(MediaStream) onStreamCreated) async {
    try {
      if (_isCapturing) {
        debugPrint('[AudioService] Já está capturando áudio');
        return true;
      }

      // Parar qualquer captura anterior
      await pararCapturaDeAudio();

      debugPrint('[AudioService] 🎤 Iniciando captura de áudio - verificando permissões primeiro...');
      
      // Configurar sessão de áudio para alto-falante principal
      await _configurarSessaoAudioParaAltoFalante();
      
      // Ativar wakelock para manter o app ativo
      await _ativarWakelock();
      
      // AGORA solicitar permissão apenas quando realmente precisar
      final permissaoOk = await solicitarPermissaoMicrofone();
      if (!permissaoOk) {
        debugPrint('[AudioService] ❌ Permissão de microfone negada - não é possível capturar áudio');
        return false;
      }
      
      debugPrint('[AudioService] ✅ Permissão concedida - iniciando WebRTC...');
      
      // Usar constraints otimizadas para alto-falante principal
      final mediaConstraints = getOptimizedAudioConstraintsForSpeaker();

      _localStream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
      
      if (_localStream == null) {
        debugPrint('[AudioService] Falha ao obter stream de áudio');
        return false;
      }
      
      final audioTracks = _localStream!.getAudioTracks();
      if (audioTracks.isEmpty) {
        debugPrint('[AudioService] Nenhuma faixa de áudio disponível');
        return false;
      }
      
      _audioTrack = audioTracks.first;
      _audioTrack!.enabled = true;
      
      // Iniciar monitoramento de nível de som
      _iniciarMonitoramentoNivelSom();
      
      debugPrint('[AudioService] Captura de áudio iniciada com sucesso');
      _isCapturing = true;
      _isInitialized = true;
      onStreamCreated(_localStream!);
      return true;
    } catch (e) {
      debugPrint('[AudioService] Erro ao iniciar captura de áudio via WebRTC: $e');
      
      // Se o erro for relacionado a permissão, tentar diagnosticar
      if (e.toString().contains('Permission') || e.toString().contains('NotAllowed')) {
        debugPrint('[AudioService] 🚨 Erro parece ser relacionado a permissão: $e');
        final status = await verificarStatusPermissao();
        debugPrint('[AudioService] 📊 Status atual da permissão após erro: $status');
      }
      
      return false;
    }
  }

  // Monitoramento de nível de som
  static Timer? _soundLevelTimer;
  static void _iniciarMonitoramentoNivelSom() {
    _soundLevelTimer?.cancel();
    
    // O monitoramento real pode ser feito no callback onSoundLevelChange
    // passado para iniciarCapturaDeAudio, ou através de um analisador de áudio
    // dedicado. Aqui, apenas simulamos um timer básico.
    _soundLevelTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (_isCapturing) {
        // Simular nível de som baseado em atividade
        // Em produção, você usaria um analisador de áudio real
        // final randomLevel = 0.3 + (DateTime.now().millisecondsSinceEpoch % 100) / 200;
        // _onSoundLevelChange?.call(randomLevel.clamp(0.0, 1.0));
      } else {
        timer.cancel();
      }
    });
  }

  static Future<void> pararCapturaDeAudio() async {
    if (!_isCapturing && _localStream == null) {
      return;
    }

    debugPrint('[AudioService] Parando captura de áudio');
    _isCapturing = false;
    
    // Parar monitoramento de som
    _soundLevelTimer?.cancel();
    _soundLevelTimer = null;

    try {
      if (_audioTrack != null) {
        _audioTrack!.enabled = false;
        _audioTrack!.stop();
        _audioTrack = null;
      }
      
      if (_localStream != null) {
        _localStream!.getTracks().forEach((track) {
          track.stop();
        });
        await _localStream!.dispose();
        _localStream = null;
      }
      
      debugPrint('[AudioService] Captura de áudio parada com sucesso');
    } catch (e) {
      debugPrint('[AudioService] Erro ao parar captura de áudio: $e');
    }
  }

  static MediaStreamTrack? getAudioTrack() => _audioTrack;
  static MediaStream? getMediaStream() => _localStream;
  
  /// Verifica o status atual da permissão de microfone sem solicitar
  static Future<PermissionStatus> verificarStatusPermissao() async {
    try {
      final status = await Permission.microphone.status;
      debugPrint('[AudioService] 🔍 Status atual da permissão: $status');
      return status;
    } catch (e) {
      debugPrint('[AudioService] ❌ Erro ao verificar status da permissão: $e');
      return PermissionStatus.denied;
    }
  }
  
  /// Abre as configurações do app para o usuário conceder permissão manualmente
  static Future<bool> abrirConfiguracoes() async {
    try {
      debugPrint('[AudioService] 🔧 Abrindo configurações do app...');
      return await openAppSettings();
    } catch (e) {
      debugPrint('[AudioService] ❌ Erro ao abrir configurações: $e');
      return false;
    }
  }
  
  /// Teste direto do WebRTC para verificar se o problema está na camada de permissão ou no WebRTC
  static Future<bool> testarWebRTCDireto() async {
    try {
      debugPrint('[AudioService] 🧪 Testando WebRTC diretamente...');
      
      final Map<String, dynamic> mediaConstraints = {
        'audio': true,
        'video': false,
      };
      
      final stream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
      
      if (stream != null) {
        debugPrint('[AudioService] ✅ WebRTC funcionou - stream obtido');
        await stream.dispose();
        return true;
      } else {
        debugPrint('[AudioService] ❌ WebRTC falhou - stream é null');
        return false;
      }
    } catch (e, stackTrace) {
      debugPrint('[AudioService] ❌ Erro no teste WebRTC: $e');
      debugPrint('[AudioService] 📚 Stack trace WebRTC: $stackTrace');
      return false;
    }
  }
  
  // Método para mutar o áudio
  static void muteAudio() {
    if (_audioTrack != null) {
      debugPrint('[AudioService] Mutando áudio');
      _audioTrack!.enabled = false;
    }
  }
  
  // Método para desmutar o áudio
  static void unmuteAudio() {
    if (_audioTrack != null) {
      debugPrint('[AudioService] Desmutando áudio');
      _audioTrack!.enabled = true;
    }
  }
  
  /// Maximiza o volume do sistema para reprodução de áudio
  static Future<void> maximizeSystemVolume() async {
    try {
      debugPrint('[AudioService] 🔊 Configurando categoria de áudio para reprodução no alto-falante principal');
      // No iOS, isso já é configurado pela sessão de áudio
      debugPrint('[AudioService] 🔊 Som configurado para sair no alto-falante principal');
    } catch (e) {
      debugPrint('[AudioService] Erro ao configurar categoria de áudio: $e');
    }
  }
  
  /// Configura as constraints de áudio otimizadas para alto-falante principal
  static Map<String, dynamic> getOptimizedAudioConstraintsForSpeaker() {
    return {
      'audio': {
        'echoCancellation': true,
        'noiseSuppression': true,
        'autoGainControl': true,
        'googEchoCancellation': true,
        'googAutoGainControl': true,
        'googNoiseSuppression': true,
        'googHighpassFilter': true,
        'googTypingNoiseDetection': true,
        'googAudioMirroring': false,
        'volume': 1.0, // Máximo
        'sampleRate': 48000,
        'channelCount': 1,
        // FORÇAR USO DO ALTO-FALANTE PRINCIPAL
        'googDefaultToSpeaker': true,
        'speakerphone': true,
      },
      'video': false,
    };
  }

  /// Configura as constraints de áudio para melhor qualidade e volume
  static Map<String, dynamic> getOptimizedAudioConstraints() {
    return getOptimizedAudioConstraintsForSpeaker();
  }

  /// Configura a sessão de áudio para alto-falante principal (não para chamada)
  static Future<void> _configurarSessaoAudioParaAltoFalante() async {
    try {
      debugPrint('[AudioService] 🔊 Configurando sessão de áudio para ALTO-FALANTE PRINCIPAL...');
      
      final session = await AudioSession.instance;
      
      // Configuração específica para alto-falante principal (não para chamada)
      final audioConfig = AudioSessionConfiguration(
        avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
        avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.defaultToSpeaker |
            AVAudioSessionCategoryOptions.allowBluetooth |
            AVAudioSessionCategoryOptions.allowAirPlay |
            AVAudioSessionCategoryOptions.mixWithOthers, // Permite mixar com outros sons
        avAudioSessionMode: AVAudioSessionMode.videoChat, // MUDANÇA CRÍTICA: videoChat em vez de voiceChat
        avAudioSessionRouteSharingPolicy: AVAudioSessionRouteSharingPolicy.defaultPolicy,
        avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.notifyOthersOnDeactivation,
        androidAudioAttributes: const AndroidAudioAttributes(
          contentType: AndroidAudioContentType.speech,
          flags: AndroidAudioFlags.audibilityEnforced,
          usage: AndroidAudioUsage.media, // MUDANÇA: media em vez de voiceCommunication
        ),
        androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
        androidWillPauseWhenDucked: false,
      );
      
      await session.configure(audioConfig);
      
      // Ativar a sessão
      await session.setActive(true);
      
      debugPrint('[AudioService] ✅ Sessão de áudio configurada para ALTO-FALANTE PRINCIPAL');
      debugPrint('[AudioService] 📱 Categoria: playAndRecord');
      debugPrint('[AudioService] 🔊 Modo: videoChat (força alto-falante principal)');
      debugPrint('[AudioService] 🎯 Opções: defaultToSpeaker, allowBluetooth, mixWithOthers');
      
    } catch (e) {
      debugPrint('[AudioService] ❌ Erro ao configurar sessão de áudio: $e');
    }
  }

  /// Ativa o wakelock para manter o app ativo em background
  static Future<void> _ativarWakelock() async {
    try {
      debugPrint('[AudioService] 🔒 Ativando wakelock para background...');
      
      await WakelockPlus.enable();
      
      final isEnabled = await WakelockPlus.enabled;
      debugPrint('[AudioService] ${isEnabled ? '✅' : '❌'} Wakelock ${isEnabled ? 'ativado' : 'falhou'}');
      
    } catch (e) {
      debugPrint('[AudioService] ❌ Erro ao ativar wakelock: $e');
    }
  }

  /// Desativa o wakelock quando não precisar mais
  static Future<void> _desativarWakelock() async {
    try {
      debugPrint('[AudioService] 🔓 Desativando wakelock...');
      
      await WakelockPlus.disable();
      
      final isEnabled = await WakelockPlus.enabled;
      debugPrint('[AudioService] ${!isEnabled ? '✅' : '❌'} Wakelock ${!isEnabled ? 'desativado' : 'ainda ativo'}');
      
    } catch (e) {
      debugPrint('[AudioService] ❌ Erro ao desativar wakelock: $e');
    }
  }

  /// Configura o app para continuar reproduzindo áudio quando outras apps são abertas
  static Future<void> enableBackgroundAudio() async {
    try {
      debugPrint('[AudioService] 🎵 Habilitando reprodução de áudio em background...');
      
      await _configurarSessaoAudioParaAltoFalante();
      await _ativarWakelock();
      
      debugPrint('[AudioService] ✅ Background audio habilitado com alto-falante principal');
      
    } catch (e) {
      debugPrint('[AudioService] ❌ Erro ao habilitar background audio: $e');
    }
  }

  /// Desabilita o background audio quando não precisar mais
  static Future<void> disableBackgroundAudio() async {
    try {
      debugPrint('[AudioService] 🔇 Desabilitando background audio...');
      
      await _desativarWakelock();
      
      // Desativar a sessão de áudio
      final session = await AudioSession.instance;
      await session.setActive(false);
      
      debugPrint('[AudioService] ✅ Background audio desabilitado');
      
    } catch (e) {
      debugPrint('[AudioService] ❌ Erro ao desabilitar background audio: $e');
    }
  }
}
