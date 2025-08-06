import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:audio_session/audio_session.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:just_audio/just_audio.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// Professional-grade audio service with real-time processing
/// Provides smooth transitions like OpenAI, Google, and Apple
class ProfessionalAudioService {
  static final ProfessionalAudioService _instance = ProfessionalAudioService._internal();
  factory ProfessionalAudioService() => _instance;
  ProfessionalAudioService._internal();

  // Core audio components
  FlutterSoundRecorder? _recorder;
  FlutterSoundPlayer? _player;
  AudioPlayer? _audioPlayer;
  AudioSession? _session;
  
  // State management
  bool _isInitialized = false;
  bool _isRecording = false;
  bool _isPlaying = false;
  bool _isProcessing = false;
  
  // Real-time audio processing
  StreamController<Uint8List>? _audioStreamController;
  StreamController<double>? _volumeLevelController;
  StreamController<String>? _transcriptionController;
  StreamController<AudioState>? _stateController;
  StreamSubscription? _recorderSubscription;
  
  // Voice Activity Detection (VAD)
  Timer? _vadTimer;
  double _currentVolumeLevel = 0.0;
  double _vadThreshold = -45.0; // VAD threshold in dB
  int _silenceCounter = 0;
  static const int _maxSilenceFrames = 30; // ~1 second at 30fps
  
  // Buffering for smooth transitions
  List<Uint8List> _audioBuffer = [];
  String _partialTranscription = '';
  
  // Configuration
  static const String _serverUrl = 'http://192.168.3.54:8000';
  static const int _sampleRate = 16000;

  /// Initialize the professional audio system
  Future<bool> initialize() async {
    if (_isInitialized) return true;
    
    try {
      print('🎤 Initializing Professional Audio Service...');
      
      // Request permissions
      await _requestPermissions();
      
      // Initialize audio session
      await _initializeAudioSession();
      
      // Initialize audio components
      await _initializeAudioComponents();
      
      // Setup real-time streams
      _setupRealTimeStreams();
      
      // Enable wakelock for voice sessions
      await WakelockPlus.enable();
      
      _isInitialized = true;
      print('✅ Professional Audio Service initialized successfully');
      return true;
      
    } catch (e) {
      print('❌ Failed to initialize Professional Audio Service: $e');
      return false;
    }
  }

  /// Request necessary permissions
  Future<void> _requestPermissions() async {
    final permissions = [
      Permission.microphone,
      Permission.storage,
      Permission.audio,
    ];
    
    for (final permission in permissions) {
      final status = await permission.request();
      if (status != PermissionStatus.granted) {
        throw Exception('Permission $permission not granted');
      }
    }
  }

