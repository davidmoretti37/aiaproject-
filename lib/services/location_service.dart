import 'package:geolocator/geolocator.dart';

class LocationService {
  static double? latitude;
  static double? longitude;

  /// Captura a localização do usuário e armazena em variáveis estáticas.
  static Future<void> initLocation() async {
    print('[LocationService] Iniciando captura de localização...');
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    print('[LocationService] Serviço de localização está ${serviceEnabled ? "ATIVADO" : "DESATIVADO"}');
    if (!serviceEnabled) {
      print('[LocationService] Serviço de localização desativado.');
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    print('[LocationService] Permissão inicial: $permission');
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      print('[LocationService] Permissão após request: $permission');
      if (permission == LocationPermission.denied) {
        print('[LocationService] Permissão de localização negada.');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print('[LocationService] Permissão de localização permanentemente negada.');
      return;
    }

    try {
      print('[LocationService] Tentando capturar posição atual...');
      Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      latitude = pos.latitude;
      longitude = pos.longitude;
      print('[LocationService] Localização capturada: latitude=$latitude, longitude=$longitude');
    } catch (e) {
      print('[LocationService] Erro ao capturar localização: $e');
    }
    print('[LocationService] Fim do método initLocation.');
  }
}
