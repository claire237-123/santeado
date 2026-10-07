import 'dart:convert';
import 'package:http/http.dart' as http;

class IAService {
  // Android connecté en USB avec adb reverse
  static const String baseUrl = 'http://127.0.0.1:8000';

  static Future<Map<String, dynamic>> poserQuestion(
    String message,
  ) async {
    final url = Uri.parse('$baseUrl/ia/question');

    try {
      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'message': message,
            }),
          )
          .timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        return {
          'succes': true,
          'categorie': data['categorie'],
          'connaissance': data['connaissance'],
          'titre': data['titre'],
          'reponse': data['reponse'],
          'conseil': data['conseil'],
          'type': data['type'],
          'source': data['source'],
          'modele': data['modele'],
        };
      }

      return {
        'succes': false,
        'message':
            'Le moteur IA a retourné une erreur (${response.statusCode}).',
      };
    } catch (e) {
      return {
        'succes': false,
        'message':
            'Impossible de contacter le moteur IA. '
            'Vérifie que le serveur SantéAdo est démarré.',
      };
    }
  }
}