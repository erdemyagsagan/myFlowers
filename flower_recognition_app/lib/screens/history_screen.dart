import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../connections/database_integrated.dart';
import 'result_screen.dart'; // Detay ekranı

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Map<String, dynamic>> _history = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email');
    if (email != null) {
      final db = DatabaseHelper();
      final data = await db.getScanHistory(email);
      setState(() {
        _history = data;
        _loading = false;
      });
    } else {
      setState(() => _loading = false);
    }
  }

  Future<void> _deleteItem(int id) async {
    final db = DatabaseHelper();
    await db.deleteScanHistoryItem(id);
    await _loadHistory(); // Listeyi güncelle
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Kayıt silindi')));
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Tanıma Geçmişi'), centerTitle: true),
      body:
          _history.isEmpty
              ? const Center(
                child: Text(
                  'Henüz geçmişte bir çiçek tanımlanmadı.',
                  style: TextStyle(fontSize: 18),
                ),
              )
              : ListView.builder(
                itemCount: _history.length,
                itemBuilder: (context, i) {
                  final item = _history[i];
                  return ListTile(
                    leading: Image.file(
                      File(item['image_path']),
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                    title: Text(item['flower_name']),
                    subtitle: Text(
                      'Doğruluk: ${(item['confidence'] * 100).toStringAsFixed(0)}% - '
                      'Tarih: ${DateFormat('dd.MM.yyyy HH:mm').format(DateTime.parse(item['timestamp']))}',
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => ResultScreen(
                                image: File(item['image_path']),
                                flowerName: item['flower_name'],
                                confidence: item['confidence'] * 100,
                              ),
                        ),
                      );
                    },
                    onLongPress: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder:
                            (context) => AlertDialog(
                              title: const Text("Kaydı Sil"),
                              content: const Text(
                                "Bu tanıma kaydını silmek istediğinize emin misiniz?",
                              ),
                              actions: [
                                TextButton(
                                  onPressed:
                                      () => Navigator.pop(context, false),
                                  child: const Text("İptal"),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text(
                                    "Sil",
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                      );

                      if (confirm == true) {
                        await _deleteItem(item['id']);
                      }
                    },
                  );
                },
              ),
    );
  }
}
