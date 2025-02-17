import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:effeciofinal/pages/schedukeRedactor.dart';
import 'package:effeciofinal/pages/HabitTracker.dart';

class HabitTrackerScreen extends StatefulWidget {
  @override
  _HabitTrackerScreenState createState() => _HabitTrackerScreenState();
}

class _HabitTrackerScreenState extends State<HabitTrackerScreen> {
  int _currentDayIndex = 15;
  final List<DateTime> _dates =
  List.generate(30, (index) => DateTime.now().add(Duration(days: index - 15)));

  void _changeDay(int offset) {
    setState(() {
      _currentDayIndex += offset;
      _currentDayIndex = _currentDayIndex.clamp(2, _dates.length - 3);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 56.0, horizontal: 24.0),
            decoration: BoxDecoration(
              color: Color(0xFFFF7F7F),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
                topRight: Radius.circular(30),
                topLeft: Radius.circular(30),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => _changeDay(-1),
                      child: Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    Text(
                      DateFormat('MMMM').format(_dates[_currentDayIndex]),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _changeDay(1),
                      child: Icon(Icons.arrow_forward, color: Colors.white),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(5, (i) {
                    int index = _currentDayIndex + i - 2;
                    return Container(
                      width: 60,
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                      decoration: BoxDecoration(
                        color: index == _currentDayIndex ? Colors.white : Color(0xFFFFB5B5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          Text(
                            DateFormat('E').format(_dates[index]),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: index == _currentDayIndex ? Color(0xFFFF7F7F) : Colors.white,
                            ),
                          ),
                          Text(
                            DateFormat('d').format(_dates[index]),
                            style: TextStyle(
                              fontSize: 16,
                              color: index == _currentDayIndex ? Color(0xFFFF7F7F) : Colors.white,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              children: [
                Text(
                  '${DateFormat('E, MMM d').format(_dates[_currentDayIndex])} Tasks',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 16),

                /// 🔹 Кнопки для перехода
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HabitScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFF7F7F),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    "Перейти в Habit Tracker",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),

                SizedBox(height: 12),

                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ScheduleScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFF7F7F),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    "Перейти в Расписание",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
