import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';

class InvestigationResultsScreen extends StatelessWidget {
  final Map<String, dynamic>? results;

  const InvestigationResultsScreen({super.key, this.results});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 7,
      child: Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(
          title: Text(
            'Investigation Results',
            style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 18, color: AppTheme.textPrimary),
          ),
          backgroundColor: Colors.transparent,
          iconTheme: const IconThemeData(color: AppTheme.textPrimary),
          bottom: TabBar(
            isScrollable: true,
            labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.w600),
            unselectedLabelStyle: GoogleFonts.outfit(fontWeight: FontWeight.w400),
            indicatorColor: AppTheme.primary,
            labelColor: AppTheme.primary,
            unselectedLabelColor: AppTheme.textSecondary,
            dividerColor: Colors.black.withOpacity(0.05),
            tabs: const [
              Tab(text: 'Executive'),
              Tab(text: 'Market'),
              Tab(text: 'Supply'),
              Tab(text: 'Patents'),
              Tab(text: 'Clinical'),
              Tab(text: 'External'),
              Tab(text: 'Internal'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(FontAwesomeIcons.circleInfo),
              tooltip: 'Agent Contributions',
              onPressed: () => _showAgentContributions(context),
            ),
             const SizedBox(width: 8),
          ],
        ),
        body: Consumer<AppState>(
          builder: (context, state, _) {
            final activeResults = results ?? state.agentResults;
            return TabBarView(
              children: [
                _buildExecutiveTab(context, activeResults['report_generator']),
                _buildMarketTab(context, activeResults['iqvia_insights']),
                _buildSupplyTab(context, activeResults['exim_trends']),
                _buildPatentTab(context, activeResults['patent_landscape']),
                _buildClinicalTab(context, activeResults['clinical_trials']),
                _buildExternalTab(context, activeResults['web_intelligence']),
                _buildInternalTab(context, activeResults['internal_knowledge']),
              ],
            );
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => Navigator.pushNamed(context, '/report_preview'),
          backgroundColor: AppTheme.primary,
          icon: const Icon(FontAwesomeIcons.filePdf, size: 18, color: Colors.white),
          label: Text('Export Report', style: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: Colors.white)),
        ),
      ),
    );
  }

  // --- TAB BUILDERS ---

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(FontAwesomeIcons.circleNotch, size: 32, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(message, style: GoogleFonts.outfit(color: Colors.grey[400])),
        ],
      ),
    );
  }

  Widget _buildExecutiveTab(BuildContext context, dynamic data) {
    if (data == null) return _buildEmptyState("Waiting for synthesis...");
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader("Executive Summary"),
          _buildInfoCard(context, data['summary'] ?? 'No summary available.'),
          
          const SizedBox(height: 24),
          _buildSectionHeader("Key Findings"),
           if (data['tables'] != null)
            ...(data['tables'] as List).map((t) => _buildSimpleTable(context, t)),
        ],
      ),
    );
  }

  Widget _buildMarketTab(BuildContext context, dynamic data) {
    if (data == null) return _buildEmptyState("Analyzing market data...");
    return SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _buildSectionHeader("IQVIA Analytics"),
          _buildInfoCard(context, data['analysis'] ?? 'No analysis.'),
          const SizedBox(height: 24),
          _buildSectionHeader("Market Stats"),
          if (data['stats'] != null) ...[
             // Helper for stats could be added here
             Text(data['stats'].toString(), style: TextStyle(color: AppTheme.textSecondary)),
          ]
        ]));
  }

  Widget _buildSupplyTab(BuildContext context, dynamic data) {
    if (data == null) return _buildEmptyState("Tracking shipments...");
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _buildSectionHeader("Supply Chain Risks"),
        _buildInfoCard(context, data['risks'] ?? 'No risks identified.'),
      ]));
  }

  Widget _buildPatentTab(BuildContext context, dynamic data) {
    if (data == null) return _buildEmptyState("Searching patents...");
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
         _buildSectionHeader("Patent Landscape"),
         _buildInfoCard(context, data['analysis'] ?? 'No patents found.'),
      ]));
  }

  Widget _buildClinicalTab(BuildContext context, dynamic data) {
    if (data == null) return _buildEmptyState("Fetching trials...");
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _buildSectionHeader("Clinical Trials"),
        _buildInfoCard(context, "Trials found: ${data['trials']?.length ?? 0}"),
      ]));
  }

  Widget _buildExternalTab(BuildContext context, dynamic data) {
    if (data == null) return _buildEmptyState("Scanning web...");
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _buildSectionHeader("Web Intelligence"),
        _buildInfoCard(context, data['summary'] ?? 'No data.'),
      ]));
  }

  Widget _buildInternalTab(BuildContext context, dynamic data) {
    if (data == null) return _buildEmptyState("Querying internal db...");
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
         _buildSectionHeader("Internal Knowledge"),
         _buildInfoCard(context, "Documents: ${data['documents']?.length ?? 0}"),
      ]));
  }

  // --- HELPERS ---

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.outfit(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: AppTheme.textSecondary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, String content) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ]
      ),
      child: Text(
        content,
        style: GoogleFonts.outfit(
          fontSize: 15,
          height: 1.6,
          color: AppTheme.textPrimary,
        ),
      ),
    );
  }

  Widget _buildSimpleTable(BuildContext context, dynamic tableData) {
    if (tableData == null) return const SizedBox();
    List headers = tableData['headers'] ?? [];
    List rows = tableData['tables'] ?? [];

    return Container(
      margin: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
         boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              tableData['title'] ?? 'Data Table',
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppTheme.secondary),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(Colors.grey[50]),
              columns: headers.map((h) => DataColumn(label: Text(h.toString(), style: GoogleFonts.outfit(fontWeight: FontWeight.w600)))).toList(),
              rows: rows.map((row) {
                return DataRow(
                  cells: (row as List).map((cell) => DataCell(Text(cell.toString(), style: GoogleFonts.outfit()))).toList(),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  void _showAgentContributions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Agent Contributions', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
            const SizedBox(height: 16),
            ...Provider.of<AppState>(context, listen: false).agents.map((agent) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Icon(FontAwesomeIcons.robot, size: 16, color: AppTheme.textSecondary),
                  const SizedBox(width: 12),
                  Text(agent.name, style: GoogleFonts.outfit(fontWeight: FontWeight.w500, color: AppTheme.textPrimary)),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}
