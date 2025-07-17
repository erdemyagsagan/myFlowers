class PredictionHistoryItem {
  final String flowerName;
  final double confidence;
  final DateTime date;
  final String imagePath; // Resmin yolu

  PredictionHistoryItem({
    required this.flowerName,
    required this.confidence,
    required this.date,
    required this.imagePath, // Resmin yolu parametresi
  });
}

class PredictionHistory {
  static final List<PredictionHistoryItem> _history = [];

  static void addPrediction(
    String flowerName,
    double confidence,
    String imagePath,
  ) {
    // Aynı çiçek ismi ve aynı tarih ile tekrar eklenmesini engellemek için kontrol ekliyoruz
    if (_history.isNotEmpty && _history.first.flowerName == flowerName) {
      return; // Aynı çiçek ismiyle yeni bir giriş yapılmasın
    }

    _history.insert(
      0,
      PredictionHistoryItem(
        flowerName: flowerName,
        confidence: confidence,
        date: DateTime.now(),
        imagePath: imagePath,
      ),
    );
  }

  static List<PredictionHistoryItem> get history => _history;
}
