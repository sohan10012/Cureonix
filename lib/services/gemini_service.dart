import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiService {
  late final String apiKey;
  final String modelId;
  final String baseUrl;

  GeminiService({
    String? apiKey,
    this.modelId = 'gemini-2.5-flash',
    this.baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models',
  }) {
    this.apiKey = apiKey ?? dotenv.env['GEMINI_API_KEY'] ?? '';
    if (this.apiKey.isEmpty) {
      debugPrint("WARNING: Gemini API Key is missing!");
    }
  }

  Future<Map<String, dynamic>> queryAgent({
    required String systemPrompt,
    required String userQuery,
  }) async {
    // strict adherence to user request for 2.5 flash, though standard API might not have it yet.
    // Ideally this comes from settings.
    final String effectiveModelId = modelId.isEmpty ? 'gemini-2.5-flash' : modelId;
    
    final url = Uri.parse('$baseUrl/$effectiveModelId:generateContent?key=$apiKey');

    final headers = {'Content-Type': 'application/json'};

    // Constructing the prompt to enforce JSON output as requested by the agents
    final fullSystemPrompt = '$systemPrompt\n\nIMPORTANT: Output PURE JSON ONLY. No markdown fencing ```json ... ```, just the raw JSON object.';

    final body = jsonEncode({
      "contents": [
        {
          "parts": [
            {"text": "System: $fullSystemPrompt"}, // Google AI Studio style system instruction via user prompt if system role not supported directly in v1beta
            {"text": "User: $userQuery"}
          ]
        }
      ],
      "generationConfig": {
        "temperature": 0.7,
        "responseMimeType": "application/json" // Force JSON mode if supported
      }
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['candidates'] != null &&
            data['candidates'].isNotEmpty &&
            data['candidates'][0]['content'] != null &&
            data['candidates'][0]['content']['parts'] != null &&
            data['candidates'][0]['content']['parts'].isNotEmpty) {
          
          final text = data['candidates'][0]['content']['parts'][0]['text'];
          
          // Clean up markdown if present despite instructions
          String cleanText = text.trim();
          if (cleanText.startsWith('```json')) {
            cleanText = cleanText.replaceAll('```json', '').replaceAll('```', '');
          } else if (cleanText.startsWith('```')) {
            cleanText = cleanText.replaceAll('```', '');
          }

          try {
            return jsonDecode(cleanText) as Map<String, dynamic>;
          } catch (e) {
            // Fallback if not valid JSON
            return {
              "summary": "Error parsing JSON response. Raw output provided.",
              "raw_output": text
            };
          }
        }
      }
      
      throw Exception('Failed to load data: ${response.statusCode} - ${response.body}');
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
  Future<String> determineBestAgent({
    required String userQuery,
    required List<Map<String, String>> availableAgents,
  }) async {
    // strict adherence to user request for 2.5 flash
    final String effectiveModelId = modelId.isEmpty ? 'gemini-2.5-flash' : modelId;
    final url = Uri.parse('$baseUrl/$effectiveModelId:generateContent?key=$apiKey');
    final headers = {'Content-Type': 'application/json'};

    // Construct a lightweight prompt for classification
    final agentDescriptions = availableAgents.map((a) => "- ID: ${a['id']}\n  Description: ${a['description']}").join("\n");
    
    final systemPrompt = '''
You are the Master Router for Cureonix. Your job is to analyze the user's query and select the SINGLE BEST agent ID to handle it.
Available Agents:
$agentDescriptions

- If the query is about market size, competitors, or growth, choose 'iqvia_insights'.
- If the query is about imports, exports, or supply chain, choose 'exim_trends'.
- If the query is about patents, exclusivity, or FTO, choose 'patent_landscape'.
- If the query is about clinical trials, phases, or sponsors, choose 'clinical_trials'.
- If the query is about news, guidelines, or sentiments, choose 'web_intelligence'.
- For generic questions or uploading docs, choose 'internal_knowledge'.

Return ONLY a JSON object with the key "selected_agent_id".
Example: {"selected_agent_id": "clinical_trials"}
''';

    final body = jsonEncode({
      "contents": [
        {
          "parts": [
            {"text": "System: $systemPrompt"},
            {"text": "User Query: $userQuery"}
          ]
        }
      ],
      "generationConfig": {
        "temperature": 0.1, // Low temp for deterministic routing
        "responseMimeType": "application/json"
      }
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['candidates'] != null &&
            data['candidates'].isNotEmpty &&
            data['candidates'][0]['content'] != null &&
            data['candidates'][0]['content']['parts'] != null) {
          
          final text = data['candidates'][0]['content']['parts'][0]['text'];
          final cleanText = text.replaceAll('```json', '').replaceAll('```', '').trim();
          final json = jsonDecode(cleanText);
          return json['selected_agent_id'] ?? 'internal_knowledge';
        }
      }
      return 'internal_knowledge'; // Fallback
    } catch (e) {
      debugPrint("Router Error: $e");
      return 'internal_knowledge'; // Fallback on error
    }
  }
}
