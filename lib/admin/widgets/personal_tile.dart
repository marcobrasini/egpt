import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:flutter_calendar_agenda/flutter_calendar_agenda.dart';
import 'package:egpt/sources/sources.dart';
import 'package:egpt/models/models.dart';
import 'package:egpt/style.dart';
import 'presence_list.dart';


class PersonalTile extends StatefulWidget {
  const PersonalTile(this.productId, {
    required this.open,
    super.key,
  });

  final String productId;
  final VoidCallback open;

  @override
  State<PersonalTile> createState() => _PersonalTileState();
}

class _PersonalTileState extends State<PersonalTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context){
    return Selector<PersonalSource, (Product, List<Session>)>(
      selector: (_, personal) {
        final product = personal.product(widget.productId);
        final sessions = personal.sessions(widget.productId);
        return (product, sessions);
      },
      builder: (context, data, _) {
        final (product, sessions) = data;
        final scheme = Theme.of(context).colorScheme;
        return GestureDetector(
          onTap: () => setState(() => _expanded = !_expanded),
          onLongPress: widget.open,
            child: Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                children: [
                  Row(
                    spacing: 16.0,
                    children: [
                      Stack(
                        alignment: AlignmentDirectional.center,
                        children: [
                          CircularPercentIndicator(
                            radius: 26,
                            lineWidth: 6,
                            percent: product.pastDays / product.duration,
                            progressColor: statusColor(product, scheme),
                            backgroundColor: scheme.neutral,
                          ),
                          CircularPercentIndicator(
                            radius: 34,
                            lineWidth: 6,
                            center: FaIcon(statusSymbol(product)),
                            percent: product.done/product.length,
                            progressColor: statusColor(product, scheme),
                            backgroundColor: scheme.neutral,
                          ),
                        ],
                      ),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.summary,
                              style: TextStyle(fontSize: 18.0),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                            Divider(),
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Inizio: ${product.start.format("dd/MM/yyyy")}"),
                                    Text("Fine:   ${product.stop.format("dd/MM/yyyy")}"),
                                  ],
                                ),
                                Text(product.recap,
                                  style: TextStyle(fontSize: 16.0),
                                ),
                              ],
                            ),
                          ],
                        )
                      ),
                    ]
                  ),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    alignment: Alignment.topCenter,
                    child: (_expanded)
                        ? Column(
                          children: [
                            const Divider(),
                            SessionList(
                              sessions: sessions,
                            ),
                          ],
                        )
                        : const SizedBox(width: double.infinity),
                  ),
                ]
              ),
            ),
          ),
        );
      },
    );
  }
}
