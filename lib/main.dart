import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:effeciofinal/pages/Home.dart';
import 'package:effeciofinal/pages/AIChat.dart';
import 'package:effeciofinal/pages/Schedule.dart';
import 'package:effeciofinal/pages/personalaccount.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await initializeDateFormatting('ru', null);
  await dotenv.load(fileName: ".env");
  runApp(EffecioApp());
}

class EffecioApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // title: 'Effecio',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    MainScreen(),
    HabitTrackerScreen(),
    AIChatScreen(),
    PersonalAccount(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /*appBar: AppBar(
        title: Text('Effecio'),
        centerTitle: true,
      ),*/
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today, color: Color(0xFFEE786B),),
            label: 'Tasks',
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart, color: Color(0xFFEE786B),),
              label: 'Habits',
              backgroundColor: Colors.white
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat,color: Color(0xFFEE786B)),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings,color: Color(0xFFEE786B)),
            label: 'Settings',
          ),
        ],
        selectedItemColor: Color(0xFFEE786B),
      ),
    );
  }
}
