import 'dart:async';

import 'package:clock/clock.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firestore_helper/firestore_helper.dart';
import 'package:firestore_helper/src/utils/mocked_classes.mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

// ignore: subtype_of_sealed_class
class MockQueryDocumentSnapshot extends Mock implements QueryDocumentSnapshot {
  final MockDocumentSnapshot _mockDocumentSnapshot;

  MockQueryDocumentSnapshot(this._mockDocumentSnapshot);
  @override
  String get id {
    return 'itemId';
  }

  @override
  DocumentReference get reference {
    return _mockDocumentSnapshot.reference;
  }
}

void main() {
  final MockFirebaseFirestore mockFirebaseFirestore = MockFirebaseFirestore();
  final MockLoggingService mockLoggingService = MockLoggingService();
  final MockCollectionReference<Map<String, dynamic>> mockCollectionReference = MockCollectionReference();
  final MockDocumentReference<Map<String, dynamic>> mockDocumentReference = MockDocumentReference();
  final MockCollectionReference<Map<String, dynamic>> mockSubCollectionReference = MockCollectionReference();
  final MockDocumentReference<Map<String, dynamic>> mockSubCollectionDocumentReference = MockDocumentReference();
  final MockQuery mockQuery = MockQuery();
  final MockQuerySnapshot mockQuerySnapshot = MockQuerySnapshot();
  final MockDocumentSnapshot<Map<String, dynamic>> mockDocumentSnapshot = MockDocumentSnapshot();
  final MockQueryDocumentSnapshot mockQueryDocumentSnapshot = MockQueryDocumentSnapshot(mockDocumentSnapshot);
  final MockStreamSubscription mockStreamSubscription = MockStreamSubscription();
  final MockDocumentChange mockDocumentChange = MockDocumentChange();

  late FirestoreHelper firestoreHelper;

  setUp(() {
    firestoreHelper = FirestoreHelper.test(
      includeAdditionalFields: false,
      firebaseFirestore: mockFirebaseFirestore,
      loggingService: mockLoggingService,
    );
  });

  tearDown(() {
    reset(mockFirebaseFirestore);
    reset(mockCollectionReference);
    reset(mockDocumentReference);
    reset(mockSubCollectionReference);
    reset(mockSubCollectionDocumentReference);
    reset(mockQuery);
    reset(mockQuerySnapshot);
    reset(mockQueryDocumentSnapshot);
    reset(mockDocumentSnapshot);
    reset(mockStreamSubscription);
    reset(mockDocumentChange);
  });

  group('addDocument', () {
    group('includeAdditionalFields', () {
      group('success', () {
        test('documentId is null', () async {
          firestoreHelper = FirestoreHelper.test(
            includeAdditionalFields: true,
            firebaseFirestore: mockFirebaseFirestore,
            loggingService: mockLoggingService,
          );
          final DateTime dateTime = DateTime(2020);
          final void Function() onCollection = () => mockFirebaseFirestore.collection('collection');
          final void Function() onDocument = () => mockCollectionReference.doc(null);
          final Function() onDocumentAdd = () => mockCollectionReference.add({
                'key': 'value',
                'updatedAt': Timestamp.fromDate(dateTime),
                'createdAt': Timestamp.fromDate(dateTime),
              });

          when(onCollection()).thenReturn(mockCollectionReference);
          when(onDocument()).thenReturn(mockDocumentReference);
          when(onDocumentAdd()).thenAnswer((_) async => mockDocumentReference);
          when(mockDocumentReference.id).thenReturn('docId');

          await withClock(Clock.fixed(dateTime), () async {
            final String? documentId = await firestoreHelper.addDocument(['collection'], {'key': 'value'});

            verify(onCollection()).called(1);
            verifyNever(onDocument());
            verifyNever(mockDocumentReference.set(any));
            verify(mockCollectionReference.add({
              'key': 'value',
              'createdAt': Timestamp.fromDate(dateTime),
              'updatedAt': Timestamp.fromDate(dateTime),
            })).called(1);
            expect(documentId, 'docId');
          });
        });
        test('documentId is not null', () async {
          firestoreHelper = FirestoreHelper.test(
            includeAdditionalFields: true,
            firebaseFirestore: mockFirebaseFirestore,
            loggingService: mockLoggingService,
          );
          final DateTime dateTime = DateTime(2020);
          final void Function() onDocument = () => mockFirebaseFirestore.doc('collection/docId');

          when(onDocument()).thenReturn(mockDocumentReference);
          when(mockDocumentReference.id).thenReturn('docId');

          await withClock(Clock.fixed(dateTime), () async {
            final String? documentId = await firestoreHelper.addDocument(
              ['collection'],
              {'key': 'value'},
              documentId: 'docId',
            );

            verify(onDocument()).called(1);
            verify(mockDocumentReference.set({
              'key': 'value',
              'updatedAt': Timestamp.fromDate(dateTime),
              'createdAt': Timestamp.fromDate(dateTime),
            })).called(1);
            expect(documentId, 'docId');
          });
        });
      });
      group('failure', () {
        test('assertion', () async {
          firestoreHelper = FirestoreHelper.test(
            includeAdditionalFields: true,
            firebaseFirestore: mockFirebaseFirestore,
            loggingService: mockLoggingService,
          );

          expect(
            () async => await firestoreHelper.addDocument(['collection', 'docId'], {'key': 'value'}),
            throwsAssertionError,
          );
          expect(
            () async => await firestoreHelper.addDocument(['collection', 'docId'], {'key': 'value'}, documentId: 'docId'),
            throwsAssertionError,
          );
        });

        test('exception', () async {
          firestoreHelper = FirestoreHelper.test(
            includeAdditionalFields: true,
            firebaseFirestore: mockFirebaseFirestore,
            loggingService: mockLoggingService,
          );

          when(mockFirebaseFirestore.collection('collection')).thenThrow(Exception('error'));

          final String? documentId = await firestoreHelper.addDocument(['collection'], {'key': 'value'}, documentId: 'docId');

          verifyNever(mockDocumentReference.set(any));
          expect(documentId, isNull);
        });
      });
    });
    group('!includeAdditionalFields', () {
      group('success', () {
        test('documentId is null', () async {
          final void Function() onCollection = () => mockFirebaseFirestore.collection('collection');
          final void Function() onDocument = () => mockCollectionReference.doc(null);
          final Function() onDocumentAdd = () => mockCollectionReference.add({'key': 'value'});

          when(onCollection()).thenReturn(mockCollectionReference);
          when(onDocument()).thenReturn(mockDocumentReference);
          when(onDocumentAdd()).thenAnswer((_) async => mockDocumentReference);
          when(mockDocumentReference.id).thenReturn('docId');

          final String? documentId = await firestoreHelper.addDocument(['collection'], {'key': 'value'});

          verify(onCollection()).called(1);
          verifyNever(onDocument());
          verifyNever(mockDocumentReference.set(any));
          verify(onDocumentAdd()).called(1);
          expect(documentId, 'docId');
        });
        test('documentId is not null', () async {
          final void Function() onDocument = () => mockFirebaseFirestore.doc('collection/docId');

          when(onDocument()).thenReturn(mockDocumentReference);
          when(mockDocumentReference.id).thenReturn('docId');

          final String? documentId = await firestoreHelper.addDocument(['collection'], {'key': 'value'}, documentId: 'docId');

          verify(onDocument()).called(1);
          verify(mockDocumentReference.set({'key': 'value'})).called(1);
          expect(documentId, 'docId');
        });
      });
      test('failure', () async {
        final void Function() onDocument = () => mockCollectionReference.doc(any);

        when(mockFirebaseFirestore.doc('collection/docId')).thenThrow(Exception('error'));

        final String? documentId = await firestoreHelper.addDocument(['collection'], {'key': 'value'}, documentId: 'docId');

        verifyNever(onDocument());
        verifyNever(mockDocumentReference.set(any));
        expect(documentId, isNull);
      });
    });
  });

  group('updateDocument', () {
    group('includeAdditionalFields', () {
      test('success', () async {
        firestoreHelper = FirestoreHelper.test(
          includeAdditionalFields: true,
          firebaseFirestore: mockFirebaseFirestore,
          loggingService: mockLoggingService,
        );
        final DateTime dateTime = DateTime(2020);
        final void Function() onDocument = () => mockFirebaseFirestore.doc('collection/docId');

        when(onDocument()).thenReturn(mockDocumentReference);

        await withClock(Clock.fixed(dateTime), () async {
          final bool isSuccess = await firestoreHelper.updateDocument(['collection', 'docId'], {'key': 'value'});

          verify(onDocument()).called(1);
          verify(mockDocumentReference.update({
            'key': 'value',
            'updatedAt': Timestamp.fromDate(dateTime),
          })).called(1);
          expect(isSuccess, isTrue);
        });
      });
      test('failure', () async {
        firestoreHelper = FirestoreHelper.test(
          includeAdditionalFields: true,
          firebaseFirestore: mockFirebaseFirestore,
          loggingService: mockLoggingService,
        );
        final DateTime dateTime = DateTime(2020);
        when(mockFirebaseFirestore.doc(any)).thenThrow(Exception('error'));

        await withClock(Clock.fixed(dateTime), () async {
          final bool isSuccess = await firestoreHelper.updateDocument(['collection', 'docId'], {'key': 'value'});

          verifyNever(mockDocumentReference.update(any));
          expect(isSuccess, isFalse);
        });
      });
    });
    group('!includeAdditionalFields', () {
      test('success', () async {
        final void Function() onDocument = () => mockFirebaseFirestore.doc('collection/docId');

        when(onDocument()).thenReturn(mockDocumentReference);

        final bool isSuccess = await firestoreHelper.updateDocument(['collection', 'docId'], {'key': 'value'});

        verify(onDocument()).called(1);
        verify(mockDocumentReference.update({'key': 'value'})).called(1);
        expect(isSuccess, isTrue);
      });
      test('failure', () async {
        when(mockFirebaseFirestore.doc(any)).thenThrow(Exception('error'));

        final bool isSuccess = await firestoreHelper.updateDocument(['collection', 'docId'], {'key': 'value'});

        verifyNever(mockDocumentReference.update(any));
        expect(isSuccess, isFalse);
      });
    });
  });

  group('deleteDocument', () {
    test('success', () async {
      final void Function() onDocument = () => mockFirebaseFirestore.doc('collection/docId');

      when(onDocument()).thenReturn(mockDocumentReference);

      final bool isSuccess = await firestoreHelper.deleteDocument(['collection', 'docId']);

      verify(onDocument()).called(1);
      verify(mockDocumentReference.delete()).called(1);
      expect(isSuccess, isTrue);
    });
    test('failure', () async {
      when(mockFirebaseFirestore.doc(any)).thenThrow(Exception('error'));

      final bool isSuccess = await firestoreHelper.deleteDocument(['collection', 'docId']);

      verifyNever(mockDocumentReference.delete());
      expect(isSuccess, isFalse);
    });
  });

  group('deleteDocumentsByQuery', () {
    test('success', () async {
      when(mockQuery.parameters).thenReturn({});
      when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(mockQuerySnapshot.docs).thenReturn([mockQueryDocumentSnapshot, mockQueryDocumentSnapshot]);
      when(mockQueryDocumentSnapshot.reference).thenReturn(mockDocumentReference);

      final bool isSuccess = await firestoreHelper.deleteDocumentsByQuery(mockQuery);

      verify(mockDocumentReference.delete()).called(2);
      expect(isSuccess, isTrue);
    });
    test('failed', () async {
      when(mockQuery.get()).thenThrow(Exception('error'));
      when(mockQuerySnapshot.docs).thenReturn([mockQueryDocumentSnapshot, mockQueryDocumentSnapshot]);
      when(mockQueryDocumentSnapshot.reference).thenReturn(mockDocumentReference);

      final bool isSuccess = await firestoreHelper.deleteDocumentsByQuery(mockQuery);

      verifyNever(mockDocumentReference.delete());
      expect(isSuccess, isFalse);
    });
  });

  group('getDocuments', () {
    group('success', () {
      test('lastDocumentSnapshot is null', () async {
        final Function() onQueryGet = () => mockQuery.get();

        when(onQueryGet()).thenAnswer((_) async => mockQuerySnapshot);
        when(mockQuerySnapshot.docs).thenReturn([mockQueryDocumentSnapshot]);

        final List<String>? elements = await firestoreHelper.getDocuments<String>(
          query: mockQuery,
          logReference: '',
          onDocumentSnapshot: (docSnapshot) => docSnapshot.id,
        );

        verifyNever(mockQuery.startAfterDocument(any));
        verify(onQueryGet()).called(1);
        expect(elements!.length, 1);
        expect(elements.first, 'itemId');
      });
      test('lastDocumentSnapshot is not null', () async {
        final MockQuery otherMockQuery = MockQuery();
        final Function() onStartAfterDocument = () => mockQuery.startAfterDocument(mockDocumentSnapshot);

        when(onStartAfterDocument()).thenReturn(otherMockQuery);
        when(otherMockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
        when(mockQuerySnapshot.docs).thenReturn([mockQueryDocumentSnapshot]);

        final List<String>? elements = await firestoreHelper.getDocuments<String>(
          query: mockQuery,
          logReference: '',
          onDocumentSnapshot: (docSnapshot) => docSnapshot.id,
          lastDocumentSnapshot: mockDocumentSnapshot,
        );

        verify(onStartAfterDocument()).called(1);
        verify(otherMockQuery.get()).called(1);
        expect(elements!.length, 1);
        expect(elements.first, 'itemId');
      });
    });
    test('failed', () async {
      final Function() onStartAfterDocument = () => mockQuery.startAfterDocument(mockDocumentSnapshot);
      final Function() onQueryGet = () => mockQuery.get();

      when(onStartAfterDocument()).thenReturn(mockQuery);
      when(onQueryGet()).thenThrow(Exception('error'));

      final List<String>? elements = await firestoreHelper.getDocuments<String>(
        query: mockQuery,
        logReference: '',
        onDocumentSnapshot: (docSnapshot) => docSnapshot.id,
        lastDocumentSnapshot: mockDocumentSnapshot,
      );

      verify(onStartAfterDocument()).called(1);
      verify(onQueryGet()).called(1);
      expect(elements, isNull);
    });
  });

  group('getDocument', () {
    test('success', () async {
      final void Function() onDocument = () => mockFirebaseFirestore.doc('collection/docId');

      when(onDocument()).thenReturn(mockDocumentReference);
      when(mockDocumentReference.get()).thenAnswer((_) async => mockDocumentSnapshot);
      when(mockDocumentSnapshot.id).thenReturn('returnedDocIt');

      final String? element = await firestoreHelper.getDocument<String>(
        ['collection', 'docId'],
        logReference: '',
        onDocumentSnapshot: (docSnapshot) => docSnapshot.id,
      );

      verify(onDocument()).called(1);
      verify(mockDocumentReference.get()).called(1);
      expect(element, 'returnedDocIt');
    });
    test('failure', () async {
      when(mockFirebaseFirestore.doc(any)).thenThrow(Exception('error'));

      final String? element = await firestoreHelper.getDocument<String>(
        ['collection', 'docId'],
        logReference: '',
        onDocumentSnapshot: (docSnapshot) => docSnapshot.id,
      );

      verifyNever(mockDocumentReference.get());
      expect(element, isNull);
    });
  });

  group('areMoreDocumentsAvailable', () {
    test('true', () async {
      final MockQuery otherMockQuery = MockQuery();
      final Function() onStartAfterDocument = () => mockQuery.startAfterDocument(mockDocumentSnapshot);

      when(otherMockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(mockQuerySnapshot.docs).thenReturn([mockQueryDocumentSnapshot]);

      when(mockQuery.limit(1)).thenReturn(mockQuery);
      when(onStartAfterDocument()).thenReturn(otherMockQuery);
      when(mockQuerySnapshot.docs).thenReturn([mockQueryDocumentSnapshot]);
      when(mockDocumentSnapshot.id).thenReturn('docId');

      final bool result = await firestoreHelper.areMoreDocumentsAvailable(
        query: mockQuery,
        lastDocumentSnapshot: mockDocumentSnapshot,
        onDocumentSnapshot: (_) => '',
      );

      expect(result, isTrue);
    });
    group('false', () {
      test('list is null', () async {
        final MockQuery otherMockQuery = MockQuery();
        final Function() onStartAfterDocument = () => mockQuery.startAfterDocument(mockDocumentSnapshot);

        when(otherMockQuery.get()).thenThrow(Exception('error'));

        when(mockQuery.limit(1)).thenReturn(mockQuery);
        when(onStartAfterDocument()).thenReturn(otherMockQuery);
        when(mockQuerySnapshot.docs).thenReturn([mockQueryDocumentSnapshot]);
        when(mockDocumentSnapshot.id).thenReturn('docId');

        final bool result = await firestoreHelper.areMoreDocumentsAvailable(
          query: mockQuery,
          lastDocumentSnapshot: mockDocumentSnapshot,
          onDocumentSnapshot: (_) => '',
        );

        expect(result, isFalse);
      });
      test('list is empty', () async {
        final MockQuery otherMockQuery = MockQuery();
        final Function() onStartAfterDocument = () => mockQuery.startAfterDocument(mockDocumentSnapshot);

        when(mockQuery.limit(1)).thenReturn(mockQuery);
        when(onStartAfterDocument()).thenReturn(otherMockQuery);
        when(mockQuerySnapshot.docs).thenReturn([]);
        when(mockDocumentSnapshot.id).thenReturn('docId');

        final bool result = await firestoreHelper.areMoreDocumentsAvailable(
          query: mockQuery,
          lastDocumentSnapshot: mockDocumentSnapshot,
          onDocumentSnapshot: (_) => '',
        );

        expect(result, isFalse);
      });
    });
  });

  group('listenToDocumentsStream', () {
    test('!isMoreQuery', () async {
      final StreamController<QuerySnapshot> streamController = StreamController()..add(mockQuerySnapshot);
      final MockFunction mockFunction = MockFunction();
      final void Function(DocumentChange) onDocumentChange = (documentChange) {
        mockFunction.call(documentChange);
      };

      when(mockQuery.parameters).thenReturn({});
      when(mockQuery.snapshots()).thenAnswer((_) => streamController.stream);
      when(mockQuerySnapshot.docChanges).thenReturn([mockDocumentChange]);
      when(mockDocumentChange.type).thenReturn(DocumentChangeType.added);
      when(mockDocumentChange.doc).thenReturn(mockDocumentSnapshot);
      when(mockDocumentSnapshot.id).thenReturn('');

      final StreamSubscription streamSubscription = await Future.value(firestoreHelper.listenToDocumentsStream(
        logReference: '',
        query: mockQuery,
        onDocumentChange: onDocumentChange,
      ));

      verify(mockFunction(mockDocumentChange)).called(1);
      expect(streamSubscription, isNotNull);

      streamController.close();
    });
    test('isMoreQuery', () async {
      final StreamController<QuerySnapshot> streamController = StreamController()..add(mockQuerySnapshot);
      final MockFunction mockFunction = MockFunction();
      final void Function(DocumentChange) onDocumentChange = (documentChange) {
        mockFunction.call(documentChange);
      };

      when(mockQuery.startAfterDocument(mockDocumentSnapshot)).thenReturn(mockQuery);
      when(mockQuery.parameters).thenReturn({});
      when(mockQuery.snapshots()).thenAnswer((_) => streamController.stream);
      when(mockQuerySnapshot.docChanges).thenReturn([mockDocumentChange]);
      when(mockDocumentChange.type).thenReturn(DocumentChangeType.added);
      when(mockDocumentChange.doc).thenReturn(mockDocumentSnapshot);
      when(mockDocumentSnapshot.id).thenReturn('');

      final StreamSubscription streamSubscription = await Future.value(firestoreHelper.listenToDocumentsStream(
        logReference: '',
        query: mockQuery,
        onDocumentChange: onDocumentChange,
        lastDocumentSnapshot: mockDocumentSnapshot,
      ));

      verify(mockFunction(mockDocumentChange)).called(1);
      expect(streamSubscription, isNotNull);

      streamController.close();
    });
  });

  test('listenToDocument', () async {
    final StreamController<DocumentSnapshot<Map<String, dynamic>>> streamController = StreamController()
      ..add(mockDocumentSnapshot);
    final void Function() onDocument = () => mockFirebaseFirestore.doc('collection/documentId');
    final MockFunction mockFunction = MockFunction();
    final void Function(DocumentSnapshot) onDocumentChange = (documentSnapshot) {
      mockFunction.call(documentSnapshot);
    };

    when(onDocument()).thenReturn(mockDocumentReference);
    when(mockDocumentReference.snapshots()).thenAnswer((_) => streamController.stream);

    final StreamSubscription streamSubscription = await Future.value(firestoreHelper.listenToDocument(
      ['collection', 'documentId'],
      logReference: '',
      onDocumentChange: onDocumentChange,
    ));

    verify(mockFunction(mockDocumentSnapshot)).called(1);
    expect(streamSubscription, isNotNull);

    streamController.close();
  });

  group('getPathToDocument', () {
    test('success', () {
      expect(firestoreHelper.getPathToDocument(['collection', 'documentId']), 'collection/documentId');
      expect(firestoreHelper.getPathToDocument(['col1', 'docId1', 'col2', 'docId2']), 'col1/docId1/col2/docId2');
    });

    test('failure', () {
      expect(() => firestoreHelper.getPathToDocument([]), throwsAssertionError);
      expect(() => firestoreHelper.getPathToDocument(['collection']), throwsAssertionError);
      expect(() => firestoreHelper.getPathToDocument(['col1', 'docId1', 'col2']), throwsAssertionError);
    });
  });
}
