import 'package:flutter/material.dart';
import '../models/agent_config.dart';
import '../config/agents.dart';
import '../services/gemini_service.dart';

/// Main application state manager for Cureonix drug repurposing analysis platform.
/// 
/// Responsibilities:
/// - User configuration (API key, model selection, user profile)
/// - Investigation orchestration (query processing, agent execution)
/// - Results management (agent outputs, status tracking)
/// - Historical data persistence
class AppState with ChangeNotifier {
  // ============================================================================
  // CONFIGURATION STATE
  // ============================================================================
  
  String _apiKey = '';
  String _modelId = 'gemini-2.5-flash';
  String _userName = 'User';
  int _selectedTabIndex = 0;

  // ============================================================================
  // INVESTIGATION STATE
  // ============================================================================
  
  bool _isAnalyzing = false;
  String _currentQuery = '';
  Map<String, dynamic> _investigationContext = {};
  List<String> _selectedAgentIds = [];
  
  /// Agent execution status: 'pending' | 'running' | 'completed' | 'error'
  final Map<String, String> _agentStatuses = {};
  
  /// Agent results: agentId -> parsed JSON data
  final Map<String, dynamic> _agentResults = {};
  
  String? _errorMessage;

  // ============================================================================
  // HISTORICAL DATA
  // ============================================================================
  
  final List<Map<String, dynamic>> _history = [];

  // ============================================================================
  // LIVE FEED (SIMULATED)
  // ============================================================================
  
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

  // ============================================================================
  // GETTERS
  // ============================================================================
  
  String get apiKey => _apiKey;
  String get modelId => _modelId;
  String get userName => _userName;
  int get selectedTabIndex => _selectedTabIndex;
  List<Map<String, dynamic>> get history => List.unmodifiable(_history);
  
  bool get isAnalyzing => _isAnalyzing;
  String get currentQuery => _currentQuery;
  Map<String, String> get agentStatuses => Map.unmodifiable(_agentStatuses);
  Map<String, dynamic> get agentResults => Map.unmodifiable(_agentResults);
  String? get errorMessage => _errorMessage;
  List<Map<String, String>> get liveFeedItems => List.unmodifiable(_liveFeedItems);
  List<AgentConfig> get agents => Agents.allAgents;

  // ============================================================================
  // CONFIGURATION SETTERS
  // ============================================================================
  
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

  // ============================================================================
  // INVESTIGATION ORCHESTRATION
  // ============================================================================
  
  /// Initiates a new investigation with the specified query and agent selection.
  /// 
  /// This method:
  /// 1. Resets investigation state
  /// 2. Ensures report_generator is always included
  /// 3. Triggers agent execution pipeline
  void startInvestigation({
    required String query,
    required Map<String, dynamic> context,
    required List<String> selectedAgents,
  }) {
    _currentQuery = query;
    _investigationContext = context;
    _selectedAgentIds = _ensureReportGeneratorIncluded(selectedAgents);
    
    _resetInvestigationState();
    _isAnalyzing = true;
    notifyListeners();

    _executeAgentPipeline();
  }

  /// Ensures report_generator is always included in agent selection.
  List<String> _ensureReportGeneratorIncluded(List<String> agentIds) {
    final agents = List<String>.from(agentIds);
    if (!agents.contains('report_generator')) {
      agents.add('report_generator');
    }
    return agents;
  }

  /// Resets all investigation-related state for a fresh execution.
  void _resetInvestigationState() {
    _agentStatuses.clear();
    _agentResults.clear();
    _errorMessage = null;
  }

  // ============================================================================
  // AGENT EXECUTION PIPELINE
  // ============================================================================
  
  /// Main execution pipeline: orchestrates single API call with visual replay.
  /// 
  /// Strategy:
  /// - Single master API call (rate limit optimization)
  /// - Visual "replay" of results to simulate progressive execution
  /// - Robust fallback to mock data on API failure
  Future<void> _executeAgentPipeline() async {
    final sortedAgents = _getSortedAgentIds();
    
    _initializeAgentStatuses(sortedAgents);
    _setFirstAgentRunning(sortedAgents);
    notifyListeners();

    try {
      await _executeWithRealAPI(sortedAgents);
    } catch (e, stackTrace) {
      debugPrint("API execution failed: $e\n$stackTrace");
      await _executeWithMockFallback(sortedAgents, e);
    } finally {
      _isAnalyzing = false;
      notifyListeners();
    }
  }

