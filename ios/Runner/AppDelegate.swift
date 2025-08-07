import Flutter
import UIKit
import AVFoundation

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    
    // Configurar categoria de áudio para usar alto-falante principal
    do {
      try AVAudioSession.sharedInstance().setCategory(.playAndRecord, 
                                                     mode: .default, 
                                                     options: [.defaultToSpeaker, .allowBluetooth])
      try AVAudioSession.sharedInstance().setActive(true)
      print("✅ Categoria de áudio configurada para usar alto-falante principal")
    } catch {
      print("❌ Erro ao configurar categoria de áudio: \(error)")
    }
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
