import 'dart:convert';
import 'package:http/http.dart' as http;
import 'models/device.dart';

class ApiService {
  static const String baseUrl = 'https://airsend.cloud';
  static String? _sessionId;

  static Map<String, String> _getHeaders() {
    return {
      'Accept': 'application/json',
      'User-Agent': 'AirsendFlutterApp/1.0',
    };
  }

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
      final uri = Uri.parse('$baseUrl/interface/login').replace(
        queryParameters: {
          'localip': localIp,
          'password': password,
        },
      );

      final response = await http.get(uri, headers: _getHeaders());

      if (response.statusCode == 200 || response.statusCode == 302) {
        // Extraction de la session depuis le body JSON
        try {
          final jsonData = json.decode(response.body);
          if (jsonData is Map && jsonData.containsKey('session')) {
            _sessionId = jsonData['session'];
            return {'session': _sessionId!};
          }
        } catch (_) {
          // Pas un JSON valide, continuer avec les autres méthodes
        }

        // Si c'est une string, chercher avec regex
        final bodyString = response.body;
        final jsonMatch =
            RegExp(r'"session"\s*:\s*"([^"]+)"').firstMatch(bodyString);

        if (jsonMatch != null) {
          _sessionId = jsonMatch.group(1)!;
          return {'session': _sessionId!};
        }

        // Fallback: chercher dans les cookies
        final setCookieHeader = response.headers['set-cookie'];
        if (setCookieHeader != null && setCookieHeader.isNotEmpty) {
          if (setCookieHeader.contains('session=')) {
            final sessionMatch =
                RegExp(r'session=([^;]+)').firstMatch(setCookieHeader);
            if (sessionMatch != null) {
              _sessionId = sessionMatch.group(1)!;
              return {'session': _sessionId!};
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
  /// [sessionId] - La session obtenue via login (peut être null si géré par cookie)
  /// [useCounter] - Indique si on veut le compteur (défaut: false)
  ///
  /// Retourne une liste de devices
  static Future<List<Device>> getDevices(String? sessionId,
      {bool useCounter = false}) async {
    try {
      // Utiliser _sessionId si sessionId n'est pas fourni
      final session = sessionId ?? _sessionId;
      if (session != null) {
        // Mettre à jour _sessionId si un nouveau est fourni
        if (sessionId != null) {
          _sessionId = sessionId;
        }
      }

      // Ajouter la session comme paramètre de requête au lieu du cookie
      final queryParams = <String, String>{
        'useCounter': useCounter.toString(),
      };
      
      if (session != null) {
        // Nettoyer la session (supprimer les espaces et retours à la ligne)
        final cleanSession = session.trim();
        queryParams['session'] = cleanSession;
      }

      final uri = Uri.parse('$baseUrl/device').replace(
        queryParameters: queryParams,
      );

      final response = await http.get(uri, headers: _getHeaders());

      if (response.statusCode == 200) {
        // Parse le JSON
        final List<dynamic> jsonList = json.decode(response.body) as List;
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
  /// [sessionId] - La session obtenue via login (peut être null si géré par cookie)
  /// [deviceId] - L'ID du device
  /// [action] - L'action à exécuter (DeviceAction)
  ///
  /// Retourne true si la commande a été envoyée avec succès
  static Future<bool> sendCommand(
      String? sessionId, int deviceId, DeviceAction action) async {
    try {
      // Utiliser _sessionId si sessionId n'est pas fourni
      final session = sessionId ?? _sessionId;
      if (session != null && sessionId != null) {
        _sessionId = sessionId;
      }
      
      // Ajouter la session comme paramètre de requête
      final queryParams = <String, String>{};
      if (session != null) {
        queryParams['session'] = session;
      }
      
      final uri = Uri.parse('$baseUrl/device/$deviceId/command/${action.value}').replace(
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      
      final response = await http.get(uri, headers: _getHeaders());

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