  /// Returns agent IDs sorted with report_generator last.
  List<String> _getSortedAgentIds() {
    final agents = List<String>.from(_selectedAgentIds);
    agents.sort((a, b) {
      if (a == 'report_generator') return 1;
      if (b == 'report_generator') return -1;
      return 0;
    });
    return agents;
  }

  /// Initializes all agent statuses to 'pending'.
  void _initializeAgentStatuses(List<String> agentIds) {
    for (final agentId in agentIds) {
      _agentStatuses[agentId] = 'pending';
    }
  }

  /// Sets first agent to 'running' for immediate visual feedback.
  void _setFirstAgentRunning(List<String> agentIds) {
    if (agentIds.isNotEmpty) {
      _agentStatuses[agentIds.first] = 'running';
    }
  }

  // ============================================================================
  // REAL API EXECUTION
  // ============================================================================
  
  /// Executes master orchestrator API call and replays results visually.
  Future<void> _executeWithRealAPI(List<String> sortedAgents) async {
    final service = GeminiService(apiKey: _apiKey, modelId: _modelId);
    final masterPrompt = _buildMasterOrchestratorPrompt(sortedAgents);

    debugPrint("🚀 Launching Master Orchestrator (Single API Call)");
    
    final masterResult = await service.queryAgent(
      systemPrompt: masterPrompt,
      userQuery: _currentQuery,
    );

    debugPrint("✅ Master Result Received. Starting Visual Replay");
    
    await _visualReplayResults(sortedAgents, masterResult);
    _saveToHistory();
  }

  /// Builds the comprehensive master orchestrator prompt.
  String _buildMasterOrchestratorPrompt(List<String> sortedAgents) {
    final prompt = StringBuffer();
    
    _appendOrchestratorHeader(prompt);
    _appendAgentInstructions(prompt, sortedAgents);
    _appendOutputConstraints(prompt);
    _appendSystemContext(prompt);
    _appendMandatoryRules(prompt);
    _appendReportGenerationRules(prompt);
    _appendFinalReportRequirements(prompt);
    _appendOutputFormat(prompt);
    
    return prompt.toString();
  }

  void _appendOrchestratorHeader(StringBuffer prompt) {
    prompt.writeln("You are the Cureonix Master Orchestrator.");
    prompt.writeln("Your goal is to execute multiple analysis agents simultaneously and output a SINGLE JSON object containing all their findings.");
    prompt.writeln("Strictly follow the JSON structure keys provided for each agent.");
    prompt.writeln("");
  }

  void _appendAgentInstructions(StringBuffer prompt, List<String> agentIds) {
    for (final agentId in agentIds) {
      final agent = Agents.allAgents.firstWhere((a) => a.id == agentId);
      
      prompt.writeln("\n--- AGENT: ${agent.name} (Key: '$agentId') ---");
      prompt.writeln("Description: ${agent.description}");
      prompt.writeln("Instruction: Analyze the user query specifically from this perspective.");
      prompt.writeln("Agent Directive: ${agent.systemPrompt}");
    }
  }

  void _appendOutputConstraints(StringBuffer prompt) {
    prompt.writeln("\n\nCRITICAL OUTPUT INSTRUCTION:");
    prompt.writeln("1. You MUST output a SINGLE valid JSON object.");
    prompt.writeln("2. The JSON keys MUST EXACTLY match the agent keys already defined in the system");
    prompt.writeln("   (e.g., iqvia_insights, clinical_trials_landscape, patent_landscape, market_opportunity, regulatory_feasibility, report_generator).");
    prompt.writeln("3. EXECUTION ORDER IS MANDATORY:");
    prompt.writeln("   - Generate data for ALL research-related agent keys FIRST.");
    prompt.writeln("   - Generate the report_generator section LAST.");
  }

  void _appendSystemContext(StringBuffer prompt) {
    prompt.writeln("\nSYSTEM ROLE:");
    prompt.writeln("You are simulating an Agentic AI system designed for early-stage drug repurposing evaluation for a generic pharmaceutical company.");
    prompt.writeln("Your responsibility is to analyze the USER QUERY and evaluate whether an APPROVED pharmaceutical molecule can be repurposed into a value-added product for a new indication, formulation, or patient population.");
    prompt.writeln("\nUSER QUERY:");
    prompt.writeln("$_currentQuery");
  }

