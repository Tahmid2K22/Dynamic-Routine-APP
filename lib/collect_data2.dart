// ignore_for_file: non_constant_identifier_names

import 'package:gsheets/gsheets.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';


class DataModel {
  final String period;
  final String data;
  final String endTime;

  DataModel({
    required this.period,
    required this.data,
    required this.endTime,
  });
}

class CollectData {
  static Future<List<DataModel>> collectAllData() async {
    final credentials = await rootBundle.loadString('assets/secret.json');
    final spreadsheetId = "1-DXAmRORedneu1k1geGJxTTqWIIMD6af0eKwDtu8AT4";
    final gsheets = GSheets(credentials);
    final ss = await gsheets.spreadsheet(spreadsheetId);

    final sections = ['Section A', 'Section B', 'Assignments'];
    List<DataModel> allData = [];

    for (var section in sections) {
      final sheet = ss.worksheetByTitle(section);
      if (sheet == null) continue;

      DateTime now = DateTime.now();
      final weekdayes = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
      String day = weekdayes[now.weekday - 1];
      final values = await sheet.values.allRows();
      var filteredValues = values.firstWhere((row) => row[0] == day, orElse: () => []);
      final keys = values.first;

      for (var i = 0; i < keys.length; i++) {
        if (keys[i] == 'Day') continue;
        final periodTimes = keys[i].split('(')[1].split(')')[0];
        final endTime = periodTimes.split('-')[1];

        final time = DateFormat('hh:mm a').format(now);
        final parsedtime = DateFormat('hh:mm a').parse(time);
        final parsedEndTime = DateFormat('hh:mm a').parse(endTime);

        if (parsedtime.isBefore(parsedEndTime) && filteredValues[i] != '-') {
          allData.add(DataModel(period: keys[i], data: filteredValues[i], endTime: endTime));
        }
      }
    }

    if (allData.isEmpty) {
      allData.add(DataModel(period: 'No more', data: 'today', endTime: '11:59 PM'));
    }

    return allData;
  }
}
