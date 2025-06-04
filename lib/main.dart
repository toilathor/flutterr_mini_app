import 'dart:convert';
import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:mini_app/contract_list_screen.dart';

void main() {
  runApp(MaterialApp(home: const ContactListScreen()));
}

class MiniApp extends StatefulWidget {
  const MiniApp({super.key});

  @override
  State<MiniApp> createState() => _MiniAppState();
}

class _MiniAppState extends State<MiniApp> {
  String? _receivedToken;
  html.MessagePort? port;

  @override
  void initState() {
    super.initState();

    // Thiết lập listener riêng để cập nhật UI khi nhận token
    html.window.onMessage.listen((event) {
      if (event.data == "capturePort") {
        // Nhận port từ event
        final receivedPort = event.ports.first;
        port = receivedPort;

        // Lắng nghe tin nhắn từ Flutter Mobile (qua WebView)
        port?.onMessage.listen((messageEvent) {
          print('Nhận từ Flutter Mobile: ${messageEvent.data}');
        });

        // (Tuỳ chọn) Gửi phản hồi về lại Flutter Mobile
        port?.postMessage("Mini App đã nhận port!");

        try {
          final data = jsonDecode(event.data);
          if (data['type'] == 'AUTH_TOKEN') {
            setState(() {
              _receivedToken = data['token'];
            });
          }
        } catch (_) {}
      } else if (event.data is Map) {
        if (event.data['type'] == 'AUTH_TOKEN') {
          setState(() {
            _receivedToken = event.data['token'];
          });
        }
      }
    });
  }

  void _requestTokenFromSuperApp() {
    // (Tuỳ chọn) Gửi phản hồi về lại Flutter Mobile
    port?.postMessage("Mini App đã nhận port!");
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mini Flutter Web App',
      home: Scaffold(
        appBar: AppBar(title: const Text('Mini Flutter Web App')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _receivedToken == null
                    ? 'No token received yet'
                    : 'Received token:\n$_receivedToken',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _requestTokenFromSuperApp,
                child: const Text('Request Token from Super App'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
