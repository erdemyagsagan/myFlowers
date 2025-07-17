import 'dart:io';
import 'package:flutter/material.dart';
import '../extensions/flower_description_service.dart';

class ResultScreen extends StatefulWidget {
  final File image;
  final String flowerName;
  final double confidence;

  const ResultScreen({
    Key? key,
    required this.image,
    required this.flowerName,
    required this.confidence,
  }) : super(key: key);

  @override
  _ResultScreenState createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  late String flowerDescription = "Yükleniyor...";

  @override
  void initState() {
    super.initState();
    _loadDescription();
  }

  Future<void> _loadDescription() async {
    await FlowerDescriptionLoader.loadDescriptions();
    final description = FlowerDescriptionLoader.getDescription(
      widget.flowerName,
    );

    setState(() {
      flowerDescription = description;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Sonuç'),
        backgroundColor: Colors.white,
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Image.file(
                widget.image,
                fit: BoxFit.cover,
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.4,
              ),
              const SizedBox(height: 24),
              Text(
                widget.flowerName,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                "${widget.confidence.toStringAsFixed(2)}%",
                style: const TextStyle(fontSize: 20, color: Colors.green),
              ),
              const SizedBox(height: 24),
              const Text(
                'Çiçek Hakkında:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                flowerDescription,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 160, 154, 154),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      "Geri Dön",
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
