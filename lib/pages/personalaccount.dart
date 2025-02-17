import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:percent_indicator/percent_indicator.dart';

class PersonalAccount extends StatefulWidget {
  @override
  _PersonalAccountState createState() => _PersonalAccountState();
}

class _PersonalAccountState extends State<PersonalAccount> {
  double progress = 0.75;
  final TextEditingController _goalController = TextEditingController();
  final CollectionReference goalsCollection =
  FirebaseFirestore.instance.collection('mydreams');

  void _addGoal() {
    if (_goalController.text.isNotEmpty) {
      goalsCollection.add({'goal': _goalController.text});
      _goalController.clear();
    }
  }

  void _removeGoal(String id) {
    goalsCollection.doc(id).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Personal Account"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "John Doe",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: Icon(Icons.settings),
                  onPressed: () {},
                ),
              ],
            ),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFFEE786B),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey,
                    spreadRadius: 2,
                    blurRadius: 5,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Excellent!",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Your today’s plan is almost done",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ],
                  ),
                  CircularPercentIndicator(
                    radius: 50.0,
                    lineWidth: 8.0,
                    percent: progress,
                    center: Text(
                      "${(progress * 100).toInt()}%",
                      style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                    ),
                    progressColor: Colors.white,
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),
            Text(
              "My Dreams",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Expanded(
              child: StreamBuilder(
                stream: goalsCollection.snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }
                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var doc = snapshot.data!.docs[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 10),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Color(0xFF343434),
                            borderRadius: BorderRadius.circular(45),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 1,
                                blurRadius: 5,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: ListTile(
                            contentPadding:
                            EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                            title: Text(
                              doc['goal'],
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                            trailing: IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _removeGoal(doc.id),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            TextField(
              controller: _goalController,
              decoration: InputDecoration(
                labelText: "Add a new goal",
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _addGoal(),
            ),
            SizedBox(height: 15),
            ElevatedButton(
              onPressed: _addGoal,
              child: Text("Add Goal"),
            ),
          ],
        ),
      ),
    );
  }
}
