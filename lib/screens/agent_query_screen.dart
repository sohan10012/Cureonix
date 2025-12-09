import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../models/agent_config.dart';
import '../providers/app_state.dart';
import 'results_screen.dart';

class AgentQueryScreen extends StatefulWidget {
  final AgentConfig agent;

  const AgentQueryScreen({super.key, required this.agent});

  @override
  State<AgentQueryScreen> createState() => _AgentQueryScreenState();
}

class _AgentQueryScreenState extends State<AgentQueryScreen> {
  final TextEditingController _controller = TextEditingController();
  
  // Specific Form Controllers
  String? _selectedTherapyArea;
  String? _selectedRegion;
  String? _selectedPhase;
  String? _selectedIndication;

  // Mock Data
  final List<String> _therapyAreas = ['Oncology', 'Diabetes', 'Cardiovascular', 'Neurology', 'Immunology'];
  final List<String> _regions = ['Global', 'North America', 'Europe', 'APAC', 'LATAM'];
  final List<String> _phases = ['Phase 1', 'Phase 2', 'Phase 3', 'Phase 4', 'Pre-clinical'];
  final List<String> _indications = ['Alzheimer\'s', 'Lung Cancer', 'T2 Diabetes', 'Hypertension', 'Rheumatoid Arthritis'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        title: Text(widget.agent.name, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color(0xFF102A43),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAgentHeader(),
            const SizedBox(height: 32),
            _buildInputSection(),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.analytics_outlined),
                label: Text('Run Analysis', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                  shadowColor: Theme.of(context).primaryColor.withOpacity(0.4),
                ),
                onPressed: _runAnalysis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAgentHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            _getIconForType(widget.agent.type),
            size: 32,
            color: Theme.of(context).primaryColor,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Workflow',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF627D98),
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.agent.description,
                style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF486581), height: 1.4),
              ),
            ],
          ),
        ),
      ],
    );
  }

  IconData _getIconForType(AgentType type) {
    switch (type) {
      case AgentType.market: return FontAwesomeIcons.chartLine;
      case AgentType.clinical: return FontAwesomeIcons.userDoctor;
      case AgentType.research: return FontAwesomeIcons.flask;
      case AgentType.safety: return FontAwesomeIcons.shieldHeart;
      default: return FontAwesomeIcons.robot;
    }
  }

  Widget _buildInputSection() {
    switch (widget.agent.type) {
      case AgentType.market:
        return _buildMarketInputs();
      case AgentType.clinical:
        return _buildClinicalInputs();
      case AgentType.research:
        return _buildResearchInputs();
      default:
        return _buildGeneralInputs();
    }
  }

  Widget _buildMarketInputs() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Market Parameters'),
        const SizedBox(height: 16),
        _buildDropdown(
          label: 'Therapy Area',
          value: _selectedTherapyArea,
          items: _therapyAreas,
          onChanged: (val) => setState(() => _selectedTherapyArea = val),
          icon: FontAwesomeIcons.pills,
        ),
        const SizedBox(height: 16),
        _buildDropdown(
          label: 'Target Region',
          value: _selectedRegion,
          items: _regions,
          onChanged: (val) => setState(() => _selectedRegion = val),
          icon: FontAwesomeIcons.earthAmericas,
        ),
        const SizedBox(height: 24),
        _buildSectionTitle('Specific Questions (Optional)'),
        const SizedBox(height: 12),
        _buildTextField('e.g., Competitor market share for insulin pumps...'),
      ],
    );
  }

  Widget _buildClinicalInputs() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Trial Criteria'),
        const SizedBox(height: 16),
        _buildDropdown(
          label: 'Indication / Disease',
          value: _selectedIndication,
          items: _indications,
          onChanged: (val) => setState(() => _selectedIndication = val),
          icon: FontAwesomeIcons.virus,
        ),
        const SizedBox(height: 16),
        _buildDropdown(
          label: 'Phase',
          value: _selectedPhase,
          items: _phases,
          onChanged: (val) => setState(() => _selectedPhase = val),
          icon: FontAwesomeIcons.listCheck,
        ),
        const SizedBox(height: 24),
        _buildSectionTitle('Keywords'),
        const SizedBox(height: 12),
        _buildTextField('e.g., mRNA vaccines, pediatric cohort...'),
      ],
    );
  }

  Widget _buildResearchInputs() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Research Focus'),
        const SizedBox(height: 16),
         Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildChip('Mechanism of Action'),
            _buildChip('Patent Expiry'),
            _buildChip('Drug Interactions'),
            _buildChip('Biomarkers'),
          ],
        ),
        const SizedBox(height: 24),
         _buildSectionTitle('Query'),
        const SizedBox(height: 12),
        _buildTextField('Enter scientific question or molecule name...'),
      ],
    );
  }
  
  Widget _buildGeneralInputs() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Agent Query'),
        const SizedBox(height: 16),
        _buildTextField('Ask anything...'),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          children: [
            ActionChip(label: const Text("Summarize Report"), onPressed: () => _controller.text = "Summarize this report"),
            ActionChip(label: const Text("Extract Key Data"), onPressed: () => _controller.text = "Extract key data points"),
          ],
        )
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          hint: Row(
            children: [
              Icon(icon, size: 18, color: const Color(0xFF627D98)),
              const SizedBox(width: 12),
              Text(label, style: GoogleFonts.inter(color: const Color(0xFF627D98))),
            ],
          ),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item, style: GoogleFonts.inter(fontWeight: FontWeight.w500)),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildTextField(String hint) {
    return TextField(
      controller: _controller,
      maxLines: 4,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(color: Colors.grey.withOpacity(0.6)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.all(20),
      ),
    );
  }

  Widget _buildChip(String label) {
    return ActionChip(
      avatar: const Icon(Icons.add, size: 16),
      label: Text(label),
      backgroundColor: Colors.white,
      side: BorderSide(color: Colors.grey.withOpacity(0.2)),
      onPressed: () {
        final text = _controller.text;
        _controller.text = text.isEmpty ? label : '$text, $label';
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF102A43).withOpacity(0.6),
        letterSpacing: 1.2,
      ),
    );
  }

  void _runAnalysis() async {
    // Construct Query based on inputs
    String finalQuery = '';

    if (widget.agent.type == AgentType.market) {
      if (_selectedTherapyArea != null) finalQuery += 'Therapy Area: $_selectedTherapyArea. ';
      if (_selectedRegion != null) finalQuery += 'Region: $_selectedRegion. ';
    } else if (widget.agent.type == AgentType.clinical) {
      if (_selectedIndication != null) finalQuery += 'Indication: $_selectedIndication. ';
      if (_selectedPhase != null) finalQuery += 'Phase: $_selectedPhase. ';
    }

    if (_controller.text.isNotEmpty) {
      finalQuery += _controller.text;
    }

    if (finalQuery.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select options or enter a query')),
      );
      return;
    }

    final appState = Provider.of<AppState>(context, listen: false);
    // Fire and forget so we can show loading screen
    appState.runQuery(widget.agent, finalQuery);

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ResultsScreen(),
        ),
      );
    }
  }
}
