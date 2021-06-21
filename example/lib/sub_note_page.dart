import 'dart:async';

import 'package:example/note.dart';
import 'package:firestore_helper/firestore_helper.dart';
import 'package:flutter/material.dart';

class SubNotePage extends StatefulWidget {
  final String noteId;
  final String subNoteId;

  const SubNotePage({
    Key? key,
    required this.noteId,
    required this.subNoteId,
  }) : super(key: key);
  @override
  _SubNotePageState createState() => _SubNotePageState();
}

class _SubNotePageState extends State<SubNotePage> {
  final FirestoreHelper _firestoreHelper = FirestoreHelper(
    includeAdditionalFields: true,
    isLoggingEnabled: true,
  );
  late final StreamSubscription subNoteStreamSubscription;
  Note? subNote;

  @override
  void initState() {
    super.initState();

    // Initialise new stream that listens to Note real-time updates
    subNoteStreamSubscription = _firestoreHelper.listenToSubCollectionDocument(
      collection: Note.kCollectionNotes,
      documentId: widget.noteId,
      subCollection: Note.kSubCollectionNotes,
      subCollectionDocumentId: widget.subNoteId,
      logReference: '_SubNotePageState.initState:',
      onDocumentChange: (documentChange) {
        final Note note = Note.fromFirestore(documentChange);

        setState(() {
          this.subNote = note;
        });
      },
    );
  }

  @override
  void dispose() {
    subNoteStreamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sub Note'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    final Note? localSubNote = subNote;

    // It takes <1s to initialise note via listener
    if (localSubNote == null) {
      return SizedBox.shrink();
    } else {
      return Column(
        children: [
          ListTile(
            leading: IconButton(
              icon: Icon(Icons.edit),
              onPressed: () => _firestoreHelper.updateSubCollectionsDocument(
                collection: Note.kCollectionNotes,
                documentId: widget.noteId,
                subCollection: Note.kSubCollectionNotes,
                subCollectionDocumentId: widget.subNoteId,
                update: Note.update().toJson(),
              ),
            ),
            title: Text(localSubNote.text),
            subtitle: Text(localSubNote.id),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                _firestoreHelper.deleteSubCollectionDocument(
                  collection: Note.kCollectionNotes,
                  documentId: widget.noteId,
                  subCollection: Note.kSubCollectionNotes,
                  subCollectionDocumentId: widget.subNoteId,
                );
                Navigator.pop(context);
              },
            ),
          ),
          Divider(height: 1),
        ],
      );
    }
  }
}
