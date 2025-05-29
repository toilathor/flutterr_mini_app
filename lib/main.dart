// import 'dart:html' as html;
// import 'dart:js' as js;
//
// import 'package:flutter/material.dart';
// import 'package:mini_app/scan_qr_screen.dart';
//
// void main() {
//   runApp(MaterialApp(home: const MiniApp()));
// }
//
// class MiniApp extends StatefulWidget {
//   const MiniApp({super.key});
//
//   @override
//   State<MiniApp> createState() => _MiniAppState();
// }
//
// class _MiniAppState extends State<MiniApp> {
//   String? _userToken;
//
//   @override
//   void initState() {
//     super.initState();
//
//     setupMessageListener();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Mini App')),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.of(context).push(MaterialPageRoute(
//                   builder: (context) => ScanQrScreen(),
//                 ));
//               },
//               child: Icon(Icons.camera_alt),
//             ),
//             Text(
//               _userToken != null
//                   ? "Token: $_userToken"
//                   : "Chờ token từ Super App...",
//               style: const TextStyle(fontSize: 18),
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           sendMessageToFlutter("Hello Super App!");
//         },
//       ),
//     );
//   }
//
//   void sendMessageToFlutter(String message) {
//     final hasToFlutter = js.context.hasProperty('ToFlutter');
//     if (hasToFlutter) {
//       js.context.callMethod('ToFlutter.postMessage', [message]);
//     } else {
//       js.context.callMethod('console.log', ['ToFlutter channel not available']);
//     }
//   }
//
//   void setupMessageListener() {
//     html.window.onMessage.listen((html.MessageEvent event) {
//       // Kiểm tra nguồn gửi
//       if (event.origin != 'http://localhost:8080') return;
//
//       // Nếu dùng WebMessageChannel thì event.ports có thể có port
//       if (event.ports.isNotEmpty) {
//         final port = event.ports[0];
//
//         port.onMessage.listen((msgEvent) {
//           print('Got secure message: ${msgEvent.data}');
//           // Xử lý dữ liệu ở đây
//         });
//       } else {
//         // Nếu không có port, xử lý trực tiếp
//         print('Message received: ${event.data}');
//       }
//     });
//   }
// }

import 'dart:convert';
import 'dart:html' as html;

import 'package:flutter/material.dart';

void main() {
  runApp(const MiniApp());
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
