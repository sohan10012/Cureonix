import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/agent_config.dart';
import '../config/agents.dart';
import '../services/gemini_service.dart';

class AppState with ChangeNotifier {
  String _apiKey = '';
  String _modelId = 'gemini-2.5-flash'; 
  String _userName = 'User'; // Default name
  int _selectedTabIndex = 0;

  // Historical data
  final List<Map<String, dynamic>> _history = [];
  
  // Active Investigation State
  bool _isAnalyzing = false;
  String _currentQuery = '';
  Map<String, dynamic> _investigationContext = {}; 
  List<String> _selectedAgentIds = [];
  
  // Agent Execution Status: 'pending', 'running', 'completed', 'error'
  final Map<String, String> _agentStatuses = {};
  // Agent Results: agentId -> parsed JSON data
  final Map<String, dynamic> _agentResults = {};
  
  // Live Feed Data (Simulated)
  final List<Map<String, String>> _liveFeedItems = [
    {
      "agent": "IQVIA Insights",
      "message": "Updated respiratory market sizing data available."
    },
    {
      "agent": "Patent Landscape",
      "message": "Flagged expiring CNS patents in key regions."
    },
    {
      "agent": "EXIM Trends",
      "message": "Detected potential API supply dependency risk."
    },
  ];

  // Getters
  String get apiKey => _apiKey;
  String get modelId => _modelId;
  String get userName => _userName;
  int get selectedTabIndex => _selectedTabIndex;
  List<Map<String, dynamic>> get history => _history;
  
  bool get isAnalyzing => _isAnalyzing;
  String get currentQuery => _currentQuery;
  Map<String, String> get agentStatuses => _agentStatuses;
  Map<String, dynamic> get agentResults => _agentResults;
  List<Map<String, String>> get liveFeedItems => _liveFeedItems;
  List<AgentConfig> get agents => Agents.allAgents;

  void setApiKey(String key) {
    _apiKey = key;
    notifyListeners();
  }

  void setUserName(String name) {
    _userName = name;
    notifyListeners();
  }

  void setTabIndex(int index) {
    _selectedTabIndex = index;
    notifyListeners();
  }

  void setModelId(String id) {
    _modelId = id;
    notifyListeners();
  }

  // --- Agent Execution Pipeline ---
  
  void startInvestigation({
    required String query,
    required Map<String, dynamic> context,
    required List<String> selectedAgents,
  }) {
    _currentQuery = query;
    _investigationContext = context;
    _selectedAgentIds = selectedAgents;
    _agentStatuses.clear();
    _agentResults.clear();
    _isAnalyzing = true;
    notifyListeners();

    _executeAgents();
  }

  Future<void> _executeAgents() async {
    // 1. Initialize statuses
    for (var agentId in _selectedAgentIds) {
      _agentStatuses[agentId] = 'pending';
    }
    notifyListeners();

    final service = GeminiService(); // Uses .env key automatically

    // 2. Run agents sequentially
    for (var agentId in _selectedAgentIds) {
      if (agentId == 'report_generator') continue; // Run last
      
      await _runSingleAgent(agentId, service);
    }

    // 3. Run Report Generator last (it needs data from others)
    if (_selectedAgentIds.contains('report_generator')) {
      await _runSingleAgent('report_generator', service);
    }

    _isAnalyzing = false;
    
    // Auto-save to history
    addToHistory({
      "query": _currentQuery,
      "results": _agentResults,
      "timestamp": DateTime.now(),
    });

    notifyListeners();
  }

  Future<void> _runSingleAgent(String agentId, GeminiService service) async {
    _agentStatuses[agentId] = 'running';
    notifyListeners();

    try {
      final agentConfig = Agents.allAgents.firstWhere((a) => a.id == agentId);
      
      // Construct a prompt that includes context + results from previous agents if needed
      String prompt = "User Query: $_currentQuery\n";
      prompt += "Context: $_investigationContext\n";
      
      // If it's the report generator, give it all previous results
      if (agentId == 'report_generator') {
        prompt += "\nPRIOR AGENT FINDINGS:\n${jsonEncode(_agentResults)}";
      }

      final result = await service.queryAgent(
        systemPrompt: agentConfig.systemPrompt,
        userQuery: prompt
      );

      _agentResults[agentId] = result;
      _agentStatuses[agentId] = 'completed';
      
    } catch (e) {
      debugPrint("Agent $agentId failed: $e");
      _agentStatuses[agentId] = 'error';
      // _agentResults[agentId] = {"error": e.toString()}; // Don't wipe data if partial
    }
    notifyListeners();
  }

  void addToHistory(Map<String, dynamic> item) {
    _history.insert(0, item);
    notifyListeners();
  }
  
  void clearHistory() {
    _history.clear();
    notifyListeners();
  }
}
