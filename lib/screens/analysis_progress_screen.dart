import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';

class AnalysisProgressScreen extends StatefulWidget {
  const AnalysisProgressScreen({super.key});

  @override
  State<AnalysisProgressScreen> createState() => _AnalysisProgressScreenState();
}

class _AnalysisProgressScreenState extends State<AnalysisProgressScreen> {
  
  @override
  void initState() {
    super.initState();
    // Check for completion to navigate
    WidgetsBinding.instance.addPostFrameCallback((_) {
       _checkCompletion();
    });
  }

  void _checkCompletion() {
    final state = Provider.of<AppState>(context, listen: false);
    if (!state.isAnalyzing && state.agentResults.isNotEmpty) {
       Navigator.pushReplacementNamed(context, '/investigation_results');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Consumer<AppState>(
        builder: (context, state, _) {
          // Auto-navigate when done
          if (!state.isAnalyzing && state.agentResults.isNotEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
               Navigator.pushReplacementNamed(context, '/investigation_results');
            });
          }

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   const SizedBox(height: 32),
                  Text(
                    'Analysis in Progress',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Cureonix Agents are investigating your query...',
                    style: GoogleFonts.outfit(fontSize: 14, color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 48),

                  Expanded(
                    child: ListView(
                      children: [
                        _buildTimelineItem(
                          context,
                          'Master Agent',
                          'Decomposing research objectives...',
                          state.isAnalyzing ? 'completed' : 'completed', // Master done first
                          isSystem: true,
                        ),
                        ...state.agents.map((agent) {
                           final status = state.agentStatuses[agent.id] ?? 'pending';
                           String details = agent.description;
                           
                           // Show mini-preview if running or done
                           if (status == 'running') {
                             details = 'Analyzing data sources...';
                           } else if (status == 'completed') {
                             details = 'Insights generated.';
                           }

                           return _buildTimelineItem(
                             context,
                             agent.name,
                             details,
                             status,
                           );
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimelineItem(BuildContext context, String title, String subtitle, String status, {bool isSystem = false}) {
    IconData icon;
    Color color;
    bool showLine = true;

    if (status == 'completed') {
      icon = FontAwesomeIcons.circleCheck;
      color = AppTheme.primary;
    } else if (status == 'running') {
      icon = FontAwesomeIcons.spinner;
      color = AppTheme.secondary; 
    } else {
      icon = FontAwesomeIcons.circle;
      color = Colors.grey[300]!;
      showLine = false;
    }

    if (isSystem) {
       color = AppTheme.primary;
       icon = FontAwesomeIcons.brain;
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: color.withValues(alpha: 0.5), width: 2),
                ),
                child: Icon(icon, size: 14, color: color),
              ),
              if (showLine) Expanded(child: Container(width: 2, color: color.withValues(alpha: 0.2))),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textPrimary)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: GoogleFonts.outfit(color: AppTheme.textSecondary, fontSize: 13)),
                  if (status == 'running') 
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: LinearProgressIndicator(backgroundColor: Colors.grey[200], color: AppTheme.primary, minHeight: 2),
                    )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
