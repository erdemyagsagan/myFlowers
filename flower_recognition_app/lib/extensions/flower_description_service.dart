import 'dart:convert';
import 'package:flutter/services.dart';

class FlowerDescriptionLoader {
  static Map<String, String> _descriptions = {};

  static Future<void> loadDescriptions() async {
    final csvData = await rootBundle.loadString(
      'assets/data/flower_descriptions.csv',
    );
    final lines = const LineSplitter().convert(csvData);

    // Debug mesajı: CSV içeriğini kontrol edelim
    print('CSV Verisi: $lines');

    for (int i = 1; i < lines.length; i++) {
      final parts = lines[i].split(';');
      if (parts.length >= 2) {
        final name = parts[0].trim().toLowerCase();
        final description = parts.sublist(1).join(';').trim();
        _descriptions[name] = description;

        // Debug mesajı: Yüklenen her çiçeği kontrol edelim
        print('Yüklenen Çiçek: $name - Açıklama: $description');
      }
    }
  }

  static String getDescription(String flowerName) {
    // Debug mesajı: Çiçek adı ve eşleşen açıklamayı kontrol edelim
    final name = flowerName.toLowerCase().trim();
    print('Aranan Çiçek Adı: $name');
    return _descriptions[name] ?? "Açıklama bulunamadı.";
  }
}
