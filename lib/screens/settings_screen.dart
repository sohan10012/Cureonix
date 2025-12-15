import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Local state for UI toggles
  bool _emailNotifications = true;
  bool _pushNotifications = true;
  bool _dailyDigest = false;
  
  bool _sourceFDA = true;
  bool _sourceEMA = true;
  bool _sourcePubMed = true;
  bool _sourceClinicalTrials = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text('Settings', style: GoogleFonts.outfit(color: AppTheme.textPrimary, fontWeight: FontWeight.w600)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppTheme.textPrimary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Profile Header
            _buildProfileCard(),
            const SizedBox(height: 32),

            // Section: Preferences
            _buildSectionHeader("NOTIFICATIONS"),
            const SizedBox(height: 16),
            _buildSettingContainer([
              _buildSwitchTile("Email Alerts", "Receive updates via email", _emailNotifications, (v) => setState(() => _emailNotifications = v)),
              _buildDivider(),
              _buildSwitchTile("Push Notifications", "Real-time mobile alerts", _pushNotifications, (v) => setState(() => _pushNotifications = v)),
              _buildDivider(),
              _buildSwitchTile("Daily Digest", "Summary every morning", _dailyDigest, (v) => setState(() => _dailyDigest = v)),
            ]),

            const SizedBox(height: 32),

            // Section: Intelligence Sources
            _buildSectionHeader("DATA SOURCES"),
            const SizedBox(height: 16),
            _buildSettingContainer([
              _buildSwitchTile("FDA Databases", "Drug approvals & recalls", _sourceFDA, (v) => setState(() => _sourceFDA = v)),
              _buildDivider(),
              _buildSwitchTile("EMA Regulatory", "European Medicines Agency", _sourceEMA, (v) => setState(() => _sourceEMA = v)),
              _buildDivider(),
              _buildSwitchTile("PubMed Central", "Biomedical literature", _sourcePubMed, (v) => setState(() => _sourcePubMed = v)),
              _buildDivider(),
              _buildSwitchTile("ClinicalTrials.gov", "Active study registries", _sourceClinicalTrials, (v) => setState(() => _sourceClinicalTrials = v)),
            ]),

            const SizedBox(height: 32),
             
             // Section: Account
            _buildSectionHeader("SYSTEM"),
            const SizedBox(height: 16),
            _buildSettingContainer([
              _buildActionTile("Change Password", FontAwesomeIcons.lock),
              _buildDivider(),
              _buildActionTile("Privacy Policy", FontAwesomeIcons.shieldHalved),
              _buildDivider(),
               _buildActionTile("Log Out", FontAwesomeIcons.rightFromBracket, isDestructive: true),
            ]),
            
            const SizedBox(height: 48),
            Text(
              "Cureonix v1.0.2 (Build 45)",
              style: GoogleFonts.outfit(color: AppTheme.textSecondary, fontSize: 12),
            ),
             const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 5)),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: AppTheme.primary.withOpacity(0.1),
            child: Text(
              "TC",
              style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.primary),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  Provider.of<AppState>(context).userName,
                  style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                ),
                Text(
                  "Senior Research Analyst",
                  style: GoogleFonts.outfit(fontSize: 14, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {}, 
            icon: const Icon(FontAwesomeIcons.penToSquare, size: 18, color: AppTheme.textSecondary),
          )
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: Row(
        children: [
           Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 12, 
              fontWeight: FontWeight.w800, 
              letterSpacing: 1.5,
              color: AppTheme.textSecondary
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingContainer(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
           BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 2)),
        ],
        border: Border.all(color: Colors.black.withOpacity(0.03)),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, bool value, Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w500, color: AppTheme.textPrimary)),
                const SizedBox(height: 2),
                Text(subtitle, style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textSecondary)),
              ],
            ),
          ),
          Switch.adaptive(
            value: value, 
            onChanged: onChanged,
            activeColor: AppTheme.primary,
            activeTrackColor: AppTheme.primary.withOpacity(0.2),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(String title, IconData icon, {bool isDestructive = false}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Icon(icon, size: 18, color: isDestructive ? Colors.red : AppTheme.textSecondary),
      title: Text(
        title, 
        style: GoogleFonts.outfit(
          fontSize: 16, 
          fontWeight: FontWeight.w500, 
          color: isDestructive ? Colors.red : AppTheme.textPrimary
        )
      ),
      trailing: const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
      onTap: () {},
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, thickness: 1, color: Colors.grey.withOpacity(0.1));
  }
}
