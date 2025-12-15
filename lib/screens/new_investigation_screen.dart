import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';

class NewInvestigationScreen extends StatefulWidget {
  const NewInvestigationScreen({super.key});

  @override
  State<NewInvestigationScreen> createState() => _NewInvestigationScreenState();
}

class _NewInvestigationScreenState extends State<NewInvestigationScreen> {
  final TextEditingController _queryController = TextEditingController();
  
  // Context Controllers
  final TextEditingController _therapyAreaController = TextEditingController(text: 'Respiratory');
  final TextEditingController _geographyController = TextEditingController(text: 'Global');
  final TextEditingController _timeHorizonController = TextEditingController(text: '5 Years');
  
  bool _isContextExpanded = true;
  bool _isScopeExpanded = false; 
  
  // Selected Agents (Default all)
  List<String> _selectedAgents = [];

  @override
  void initState() {
    super.initState();
    // Select all agents by default
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final agents = Provider.of<AppState>(context, listen: false).agents;
      setState(() {
        _selectedAgents = agents.map((a) => a.id).toList();
      });
    });
  }

  void _runAnalysis() {
    if (_queryController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a research question.')),
      );
      return;
    }

    final contextData = {
      'therapy_area': _therapyAreaController.text,
      'geography': _geographyController.text,
      'time_horizon': _timeHorizonController.text,
    };

    Provider.of<AppState>(context, listen: false).startInvestigation(
      query: _queryController.text,
      context: contextData,
      selectedAgents: _selectedAgents,
    );

    Navigator.pushNamed(context, '/analysis_progress');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background, // Light background
      appBar: AppBar(
        title: Text('New Investigation', style: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
        leading: IconButton(
          icon: const Icon(FontAwesomeIcons.arrowLeft, size: 20, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // STEP 1: RESEARCH QUESTION
            Text(
              'Research Question',
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.black.withOpacity(0.05)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
                ]
              ),
              child: TextField(
                controller: _queryController,
                maxLines: 4,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: InputDecoration(
                  hintText: 'e.g. Identify unmet needs in pediatric asthma treatment in Southeast Asia...',
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
              ),
            ),
            
            const SizedBox(height: 32),

            // STEP 2: CONTEXT
             Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Context & Parameters',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                    letterSpacing: 0.5,
                  ),
                ),
                IconButton(
                  icon: Icon(_isContextExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: Colors.grey[400]),
                  onPressed: () => setState(() => _isContextExpanded = !_isContextExpanded),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                )
              ],
            ),
             const SizedBox(height: 12),
            if (_isContextExpanded)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.black.withOpacity(0.05)),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5)],
                ),
                child: Column(
                  children: [
                    _buildInputField('Therapy Area', _therapyAreaController, FontAwesomeIcons.heartPulse),
                    const SizedBox(height: 16),
                    _buildInputField('Geography', _geographyController, FontAwesomeIcons.earthAmericas),
                    const SizedBox(height: 16),
                    _buildInputField('Time Horizon', _timeHorizonController, FontAwesomeIcons.clock),
                  ],
                ),
              ),

             const SizedBox(height: 32),

             // STEP 3: AGENT SCOPE
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Active Agents',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                    letterSpacing: 0.5,
                  ),
                ),
                TextButton(
                  onPressed: () => setState(() => _isScopeExpanded = !_isScopeExpanded),
                  child: Text(_isScopeExpanded ? 'Hide' : 'Customize', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600)),
                )
              ],
            ),
            if (_isScopeExpanded)
               Consumer<AppState>(
                builder: (context, state, _) {
                  return Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: state.agents.map((agent) {
                      final isSelected = _selectedAgents.contains(agent.id);
                      return FilterChip(
                        label: Text(agent.name),
                        selected: isSelected,
                        onSelected: (bool selected) {
                          setState(() {
                            if (selected) {
                              _selectedAgents.add(agent.id);
                            } else {
                              _selectedAgents.remove(agent.id);
                            }
                          });
                        },
                        backgroundColor: Colors.white,
                        selectedColor: AppTheme.primary.withOpacity(0.1),
                        checkmarkColor: AppTheme.primary,
                        labelStyle: TextStyle(color: isSelected ? AppTheme.primary : Colors.grey[500]),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20), 
                          side: BorderSide(color: isSelected ? AppTheme.primary : Colors.black.withOpacity(0.05)),
                        ),
                        showCheckmark: false,
                      );
                    }).toList(),
                  );
                },
               ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.black.withOpacity(0.05))),
        ),
        child: ElevatedButton(
          onPressed: _runAnalysis,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(FontAwesomeIcons.bolt, size: 18),
              const SizedBox(width: 8),
              Text('Launch Investigation', style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[400]),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey[500], fontWeight: FontWeight.w500)),
              TextField(
                controller: controller,
                style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 14, color: AppTheme.textPrimary),
                decoration: const InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 4),
                  border: InputBorder.none,
                   enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