  /// Initialize audio session with professional settings
  Future<void> _initializeAudioSession() async {
    _session = await AudioSession.instance;
    await _session!.configure(AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
      avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.allowBluetooth |
          AVAudioSessionCategoryOptions.defaultToSpeaker,
      avAudioSessionMode: AVAudioSessionMode.spokenAudio,
      avAudioSessionRouteSharingPolicy: AVAudioSessionRouteSharingPolicy.defaultPolicy,
      avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
      androidAudioAttributes: const AndroidAudioAttributes(
        contentType: AndroidAudioContentType.speech,
        flags: AndroidAudioFlags.audibilityEnforced,
        usage: AndroidAudioUsage.voiceCommunication,
      ),
      androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
      androidWillPauseWhenDucked: true,
    ));
  }

  /// Initialize audio components
  Future<void> _initializeAudioComponents() async {
    // Initialize FlutterSound for professional recording
    _recorder = FlutterSoundRecorder();
    await _recorder!.openRecorder();
    await _recorder!.setSubscriptionDuration(const Duration(milliseconds: 100));
    
    // Initialize player for smooth playback
    _player = FlutterSoundPlayer();
    await _player!.openPlayer();
    
    // Initialize just_audio for high-performance playback
    _audioPlayer = AudioPlayer();
  }

  /// Setup real-time audio streams
  void _setupRealTimeStreams() {
    _audioStreamController = StreamController<Uint8List>.broadcast();
    _volumeLevelController = StreamController<double>.broadcast();
    _transcriptionController = StreamController<String>.broadcast();
    _stateController = StreamController<AudioState>.broadcast();
  }

  /// Start professional voice recording with real-time processing
  Future<bool> startListening({
    Function(String)? onPartialResult,
    Function(String)? onFinalResult,
    Function(double)? onVolumeLevel,
    Function(AudioState)? onStateChange,
  }) async {
    if (!_isInitialized || _isRecording) return false;
    
    try {
      print('🎙️ Starting professional voice recording...');
      
      _isRecording = true;
      _isProcessing = false;
      _audioBuffer.clear();
      _partialTranscription = '';
      _silenceCounter = 0;
      
      // Notify state change
      _stateController?.add(AudioState.listening);
      onStateChange?.call(AudioState.listening);
      
      // Start real-time recording with streaming
      await _startRealTimeRecording(
        onPartialResult: onPartialResult,
        onVolumeLevel: onVolumeLevel,
      );
      
      // Start Voice Activity Detection
      _startVAD();
      
      return true;
      
    } catch (e) {
      print('❌ Failed to start listening: $e');
      _isRecording = false;
      return false;
    }
  }

  /// Start real-time recording with streaming to server
  Future<void> _startRealTimeRecording({
    Function(String)? onPartialResult,
    Function(double)? onVolumeLevel,
  }) async {
    _audioStreamController = StreamController<Uint8List>.broadcast();
    
    _audioStreamController = StreamController<Uint8List>.broadcast();
    
    // Listen to the audio stream for data chunks
    _recorderSubscription = _audioStreamController!.stream.listen((data) {
      _audioBuffer.add(data);
      _sendAudioChunkToServer(data, onPartialResult: onPartialResult);
    });

    // Also listen to onProgress for decibels
    _recorder!.onProgress!.listen((e) {
      if (e.decibels != null) {
        _currentVolumeLevel = e.decibels!;
        _volumeLevelController?.add(e.decibels!);
        onVolumeLevel?.call(e.decibels!);
      }
    });

    await _recorder!.startRecorder(
      toStream: _audioStreamController!.sink,
      codec: Codec.pcm16,
      numChannels: 1,
      sampleRate: _sampleRate,
    );
  }

  /// Send audio chunk to server for real-time transcription
  Future<void> _sendAudioChunkToServer(
    Uint8List audioChunk, {
    Function(String)? onPartialResult,
  }) async {
    try {
      // Convert audio to base64 for transmission
      final base64Audio = base64Encode(audioChunk);
      
      final response = await http.post(
        Uri.parse('$_serverUrl/transcribe-stream'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'audio_data': base64Audio,
          'sample_rate': _sampleRate,
          'is_partial': true,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final transcription = data['transcription'] ?? '';
        
        if (transcription.isNotEmpty && transcription != _partialTranscription) {
          _partialTranscription = transcription;
          _transcriptionController?.add(transcription);
          onPartialResult?.call(transcription);
        }
      }
      
    } catch (e) {
      print('⚠️ Error sending audio chunk: $e');
    }
  }

  /// Start Voice Activity Detection for automatic processing
  void _startVAD() {
    _vadTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!_isRecording) {
        timer.cancel();
        return;
      }
      
      // Check if user is speaking
      if (_currentVolumeLevel > _vadThreshold) {
        _silenceCounter = 0;
      } else {
        _silenceCounter++;
      }
      
      // Auto-process after silence period
      if (_silenceCounter >= _maxSilenceFrames && _partialTranscription.isNotEmpty) {
        print('🔇 Silence detected, auto-processing transcription');
        stopListening();
      }
    });
  }

  /// Stop listening and return final transcription
  Future<String> stopListening() async {
    if (!_isRecording) return '';
    
    try {
      print('🛑 Stopping professional voice recording...');
      
      _isRecording = false;
      
      // Stop VAD
      _vadTimer?.cancel();
      
      // Stop recording
      await _recorder!.stopRecorder();
      await _recorderSubscription?.cancel();
      await _audioStreamController?.close();
      
      // Get final transcription
      final finalTranscription = await _getFinalTranscription();
      
      // Notify state change
      _stateController?.add(AudioState.processing);
      
      return finalTranscription;
      
    } catch (e) {
      print('❌ Error stopping recording: $e');
      return _partialTranscription;
    }
  }

  /// Get final transcription from server
  Future<String> _getFinalTranscription() async {
    try {
      if (_partialTranscription.isNotEmpty) {
        // Send final transcription request
        final response = await http.post(
          Uri.parse('$_serverUrl/transcribe-final'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'partial_transcription': _partialTranscription,
          }),
        );
        
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          return data['final_transcription'] ?? _partialTranscription;
        }
      }
      
      return _partialTranscription;
      
    } catch (e) {
      print('⚠️ Error getting final transcription: $e');
      return _partialTranscription;
    }
  }

  /// Play AI response with smooth transitions
  Future<void> playResponse(String text, {
    Function()? onStart,
    Function()? onComplete,
    Function(AudioState)? onStateChange,
  }) async {
    if (_isPlaying) return;
    
    try {
      print('🔊 Playing AI response with professional audio...');
      
      _isPlaying = true;
      
      // Notify state change
      _stateController?.add(AudioState.speaking);
      onStateChange?.call(AudioState.speaking);
      onStart?.call();
      
      // Get audio from TTS service
      final audioUrl = await _getAudioFromTTS(text);
      
      if (audioUrl != null) {
        // Play with just_audio for high performance
        await _audioPlayer!.setUrl(audioUrl);
        await _audioPlayer!.play();
        
        // Wait for completion
        await _audioPlayer!.playerStateStream
            .firstWhere((state) => state.processingState == ProcessingState.completed);
      }
      
      _isPlaying = false;
      
      // Notify completion
      _stateController?.add(AudioState.idle);
      onStateChange?.call(AudioState.idle);
      onComplete?.call();
      
    } catch (e) {
      print('❌ Error playing response: $e');
      _isPlaying = false;
    }
  }

  /// Get audio from TTS service
  Future<String?> _getAudioFromTTS(String text) async {
    try {
      final response = await http.post(
        Uri.parse('$_serverUrl/tts'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'text': text,
          'voice': 'professional',
          'speed': 1.0,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['audio_url'];
      }
      
      return null;
      
    } catch (e) {
      print('⚠️ Error getting TTS audio: $e');
      return null;
    }
  }

  /// Get real-time audio stream
  Stream<Uint8List> get audioStream => _audioStreamController!.stream;
  
  /// Get real-time volume level stream
  Stream<double> get volumeLevelStream => _volumeLevelController!.stream;
  
  /// Get real-time transcription stream
  Stream<String> get transcriptionStream => _transcriptionController!.stream;
  
  /// Get audio state stream
  Stream<AudioState> get stateStream => _stateController!.stream;
  
  /// Check if currently recording
  bool get isRecording => _isRecording;
  
  /// Check if currently playing
  bool get isPlaying => _isPlaying;
  
  /// Check if currently processing
  bool get isProcessing => _isProcessing;
  
  /// Get current volume level
  double get currentVolumeLevel => _currentVolumeLevel;

  /// Dispose resources
  Future<void> dispose() async {
    try {
      _isRecording = false;
      _isPlaying = false;
      
      _vadTimer?.cancel();
      
      await _recorder?.closeRecorder();
      await _player?.closePlayer();
      await _audioPlayer?.dispose();
      
      await _recorderSubscription?.cancel();
      await _audioStreamController?.close();
      await _volumeLevelController?.close();
      await _transcriptionController?.close();
      await _stateController?.close();
      
      await WakelockPlus.disable();
      
      _isInitialized = false;
      
    } catch (e) {
      print('⚠️ Error disposing audio service: $e');
    }
  }
}

/// Audio state enumeration
enum AudioState {
  idle,
  listening,
  processing,
  speaking,
  error,
}
