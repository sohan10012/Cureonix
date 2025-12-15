import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../theme/app_theme.dart';

class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock Data
    final activities = [
      {'title': 'Analysis Completed', 'time': '2 mins ago', 'desc': 'Pediatric Asthma market gap analysis finalized.', 'icon': FontAwesomeIcons.check, 'color': AppTheme.primary},
      {'title': 'New Data Source', 'time': '1 hour ago', 'desc': 'Connected to ClinicalTrials.gov real-time feed.', 'icon': FontAwesomeIcons.link, 'color': AppTheme.secondary},
      {'title': 'Patent Alert', 'time': '4 hours ago', 'desc': 'Expiry detected for key competitor molecule.', 'icon': FontAwesomeIcons.triangleExclamation, 'color': AppTheme.accent},
    ];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('System Activity', style: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(24, 120, 24, 100),
          itemCount: activities.length,
          itemBuilder: (context, index) {
            final item = activities[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.black.withOpacity(0.05)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
                ]
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (item['color'] as Color).withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: (item['color'] as Color).withOpacity(0.2)),
                  ),
                  child: Icon(item['icon'] as IconData, color: item['color'] as Color, size: 20),
                ),
                title: Text(item['title'] as String, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.textPrimary)),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 6.0),
                  child: Text(item['desc'] as String, style: GoogleFonts.outfit(color: AppTheme.textSecondary, fontSize: 13, height: 1.4)),
                ),
                trailing: Text(item['time'] as String, style: GoogleFonts.outfit(fontSize: 11, color: Colors.grey[400], fontWeight: FontWeight.w500)),
              ),
            );
          },
        ),
      ),
    );
  }
}
