import 'dart:html' as html;
import 'dart:js' as js;

import 'package:flutter/material.dart';
import 'package:mini_app/scan_qr_screen.dart';

void main() {
  runApp(const MiniApp());
}

class MiniApp extends StatefulWidget {
  const MiniApp({super.key});

  @override
  State<MiniApp> createState() => _MiniAppState();
}

class _MiniAppState extends State<MiniApp> {
  String? _userToken;

  @override
  void initState() {
    super.initState();

    // Lắng nghe token từ Super App
    html.window.onMessage.listen((event) {
      final data = event.data;
      if (data is Map && data.containsKey('token')) {
        setState(() {
          _userToken = data['token'];
        });
        print("Received token: $_userToken");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mini App')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => ScanQrScreen(),
                ));
              },
              child: Icon(Icons.camera_alt),
            ),
            Text(
              _userToken != null
                  ? "Token: $_userToken"
                  : "Chờ token từ Super App...",
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          sendMessageToFlutter("Hello Super App!");
        },
      ),
    );
  }

  void sendMessageToFlutter(String message) {
    final hasToFlutter = js.context.hasProperty('ToFlutter');
    if (hasToFlutter) {
      js.context.callMethod('ToFlutter.postMessage', [message]);
    } else {
      js.context.callMethod('console.log', ['ToFlutter channel not available']);
    }
  }
}