  void _appendMandatoryRules(StringBuffer prompt) {
    prompt.writeln("\nMANDATORY MOLECULE ANCHORING (NON-NEGOTIABLE):");
    prompt.writeln("- You MUST explicitly identify ONE primary APPROVED molecule from the user query.");
    prompt.writeln("- You MUST name this molecule explicitly in EVERY agent section.");
    prompt.writeln("- You MUST repeatedly reference this molecule in the final report.");
    prompt.writeln("- If no molecule can be clearly identified, explicitly state:");
    prompt.writeln('  "No clear molecule identified from user query"');
    prompt.writeln("  and limit analysis accordingly.");
    
    prompt.writeln("\nGLOBAL ANALYSIS RULES:");
    prompt.writeln("- Focus STRICTLY on drug repurposing, reformulation, or population-specific extension.");
    prompt.writeln("- Assume early-stage, near- to mid-term evaluation (portfolio screening).");
    prompt.writeln("- Do NOT discuss futuristic cures, disease eradication, or speculative long-term science.");
    prompt.writeln("- Do NOT generate therapy-area-only or industry-level market reports.");
    prompt.writeln("- All insights must connect back to the identified molecule.");
  }

  void _appendReportGenerationRules(StringBuffer prompt) {
    prompt.writeln("\nREPORT GENERATION RULES (report_generator):");
    prompt.writeln("- You MUST READ and SYNTHESIZE insights from ALL other agent keys.");
    prompt.writeln("- Do NOT repeat content verbatim.");
    prompt.writeln("- EXPAND deeply on every finding and its implications.");
    prompt.writeln("- Treat all simulated data as realistic and decision-relevant.");
    prompt.writeln("- The report MUST be MASSIVE and detailed.");
    prompt.writeln("- Write at the depth of an internal pharma R&D / portfolio strategy white paper.");
  }

  void _appendFinalReportRequirements(StringBuffer prompt) {
    prompt.writeln("\nFINAL REPORT MUST EXPLICITLY INCLUDE:");
    prompt.writeln("- Molecule overview and current approved use");
    prompt.writeln("- Clear unmet medical need for the new indication / population");
    prompt.writeln("- Analysis of completed or ongoing clinical trials involving the molecule");
    prompt.writeln("- Patent status, expiry timeline, and freedom-to-operate assessment");
    prompt.writeln("- Market opportunity tied directly to the molecule and new use");
    prompt.writeln("- High-level regulatory feasibility");
    prompt.writeln("- A FINAL, DECISION-ORIENTED RECOMMENDATION stating whether repurposing is viable and why");
    
    prompt.writeln("\nIMPORTANT:");
    prompt.writeln("This is a PROTOTYPE simulation of an Agentic AI system.");
    prompt.writeln("All outputs must reflect early-stage evaluation, not final regulatory approval.");
  }

  void _appendOutputFormat(StringBuffer prompt) {
    prompt.writeln("\nOUTPUT FORMAT:");
    prompt.writeln("- Return ONLY the JSON object.");
    prompt.writeln("- Do NOT include markdown, explanations, or text outside the JSON.");
    prompt.writeln("User Context: $_investigationContext");
  }

  // ============================================================================
  // VISUAL REPLAY MECHANISM
  // ============================================================================
  
  /// Simulates progressive agent execution by replaying pre-fetched results.
  /// 
  /// This creates the illusion of sequential agent execution while actually
  /// using data from a single API call.
  Future<void> _visualReplayResults(
    List<String> agentIds,
    Map<String, dynamic> masterResult,
  ) async {
    for (final agentId in agentIds) {
      _agentStatuses[agentId] = 'running';
      notifyListeners();
      
      await Future.delayed(_getThinkingDuration(agentId));
      
      _processAgentResult(agentId, masterResult);
      notifyListeners();
      
      await Future.delayed(const Duration(milliseconds: 300));
    }
  }

  /// Returns realistic "thinking" duration for agent execution simulation.
  Duration _getThinkingDuration(String agentId) {
    final baseDelay = 800;
    final variance = DateTime.now().millisecond % 700;
    final reportBonus = agentId == 'report_generator' ? 1000 : 0;
    
    return Duration(milliseconds: baseDelay + variance + reportBonus);
  }

