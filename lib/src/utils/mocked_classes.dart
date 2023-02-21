import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firestore_helper/src/logging_service.dart';
import 'package:logger/logger.dart';
import 'package:mockito/annotations.dart';

import 'mock_function.dart';

@GenerateMocks([
  LoggingService,
  AggregateQuery,
  AggregateQuerySnapshot,
  DocumentSnapshot,
  DocumentChange,
  FirebaseFirestore,
  CollectionReference,
  DocumentReference,
  Query,
  QuerySnapshot,
  StreamSubscription,
  Logger,
], customMocks: [
  MockSpec<FunctionMock>(as: #MockFunction),
])
void main() {}
