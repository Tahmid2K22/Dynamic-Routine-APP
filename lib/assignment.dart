// ignore_for_file: camel_case_types

import 'package:flutter/material.dart';
import 'Routine Dynamic page.dart' show ViewCard;

class assignmentClass extends StatelessWidget {
  final List<List<String>> assn;
  const assignmentClass({super.key, required this.assn});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 137, 0, 161),
          elevation: 10,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(20),
            ),
          ),
          title: const Text(
            'Assignment & Project',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      body: Center(
        child: Column(
          children: <Widget>[
            const SizedBox(height: 20.0),
            Expanded(
                child:  ListView.builder(
                  itemCount: assn.length,
                  itemBuilder: (context, index) {
                    return ViewCard(
                      title: 'Assignment ${index + 1}',
                      description: assn[index][0],
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}