  /// Processes individual agent result with fallback to mock data.
  void _processAgentResult(String agentId, Map<String, dynamic> masterResult) {
    if (masterResult.containsKey(agentId)) {
      _agentResults[agentId] = masterResult[agentId];
      _agentStatuses[agentId] = 'completed';
    } else {
      _handleMissingAgentResult(agentId);
    }
  }

  /// Handles missing agent results by falling back to mock data.
  void _handleMissingAgentResult(String agentId) {
    final mockData = _getMockDataForAgent(agentId);
    
    if (mockData != null) {
      _agentResults[agentId] = mockData;
      if (_agentResults[agentId] is Map) {
        _agentResults[agentId]['_is_fallback'] = true;
      }
      _agentStatuses[agentId] = 'completed';
      debugPrint("Recovered missing key '$agentId' using mock data");
    } else {
      _agentResults[agentId] = {"error": "No data returned for this agent."};
      _agentStatuses[agentId] = 'error';
      debugPrint("Missing key '$agentId' with no mock fallback available");
    }
  }

  // ============================================================================
  // MOCK FALLBACK EXECUTION
  // ============================================================================
  
  /// Executes investigation using mock data when API fails.
  Future<void> _executeWithMockFallback(
    List<String> sortedAgents,
    Object error,
  ) async {
    _captureAPIError(error);
    
    debugPrint("API failed. Switching to simulation mode");
    
    final dataAgents = sortedAgents.where((id) => id != 'report_generator').toList();
    final hasReportGenerator = sortedAgents.contains('report_generator');
    
    await _replayMockDataForAgents(dataAgents);
    
    if (hasReportGenerator) {
      await _replayMockReportGenerator();
    }
    
    _saveToHistory();
    _errorMessage = null; // Clear error to allow navigation
  }

  /// Captures and categorizes API error for user feedback.
  void _captureAPIError(Object error) {
    final errorString = error.toString();
    
    if (errorString.contains("429")) {
      _errorMessage = "Quota Exceeded (429): API Rate Limit Hit.";
    } else if (errorString.contains("400") || errorString.contains("403")) {
      _errorMessage = "Auth Error: Invalid Key or Model ($errorString)";
    } else {
      _errorMessage = "Connection Error: $errorString";
    }
  }

  /// Replays mock data for data-gathering agents.
  Future<void> _replayMockDataForAgents(List<String> agentIds) async {
    for (final agentId in agentIds) {
      _agentStatuses[agentId] = 'running';
      notifyListeners();
      
      await Future.delayed(const Duration(milliseconds: 600));
      
      final mockData = _getMockDataForAgent(agentId);
      if (mockData != null) {
        _agentResults[agentId] = mockData;
        _agentStatuses[agentId] = 'completed';
      } else {
        _agentResults[agentId] = {
          "summary": "Simulated data unavailable for this agent."
        };
        _agentStatuses[agentId] = 'completed';
      }
      
      notifyListeners();
    }
  }

  /// Replays mock data for report generator.
  Future<void> _replayMockReportGenerator() async {
    _agentStatuses['report_generator'] = 'running';
    notifyListeners();
    
    await Future.delayed(const Duration(milliseconds: 800));
    
    final mockReport = _getMockDataForAgent('report_generator');
    if (mockReport != null) {
      _agentResults['report_generator'] = mockReport;
      _agentStatuses['report_generator'] = 'completed';
    }
    
    notifyListeners();
  }

  // ============================================================================
  // MOCK DATA PROVIDER
  // ============================================================================
  
  /// Returns mock data for specified agent, or null if unavailable.
  Map<String, dynamic>? _getMockDataForAgent(String agentId) {
    return _getAllMockData()[agentId];
  }

  /// Returns comprehensive mock dataset for all agents.
  Map<String, dynamic> _getAllMockData() {
    return {
      "iqvia_insights": {
        "summary": "Simulated Market Data: The respiratory market is projected to grow at 5.2% CAGR.",
        "market_size_table": [
          {"category": "Total Market", "value": "\$15.2B", "unit": "USD"}
        ],
      },
      "exim_trends": {
        "summary": "Simulated Trade Data: Key API imports sourced primarily from APAC region.",
        "risks": "Potential supply chain disruption in Q3 due to logistics constraints."
      },
      "patent_landscape": {
        "summary": "Simulated Patent Search: Found 3 primary blocking patents expiring in 2026.",
      },
      "clinical_trials": {
        "summary": "Simulated Trials: 12 active Phase 3 trials identified for similar MOAs.",
        "active_trials": ["NCT01234567", "NCT09876543"]
      },
      "report_generator": {
        "summary": _getMockReportContent(),
        "tables": [
          {
            "title": "Projected Market Growth (2024-2029)",
            "headers": ["Year", "Revenue (\$B)", "Growth %"],
            "rows": [
              ["2024", "15.2", "5.8%"],
              ["2025", "16.1", "6.2%"],
              ["2026", "17.2", "6.8%"],
              ["2027", "18.5", "7.1%"],
              ["2028", "19.9", "7.5%"]
            ]
          }
        ]
      }
    };
  }

