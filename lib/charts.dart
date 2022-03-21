import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:winaday/domain.dart';
import 'package:winaday/theme.dart';
import 'package:winaday/view.dart';

import 'model.dart';

class DataPoint {
  final String label;
  final int value;
  final charts.Color color;

  DataPoint(this.label, this.value, this.color);
}

class LegendItem {
  final String label;
  final Color color;

  LegendItem(this.label, this.color);
}

List<charts.Color> winDayColors = [
  charts.Color(r: grey.red, g: grey.green, b: grey.blue),
  charts.Color(r: crayolaBlue.red, g: crayolaBlue.green, b: crayolaBlue.blue),
  charts.Color(
      r: brownsOrange.red, g: brownsOrange.green, b: brownsOrange.blue),
];

List<charts.Color> chartPriorityColors = priorityColors
    .map((c) => charts.Color(r: c.red, g: c.green, b: c.blue))
    .toList();

List<DataPoint> getWinDaysDataPoints(StatsModel model) {
  if (model.daysTotal == 0) {
    return [];
  }

  int daysWithWinsCount = 0;
  int daysWithAwesomeWinsCount = 0;
  for (var x in model.stats.items) {
    if (x.win.overallResult == OverallDayResult.gotMyWin) {
      daysWithWinsCount++;
    } else if (x.win.overallResult == OverallDayResult.awesomeAchievement) {
      daysWithAwesomeWinsCount++;
    }
  }

  return [
    DataPoint(
        'Days without wins',
        model.daysTotal - daysWithWinsCount - daysWithAwesomeWinsCount,
        winDayColors[0]),
    DataPoint('Days with wins', daysWithWinsCount, winDayColors[1]),
    DataPoint(
        'Awesome achievement days', daysWithAwesomeWinsCount, winDayColors[2]),
  ];
}

List<LegendItem> getWinDaysLegend(StatsModel model) {
  return [
    LegendItem('Days without wins', grey),
    LegendItem('Days with wins', crayolaBlue),
    LegendItem('Awesome achievement days', brownsOrange)
  ];
}

Map<String, int> getPriorityCounts(StatsModel model) {
  var priorityCounts = <String, int>{};
  for (var x in model.stats.items) {
    for (var p in x.win.priorities) {
      priorityCounts[p] = (priorityCounts[p] ?? 0) + 1;
    }
  }
  return priorityCounts;
}

List<DataPoint> getPriorityDataPoints(StatsModel model) {
  var priorityCounts = getPriorityCounts(model);
  var dataPoints = model.priorityList.items
      .map((p) => DataPoint(p.id, priorityCounts[p.id] ?? 0,
          chartPriorityColors[p.color % chartPriorityColors.length]))
      .where((dp) => dp.value > 0)
      .toList();

  dataPoints.sort((a, b) => b.value.compareTo(a.value));
  return dataPoints;
}

List<LegendItem> getPrioritiesLegend(StatsModel model) {
  var priorityCounts = getPriorityCounts(model);
  var prioritiesWithCounts = model.priorityList.items
      .where((p) => (priorityCounts[p.id] ?? 0) > 0)
      .map((p) => PriorityDataWithCount(p, priorityCounts[p.id] ?? 0))
      .toList();
  prioritiesWithCounts.sort((a, b) => b.count.compareTo(a.count));

  return prioritiesWithCounts
      .map((p) =>
          LegendItem(p.priority.text, getPriorityBoxColor(p.priority.color)))
      .toList();
}

@immutable
class PriorityDataWithCount extends Model {
  final PriorityData priority;
  final int count;

  const PriorityDataWithCount(this.priority, this.count);
}

List<LegendItem> getUnattendedPrioritiesLegend(StatsModel model) {
  var priorityCounts = getPriorityCounts(model);
  return model.priorityList.items
      .where((p) => (priorityCounts[p.id] ?? 0) == 0 && !p.deleted)
      .map((p) => LegendItem(p.text, getPriorityBoxColor(p.color)))
      .toList();
}

Widget pieChart(String id, List<DataPoint> dataPoints) {
  var seriesList = [
    charts.Series<DataPoint, String>(
      id: id,
      domainFn: (DataPoint dp, _) => dp.label,
      measureFn: (DataPoint dp, _) => dp.value,
      colorFn: (DataPoint dp, _) => dp.color,
      data: dataPoints,
    )
  ];

  return charts.PieChart(seriesList, animate: false);
}

Widget histograms(String id, List<DataPoint> dataPoints) {
  var seriesList = [
    charts.Series<DataPoint, String>(
      id: id,
      domainFn: (DataPoint dp, _) => dp.label,
      measureFn: (DataPoint dp, _) => dp.value,
      colorFn: (DataPoint dp, _) => dp.color,
      labelAccessorFn: (DataPoint dp, _) => dp.value.toString(),
      data: dataPoints,
    )
  ];

  return charts.BarChart(seriesList,
      animate: false,
      barRendererDecorator: charts.BarLabelDecorator<String>(),
      domainAxis: const charts.OrdinalAxisSpec(
          showAxisLine: true, renderSpec: charts.NoneRenderSpec()));
}

Widget legend(List<LegendItem> items) {
  return Column(
      children: items
          .map((x) => Padding(
              padding: const EdgeInsets.all(4.0),
              child: Row(children: [
                Container(
                    height: 32.0,
                    width: 32.0,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4.0),
                        color: x.color)),
                Flexible(
                    child: Wrap(children: [
                  Padding(
                      padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                      child: Text(x.label,
                          style: GoogleFonts.openSans(
                              textStyle:
                                  const TextStyle(fontSize: TEXT_FONT_SIZE))))
                ]))
              ])))
          .toList());
}
