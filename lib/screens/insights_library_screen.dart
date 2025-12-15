import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';

class InsightsLibraryScreen extends StatelessWidget {
  const InsightsLibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Insights Library', style: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(FontAwesomeIcons.trash, size: 18),
            onPressed: () {
               Provider.of<AppState>(context, listen: false).clearHistory();
            },
          )
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: Consumer<AppState>(
          builder: (context, state, _) {
            if (state.history.isEmpty) {
               return Center(
                 child: Column(
                   mainAxisAlignment: MainAxisAlignment.center,
                   children: [
                     Icon(FontAwesomeIcons.folderOpen, size: 64, color: Colors.grey[300]),
                     const SizedBox(height: 24),
                     Text('No past investigations found.', style: GoogleFonts.outfit(color: Colors.grey[400], fontSize: 16)),
                     const SizedBox(height: 16),
                     ElevatedButton.icon(
                       onPressed: () => Navigator.pushNamed(context, '/new_investigation'),
                       icon: const Icon(Icons.add),
                       label: const Text('New Analysis'),
                       style: ElevatedButton.styleFrom(
                         backgroundColor: Colors.white,
                         foregroundColor: AppTheme.primary,
                         elevation: 2,
                       ),
                     )
                   ],
                 ),
               );
            }
        
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(24, 120, 24, 100), // Adjusted for navbar
              itemCount: state.history.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final item = state.history[index];
                final query = item['query'] ?? 'Unknown Query';
                final timestamp = item['timestamp'] as DateTime?;
                final dateStr = timestamp != null ? DateFormat('MMM d, y • h:mm a').format(timestamp) : 'Unknown Date';
                
                return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.black.withOpacity(0.05)),
                    boxShadow: [
                       BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
                    ]
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
                            ),
                            child: Text(
                              'REPORT',
                              style: GoogleFonts.outfit(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.primary,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(dateStr, style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey[400])),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        query,
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 16),
                      Divider(color: Colors.black.withOpacity(0.05)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(FontAwesomeIcons.eye, size: 14, color: Colors.grey[400]),
                          const SizedBox(width: 8),
                          Text('View Analysis', style: GoogleFonts.outfit(fontSize: 13, color: Colors.grey[500])),
                          const Spacer(),
                          const Icon(Icons.arrow_forward_ios, size: 14, color: AppTheme.primary),
                        ],
                      )
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
