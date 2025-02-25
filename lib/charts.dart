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

Map<String, int> getAnyDayPriorityCounts(StatsModel model) {
  var priorityCounts = <String, int>{};
  for (var x in model.stats.items) {
    for (var p in x.win.priorities) {
      priorityCounts[p] = (priorityCounts[p] ?? 0) + 1;
    }
  }
  return priorityCounts;
}

Map<String, int> getAwesomeDayPriorityCounts(StatsModel model) {
  var priorityCounts = <String, int>{};
  for (var x in model.stats.items) {
    if (x.win.overallResult == OverallDayResult.awesomeAchievement) {
      for (var p in x.win.priorities) {
        priorityCounts[p] = (priorityCounts[p] ?? 0) + 1;
      }
    }
  }
  return priorityCounts;
}

List<DataPoint> getAnyDayPriorityDataPoints(StatsModel model) {
  var priorityCounts = getAnyDayPriorityCounts(model);
  var dataPoints = model.priorityList.items
      .map((p) => DataPoint(p.id, priorityCounts[p.id] ?? 0,
          priorityColors[p.color % priorityColors.length]))
      .where((dp) => dp.value > 0)
      .toList();

  dataPoints.sort((a, b) => b.value.compareTo(a.value));
  return dataPoints;
}

List<DataPoint> getAwesomeDayPriorityDataPoints(StatsModel model) {
  var priorityCounts = getAwesomeDayPriorityCounts(model);
  var dataPoints = model.priorityList.items
      .map((p) => DataPoint(p.id, priorityCounts[p.id] ?? 0,
          priorityColors[p.color % priorityColors.length]))
      .where((dp) => dp.value > 0)
      .toList();

  dataPoints.sort((a, b) => b.value.compareTo(a.value));
  return dataPoints;
}

List<LegendItem> getAnyDayPrioritiesLegend(StatsModel model) {
  var priorityCounts = getAnyDayPriorityCounts(model);
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

List<LegendItem> getAwesomeDayPrioritiesLegend(StatsModel model) {
  var priorityCounts = getAwesomeDayPriorityCounts(model);
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

List<LegendItem> getAnyDayUnattendedPrioritiesLegend(StatsModel model) {
  var priorityCounts = getAnyDayPriorityCounts(model);
  return model.priorityList.items
      .where((p) => (priorityCounts[p.id] ?? 0) == 0 && !p.deleted)
      .map((p) => LegendItem(p.text, getPriorityBoxColor(p.color)))
      .toList();
}

List<LegendItem> getAwesomeDayUnattendedPrioritiesLegend(StatsModel model) {
  var priorityCounts = getAwesomeDayPriorityCounts(model);
  return model.priorityList.items
      .where((p) => (priorityCounts[p.id] ?? 0) == 0 && !p.deleted)
      .map((p) => LegendItem(p.text, getPriorityBoxColor(p.color)))
      .toList();
}

Widget pieChart(String id, List<DataPoint> dataPoints, double screenWidth) {
  if (dataPoints.isNotEmpty) {
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
  return Padding(
      padding: const EdgeInsets.only(top: 128), child: Text("No data"));
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
