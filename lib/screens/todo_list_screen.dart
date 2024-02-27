import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../dialog/add_task_dialog.dart';

class TodoListScreen extends StatefulWidget {
  @override
  _TodoListScreenState createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _user;
  late CollectionReference _tasks;

  @override
  void initState() {
    super.initState();
    _checkCurrentUser();
  }

  Future<void> _checkCurrentUser() async {
    _user = _auth.currentUser;
    if (_user == null) {
      await _signInAnonymously();
    }
    _tasks = _firestore.collection('tasks');
  }

  Future<void> _signInAnonymously() async {
    try {
      final UserCredential userCredential = await _auth.signInAnonymously();
      _user = userCredential.user;
    } catch (e) {
      print('Error signing in anonymously: $e');
    }
  }

  Future<void> _addTask(String taskName) async {
    try {
      await _tasks.add({
        'name': taskName,
        'completed': false,
        'userId': _user!.uid,
      });
    } catch (e) {
      print('Error adding task: $e');
    }
  }

  Future<void> _toggleTaskCompletion(DocumentSnapshot task) async {
    try {
      await task.reference.update({'completed': !task['completed']});
    } catch (e) {
      print('Error toggling task completion: $e');
    }
  }

  Future<void> _deleteTask(DocumentSnapshot task) async {
    try {
      await task.reference.delete();
    } catch (e) {
      print('Error deleting task: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Todo List'),
      ),
      body: _user == null
          ? Center(
        child: CircularProgressIndicator(),
      )
          : StreamBuilder<QuerySnapshot>(
        stream: _tasks.where('userId', isEqualTo: _user!.uid).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            final List<DocumentSnapshot> tasks = snapshot.data!.docs;
            return ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return ListTile(
                  title: Text(task['name']),
                  leading: Checkbox(
                    value: task['completed'],
                    onChanged: (_) => _toggleTaskCompletion(task),
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => _deleteTask(task),
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final taskName = await showDialog<String>(
            context: context,
            builder: (context) => AddTaskDialog(),
          );
          if (taskName != null && taskName.isNotEmpty) {
            _addTask(taskName);
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}