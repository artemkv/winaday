import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'domain.dart';
import 'theme.dart';
import 'view.dart';
import 'dateutil.dart';
import 'model.dart';

@immutable
class DataPoint<T> {
  final T label;
  final int value;
  final charts.Color color;

  const DataPoint(this.label, this.value, this.color);
}

@immutable
class LegendItem {
  final String label;
  final Color color;

  const LegendItem(this.label, this.color);
}

@immutable
class PriorityDataWithCount extends Model {
  final PriorityData priority;
  final int count;

  const PriorityDataWithCount(this.priority, this.count);
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

charts.Color toChartColor(int color) {
  return chartPriorityColors[color % chartPriorityColors.length];
}

List<DataPoint<String>> getWinDaysDataPoints(MonthlyStatsModel model) {
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

List<DataPoint<int>> getCumulativePriorityDataPoints(
    MonthlyStatsModel model, PriorityData priority) {
  var prioritiesByDays = {
    for (var x in model.stats.items) x.date.toCompact(): x.win.priorities
  };

  var dataPoints = <DataPoint<int>>[];

  int dayIndex = 1;
  int counter = 0;
  var day = model.from;
  while (day.isBefore(model.to) || day.isSameDate(model.to)) {
    var prioritiesOnDay = prioritiesByDays[day.toCompact()];
    if (prioritiesOnDay != null && prioritiesOnDay.contains(priority.id)) {
      counter++;
    }
    dataPoints.add(DataPoint(dayIndex, counter, toChartColor(priority.color)));
    day = day.nextDay();
    dayIndex++;
  }

  return dataPoints;
}

List<List<DataPoint<int>>> getCumulativePrioritySeries(
    MonthlyStatsModel model) {
  var priorityCounts = getPriorityCounts(model);

  var series = model.priorityList.items
      .where((p) => (priorityCounts[p.id] ?? 0) > 0)
      .map((p) => getCumulativePriorityDataPoints(model, p))
      .toList();
  return series;
}

List<LegendItem> getWinDaysLegend(MonthlyStatsModel model) {
  return [
    LegendItem('Days without wins', grey),
    LegendItem('Days with wins', crayolaBlue),
    LegendItem('Awesome achievement days', brownsOrange)
  ];
}

Map<String, int> getPriorityCounts(MonthlyStatsModel model) {
  var priorityCounts = <String, int>{};
  for (var x in model.stats.items) {
    for (var p in x.win.priorities) {
      priorityCounts[p] = (priorityCounts[p] ?? 0) + 1;
    }
  }
  return priorityCounts;
}

List<DataPoint<String>> getPriorityDataPoints(MonthlyStatsModel model) {
  var priorityCounts = getPriorityCounts(model);
  var dataPoints = model.priorityList.items
      .map((p) =>
          DataPoint(p.id, priorityCounts[p.id] ?? 0, toChartColor(p.color)))
      .where((dp) => dp.value > 0)
      .toList();

  dataPoints.sort((a, b) => b.value.compareTo(a.value));
  return dataPoints;
}

List<LegendItem> getPrioritiesLegend(MonthlyStatsModel model) {
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

List<LegendItem> getUnattendedPrioritiesLegend(MonthlyStatsModel model) {
  var priorityCounts = getPriorityCounts(model);
  return model.priorityList.items
      .where((p) => (priorityCounts[p.id] ?? 0) == 0 && !p.deleted)
      .map((p) => LegendItem(p.text, getPriorityBoxColor(p.color)))
      .toList();
}

Widget pieChart(String id, List<DataPoint<String>> dataPoints) {
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

Widget histograms(String id, List<DataPoint<String>> dataPoints) {
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

Widget cumulative(String id, List<List<DataPoint<int>>> series) {
  var seriesList = series
      .map((dataPoints) => charts.Series<DataPoint, int>(
            id: id,
            domainFn: (DataPoint dp, _) => dp.label,
            measureFn: (DataPoint dp, _) => dp.value,
            colorFn: (DataPoint dp, _) => dp.color,
            //areaColorFn: (DataPoint dp, _) => dp.color,
            labelAccessorFn: (DataPoint dp, _) => dp.value.toString(),
            data: dataPoints,
          ))
      .toList();

  return charts.LineChart(
    seriesList,
    animate: false,
    defaultRenderer:
        charts.LineRendererConfig(includeArea: false, stacked: false),
  );
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
