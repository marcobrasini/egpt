import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:egpt/sources/sources.dart';
import 'package:egpt/style.dart';
import 'source_admin.dart';


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
    final register = context.watch<RegisterSource>();
    final scheme = Theme.of(context).colorScheme;
    return SliverMainAxisGroup(
      slivers: [
        SliverAppBar(
          automaticallyImplyActions: false,
          automaticallyImplyLeading: false,
          centerTitle: true,
          title:  const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child:Text("Membri e abbonamenti",
              style: TextStyle(fontSize: 24.0),
            ),
          ),
        ),
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
                              Text("${register.activeMembers}",
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
                              if (register.bestMember() case final best?) Text(
                                  '${best.member.name} '
                                      '${(best.ratio * 100).toStringAsFixed(0)}%'
                              ) else Text("-"),
                            ],
                          ),
                          Column(
                            children: [
                              const Text("Peggiore",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              if (register.worstMember() case final worst?) Text(
                                  '${worst.member.name} '
                                  '${(worst.ratio * 100).toStringAsFixed(0)}%'
                              ) else Text("-"),
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
                                      value: register.activeMembers.toDouble(),
                                      color: scheme.primary,
                                    ),
                                    PieChartSectionData(
                                      value: register.warningMembers.toDouble(),
                                      color: scheme.warning,
                                    ),
                                    PieChartSectionData(
                                      value: register.stoppedMembers.toDouble(),
                                      color: scheme.neutral,
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
                                        color: scheme.warning,
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
                                        color: scheme.neutral,
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
      ],
    );
  }
}
