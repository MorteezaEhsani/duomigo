import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class FeedbackScreen extends StatelessWidget {
  final Map<String, dynamic> data;
  const FeedbackScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final transcript = (data['transcript'] ?? '') as String;

    // rubric: {fluency, pronunciation, grammar, vocabulary, coherence, task}
    final rubric = Map<String, num>.from(data['rubric'] ?? {});
    final rubricLabels = <String>[
      'fluency',
      'pronunciation',
      'grammar',
      'vocabulary',
      'coherence',
      'task',
    ];
    final rubricValues = rubricLabels
        .map((k) => rubric[k]?.toDouble() ?? 0.0)
        .toList();

    // metrics
    final metrics = Map<String, dynamic>.from(data['metrics'] ?? {});
    final wpm = (metrics['wordsPerMinute'] ?? 0).toDouble();
    final fillerPerMin = (metrics['fillerPerMin'] ?? 0).toDouble();
    final ttr = (metrics['typeTokenRatio'] ?? 0.0).toDouble(); // 0..1

    final overall = (data['overall'] ?? 0) as int;
    final cefr = (data['cefr'] ?? '') as String;
    final actionPlan = List<String>.from(data['actionPlan'] ?? const []);
    final grammarIssues = List<Map<String, dynamic>>.from(
      data['grammarIssues'] ?? const [],
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Feedback')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Overall: $overall',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                _CefrBadge(cefr: cefr),
              ],
            ),
            const SizedBox(height: 16),

            // Radar chart for rubric
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Theme.of(context).dividerColor),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Speaking Subscores',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 260,
                      child: RadarChart(
                        RadarChartData(
                          radarBackgroundColor: Colors.transparent,
                          borderData: FlBorderData(show: false),
                          radarBorderData: const BorderSide(width: 1),
                          titleTextStyle: Theme.of(context).textTheme.bodySmall,
                          tickCount: 5,
                          ticksTextStyle: Theme.of(context).textTheme.bodySmall,
                          tickBorderData: const BorderSide(width: 0.5),
                          gridBorderData: const BorderSide(width: 0.5),
                          radarShape: RadarShape.polygon,
                          dataSets: [
                            RadarDataSet(
                              entryRadius: 1,
                              fillColor: Theme.of(
                                context,
                              ).colorScheme.primary.withOpacity(0.2),
                              borderColor: Theme.of(
                                context,
                              ).colorScheme.primary,
                              borderWidth: 2,
                              dataEntries: rubricValues
                                  .map(
                                    (v) => RadarEntry(value: v.clamp(0, 100)),
                                  )
                                  .toList(),
                            ),
                          ],
                          getTitle: (index, angle) {
                            final label =
                                rubricLabels[index % rubricLabels.length];
                            return RadarChartTitle(
                              text: _pretty(label),
                              positionPercentageOffset: 0.05,
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Metrics bar chart
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Theme.of(context).dividerColor),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Delivery Metrics',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'WPM, fillers/min (lower is better), and lexical diversity (TTR).',
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 180,
                      child: BarChart(
                        BarChartData(
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                          ),
                          borderData: FlBorderData(show: false),
                          titlesData: FlTitlesData(
                            leftTitles: const AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 32,
                              ),
                            ),
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  final i = value.toInt();
                                  final labels = ['WPM', 'Fillers/min', 'TTR'];
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 6),
                                    child: Text(
                                      labels[i],
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          barGroups: [
                            BarChartGroupData(
                              x: 0,
                              barRods: [
                                BarChartRodData(
                                  toY: wpm,
                                  width: 18,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ],
                            ),
                            BarChartGroupData(
                              x: 1,
                              barRods: [
                                BarChartRodData(
                                  toY: fillerPerMin,
                                  width: 18,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ],
                            ),
                            BarChartGroupData(
                              x: 2,
                              barRods: [
                                BarChartRodData(
                                  toY: ttr * 100,
                                  width: 18,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Transcript
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Theme.of(context).dividerColor),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Transcript',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(transcript),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Grammar Issues
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Theme.of(context).dividerColor),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Grammar Suggestions',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    if (grammarIssues.isEmpty)
                      const Text('No major grammar issues detected.')
                    else
                      Column(
                        children: grammarIssues.map((g) {
                          final before = (g['before'] ?? '').toString();
                          final after = (g['after'] ?? '').toString();
                          final exp = (g['explanation'] ?? '').toString();
                          return ListTile(
                            leading: const Icon(Icons.edit),
                            title: Text('$before  →  $after'),
                            subtitle: Text(exp),
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Action Plan
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Theme.of(context).dividerColor),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Action Plan (next attempt)',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    for (final tip in actionPlan)
                      ListTile(
                        dense: true,
                        visualDensity: VisualDensity.compact,
                        leading: const Icon(Icons.check_circle_outline),
                        title: Text(tip),
                        contentPadding: EdgeInsets.zero,
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _pretty(String k) =>
      k.substring(0, 1).toUpperCase() + k.substring(1).replaceAll('_', ' ');
}

class _CefrBadge extends StatelessWidget {
  final String cefr;
  const _CefrBadge({required this.cefr});

  @override
  Widget build(BuildContext context) {
    final color = switch (cefr) {
      'A1' || 'A2' => Colors.orange,
      'B1' => Colors.amber,
      'B2' => Colors.teal,
      'C1' => Colors.indigo,
      'C2' => Colors.purple,
      _ => Colors.grey,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        'CEFR: $cefr',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(color: color),
      ),
    );
  }
}
