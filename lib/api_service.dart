import 'package:dio/dio.dart';
import 'models/device.dart';

class ApiService {
  static const String baseUrl = 'https://airsend.cloud';
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      headers: {
        'Accept': 'application/json',
        'User-Agent': 'AirsendFlutterApp/1.0',
      },
      validateStatus: (status) => status! < 500,
    ),
  );

  /// Connexion à l'API Airsend
  ///
  /// [localIp] - L'adresse IP locale
  /// [password] - Le mot de passe
  ///
  /// Retourne une Map contenant la session si la connexion réussit
  /// Lance une exception en cas d'erreur
  static Future<Map<String, dynamic>> login(
      String localIp, String password) async {
    try {
      final response = await _dio.get(
        '/interface/login',
        queryParameters: {
          'localip': localIp,
          'password': password,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 302) {
        // Extraction de la session depuis le body JSON
        if (response.data is Map && response.data.containsKey('session')) {
          return {'session': response.data['session']};
        }

        // Si c'est une string, chercher avec regex
        final bodyString = response.data.toString();
        final jsonMatch =
            RegExp(r'"session"\s*:\s*"([^"]+)"').firstMatch(bodyString);

        if (jsonMatch != null) {
          final sessionId = jsonMatch.group(1)!;
          return {'session': sessionId};
        }

        // Fallback: chercher dans les cookies
        final setCookieHeader = response.headers['set-cookie'];
        if (setCookieHeader != null && setCookieHeader.isNotEmpty) {
          final cookieString = setCookieHeader.first;
          if (cookieString.contains('session=')) {
            final sessionMatch =
                RegExp(r'session=([^;]+)').firstMatch(cookieString);
            if (sessionMatch != null) {
              final sessionId = sessionMatch.group(1)!;
              return {'session': sessionId};
            }
          }
        }

        throw Exception('Session non trouvée dans la réponse');
      } else {
        throw Exception('Erreur de connexion: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Récupère la liste des devices
  ///
  /// [sessionId] - La session obtenue via login
  /// [useCounter] - Indique si on veut le compteur (défaut: false)
  ///
  /// Retourne une liste de devices
  static Future<List<Device>> getDevices(String sessionId,
      {bool useCounter = false}) async {
    try {
      print('========== GET DEVICES ==========');
      print('URL: $baseUrl/device?useCounter=$useCounter');
      print('Cookie: session=$sessionId');

      final response = await _dio.get(
        '/device',
        queryParameters: {'useCounter': useCounter},
        options: Options(
          headers: {
            'Cookie': 'session=$sessionId',
          },
        ),
      );

      print('Status code: ${response.statusCode}');
      print('--- HEADERS REÇUS ---');
      response.headers.map.forEach((key, value) {
        print('  $key: $value');
      });
      print('--- BODY ---');
      print('${response.data}');
      print('=================================');

      if (response.statusCode == 200) {
        // Parse le JSON
        final List<dynamic> jsonList = response.data as List;
        return jsonList.map((json) => Device.fromJson(json)).toList();
      } else {
        throw Exception(
            'Erreur lors de la récupération des devices: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Envoie une commande à un device
  ///
  /// [sessionId] - La session obtenue via login
  /// [deviceId] - L'ID du device
  /// [action] - L'action à exécuter (DeviceAction)
  ///
  /// Retourne true si la commande a été envoyée avec succès
  static Future<bool> sendCommand(
      String sessionId, int deviceId, DeviceAction action) async {
    try {
      final response = await _dio.get(
        '/device/$deviceId/command/${action.value}',
        options: Options(
          headers: {
            'Cookie': 'session=$sessionId',
          },
        ),
      );

      return response.statusCode == 200;
    } catch (e) {
      rethrow;
    }
  }
}

/// Actions disponibles pour les devices
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
