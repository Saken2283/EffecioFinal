import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class HabitScreen extends StatefulWidget {
  @override
  _HabitTrackerScreenState createState() => _HabitTrackerScreenState();
}

class _HabitTrackerScreenState extends State<HabitScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  TextEditingController habitController = TextEditingController();
  DateTime selectedMonth = DateTime.now();

  void _addHabit(String habitName) {
    String monthKey = DateFormat('yyyy-MM').format(selectedMonth);
    _firestore.collection('habits').add({
      'name': habitName,
      'month': monthKey,
      'progress': {},
    });
  }

  void _toggleDay(String id, String date, Map<String, dynamic> progress) {
    progress[date] = !(progress[date] ?? false);
    _firestore.collection('habits').doc(id).update({'progress': progress});
  }

  void _deleteHabit(String id) {
    _firestore.collection('habits').doc(id).delete();
  }

  void _showAddHabitDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Добавить привычку"),
          content: TextField(
            controller: habitController,
            decoration: InputDecoration(labelText: "Название"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Отмена"),
            ),
            ElevatedButton(
              onPressed: () {
                if (habitController.text.isNotEmpty) {
                  _addHabit(habitController.text);
                  habitController.clear();
                  Navigator.pop(context);
                }
              },
              child: Text("Добавить"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    String monthKey = DateFormat('yyyy-MM').format(selectedMonth);
    int daysInMonth = DateTime(selectedMonth.year, selectedMonth.month + 1, 0).day;

    return Scaffold(
      appBar: AppBar(
        title: Text("Трекер привычек"),
        actions: [
          IconButton(
            icon: Icon(Icons.arrow_left),
            onPressed: () => setState(() {
              selectedMonth = DateTime(selectedMonth.year, selectedMonth.month - 1, 1);
            }),
          ),
          Text(DateFormat('MMMM yyyy', 'ru').format(selectedMonth),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          IconButton(
            icon: Icon(Icons.arrow_right),
            onPressed: () => setState(() {
              selectedMonth = DateTime(selectedMonth.year, selectedMonth.month + 1, 1);
            }),
          ),
        ],
      ),
      body: StreamBuilder(
        stream: _firestore
            .collection('habits')
            .where('month', isEqualTo: monthKey)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          return ListView(
            padding: EdgeInsets.all(16),
            children: snapshot.data!.docs.map((doc) {
              Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
              return Card(
                margin: EdgeInsets.only(bottom: 16),
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              data['name'],
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteHabit(doc.id),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: List.generate(daysInMonth, (index) {
                          String date = DateFormat('yyyy-MM-dd').format(
                            DateTime(selectedMonth.year, selectedMonth.month, index + 1),
                          );
                          bool isChecked = data['progress'][date] ?? false;
                          return GestureDetector(
                            onTap: () =>
                                _toggleDay(doc.id, date, Map.from(data['progress'])),
                            child: Container(
                              width: 30,
                              height: 30,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: isChecked ? Colors.blueAccent : Colors.grey[300],
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                "${index + 1}",
                                style: TextStyle(
                                  color: isChecked ? Colors.white : Colors.black,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddHabitDialog,
        child: Icon(Icons.add),
        backgroundColor: Colors.blueAccent,
      ),
      backgroundColor: Colors.grey[200],
    );
  }
}

