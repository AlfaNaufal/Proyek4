import 'package:flutter/material.dart';
import 'package:logbook_app_001/log_view.dart';
import 'package:logbook_app_001/features/vision/vision_view.dart';
import 'package:logbook_app_001/features/image_processing/image_processing_view.dart';

class DashboardView extends StatelessWidget {
  final Map<String, dynamic> currentUser;

  const DashboardView({super.key, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Super App Dashboard'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Selamat Datang, ${currentUser['username']}",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            
            // Menu 1: Logbook
            _buildMenuCard(
              context, 
              icon: Icons.library_books, 
              title: "Manajemen Logbook", 
              desc: "Role Anda: ${currentUser['role']}",
              onTap: () => Navigator.push(
                context, 
                MaterialPageRoute(
                  builder: (_) => LogView(currentUser: currentUser),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Menu 2: Smart-Patrol (Kamera)
            _buildMenuCard(
              context, 
              icon: Icons.camera_alt, 
              title: "Smart-Patrol Vision", 
              desc: "Deteksi kerusakan jalan secara real-time",
              onTap: () => Navigator.push(
                context, 
                MaterialPageRoute(builder: (_) => const VisionView())
              ),
            ),
            const SizedBox(height: 16),

            // Menu 3: OpenCV Manipulasi Citra
            _buildMenuCard(
              context, 
              icon: Icons.image_search, 
              title: "Manipulasi Citra (OpenCV)", 
              desc: "Histogram, Konvolusi, & Fourier Transform",
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ImageProcessingView()));
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, {required IconData icon, required String title, required String desc, required VoidCallback onTap}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Icon(icon, size: 40, color: Theme.of(context).primaryColor),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(desc, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}