import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class AIService {
  static Future<String> generatePesan({
    required int screenTimeSeconds,
    required int jedaHariIni,
    required int targetDailyMinutes,
  }) async {
    // Daftar semua key yang ada di .env
    final List<String> apiKeys = [
      dotenv.env['GEMINI_API_KEY_1'] ?? '',
      dotenv.env['GEMINI_API_KEY_2'] ?? '',
      dotenv.env['GEMINI_API_KEY_3'] ?? '',
    ].where((key) => key.isNotEmpty).toList();

    if (apiKeys.isEmpty) {
      return "Waduh, API key belum disetting di .env cuy!";
    }

    final jamPakai = screenTimeSeconds ~/ 3600;
    final menitPakai = (screenTimeSeconds % 3600) ~/ 60;
    final jamTarget = targetDailyMinutes ~/ 60;
    final randomSeed = Random().nextInt(10000);

    final promptText = '''
    Kamu adalah "MengJeda", asisten tongkrongan Gen-Z yang asik, ceplas-ceplos, dan peduli kesehatan digital.
    Ini statistik temen lu sekarang (Seed Acak: $randomSeed - WAJIB bikin respon yang beda dari sebelumnya!):
- Waktu main HP: $jamPakai jam $menitPakai menit (Batas wajar: $jamTarget jam)
- Udah jeda: $jedaHariIni kali.

    Instruksi:
1. Kalo waktu main HP masih 0 jam 0 menit, sapa gaya gaul (misal: "Wih ada yang baru on nih", "Tumben baru on :3").
2. Kalo main udah lebih dari 2 jam, agak ngomel dikit (misal: "Buset dah lama bener", "Mata kamu gak sakit kah??").
3. Kasih rekomendasi jeda secara natural (misal: "Tutup dulu HP-nya 10 menit dongg", "Chill dulu 5 menit ajaa").
4. Bikin cuma 1 KALIMAT aja! (Maksimal 25 kata). Gak usah pake list atau poin.
5. Pake bahasa tongkrongan (kamu, chill,dll).
    ''';


    for (int i = 0; i < apiKeys.length; i++) {
      final currentKey = apiKeys[i];
      final endpoint = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-3.8-flash:generateContent?key=$currentKey';

      try {
        final response = await http.post(
          Uri.parse(endpoint),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            "contents": [
              {
                "parts": [
                  {"text": promptText}
                ]
              }
            ]
          }),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          return data['candidates'][0]['content']['parts'][0]['text'].toString().trim();
        } else {
          debugPrint("=== API KEY KE-${i + 1} GAGAL (Status: ${response.statusCode}) ===");
          debugPrint(response.body);
          // Kalau error karena kuota habis (429), lanjut loop ke key berikutnya
          if (response.statusCode == 429) {
            continue; 
          }
        }
      } catch (e) {
        debugPrint("Error Jaringan dengan Key ke-${i + 1}: $e");
      }
    }

    return "Waduh semua server lagi sibuk nihh T^T Tunggu sebentar yaa...";
  }
}