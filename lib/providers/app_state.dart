import 'package:flutter/material.dart';
import '../models/agent_config.dart';
import '../config/agents.dart';
import '../services/gemini_service.dart';

class AppState with ChangeNotifier {
  String _apiKey = '';
  String _modelId = 'gemini-2.5-flash'; // Defaulting to 1.5 as 2.5 might not be live on public API yet
  
  final List<Map<String, dynamic>> _history = [];
  bool _isLoading = false;
  String _loadingStatus = '';

  // Getters
  String get loadingStatus => _loadingStatus;
  String get apiKey => _apiKey;
  String get modelId => _modelId;
  List<Map<String, dynamic>> get history => _history;
  bool get isLoading => _isLoading;
  List<AgentConfig> get agents => Agents.allAgents;

  void setApiKey(String key) {
    _apiKey = key;
    notifyListeners();
  }

  void setModelId(String id) {
    _modelId = id;
    notifyListeners();
  }

  Future<void> askRouter(String query) async {
    if (_apiKey.isEmpty) {
      addToHistory({
        "agent": "Router",
        "query": query,
        "response": {"summary": "Error: API Key is missing. Please configure it in Settings."},
        "timestamp": DateTime.now(),
        "isError": true
      });
      return;
    }

    _isLoading = true;
    _loadingStatus = 'Analyzing query intent...';
    notifyListeners();

    try {
      final service = GeminiService(apiKey: _apiKey, modelId: _modelId);
      
      // 1. Determine Agent
      final availableAgents = agents.map((a) => {'id': a.id, 'description': a.description}).toList();
      final bestAgentId = await service.determineBestAgent(userQuery: query, availableAgents: availableAgents);
      
      final selectedAgent = agents.firstWhere(
        (a) => a.id == bestAgentId, 
        orElse: () => agents.firstWhere((a) => a.id == 'internal_knowledge')
      );

      _loadingStatus = 'Routing to ${selectedAgent.name}...';
      notifyListeners();

      // 2. Run Query with Selected Agent
      await runQuery(selectedAgent, query, isRouted: true);

    } catch (e) {
      addToHistory({
        "agent": "Router",
        "query": query,
        "response": {"summary": "Router Error: ${e.toString()}"},
        "timestamp": DateTime.now(),
        "isError": true
      });
      _isLoading = false;
      _loadingStatus = '';
      notifyListeners();
    }
  }

  // Modified runQuery to accept isRouted flag to handle loading state/notifications differently if needed
  Future<void> runQuery(AgentConfig agent, String query, {bool isRouted = false}) async {
    if (_apiKey.isEmpty) {
      addToHistory({
        "agent": agent.name,
        "query": query,
        "response": {"summary": "Error: API Key is missing. Please configure it in Settings."},
        "timestamp": DateTime.now(),
        "isError": true
      });
      return;
    }

    if (!isRouted) {
      _isLoading = true;
    }
    
    _loadingStatus = 'Generating insights with ${agent.name}...';
    notifyListeners();

    try {
      final service = GeminiService(apiKey: _apiKey, modelId: _modelId);
      final response = await service.queryAgent(
        systemPrompt: agent.systemPrompt,
        userQuery: query,
      );

      addToHistory({
        "agent": agent.name,
        "query": query,
        "response": response,
        "timestamp": DateTime.now(),
        "isError": false,
        "routed": isRouted 
      });
    } catch (e) {
      addToHistory({
        "agent": agent.name,
        "query": query,
        "response": {"summary": "Error: ${e.toString()}"},
        "timestamp": DateTime.now(),
        "isError": true
      });
    } finally {
      _isLoading = false;
      _loadingStatus = '';
      notifyListeners();
    }
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
