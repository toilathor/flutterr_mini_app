import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanQrScreen extends StatefulWidget {
  const ScanQrScreen({super.key});

  @override
  State<ScanQrScreen> createState() => _ScanQrScreenState();
}

class _ScanQrScreenState extends State<ScanQrScreen> {
  final MobileScannerController controller = MobileScannerController(
    returnImage: true,
    torchEnabled: true,
    autoStart: false,
  );

  ValueNotifier<String> qrValue = ValueNotifier("");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          MobileScanner(
            controller: controller,
            onDetect: (result) {
              qrValue.value = result.barcodes.first.rawValue ?? "";
              print(result.barcodes.first.rawValue);
            },
          ),
          ValueListenableBuilder(
              valueListenable: qrValue,
              builder: (context, value, child) {
                return Container(
                  color: Colors.black.withOpacity(0.5),
                  child: Text(
                    value,
                    style: const TextStyle(fontSize: 20),
                  ),
                );
              }),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          controller.start();
        },
      ),
    );
  }
}
