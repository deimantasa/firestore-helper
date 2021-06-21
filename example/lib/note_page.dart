import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:example/note.dart';
import 'package:example/sub_note_page.dart';
import 'package:firestore_helper/firestore_helper.dart';
import 'package:flutter/material.dart';

class NotePage extends StatefulWidget {
  final String noteId;

  const NotePage({
    Key? key,
    required this.noteId,
  }) : super(key: key);
  @override
  _NotePageState createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> {
  final FirestoreHelper _firestoreHelper = FirestoreHelper(
    includeAdditionalFields: true,
    isLoggingEnabled: true,
  );
  final List<StreamSubscription> _streamSubscriptions = [];
  final List<Note> _subNotes = [];
  Note? _note;

  @override
  void initState() {
    super.initState();

    // Initialise new stream that listens to Note real-time updates
    final StreamSubscription noteStreamSubscription = _firestoreHelper
        .listenToDocument(Note.kCollectionNotes, widget.noteId, '_NotePageState.initState:', onDocumentChange: (documentChange) {
      final Note note = Note.fromFirestore(documentChange);

      setState(() {
        this._note = note;
      });
    });

    // Initialise new stream that listens to all SubNotes within Note in real-time
    final StreamSubscription subNotesStreamSubscription = _firestoreHelper.listenToElementsStream(
        logReference: '_NotePageState.initState:',
        query:
            FirebaseFirestore.instance.collection(Note.kCollectionNotes).doc(widget.noteId).collection(Note.kSubCollectionNotes),
        onDocumentChange: (documentChange) {
          final Note note = Note.fromFirestoreChanged(documentChange);

          setState(() {
            switch (documentChange.type) {
              case DocumentChangeType.added:
                // Adding new item to the list.
                _subNotes.insert(0, note);
                break;
              case DocumentChangeType.modified:
                final int index = _subNotes.indexWhere((element) => element.id == note.id);

                if (index != -1) {
                  _subNotes[index] = note;
                }
                break;
              case DocumentChangeType.removed:
                _subNotes.removeWhere((element) => element.id == note.id);
                break;
            }
          });
        });

    _streamSubscriptions..add(noteStreamSubscription)..add(subNotesStreamSubscription);
  }

  @override
  void dispose() {
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
        title: Text('Note'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    final Note? localNote = _note;

    // It takes <1s to initialise note via listener
    if (localNote == null) {
      return SizedBox.shrink();
    } else {
      return Column(
        children: [
          ListTile(
            leading: IconButton(
              icon: Icon(Icons.edit),
              onPressed: () => _firestoreHelper.updateDocument(
                Note.kCollectionNotes,
                localNote.id,
                Note.update().toJson(),
              ),
            ),
            title: Text(localNote.text),
            subtitle: Text(localNote.id),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                _firestoreHelper.deleteDocument(Note.kCollectionNotes, widget.noteId);
                Navigator.pop(context);
              },
            ),
          ),
          Divider(height: 1),
          SizedBox(height: 8),
          Text(
            'Sub Notes',
            style: Theme.of(context).textTheme.headline6,
          ),
          SizedBox(height: 8),
          Divider(height: 1),
          Expanded(
            child: ListView.builder(
              itemCount: _subNotes.length,
              itemBuilder: (context, index) {
                final Note subNote = _subNotes[index];

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () => _firestoreHelper.updateSubCollectionsDocument(
                          collection: Note.kCollectionNotes,
                          documentId: widget.noteId,
                          subCollection: Note.kSubCollectionNotes,
                          subCollectionDocumentId: subNote.id,
                          update: Note.update().toJson(),
                        ),
                      ),
                      title: Text(subNote.text),
                      subtitle: Text(subNote.id),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => _firestoreHelper.deleteSubCollectionDocument(
                          collection: Note.kCollectionNotes,
                          documentId: widget.noteId,
                          subCollection: Note.kSubCollectionNotes,
                          subCollectionDocumentId: subNote.id,
                        ),
                      ),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SubNotePage(
                            noteId: widget.noteId,
                            subNoteId: subNote.id,
                          ),
                        ),
                      ),
                    ),
                    Divider(height: 1),
                  ],
                );
              },
            ),
          ),
          Divider(height: 1),
          SizedBox(height: 8),
          Text(
            'Options',
            style: Theme.of(context).textTheme.headline6,
          ),
          SizedBox(height: 8),
          Divider(height: 1),
          ListTile(
            title: Text('Add Sub Collection Document'),
            subtitle: Text('Adds new Sub Note within this note'),
            onTap: () => _firestoreHelper.addSubCollectionDocument(
              collection: Note.kCollectionNotes,
              documentId: widget.noteId,
              subCollection: Note.kSubCollectionNotes,
              update: Note.update().toJson(),
            ),
          ),
        ],
      );
    }
  }
}
