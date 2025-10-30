import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  String? _sessionCookie;
  final String baseUrl;

  ApiService({required this.baseUrl});

  // Login et récupération du cookie de session
  Future<bool> login(String localIp, String password) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/interface/login')
            .replace(queryParameters: {
          'localip': localIp,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        // Récupérer le cookie de session depuis les headers
        final setCookie = response.headers['set-cookie'];
        if (setCookie != null) {
          _sessionCookie = setCookie.split(';')[0];
          return true;
        }
      }
      return false;
    } catch (e) {
      print('Erreur de connexion: $e');
      return false;
    }
  }

  // Récupérer la liste des devices
  Future<List<Device>> getDevices({bool? useCounter}) async {
    if (_sessionCookie == null) {
      throw Exception('Non authentifié. Veuillez vous connecter d\'abord.');
    }

    try {
      final uri = useCounter != null
          ? Uri.parse('$baseUrl/device')
              .replace(queryParameters: {'useCounter': useCounter.toString()})
          : Uri.parse('$baseUrl/device');

      final response = await http.get(
        uri,
        headers: {
          'Cookie': _sessionCookie!,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => Device.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Session expirée. Veuillez vous reconnecter.');
      } else {
        throw Exception('Erreur lors de la récupération des devices');
      }
    } catch (e) {
      print('Erreur: $e');
      rethrow;
    }
  }

  // Envoyer une commande à un device
  Future<bool> sendCommand(int deviceId, DeviceAction action) async {
    if (_sessionCookie == null) {
      throw Exception('Non authentifié. Veuillez vous connecter d\'abord.');
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/device/$deviceId/command/${action.value}'),
        headers: {
          'Cookie': _sessionCookie!,
        },
      );

      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 401) {
        throw Exception('Session expirée. Veuillez vous reconnecter.');
      } else {
        throw Exception('Erreur lors de l\'envoi de la commande');
      }
    } catch (e) {
      print('Erreur: $e');
      return false;
    }
  }

  bool isAuthenticated() {
    return _sessionCookie != null;
  }

  void logout() {
    _sessionCookie = null;
  }
}

// Modèle Device
class Device {
  final int id;
  final String name;
  final int type;
  final int pid;
  final int addr;
  final int opt;
  final int counter;

  Device({
    required this.id,
    required this.name,
    required this.type,
    required this.pid,
    required this.addr,
    required this.opt,
    required this.counter,
  });

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      pid: json['pid'],
      addr: json['addr'],
      opt: json['opt'],
      counter: json['counter'],
    );
  }
}

// Enum pour les actions du device
enum DeviceAction {
  off(0),
  on(1),
  prog(2),
  stop(3),
  down(4),
  up(5),
  toggle(6);

  final int value;
  const DeviceAction(this.value);
}