  /// Returns comprehensive mock report content.
  String _getMockReportContent() {
    return """
EXECUTIVE SUMMARY (SIMULATED)

Overview
This generated report synthesizes findings across market intelligence, clinical development, and supply chain domains to provide a comprehensive strategic outlook. While the live analysis encountered a momentary service interruption (fallback mode active), this simulated projection is based on high-confidence industry patterns for similar therapeutic areas.

1. Strategic Market Analysis
The global market for the analyzed indication is currently demonstrating robust growth characteristics, driven by increasing prevalence rates and improved diagnostic capabilities. Historical data suggests a Compound Annual Growth Rate (CAGR) of approximately 5.8% over the last five years, with projections accelerating to 6.2% through 2028. Key drivers include:
- Rising adoption of biologic therapies in developed markets.
- Expansion of healthcare access in emerging economies (APAC and LATAM).
- Shift towards personalized medicine and biomarker-driven treatment protocols.

2. Competitive Landscape & Positioning
The simulator identifies a consolidated landscape with three dominant players holding ~60% market share. However, the "challenger" segment is rapidly expanding.
- Competitor A: Leads in efficacy but suffers from administration complexity.
- Competitor B: dominates the oral formulation segment but faces patent expiry in 2026.
- Emerging Players: Several biotech firms are entering Phase 3 with novel MOAs that could disrupt the standard of care.

3. Clinical Pipeline Assessment
The clinical development pipeline is highly active. Our simulated scan detects:
- 15+ Active Phase 3 trials globally.
- A marked shift towards subcutaneous formulations aimed at improving patient adherence.
- High trial density in North America and Western Europe, with recruitment challenges noted in Eastern Europe.
- Top sponsors are prioritizing pediatric indications, responding to regulatory incentives (e.g., pediatric exclusivity vouchers).

4. Supply Chain Resilience
Global supply chain analysis reveals moderate risks.
- API Sourcing: Heavily concentrated in the APAC region (approx. 70% of global volume). This creates dependency risks.
- Logistics: Cold-chain requirements for biologics impose significant cost pressures and vulnerability to logistics disruptions.
- Mitigation Strategies: We recommend diversifying API sourcing to include secondary suppliers in the EU or North America and implementing real-time inventory tracking.

5. Intellectual Property & FTO
The patent landscape is entering a transitional phase.
- Primary patents for the current standard of care are approaching the 2026 cliff.
- This creates an immediate window for generic/biosimilar entry.
- Freedom-To-Operate (FTO) analysis suggests clear whitespace in specific formulation technologies, offering an opportunity for novel delivery systems to bypass existing IP thickets.

6. Conclusion & Recommendations
To maximize territory potential, we recommend a three-pronged strategy:
A. Accelerate clinical differentiation by focusing on patient-centric outcomes (QoL).
B. Preemptively secure straight-to-patient logistics channels to mitigate supply risks.
C. Aggressively pursue adjunctive IP protection around delivery mechanisms to extend exclusivity beyond the 2026 molecule patent expiry.

(Simulated Report End - This content mimics the structure of a full 6-page whitepaper.)
""";
  }

  // ============================================================================
  // HISTORY MANAGEMENT
  // ============================================================================
  
  /// Saves current investigation to history.
  void _saveToHistory() {
    addToHistory({
      "query": _currentQuery,
      "results": Map<String, dynamic>.from(_agentResults),
      "timestamp": DateTime.now(),
    });
  }

  /// Adds investigation result to history.
  void addToHistory(Map<String, dynamic> item) {
    _history.insert(0, item);
    notifyListeners();
  }

  /// Clears all historical data.
  void clearHistory() {
    _history.clear();
    notifyListeners();
  }
}
