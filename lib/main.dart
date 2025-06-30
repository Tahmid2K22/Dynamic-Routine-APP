// ignore_for_file: non_constant_identifier_names


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'collect_data.dart' show CollectData, DataModel;
import 'Routine Dynamic page.dart';
import 'assignment.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'static_routine.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';


List<List<String>> allData = [];
List<DataModel> dataA = [];
List<DataModel> dataB = [];
List<List<String>> sectionA_data = [];
List<List<String>> sectionB_data = [];
List<Widget> pages = [];
List<List<String>> assn = [];
String section = 'Section B';

List<DataModel> collectSecData({required List<List<String>> Data}){

    List<DataModel> allData = [];

      DateTime now = DateTime.now();
      final weekdayes = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
      String day = weekdayes[now.weekday - 1];
      final values = Data;
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

    if(allData.isEmpty) {
      allData.add(DataModel(period: 'No more', data: 'today', endTime: '11:59 PM'));
    }

    return allData;
  }


clearData() {
  allData.clear();
  dataA.clear();
  dataB.clear();
  sectionA_data.clear();
  sectionB_data.clear();
  assn.clear();
}

Future<String> getSection() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? section = prefs.getString('section');
  return section ?? 'Section B';
}

fetchData() async{
  final dynamic results = await CollectData.collectAllData();

  sectionB_data = results['sheet1'];
  sectionA_data = results['sheet2'];
  dataA= collectSecData(Data: sectionA_data);
  dataB= collectSecData(Data: sectionB_data);
  assn = results['sheet3'];
  section = await getSection();

  pages = [
    Routine(dataA: dataA, dataB: dataB),
    Routine_table_view(sectionA: sectionA_data, sectionB: sectionB_data),
    assignmentClass(assn: assn),
  ];

}


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final List<ConnectivityResult> connectivityResult = await (Connectivity().checkConnectivity());
  if(connectivityResult.contains(ConnectivityResult.none)){
    runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Text('No Internet Connection'),
        ),
      ),
    ));
    return;
  }
 
  //await fetchData();
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: splashScreen(),
  ));
}

class splashScreen extends StatefulWidget {
  const splashScreen({super.key});

  @override
  State<splashScreen> createState() => _splashScreenState();
}

class _splashScreenState extends State<splashScreen> {
  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: fetchData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            color: Colors.white,
            child: Center(
              child: Image.asset('assets/icon.png', height: 350, width: 350),
            ),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text('Error: ${snapshot.error}'),
            ),
          );
        } else {
          return BottomNavBar();
        }
      },
    );
  }
}

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> with WidgetsBindingObserver {
  int _page = 0;
  final GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose(){
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  @override
  void didChangeAppLifecycleState(AppLifecycleState state){
    super.didChangeAppLifecycleState(state);
    if(state == AppLifecycleState.resumed){
      setState(() {
        debugPrint('Resumed');
        SystemNavigator.pop();
        clearData();
        fetchData();
      });      
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CurvedNavigationBar(
        key: _bottomNavigationKey,
        index: 0,
        items: <Widget>[
          Icon(Icons.looks_one, size: 20),
          Icon(Icons.looks_two, size: 20),
          Icon(Icons.looks_3, size: 20),
        ],
        color: Colors.white,
        buttonBackgroundColor: Colors.white,
        backgroundColor: Colors.blueAccent,
        animationCurve: Curves.easeInOut,
        animationDuration: Duration(milliseconds: 600),
        onTap: (index) {
          setState(() {
            _page = index;
          });
        },
        letIndexChange: (index) => true,
      ),
      body: pages[_page],
    );
  }
}
