// ignore_for_file: non_constant_identifier_names

import 'dart:convert';

import 'package:gsheets/gsheets.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;


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
  static Future<Map<String,List<List<String>>>> collectAllData() async {
    final scriptURL = "https://script.google.com/macros/s/AKfycbwV26WyUpb8zgfyWGlepwMP3JS3Vo6YamCIlYaJR03KGtdSDbIeqC80cFITkh04HjZfAQ/exec";
    var response = await http.get(Uri.parse(scriptURL));
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      return data.map((key, value) => MapEntry(
          key, (value as List).map((e) => (e as List).cast<String>()).toList()));
    } else {
      throw Exception('Failed to load data from Google Apps Script');
    }
  }
}
