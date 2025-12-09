import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/app_state.dart';
import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

class ResultsScreen extends StatelessWidget {
  final Map<String, dynamic>? resultData;

  const ResultsScreen({super.key, this.resultData});

  @override
  Widget build(BuildContext context) {
    if (resultData != null) {
      return _buildContent(context, resultData!);
    }

    final appState = Provider.of<AppState>(context);
    final historyItem = appState.history.isNotEmpty ? appState.history.first : null;
    final isLoading = appState.isLoading;

    if (isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Pulse Animation Container
              TweenAnimationBuilder(
                tween: Tween<double>(begin: 0.8, end: 1.2),
                duration: const Duration(seconds: 1),
                curve: Curves.easeInOut,
                builder: (context, scale, child) {
                  return Transform.scale(
                    scale: scale,
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.auto_awesome, // Brain/AI icon
                        size: 64,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  );
                },
                onEnd: () {}, // Loop could be done with AnimationController but simple pulse is okay for now
              ),
              const SizedBox(height: 48),
              
              // Animated Status Text
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: Text(
                  appState.loadingStatus,
                  key: ValueKey<String>(appState.loadingStatus),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF102A43),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Progress Bar
              SizedBox(
                width: 200,
                child: LinearProgressIndicator(
                  backgroundColor: const Color(0xFFF0F4F8),
                  valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.secondary),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (historyItem == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Results')),
        body: const Center(child: Text('No results found.')),
      );
    }
    
    return _buildContent(context, historyItem);
  }

  Widget _buildContent(BuildContext context, Map<String, dynamic> item) {
    final isError = item['isError'] == true;
    final response = item['response'];
    final query = item['query'] ?? 'Analysis Results';

    return Scaffold(
      appBar: AppBar(
        title: Text(query.length > 20 ? '${query.substring(0, 20)}...' : query),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
               // Trigger actual PDF generation
               _generateAndOpenPdf(context, item);
            },
          )
        ],
      ),
      body: isError
          ? Center(child: Text('Error: ${response['summary'] ?? "Unknown error"}'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (response['summary'] != null) ...[
                    const _SectionHeader(title: 'Executive Summary'),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          response['summary'],
                          style: const TextStyle(fontSize: 16, height: 1.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  
                  // Dynamically render other keys as tables or lists
                  ...response.keys.map<Widget>((key) {
                    if (key == 'summary' || key == 'assumptions' || key == 'raw_output') return const SizedBox.shrink();
                    final value = response[key];
                    if (value is List && value.isNotEmpty) {
                       // simple heuristic: list of maps = table -> render table
                       // list of strings = bullets -> render bullets
                       if (value.first is Map) {
                         return Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                             _SectionHeader(title: _formatKey(key)),
                             _buildTable(value.cast<Map<String, dynamic>>()),
                             const SizedBox(height: 24),
                           ],
                         );
                       } else if (value.first is String) {
                          return Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                             _SectionHeader(title: _formatKey(key)),
                             ...value.map<Widget>((item) => Padding(
                               padding: const EdgeInsets.only(bottom: 8.0),
                               child: Row(
                                 crossAxisAlignment: CrossAxisAlignment.start,
                                 children: [
                                   const Text('• ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                   Expanded(child: Text(item.toString())),
                                 ],
                               ),
                             )),
                             const SizedBox(height: 24),
                           ],
                         );
                       }
                    } else if (value is Map) {
                      // Handle map (e.g., phase_distribution)
                       return Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                             _SectionHeader(title: _formatKey(key)),
                             _buildKeyValueList(value.cast<String, dynamic>()),
                             const SizedBox(height: 24),
                           ],
                         );
                    }
                     return const SizedBox.shrink();
                  }).toList(),

                  if (response['assumptions'] != null && response['assumptions'].toString().isNotEmpty) ...[
                    const _SectionHeader(title: 'Assumptions & Methodology'),
                    Card(
                      color: Colors.amber.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          response['assumptions'],
                          style: TextStyle(fontSize: 14, color: Colors.brown.shade800),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  if (response['raw_output'] != null) ...[
                    const _SectionHeader(title: 'Raw Output (Debug)'),
                    SelectableText(response['raw_output'].toString()),
                  ]
                ],
              ),
            ),
    );
  }

  String _formatKey(String key) {
    return key.split('_').map((word) => word[0].toUpperCase() + word.substring(1)).join(' ');
  }

  Widget _buildTable(List<Map<String, dynamic>> data) {
    if (data.isEmpty) return const Text("No data");
    
    // Get headers from first item keys
    final headers = data.first.keys.toList();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(const Color(0xFFE0F7FA)),
        columns: headers.map((h) => DataColumn(label: Text(h.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold)))).toList(),
        rows: data.map((row) {
          return DataRow(
            cells: headers.map((h) => DataCell(Text(row[h]?.toString() ?? '-'))).toList(),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildKeyValueList(Map<String, dynamic> data) {
     return Column(
       children: data.entries.map((e) => ListTile(
         title: Text(e.key),
         trailing: Text(e.value.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
       )).toList(),
     );
  }


  Future<void> _generateAndOpenPdf(BuildContext context, Map<String, dynamic> item) async {
    final pdf = pw.Document();
    final response = item['response'] ?? {};
    final query = item['query'] ?? 'Analysis Report';
    final timestamp = item['timestamp']?.toString() ?? DateTime.now().toString();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            _buildPdfHeader(query, timestamp),
            pw.SizedBox(height: 20),
            if (response['summary'] != null) ...[
              pw.Header(level: 1, text: 'Executive Summary'),
              pw.Paragraph(text: response['summary'].toString()),
              pw.SizedBox(height: 10),
            ],
            // Iterate remaining keys
            ...response.keys.map((key) {
               if (key == 'summary' || key == 'assumptions' || key == 'raw_output') return pw.Container();
               final value = response[key];
               if (value is List && value.isNotEmpty && value.first is Map) {
                 // Table
                 final List<Map<String, dynamic>> listData = value.cast<Map<String, dynamic>>();
                 final headers = listData.first.keys.toList();
                 final data = listData.map((row) => headers.map((h) => row[h]?.toString() ?? '-').toList()).toList();
                 
                 return pw.Column(
                   crossAxisAlignment: pw.CrossAxisAlignment.start,
                   children: [
                     pw.Header(level: 2, text: _formatKey(key)),
                     pw.TableHelper.fromTextArray(
                       headers: headers.map((h) => h.toUpperCase()).toList(),
                       data: data,
                       border: pw.TableBorder.all(color: PdfColors.grey300),
                       headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                       headerDecoration: const pw.BoxDecoration(color: PdfColors.blue800),
                       cellAlignment: pw.Alignment.centerLeft,
                     ),
                     pw.SizedBox(height: 15),
                   ]
                 );
               } else if (value is Map) {
                 return pw.Column(
                   crossAxisAlignment: pw.CrossAxisAlignment.start,
                   children: [
                      pw.Header(level: 2, text: _formatKey(key)),
                      ...value.entries.map((e) => pw.Bullet(text: "${e.key}: ${e.value}")),
                      pw.SizedBox(height: 15),
                   ]
                 );
               }
               return pw.Container();
            }).toList(),

            if (response['assumptions'] != null) ...[
              pw.Divider(),
              pw.Header(level: 2, text: 'Assumptions & Methodology'),
              pw.Paragraph(text: response['assumptions'].toString(), style: const pw.TextStyle(color: PdfColors.grey700)),
            ],
            
            pw.Footer(
               margin: const pw.EdgeInsets.only(top: 20),
               title: pw.Text('Generated by Cureonix AI • Confidential Pharmacological Intelligence',
                 style: const pw.TextStyle(color: PdfColors.grey500, fontSize: 10)
               )
            )
          ];
        },
      ),
    );

    try {
      final output = await getApplicationDocumentsDirectory();
      // Sanitize filename
      final sanitizedQuery = query.replaceAll(RegExp(r'[^\w\s]+'), '').trim().replaceAll(' ', '_');
      final file = File("${output.path}/Cureonix_Report_${sanitizedQuery}_${DateTime.now().millisecondsSinceEpoch}.pdf");
      await file.writeAsBytes(await pdf.save());

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Report saved to ${file.path}')),
        );
      }
      
      await OpenFilex.open(file.path);
      
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating PDF: $e')),
        );
      }
    }
  }

  pw.Widget _buildPdfHeader(String query, String timestamp) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('CUREONIX', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 24, color: PdfColors.blue900)),
            pw.Text('AI INTELLIGENCE REPORT', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14, color: PdfColors.teal)),
          ],
        ),
        pw.Divider(thickness: 2, color: PdfColors.blue900),
        pw.SizedBox(height: 10),
        pw.Text('Query: $query', style: pw.TextStyle(fontSize: 12, color: PdfColors.black)),
        pw.Text('Date: $timestamp', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }
}
