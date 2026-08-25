import 'package:egpt/admin/source_admin.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class AdminStatistic extends StatefulWidget {
  const AdminStatistic({super.key});

  @override
  State<AdminStatistic> createState() => _AdminStatisticState();
}

class _AdminStatisticState extends State<AdminStatistic> {
  late final AdminSource admin;

  @override
  void initState() {
    super.initState();
    admin = context.read<AdminSource>();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<AdminSource>();
    final scheme = Theme.of(context).colorScheme;
    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  flex: 4,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        spacing: 8.0,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("${admin.register.members.length}",
                                style: TextStyle(
                                    fontSize: 28.0,
                                    fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text("membri attivi"),
                            ],
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12.0),
                            child: Divider(),
                          ),
                          Column(
                            children: [
                              const Text("Migliore",
                                style:TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text("100%"),
                            ],
                          ),
                          Column(
                            children: [
                              const Text("Peggiore",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text("0%"),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Center(
                        child: Column(
                          spacing: 8.0,
                          children: [
                            AspectRatio(
                              aspectRatio: 1,
                              child: PieChart(
                                PieChartData(
                                  sections: [
                                    PieChartSectionData(
                                      value: 43,
                                      color: scheme.primary,
                                    ),
                                    PieChartSectionData(
                                      value: 3,
                                      color: scheme.secondary,
                                    ),
                                    PieChartSectionData(
                                      value: 5,
                                      color: scheme.tertiary,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Wrap(
                              direction: Axis.horizontal,
                              alignment: WrapAlignment.center,
                              runAlignment: WrapAlignment.spaceBetween,
                              spacing: 24,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 16,
                                      height: 16,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: scheme.primary,
                                      ),
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.only(left: 8.0),
                                      child: Text('Attivi'),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 16,
                                      height: 16,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: scheme.secondary,
                                      ),
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.only(left: 8.0),
                                      child: Text('Scadenza'),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 16,
                                      height: 16,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: scheme.tertiary,
                                      ),
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.only(left: 8.0),
                                      child: Text('Inattivi'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: AspectRatio(
                aspectRatio: 1.8,
                child: LineChart(
                  LineChartData(
                    lineBarsData: [
                      LineChartBarData(
                        barWidth: 4,
                        isStrokeCapRound: true,
                        dotData: const FlDotData(show: false),
                        // belowBarData: BarAreaData(show: false),
                        spots: const [
                        FlSpot(1, 1/4),
                        FlSpot(3, 1.5/4),
                        FlSpot(5, 1.4/4),
                        FlSpot(7, 3.4/4),
                        FlSpot(10, 2/4),
                        FlSpot(12, 2.2/4),
                        FlSpot(13, 1.8/4),
                        ],
                      )
                    ],
                    minX: 0,
                    maxX: 14,
                    maxY: 1,
                    minY: 0,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
