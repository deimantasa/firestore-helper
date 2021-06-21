import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_lorem/flutter_lorem.dart';
import 'package:json_annotation/json_annotation.dart';

part 'note.g.dart';

@JsonSerializable(anyMap: true)
class Note {
  static const String kCollectionNotes = 'notes';
  static const String kSubCollectionNotes = 'subnotes';

  @JsonKey(ignore: true)
  late DocumentSnapshot documentSnapshot;
  @JsonKey(ignore: true)
  DocumentChangeType? documentChangeType;

  // Easier way to retrieve ID of the item.
  String get id => documentSnapshot.id;
  String text;

  Note(this.text);

  // Used for Updating the Note to random text.
  Note.update() : this.text = lorem(paragraphs: 1, words: 2);

  factory Note.fromFirestore(DocumentSnapshot documentSnapshot) {
    final Map<String, dynamic> data = documentSnapshot.data() as Map<String, dynamic>;
    final Note note = _$NoteFromJson(data);

    note.documentSnapshot = documentSnapshot;
    return note;
  }

  factory Note.fromFirestoreChanged(DocumentChange documentChange) {
    final Map<String, dynamic> data = documentChange.doc.data() as Map<String, dynamic>;
    final Note note = _$NoteFromJson(data);

    note.documentSnapshot = documentChange.doc;
    note.documentChangeType = documentChange.type;
    return note;
  }

  factory Note.fromJson(Map<String, dynamic> json) => _$NoteFromJson(json);
  Map<String, dynamic> toJson() => _$NoteToJson(this);
}
