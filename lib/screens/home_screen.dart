import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/app_state.dart';
import '../models/agent_config.dart';
import 'agent_query_screen.dart';
import 'results_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final agents = appState.agents;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        title: Text(
          'Cureonix', 
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            color: const Color(0xFF102A43),
          )
        ),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(FontAwesomeIcons.clockRotateLeft, size: 20),
            color: const Color(0xFF102A43),
            onPressed: () => Navigator.pushNamed(context, '/history'),
          ),
          IconButton(
            icon: const Icon(FontAwesomeIcons.gear, size: 20),
            color: const Color(0xFF102A43),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back,',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: const Color(0xFF627D98),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Select an AI Agent',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF102A43),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Omni-Search Bar
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF102A43).withOpacity(0.08),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Ask Cureonix anything...',
                        hintStyle: GoogleFonts.inter(color: const Color(0xFF9AA5B1)),
                        prefixIcon: const Icon(FontAwesomeIcons.wandMagicSparkles, color: Color(0xFF0056D2), size: 18),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        suffixIcon: Container(
                          margin: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0056D2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                        ),
                      ),
                      onSubmitted: (value) {
                         if (value.isNotEmpty) {
                            final appState = Provider.of<AppState>(context, listen: false);
                            // Fire and forget - let AppState manage the loading/error state
                            appState.askRouter(value);
                            
                            if (context.mounted) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const ResultsScreen()),
                              );
                            }
                         }
                      },
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.82,
                ),
                itemCount: agents.length,
                itemBuilder: (context, index) {
                  return AgentCard(agent: agents[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AgentCard extends StatelessWidget {
  final AgentConfig agent;
  
  const AgentCard({super.key, required this.agent});

  IconData _getAgentIcon(String name) {
    final n = name.toLowerCase();
    if (n.contains('research')) return FontAwesomeIcons.flask;
    if (n.contains('clinical') || n.contains('trial')) return FontAwesomeIcons.clipboardCheck;
    if (n.contains('literature') || n.contains('review')) return FontAwesomeIcons.bookMedical;
    if (n.contains('safety')) return FontAwesomeIcons.shieldHeart;
    if (n.contains('market') || n.contains('intelligence')) return FontAwesomeIcons.chartLine;
    return FontAwesomeIcons.robot;
  }

  Color _getIconColor(String name) {
    final n = name.toLowerCase();
    if (n.contains('research')) return const Color(0xFF0056D2);
    if (n.contains('safe')) return const Color(0xFFD32F2F);
    if (n.contains('market')) return const Color(0xFFF57C00);
    return const Color(0xFF00AA9E);
  }

  @override
  Widget build(BuildContext context) {
    final iconData = _getAgentIcon(agent.name);
    final accentColor = _getIconColor(agent.name);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF102A43).withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: const Color(0xFF102A43).withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AgentQueryScreen(agent: agent),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    iconData,
                    size: 24,
                    color: accentColor,
                  ),
                ),
                const Spacer(),
                Text(
                  agent.name,
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: const Color(0xFF102A43),
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  agent.description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 12, 
                    color: const Color(0xFF627D98),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 4),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
