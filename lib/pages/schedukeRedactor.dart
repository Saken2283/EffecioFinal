import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ScheduleScreen extends StatefulWidget {
  @override
  _ScheduleScreenState createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  TimeOfDay? startTime;
  TimeOfDay? endTime;
  TextEditingController taskController = TextEditingController();

  void _addTask(String title, TimeOfDay startTime, TimeOfDay endTime) {
    _firestore.collection('schedule').add({
      'title': title,
      'startTime': '${startTime.hour}:${startTime.minute}',
      'endTime': '${endTime.hour}:${endTime.minute}',
    });
  }

  void _deleteTask(String id) {
    _firestore.collection('schedule').doc(id).delete();
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          startTime = picked;
        } else {
          endTime = picked;
        }
      });
    }
  }

  void _showAddTaskDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Добавить задачу"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: taskController,
                decoration: InputDecoration(labelText: "Название задачи"),
              ),
              SizedBox(height: 10),
              GestureDetector(
                onTap: () => _selectTime(context, true),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    startTime == null
                        ? "Выбрать время начала"
                        : "Начало: ${startTime!.format(context)}",
                  ),
                ),
              ),
              SizedBox(height: 10),
              GestureDetector(
                onTap: () => _selectTime(context, false),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    endTime == null
                        ? "Выбрать время конца"
                        : "Конец: ${endTime!.format(context)}",
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Отмена"),
            ),
            ElevatedButton(
              onPressed: () {
                if (taskController.text.isNotEmpty &&
                    startTime != null &&
                    endTime != null) {
                  _addTask(taskController.text, startTime!, endTime!);
                  taskController.clear();
                  startTime = null;
                  endTime = null;
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
    return Scaffold(
      appBar: AppBar(title: Text("Расписание")),
      body: StreamBuilder(
        stream: _firestore.collection('schedule').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          return ListView(
            padding: EdgeInsets.all(16),
            children: snapshot.data!.docs.map((doc) {
              Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
              return Column(
                children: [
                  Row(
                    children: [
                      Text(data['startTime'], style: TextStyle(fontSize: 16)),
                      Expanded(
                        child: Divider(color: Colors.black, thickness: 1),
                      ),
                    ],
                  ),
                  ListTile(
                    title: Text(data['title'], style: TextStyle(fontSize: 18)),
                    subtitle: Text("${data['startTime']} - ${data['endTime']}"),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteTask(doc.id),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Divider(color: Colors.black, thickness: 1),
                      ),
                      Text(data['endTime'], style: TextStyle(fontSize: 16)),
                    ],
                  ),
                  SizedBox(height: 10),
                ],
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        child: Icon(Icons.add),
      ),
    );
  }
}
