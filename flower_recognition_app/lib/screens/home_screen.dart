import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../connections/model_integrated.dart';
import '../extensions/prediction_history.dart';
import 'result_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  File? _image;
  final picker = ImagePicker();
  final FlowerModelService _flowerModelService = FlowerModelService();
  bool _isLoading = true;
  bool _isPredicting = false; // Kontrol bayrağı

  @override
  void initState() {
    super.initState();
    _loadModel();
  }

  Future<void> _loadModel() async {
    await _flowerModelService.loadModelAndLabels();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _predictImage(File image) async {
    if (_isPredicting) return;

    setState(() {
      _isPredicting = true;
    });

    try {
      final result = await _flowerModelService.predict(image);

      if (result.containsKey("flower") && result.containsKey("confidence")) {
        final flowerName = result["flower"];
        final confidence = double.parse(result["confidence"]);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => ResultScreen(
                  image: image,
                  flowerName: flowerName,
                  confidence: confidence,
                ),
          ),
        );
        // Sadece burada 1 kez geçmişe ekleniyor
        PredictionHistory.addPrediction(flowerName, confidence, image.path);
      } else {
        throw Exception("Geçersiz tahmin sonucu.");
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Tahmin yapılamadı: $e")));
    } finally {
      if (mounted) {
        setState(() {
          _isPredicting = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _flowerModelService.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "myFlowers",
          style: TextStyle(
            fontFamily: 'PlaywriteCU',
            fontSize: 26,
            color: Colors.black54,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),

      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 85),
                    if (_image != null) ...[
                      Image.file(
                        _image!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: MediaQuery.of(context).size.height * 0.4,
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed:
                              (_image == null || _isPredicting)
                                  ? null
                                  : () => _predictImage(_image!),
                          icon: const Icon(Icons.search, size: 28),
                          label: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Text(
                              "Tanımla",
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "---------------- ya da ----------------",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ] else ...[
                      Image.asset(
                        'assets/images/myFlowersLogo.png',
                        height: 150,
                      ),
                      const SizedBox(height: 16),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          "Lütfen öğrenmek istediğiniz çiçeğin fotoğrafını çekiniz veya galeriden seçiniz.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 15),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _pickImage(ImageSource.camera),
                        icon: const Icon(Icons.camera_alt, size: 28),
                        label: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                            "Kamerayla Çek",
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _pickImage(ImageSource.gallery),
                        icon: const Icon(Icons.photo, size: 28),
                        label: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                            "Galeriden Seç",
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
