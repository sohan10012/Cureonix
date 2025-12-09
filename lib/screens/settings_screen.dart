import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _apiKeyController = TextEditingController();
  final TextEditingController _modelIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final appState = Provider.of<AppState>(context, listen: false);
    _apiKeyController.text = appState.apiKey;
    _modelIdController.text = appState.modelId;
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _modelIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue),
                    SizedBox(height: 8),
                    Text(
                      'This app uses Gemini 2.5 Flash directly. You need a valid Google AI Studio API Key.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _apiKeyController,
              decoration: const InputDecoration(
                labelText: 'Gemini API Key',
                border: OutlineInputBorder(),
                helperText: 'Get key from aistudio.google.com',
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _modelIdController,
              decoration: const InputDecoration(
                labelText: 'Model ID',
                border: OutlineInputBorder(),
                helperText: 'Default: gemini-2.5-flash (or gemini-1.5-flash)',
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                final appState = Provider.of<AppState>(context, listen: false);
                appState.setApiKey(_apiKeyController.text);
                appState.setModelId(_modelIdController.text);
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Settings Saved')),
                );
              },
              child: const Text('Save Configuration'),
            ),
          ],
        ),
      ),
    );
  }
}
