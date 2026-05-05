import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';
import 'firebase_options.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IoT Firebase Dashboard',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        textTheme: GoogleFonts.poppinsTextTheme(),
        useMaterial3: true,
      ),
      home: const IoTDashboard(),
    );
  }
}

class IoTDashboard extends StatefulWidget {
  const IoTDashboard({super.key});

  @override
  State<IoTDashboard> createState() => _IoTDashboardState();
}

class _IoTDashboardState extends State<IoTDashboard> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  
  bool _isAuthenticated = false;
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _authenticateUser();
  }

  // Autentikasi sesuai tech_spec.md
  Future<void> _authenticateUser() async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: "iotia2026ti2b@gmail.com",
        password: "12345678",
      );
      setState(() => _isAuthenticated = true);
      _checkFirebaseConnection();
    } catch (e) {
      debugPrint("Auth Error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Auth failed: $e")),
        );
      }
    }
  }

  // Periksa koneksi Firebase
  void _checkFirebaseConnection() {
    _dbRef.child(".info/connected").onValue.listen((event) {
      setState(() => _isConnected = event.snapshot.value == true);
    });
  }



  @override
  Widget build(BuildContext context) {
    if (!_isAuthenticated) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("IoT Dashboard"),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              children: [
                Icon(_isConnected ? Icons.cloud_done : Icons.cloud_off,
                    color: _isConnected ? Colors.greenAccent : Colors.redAccent),
                const SizedBox(width: 6),
                Text(
                  _isConnected ? "Online" : "Offline",
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildStatusBanner(),
            const SizedBox(height: 16),
            _buildSensorCard("🌡️ Suhu", "/esiot-db/suhu", "°C", Icons.thermostat, Colors.red),
            _buildSensorCard("💧 Kelembapan", "/esiot-db/kelembapan", "%", Icons.water_drop, Colors.blue),
            const SizedBox(height: 16),
            _buildControlCard(),
          ],
        ),
      ),
    );
  }

Widget _buildStatusBanner() {
    return Card(
      color: Colors.blue.shade50,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(_isConnected ? Icons.check_circle : Icons.error_outline,
                color: _isConnected ? Colors.green : Colors.red, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _isConnected
                    ? "Terhubung ke Firebase: pembacaan Suhu & Kelembapan aktif"
                    : "Tidak terhubung ke Firebase. Periksa koneksi Anda.",
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSensorCard(String title, String path, String unit, IconData icon, Color color) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: StreamBuilder(
        stream: _dbRef.child(path).onValue,
        builder: (context, snapshot) {
          String value = "--";
          if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
            value = snapshot.data!.snapshot.value.toString();
          }
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            leading: CircleAvatar(
              radius: 26,
              backgroundColor: color.withOpacity(0.15),
              child: Icon(icon, color: color, size: 28),
            ),
            title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            subtitle: Text("Realtime sensor data", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            trailing: Text("$value $unit", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
          );
        },
      ),
    );
  }

  Widget _buildControlCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: StreamBuilder(
          stream: _dbRef.child("/esiot-db/led").onValue,
          builder: (context, snapshot) {
            int ledStatus = 0;
            if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
              ledStatus = int.parse(snapshot.data!.snapshot.value.toString());
            }
            final isOn = ledStatus == 1;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.lightbulb,
                      color: isOn ? Colors.amber.shade700 : Colors.grey.shade600,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        "Kontrol LED",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Chip(
                      label: Text(isOn ? "ON" : "OFF"),
                      backgroundColor: isOn ? Colors.green.shade100 : Colors.grey.shade200,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  "Tekan tombol di bawah untuk menyalakan atau mematikan LED.",
                  style: TextStyle(color: Colors.grey[700], fontSize: 14),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  icon: Icon(isOn ? Icons.power_settings_new : Icons.lightbulb_outline),
                  label: Text(isOn ? "Matikan LED" : "Nyalakan LED", style: const TextStyle(fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isOn ? Colors.redAccent : Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () {
                    _dbRef.child("/esiot-db/led").set(isOn ? 0 : 1);
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
