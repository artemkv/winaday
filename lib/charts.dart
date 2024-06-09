import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'model.dart';
import 'domain.dart';
import 'theme.dart';
import 'view.dart';

class DataPoint {
  final String label;
  final int value;
  final Color color;

  DataPoint(this.label, this.value, this.color);
}

class LegendItem {
  final String label;
  final Color color;

  LegendItem(this.label, this.color);
}

List<Color> winDayColors = [grey, crayolaBlue, brownsOrange];

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
          priorityColors[p.color % priorityColors.length]))
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

Widget pieChart(String id, List<DataPoint> dataPoints, double screenWidth) {
  return PieChart(PieChartData(
      sectionsSpace: 2,
      centerSpaceRadius: 0,
      sections: dataPoints
          .map(
            (dp) => PieChartSectionData(
                value: dp.value.toDouble(),
                title: dp.value.toString(),
                radius: screenWidth / 3.2,
                titleStyle: const TextStyle(
                    color: Colors.white, fontSize: TEXT_FONT_SIZE),
                color: dp.color),
          )
          .toList()));
}

Widget histograms(String id, List<DataPoint> dataPoints) {
  var interval = 1.0;
  if (dataPoints.isNotEmpty) {
    var values = dataPoints.map((dp) => dp.value).toList();
    var max = values.reduce((a, b) => a > b ? a : b).toDouble();
    interval = (max / 3.5).floor().toDouble();
    if (interval < 1.0) {
      interval = 1.0;
    }
  }

  return BarChart(
    BarChartData(
        titlesData: FlTitlesData(
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
                sideTitles: SideTitles(
                    showTitles: true, reservedSize: 32, interval: interval))),
        borderData: FlBorderData(
            border: Border(
                bottom: BorderSide(width: 1, color: grey),
                top: BorderSide(width: 1, color: grey))),
        gridData:
            FlGridData(drawVerticalLine: false, horizontalInterval: interval),
        barGroups: dataPoints
            .asMap()
            .entries
            .map((e) => BarChartGroupData(x: e.key, barRods: [
                  BarChartRodData(
                      toY: e.value.value.toDouble(),
                      width: 16,
                      borderRadius: const BorderRadius.all(Radius.zero),
                      color: e.value.color),
                ]))
            .toList()),
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
