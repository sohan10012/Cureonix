import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// For standard flutter styling if needed
import '../providers/app_state.dart';
import '../theme/app_theme.dart';

class CommandCenterScreen extends StatelessWidget {
  const CommandCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: false, // Fixed header
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background, // Solid background
        elevation: 0,
        title: Row(
          children: [
             // Brighter gradient for Light Mode
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [AppTheme.primary, AppTheme.secondary],
              ).createShader(bounds),
              child: const Icon(FontAwesomeIcons.dna, size: 24, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Text('CUREONIX', style: Theme.of(context).appBarTheme.titleTextStyle?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: 2.0,
              color: AppTheme.textPrimary,
            )),
          ],
        ),
        // Actions removed for cleaner look
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12), // Standard padding
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Message
              Text(
                'Good afternoon, ${Provider.of<AppState>(context).userName}',
                style: GoogleFonts.outfit(fontSize: 16, color: AppTheme.primary, letterSpacing: 1, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4), 
              Text(
                'Intelligence Hub',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 32,
                  color: AppTheme.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              
              const SizedBox(height: 24),
              
              // NEW: Market Pulse Section
              Row(
                children: [
                  const Icon(FontAwesomeIcons.waveSquare, size: 14, color: AppTheme.secondary), 
                  const SizedBox(width: 8),
                  Text(
                    'MARKET PULSE',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              SizedBox(
                height: 110,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildMetricCard("FDA Approvals", "4", "This Week", Colors.green),
                    const SizedBox(width: 12),
                    _buildMetricCard("New Trials", "12", "Oncology", AppTheme.primary),
                    const SizedBox(width: 12),
                    _buildMetricCard("Patent Expiry", "2", "High Impact", Colors.orange),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Hero Search / Prompt (White Glass with Shadow)
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/new_investigation'),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20), // Reduced internal padding
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primary.withOpacity(0.15),
                        blurRadius: 30,
                        spreadRadius: -5,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       Row(
                         children: [
                           Icon(FontAwesomeIcons.magnifyingGlass, color: AppTheme.primary, size: 20),
                           const SizedBox(width: 12),
                           Text('Initialize New Analysis...', style: GoogleFonts.outfit(fontSize: 16, color: AppTheme.textPrimary.withOpacity(0.6))), // Reduced font size
                         ],
                       ),
                       const SizedBox(height: 12), // Reduced
                       Wrap(
                         spacing: 8,
                         children: [
                           _buildChip("Unmet Needs", AppTheme.secondary),
                           _buildChip("Market Gaps", AppTheme.primary),
                           _buildChip("Repurposing", Colors.deepPurpleAccent),
                         ],
                       )
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 32), // Reduced from 48

              // Live Intelligence Feed header
              Row(
                children: [
                  const Icon(FontAwesomeIcons.bolt, size: 14, color: AppTheme.accent), 
                  const SizedBox(width: 8),
                  Text(
                    'LIVE FEED',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12), // Reduced

              // Glass Live Feed (White)
              Consumer<AppState>(
                builder: (context, state, _) {
                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: state.liveFeedItems.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = state.liveFeedItems[index];
                      // Determine icon based on agent name (simple heuristic)
                      IconData icon = FontAwesomeIcons.robot;
                      Color color = Colors.grey;
                      
                      if (item['agent']!.contains('IQVIA')) { icon = FontAwesomeIcons.chartLine; color = const Color(0xFF0056D2); }
                      if (item['agent']!.contains('Patent')) { icon = FontAwesomeIcons.scaleBalanced; color = Colors.amber; } 
                      if (item['agent']!.contains('EXIM')) { icon = FontAwesomeIcons.ship; color = AppTheme.primary; }

                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0,4)),
                          ]
                        ),
                        child: Row(
                          children: [
                             Container(
                               padding: const EdgeInsets.all(10),
                               decoration: BoxDecoration(
                                 color: color.withOpacity(0.1),
                                 borderRadius: BorderRadius.circular(10),
                               ),
                               child: Icon(icon, size: 16, color: color),
                             ),
                             const SizedBox(width: 16),
                             Expanded(
                               child: Column(
                                 crossAxisAlignment: CrossAxisAlignment.start,
                                 children: [
                                     Row(
                                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                       children: [
                                         Text(
                                           item['agent'] ?? '',
                                           style: GoogleFonts.outfit(
                                             fontWeight: FontWeight.w600,
                                             fontSize: 13,
                                             color: AppTheme.primary,
                                           ),
                                         ),
                                         Text(
                                           'NOW',
                                           style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.accent),
                                         ),
                                       ],
                                     ),
                                     const SizedBox(height: 4),
                                     Text(
                                       item['update'] ?? '',
                                       style: GoogleFonts.outfit(fontSize: 14, color: AppTheme.textPrimary),
                                     ),
                                 ],
                               ),
                             ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
              
              const SizedBox(height: 32), // Reduced from 48

              // Recent Investigations Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'RECENT FILES',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12), // Reduced

              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildRecentFileCard(context, "Oncology Market Q3", "Global Analysis"),
                    const SizedBox(width: 12),
                    _buildRecentFileCard(context, "Insulin Supply Chain", "Risk Assessment"),
                     const SizedBox(width: 12),
                    _buildRecentFileCard(context, "Alzheimers Trials", "Phase 3 Update"),
                  ],
                ),
              ),
               const SizedBox(height: 100), // Bottom padding for navbar
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: GoogleFonts.outfit(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildMetricCard(String title, String value, String subtitle, Color color) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
           BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0,4)),
        ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Text(
             title,
             style: GoogleFonts.outfit(
               fontSize: 12,
               fontWeight: FontWeight.w600,
               color: AppTheme.textSecondary,
             ),
             maxLines: 1, 
             overflow: TextOverflow.ellipsis,
           ),
           const Spacer(),
           Text(
             value,
             style: GoogleFonts.outfit(
               fontSize: 24,
               fontWeight: FontWeight.bold,
               color: color,
             ),
           ),
           const SizedBox(height: 4),
           Text(
             subtitle,
             style: GoogleFonts.outfit(
               fontSize: 11,
               color: AppTheme.textPrimary.withOpacity(0.7),
             ),
           ),
        ],
      ),
    );
  }

  Widget _buildRecentFileCard(BuildContext context, String title, String subtitle) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
           BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0,4)),
        ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(FontAwesomeIcons.fileLines, size: 14, color: AppTheme.primary),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.textPrimary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: GoogleFonts.outfit(fontSize: 11, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }
}
