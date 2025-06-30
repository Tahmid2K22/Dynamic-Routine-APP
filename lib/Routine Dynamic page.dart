import 'package:flutter/material.dart';
import 'collect_data.dart';
import 'package:shared_preferences/shared_preferences.dart';
getSection() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? section = prefs.getString('section');
  return section ?? 'Section B';
}

setString(String section) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('section', section);
}

class Routine extends StatefulWidget {
  final List<DataModel> dataA,dataB;
  //final String section;
  const Routine({super.key, required this.dataA, required this.dataB});

  @override
  State<Routine> createState() => _RoutineState();
}

class _RoutineState extends State<Routine> {
  late String select_sec;
  List<DataModel> data = List.empty();




  @override
  void initState() {
    super.initState();
    getSection().then((section) {
      setState(() {
        select_sec = section;
        //debugPrint(select_sec);
        if (select_sec == "Section A") {
          data = widget.dataA;
        } else {
          data = widget.dataB;
        }
        if(data.isEmpty){
          data = [DataModel(period: 'Loading...', data: '', endTime: '')];
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dynamic Routine',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 137, 0, 161),
          elevation: 10,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(20),
            ),
          ),
          title: const Text(
            'Routine Upcoming',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 20.0),
              DropdownButton<String>(
                value: select_sec = data == widget.dataA? "Section A" : "Section B",
                style: const TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                focusColor: Colors.white,
                items: <String>['Section A', 'Section B'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) async {
                  if (newValue != null) {
                    if(mounted){
                    setState(() {
                      select_sec = newValue;
                      if(select_sec == "Section A"){
                        data = widget.dataA;
                      }else{
                        data = widget.dataB;
                      }
                    }
                    );
                    }
                    await setString(select_sec);
                  }
                },
              ),  
              const SizedBox(height: 20.0),
              Expanded(
                child:  ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    return ViewCard(
                      title: data[index].period,
                      description: data[index].data,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ViewCard extends StatelessWidget {
  final String title;
  final String description;

  const ViewCard({super.key, required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        margin: const EdgeInsets.only(left: 15.0, right: 15.0, top: 0.0, bottom: 10.0),
        elevation: 5.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 32, 0, 83),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 10.0),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 16.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
