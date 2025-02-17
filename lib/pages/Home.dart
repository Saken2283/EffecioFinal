import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class MainScreen extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<MainScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  late ValueNotifier<List<Map<String, dynamic>>> _selectedEvents;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _selectedEvents = ValueNotifier<List<Map<String, dynamic>>>([]);
    _selectedDay = _focusedDay;
    _loadEventsForDay(_selectedDay!);
  }

  Future<void> _loadEventsForDay(DateTime day) async {
    String formattedDate = DateFormat('yyyy-MM-dd').format(day);
    QuerySnapshot snapshot = await _firestore
        .collection('events')
        .where('date', isEqualTo: formattedDate)
        .get();

    _selectedEvents.value =
        snapshot.docs.map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>}).toList();
  }

  Future<void> _addEvent(String task) async {
    if (_selectedDay == null) return;
    String formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDay!);
    await _firestore.collection('events').add({
      'task': task,
      'date': formattedDate,
      'timestamp': FieldValue.serverTimestamp(),
    });
    _loadEventsForDay(_selectedDay!);
  }

  Future<void> _deleteEvent(String eventId) async {
    await _firestore.collection('events').doc(eventId).delete();
    _loadEventsForDay(_selectedDay!);
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Good Morning, User!', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFFEE786B),
        centerTitle: true,
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 01, 01),
            lastDay: DateTime.utc(2025, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
                _loadEventsForDay(selectedDay);
              });
            },
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
              selectedDecoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle),
            ),
            headerStyle: HeaderStyle(formatButtonVisible: false),
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(16.0),
              child: ValueListenableBuilder<List<Map<String, dynamic>>>(
                valueListenable: _selectedEvents,
                builder: (context, events, _) {
                  return ListView.builder(
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      final event = events[index];
                      return TaskCard(
                        task: event['task'],
                        onDelete: () => _deleteEvent(event['id']),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEventDialog(),
        child: Icon(Icons.add),
        backgroundColor: Color(0xFFEE786B),
      ),
    );
  }

  void _showAddEventDialog() {
    TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Event'),
          content: TextField(controller: controller, decoration: InputDecoration(hintText: 'Enter task')),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  _addEvent(controller.text);
                  Navigator.pop(context);
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }
}

class TaskCard extends StatelessWidget {
  final String task;
  final VoidCallback onDelete;

  const TaskCard({required this.task, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading: Icon(Icons.check_circle_outline, color: Color(0xFFEE786B)),
        title: Text(task, style: TextStyle(fontWeight: FontWeight.bold)),
        trailing: IconButton(
          icon: Icon(Icons.delete, color: Colors.red),
          onPressed: onDelete,
        ),
      ),
    );
  }
}
