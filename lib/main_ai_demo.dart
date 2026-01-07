import 'package:flutter/material.dart';
import 'pages/ai_recognition/ai_recognition_page.dart';
import 'pages/ai_recognition/ai_recognition_history_page.dart';

// ⚠️ IMPORTANT: Update these before running
const String BACKEND_URL = 'http://10.0.2.2:3000'; // Android emulator
// For physical device, change to: 'http://192.168.x.x:3000'
// For iOS simulator: 'http://localhost:3000'

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RechoiceP1 - AI Image Recognition',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const AIRecognitionDemo(),
    );
  }
}

/// Demo page showing AI recognition integration
class AIRecognitionDemo extends StatefulWidget {
  const AIRecognitionDemo({Key? key}) : super(key: key);

  @override
  State<AIRecognitionDemo> createState() => _AIRecognitionDemoState();
}

class _AIRecognitionDemoState extends State<AIRecognitionDemo> {
  int _selectedIndex = 0;
  final String _userId = 'user_${DateTime.now().millisecondsSinceEpoch}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Image Recognition'),
        backgroundColor: Colors.blue,
        elevation: 0,
        centerTitle: true,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          AIRecognitionPage(userId: _userId),
          AIRecognitionHistoryPage(userId: _userId),
          _buildSettingsPage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt),
            label: 'Recognize',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsPage() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Settings',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          _buildSettingCard(
            title: 'User ID',
            subtitle: _userId,
            icon: Icons.person,
          ),
          const SizedBox(height: 16),
          _buildSettingCard(
            title: 'Backend URL',
            subtitle: BACKEND_URL,
            icon: Icons.cloud,
          ),
          const SizedBox(height: 16),
          _buildSettingCard(
            title: 'API Status',
            subtitle: 'Connected',
            icon: Icons.check_circle,
            subtitleColor: Colors.green,
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'How to use:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                SizedBox(height: 8),
                Text('1. Go to "Recognize" tab'),
                Text('2. Take a photo or select from gallery'),
                Text('3. Tap "Recognize Image"'),
                Text('4. Wait for AI to analyze the image'),
                Text('5. View results with labels, objects, colors, etc'),
                SizedBox(height: 8),
                Text(
                  'Results are stored in history for later review.',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingCard({
    required String title,
    required String subtitle,
    required IconData icon,
    Color? subtitleColor,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, size: 32, color: Colors.blue),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: subtitleColor ?? Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
