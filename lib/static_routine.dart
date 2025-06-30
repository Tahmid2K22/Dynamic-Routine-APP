// ignore_for_file: must_be_immutable, camel_case_types

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

getSection() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? section = prefs.getString('section');
  return section ?? 'Section B';
}

setSection(String section) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('section', section);
}

class Routine_table_view extends StatefulWidget {
  final List<List<String>> sectionA;
  final List<List<String>> sectionB;
  final List<DataRow> rows1;
  final List<DataRow> rows2;
  List<DataRow> rows = [];

  Routine_table_view({super.key, required this.sectionA, required this.sectionB}):
      //if(sectionA.isEmpty || sectionB.isEmpty) throw ArgumentError('sectionA and sectionB cannot be empty'),
      rows1 = List.generate((sectionA.length), (index) {
          return DataRow(
              cells: List.generate(sectionA[index].length, (cellIndex) {
            return DataCell(Text(sectionA[index][cellIndex]));
          }));
        }),
        rows2 = List.generate(sectionB.length, (index) {
          return DataRow(
              cells: List.generate(sectionB[index].length, (cellIndex) {
            return DataCell(Text(sectionB[index][cellIndex]));
          }));
        });

  @override
  State<Routine_table_view> createState() => _Routine_table_viewState();
}

class _Routine_table_viewState extends State<Routine_table_view> {
  @override
  void initState() {
    super.initState();
    getSection().then((value) {
      setState(() {
        widget.rows = value == 'Section A' ? widget.rows1 : widget.rows2;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Routine Table',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar:AppBar(
          backgroundColor: const Color.fromARGB(255, 137, 0, 161),
          elevation: 10,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(20),
            ),
          ),
          title: const Text(
            'Routine',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              DropdownButton<String>(
                value: widget.rows == widget.rows1 ? 'Section A' : 'Section B',
                items: <String>['Section A', 'Section B'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    widget.rows = newValue == 'Section A' ? widget.rows1 : widget.rows2;
                    if (newValue != null) {
                      setSection(newValue);
                    }
                  });
                },
              ),
              SizedBox(height: 20.0),
              Expanded(
                child: DataTable2(
                  columnSpacing: 20,
                  horizontalMargin: 12,
                  minWidth: 1000,
                  headingRowHeight: 0,
                  dividerThickness: 2,
                  fixedLeftColumns: 1,
                  dataRowHeight: widget.rows.isNotEmpty
                      ? widget.rows
                          .map((row) => row.cells
                              .map((cell) => (cell.child as Text).data?.length ?? 0)
                              .reduce((a, b) => a > b ? a : b))
                          .reduce((a, b) => a > b ? a : b)
                          .toDouble() * 2
                      : 56.0,
                  columns: List.generate(widget.sectionA[0].length, (index) {
                   // widget.sectionA[0][index] = (widget.sectionA[0][index].split('(')[1].split(')')[0]);
                    return DataColumn2(
                      label: Text(widget.sectionA[0][index]),
                      size: ColumnSize.L);
                  }),
                  rows: widget.rows,
                ),
              ),
              SizedBox(height: 20.0),
            ],
          ),
        ),
      ),
    );
  }
}
