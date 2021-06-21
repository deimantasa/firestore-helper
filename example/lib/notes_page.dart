import 'package:example/note.dart';
import 'package:example/note_page.dart';
import 'package:flutter/material.dart';

class NotesPage extends StatefulWidget {
  final List<Note> notes;

  const NotesPage({
    Key? key,
    required this.notes,
  }) : super(key: key);
  @override
  _NotesPageState createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notes'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: widget.notes.length,
      itemBuilder: (BuildContext context, int index) {
        final Note note = widget.notes[index];

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(note.text),
              subtitle: Text(note.id),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => NotePage(noteId: note.id))),
            ),
            Divider(height: 1),
          ],
        );
      },
    );
  }
}
