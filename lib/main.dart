import 'package:F_202030_Bluetooth/device_screen.dart';
import 'package:F_202030_Bluetooth/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;
  FlutterBlue flutterBlue = FlutterBlue.instance;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  void _discover() {
    // Start scanning
    widget.flutterBlue.startScan(timeout: Duration(seconds: 4));

    // Listen to scan results
    var subscription = widget.flutterBlue.scanResults.listen((results) {
      // do something with scan results
      for (ScanResult r in results) {
        print('${r.device.name} found! rssi: ${r.rssi}');
      }
    });
  }

  Widget _avaiableDevices() {
    return StreamBuilder<List<ScanResult>>(
      stream: FlutterBlue.instance.scanResults,
      initialData: [],
      builder: (c, snapshot) => Column(
        children: snapshot.data
            .map(
              (r) => ScanResultTile(
                result: r,
                onTap: () => Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) {
                  r.device.connect();
                  return DeviceScreen(device: r.device);
                })),
              ),
            )
            .toList(),
      ),
    );
  }

  void _stopScan() {
    widget.flutterBlue.stopScan();
  }

  void _connect() async {
    // Connect to the device
    //await widget.device.connect();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FlatButton(
                  child: Text("Scan"),
                  onPressed: () {
                    _discover();
                  },
                ),
                FlatButton(
                  child: Text("Stop"),
                  onPressed: () {
                    _stopScan();
                  },
                ),
                FlatButton(
                  child: Text("Connect"),
                  onPressed: () {
                    _connect();
                  },
                ),
              ],
            ),
            _avaiableDevices(),
          ],
        ),
      ),
    );
  }
}
