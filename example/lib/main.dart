// ignore_for_file: avoid_print

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:win_ble/win_ble.dart';
import 'package:win_ble_example/device_info.dart';

void main() {
  runApp(const MaterialApp(debugShowCheckedModeBanner: false, home: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StreamSubscription? scanStream;

  @override
  void initState() {
    WinBle.initialize(enableLog: true);
    // call winBLe.dispose() when done
    WinBle.connectionStream.listen((event) {
      print("Connection Event : " + event.toString());
    });
    super.initState();
  }

  String bleStatus = "";
  String bleError = "";

  List<BleDevice> devices = <BleDevice>[];

  /// Main Methods
  startScanning() {
    scanStream = WinBle.startScanning().listen((event) {
      setState(() {
        if (!devices.any((element) => element.address == event.address)) {
          devices.add(event);
        }
      });
    });
  }

  stopScanning() {
    WinBle.stopScanning();
    scanStream?.cancel();
  }

  onDeviceTap(BleDevice device) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => DeviceInfo(
                device: device,
              )),
    );
  }

  @override
  void dispose() {
    scanStream?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Win BLe"),
          centerTitle: true,
        ),
        body: SizedBox(
          child: Column(
            children: [
              // Top Buttons
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  kButton("Start", () {
                    startScanning();
                  }),
                  kButton("Stop", () {
                    stopScanning();
                  }),
                ],
              ),

              Column(
                children: [
                  Text(bleStatus),
                  Text(bleError),
                ],
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: devices.length,
                  itemBuilder: (BuildContext context, int index) {
                    BleDevice device = devices[index];
                    return InkWell(
                      onTap: () {
                        stopScanning();

                        onDeviceTap(device);
                      },
                      child: Card(
                        child: ListTile(
                            leading:
                                Text(device.name.isEmpty ? "N/A" : device.name),
                            title: Text(device.address),
                            subtitle: Text(
                                "rssi : ${device.rssi} | AdvTpe : ${device.advType}")),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ));
  }

  kButton(String txt, onTap) {
    return ElevatedButton(
      onPressed: onTap,
      child: Text(
        txt,
        style: const TextStyle(fontSize: 20),
      ),
    );
  }
}
