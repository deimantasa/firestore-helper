import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_helper/main/logging_service.dart';
import 'package:mockito/annotations.dart';

import 'mock_function.dart';

@GenerateMocks([
  LoggingService,
  DocumentSnapshot,
  DocumentChange,
  FirebaseFirestore,
  CollectionReference,
  DocumentReference,
  Query,
  QuerySnapshot,
  StreamSubscription,
], customMocks: [
  MockSpec<FunctionMock>(as: #MockFunction),
])
void main() {}
