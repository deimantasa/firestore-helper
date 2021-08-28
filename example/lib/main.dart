import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:example/note.dart';
import 'package:example/note_page.dart';
import 'package:example/notes_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firestore_helper/firestore_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firestore Helper Demo',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Initialise helper
  final FirestoreHelper _firestoreHelper = FirestoreHelper(
    includeAdditionalFields: true,
    isLoggingEnabled: !kReleaseMode,
  );
  final List<Note> _notes = [];
  final List<StreamSubscription> _streamSubscriptions = [];

  @override
  void initState() {
    super.initState();

    // Initialise subscriptions for real-time updates.
    final StreamSubscription streamSubscription = _firestoreHelper.listenToDocumentsStream(
        logReference: '_MyHomePageState.initState',
        query: FirebaseFirestore.instance.collection(Note.kCollectionNotes),
        // React to change.
        onDocumentChange: (documentChange) {
          final Note note = Note.fromFirestoreChanged(documentChange);

          setState(() {
            switch (documentChange.type) {
              case DocumentChangeType.added:
                // Adding new item to the list.
                _notes.insert(0, note);
                break;
              case DocumentChangeType.modified:
                // Updating item if it's existing.
                final int index = _notes.indexWhere((element) => element.id == note.id);

                if (index != -1) {
                  _notes[index] = note;
                }
                break;
              case DocumentChangeType.removed:
                // Removing item if it's existing.
                _notes.removeWhere((element) => element.id == note.id);
                break;
            }
          });
        });
    _streamSubscriptions.add(streamSubscription);
  }

  @override
  void dispose() {
    // Cancel all subscriptions.
    _streamSubscriptions.forEach((element) {
      element.cancel();
    });
    _streamSubscriptions.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Firestore Helper DEMO'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        Expanded(
          child: Column(
            children: [
              SizedBox(height: 8),
              Text(
                'Notes',
                style: Theme.of(context).textTheme.headline6,
              ),
              SizedBox(height: 8),
              Divider(height: 1),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _notes.length,
                  itemBuilder: (BuildContext context, int index) {
                    final Note note = _notes[index];

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          leading: IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () => _firestoreHelper.updateDocument(
                              [Note.kCollectionNotes, note.id],
                              Note.update().toJson(),
                            ),
                          ),
                          title: Text(note.text),
                          subtitle: Text(note.id),
                          trailing: IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () => _firestoreHelper.deleteDocument([Note.kCollectionNotes, note.id]),
                          ),
                          onTap: () =>
                              Navigator.push(context, MaterialPageRoute(builder: (context) => NotePage(noteId: note.id))),
                        ),
                        Divider(height: 1),
                      ],
                    );
                  },
                ),
              )
            ],
          ),
        ),
        Divider(height: 1),
        Expanded(
          child: Column(
            children: [
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Options',
                    style: Theme.of(context).textTheme.headline6,
                  ),
                ],
              ),
              SizedBox(height: 8),
              Divider(height: 1),
              SizedBox(height: 8),
              Expanded(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    ListTile(
                      title: Text('Add Document'),
                      subtitle: Text('Adds new Note'),
                      onTap: () => _firestoreHelper.addDocument(
                        [Note.kCollectionNotes],
                        Note.update().toJson(),
                      ),
                    ),
                    Divider(height: 1),
                    ListTile(
                      title: Text('Add Document with ID'),
                      subtitle: Text('Adds new Note with predefined ID'),
                      onTap: () => _firestoreHelper.addDocument(
                        [Note.kCollectionNotes],
                        Note.update().toJson(),
                        documentId: DateTime.now().millisecondsSinceEpoch.toString(),
                      ),
                    ),
                    Divider(height: 1),
                    if (_notes.isNotEmpty) ...[
                      ListTile(
                        title: Text('Delete Documents by query'),
                        subtitle: Text('Deletes all Notes'),
                        onTap: () => _firestoreHelper.deleteDocumentsByQuery(
                          FirebaseFirestore.instance.collection(Note.kCollectionNotes),
                        ),
                      ),
                      Divider(height: 1),
                      ListTile(
                        title: Text('Get Documents'),
                        subtitle: Text('Shows list of all notes'),
                        onTap: () async {
                          final List<Note>? notes = await _firestoreHelper.getDocuments<Note>(
                              query: FirebaseFirestore.instance.collection(Note.kCollectionNotes),
                              logReference: '_MyHomePageState._buildBody.getElements',
                              onDocumentSnapshot: (documentSnapshot) => Note.fromFirestore(documentSnapshot));

                          if (notes != null) {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => NotesPage(notes: _notes)));
                          }
                        },
                      ),
                      Divider(height: 1),
                      ListTile(
                        title: Text('Get Document'),
                        subtitle: Text('Shows last Note'),
                        onTap: () async {
                          final Note? note = await _firestoreHelper.getDocument(
                            [Note.kCollectionNotes, _notes.first.id],
                            logReference: '_MyHomePageState._buildBody.getElement',
                            onDocumentSnapshot: (documentSnapshot) => Note.fromFirestore(documentSnapshot),
                          );

                          if (note != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => NotePage(noteId: note.id)),
                            );
                          }
                        },
                      ),
                      Divider(height: 1),
                      // Since we don't have pagination - it does not make sense.
                      ListTile(
                        title: Text('Are more elements available'),
                        onTap: () async {
                          final bool areMoreAvailable = await _firestoreHelper.areMoreDocumentsAvailable(
                            query: FirebaseFirestore.instance.collection(Note.kCollectionNotes),
                            lastDocumentSnapshot: _notes.last.documentSnapshot,
                            onDocumentSnapshot: (documentSnapshot) => Note.fromFirestore(documentSnapshot),
                          );

                          print(areMoreAvailable);
                        },
                      ),
                      Divider(height: 1),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
