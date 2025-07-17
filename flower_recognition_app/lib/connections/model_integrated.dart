import 'dart:io';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'package:shared_preferences/shared_preferences.dart';

import '../connections/database_integrated.dart';

class FlowerModelService {
  late Interpreter _interpreter;
  late List<String> _labels;

  // Türkçe çiçek isimleri listesi
  static const List<String> turkishLabels = [
    "Pembe Çuha Çiçeği",
    "Sert Yapraklı Orkide",
    "Campanula Medium",
    "Tatlı Bezelye",
    "İngiliz Kadife Çiçeği",
    "Kaplan Zambak",
    "Ay Orkide",
    "Cennet Kuşu",
    "Kurtboğan",
    "Eşek Dikeni",
    "Aslanağzı",
    "Öksürükotu",
    "Kral Protea",
    "Devedikeni",
    "Sarısüsen",
    "Küre Çiçeği",
    "Ekinezya",
    "Alstromerya",
    "Balon Çiçeği",
    "Gala Çiçeği",
    "Ateş Zambağı",
    "İğne Yastığı Çiçeği",
    "Fritillaria",
    "Kırmızı Zencefil",
    "Türk Sümbülü",
    "Gelincik",
    "Galler Tüy Çiçeği",
    "Sapsız Gentian",
    "Enginar",
    "Hüsnüyusuf Çiçeği",
    "Karanfil",
    "Alev Çiçeği",
    "Şam Çörek Otu",
    "Meksika Yıldızı",
    "Alp Deniz İğdesi",
    "Cattleya Labiata",
    "Nerine Bowdenii",
    "Havaifişek Çiçeği",
    "Siam Lalesi",
    "Çöplemecik",
    "Barberton Papatya",
    "Nergis",
    "Kuzgunkılıcı",
    "Atatürk Çiçeği",
    "Bolero Mavisi",
    "Şebboy",
    "Kadife Çiçeği",
    "Altıntabak Çiçeği",
    "Beyaz Ay Papatyası",
    "Karahindiba",
    "Petunya",
    "Hercai Menekşe",
    "Çuha Çiçeği",
    "Ayçiçeği",
    "Itır",
    "Yıldız Çiçeği",
    "Gavura Çiçeği",
    "Turnagagası",
    "Turuncu Dalya",
    "Pembe Sarı Dalya",
    "Cautleya Spicata",
    "Japon Dağ Lalesi",
    "Güneş Şapkası",
    "Gümüş Çalısı",
    "Acem Lalesi",
    "Kır papatyası",
    "Bahar Çiğdemi",
    "Alman Süseni",
    "Rüzgar Çiçeği",
    "Romneya Coulteri",
    "Koyun Gözü Çiçeği",
    "Orman gülü",
    "Nilüfer",
    "Gül",
    "Boru Çiçeği",
    "Gündüz Sefası",
    "Çarkıfelek",
    "Hint lotusu",
    "Tüylü Kurbağa Zambağı",
    "Antoryum",
    "Plumeria",
    "Akasma",
    "Hibiscus",
    "Hasekiküpesi",
    "Çöl Gülü",
    "Ebegümeci",
    "Manolya",
    "Siklamen",
    "Su Teresi",
    "Kana Çiçeği",
    "Güzel Hatun Çiçeği",
    "Arı Otu",
    "Top Yosunu",
    "Yüksükotu",
    "Begonvil Sarmaşığı",
    "Kamelya",
    "Ebegümeci",
    "Meksika Petunyası",
    "Bromelya",
    "Gayret Çiçeği",
    "Acemborusu",
    "Böğürtlen Zambağı",
  ];

  Future<void> loadModelAndLabels() async {
    _interpreter = await Interpreter.fromAsset(
      'assets/models/resnet152_erdem2.tflite',
    );
    _labels = turkishLabels;
  }

  Future<Map<String, dynamic>> predict(File imageFile) async {
    final imageBytes = await imageFile.readAsBytes();
    final originalImage = img.decodeImage(imageBytes)!;
    final resizedImage = img.copyResize(originalImage, width: 224, height: 224);

    const mean = [123.68, 116.779, 103.939];
    var input = List.generate(
      1,
      (_) => List.generate(
        224,
        (y) => List.generate(224, (x) {
          final pixel = resizedImage.getPixel(x, y);
          final r = pixel.r.toDouble();
          final g = pixel.g.toDouble();
          final b = pixel.b.toDouble();
          return [b - mean[2], g - mean[1], r - mean[0]];
        }),
      ),
    );

    var output = List.generate(1, (_) => List.filled(_labels.length, 0.0));
    _interpreter.run(input, output);

    final prediction = output[0];
    final maxIndex = prediction.indexWhere(
      (value) => value == prediction.reduce((a, b) => a > b ? a : b),
    );
    final predictedLabel = _labels[maxIndex];
    final confidence = prediction[maxIndex];

    // 🧠 Tahmini veritabanına kaydet
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email');

    if (email != null) {
      await DatabaseHelper().insertPrediction(
        email,
        predictedLabel,
        confidence,
        imageFile.path,
      );
    }

    return {
      "flower": predictedLabel,
      "confidence": (confidence * 100).toStringAsFixed(2),
    };
  }

  void close() {
    _interpreter.close();
  }
}
