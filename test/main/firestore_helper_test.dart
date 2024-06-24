import 'dart:async';
import 'dart:math';

import 'package:clock/clock.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firestore_helper/firestore_helper.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../utils/mocked_classes.mocks.dart';

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
  final mockFirebaseFirestore = MockFirebaseFirestore();
  final mockLoggingService = MockLoggingService();
  final mockCollectionReference = MockCollectionReference<Map<String, dynamic>>();
  final mockDocumentReference = MockDocumentReference<Map<String, dynamic>>();
  final mockSubCollectionReference = MockCollectionReference<Map<String, dynamic>>();
  final mockSubCollectionDocumentReference = MockDocumentReference<Map<String, dynamic>>();
  final mockAggregateQuery = MockAggregateQuery();
  final mockAggregateQuerySnapshot = MockAggregateQuerySnapshot();
  final mockQuery = MockQuery();
  final mockQuerySnapshot = MockQuerySnapshot();
  final mockDocumentSnapshot = MockDocumentSnapshot<Map<String, dynamic>>();
  final mockQueryDocumentSnapshot = MockQueryDocumentSnapshot(mockDocumentSnapshot);
  final mockStreamSubscription = MockStreamSubscription();
  final mockDocumentChange = MockDocumentChange();

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
    reset(mockAggregateQuery);
    reset(mockAggregateQuerySnapshot);
    reset(mockQuery);
    reset(mockQuerySnapshot);
    reset(mockQueryDocumentSnapshot);
    reset(mockDocumentSnapshot);
    reset(mockStreamSubscription);
    reset(mockDocumentChange);
  });

  group('addDocument', () {
    group('includeAdditionalFields', () {
      test('success', () async {
        firestoreHelper = FirestoreHelper.test(
          includeAdditionalFields: true,
          firebaseFirestore: mockFirebaseFirestore,
          loggingService: mockLoggingService,
        );
        final dateTime = DateTime(2020);
        final void Function() onCollection = () => mockFirebaseFirestore.collection('collection');
        final Function() onDocumentAdd = () => mockCollectionReference.add({
              'key': 'value',
              'updatedAt': Timestamp.fromDate(dateTime),
              'createdAt': Timestamp.fromDate(dateTime),
            });

        when(onCollection()).thenReturn(mockCollectionReference);
        when(onDocumentAdd()).thenAnswer((_) async => mockDocumentReference);
        when(mockDocumentReference.id).thenReturn('docId');

        await withClock(Clock.fixed(dateTime), () async {
          final String? documentId = await firestoreHelper.addDocument(['collection'], {'key': 'value'});

          verify(onCollection()).called(1);
          verifyNever(mockDocumentReference.set(any));
          verify(mockCollectionReference.add({
            'key': 'value',
            'createdAt': Timestamp.fromDate(dateTime),
            'updatedAt': Timestamp.fromDate(dateTime),
          })).called(1);
          expect(documentId, 'docId');
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
        });

        test('exception', () async {
          firestoreHelper = FirestoreHelper.test(
            includeAdditionalFields: true,
            firebaseFirestore: mockFirebaseFirestore,
            loggingService: mockLoggingService,
          );
          when(mockFirebaseFirestore.collection('collection')).thenThrow(Exception('error'));

          final String? documentId = await firestoreHelper.addDocument(['collection'], {'key': 'value'});

          verifyNever(mockDocumentReference.set(any));
          expect(documentId, isNull);
        });
      });
    });
    group('!includeAdditionalFields', () {
      test('success', () async {
        final void Function() onCollection = () => mockFirebaseFirestore.collection('collection');
        final void Function() onDocument = () => mockCollectionReference.doc(null);
        final Function() onDocumentAdd = () => mockCollectionReference.add({'key': 'value'});

        when(onCollection()).thenReturn(mockCollectionReference);
        when(onDocument()).thenReturn(mockDocumentReference);
        when(onDocumentAdd()).thenAnswer((_) async => mockDocumentReference);
        when(mockDocumentReference.id).thenReturn('docId');

        final documentId = await firestoreHelper.addDocument(['collection'], {'key': 'value'});

        verify(onCollection()).called(1);
        verifyNever(onDocument());
        verifyNever(mockDocumentReference.set(any));
        verify(onDocumentAdd()).called(1);
        expect(documentId, 'docId');
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
        });
        test('exception', () async {
          firestoreHelper = FirestoreHelper.test(
            includeAdditionalFields: true,
            firebaseFirestore: mockFirebaseFirestore,
            loggingService: mockLoggingService,
          );
          when(mockFirebaseFirestore.doc(any)).thenThrow(Exception('error'));

          final String? documentId = await firestoreHelper.addDocument(['collection'], {'key': 'value'});

          verifyNever(mockDocumentReference.set(any));
          expect(documentId, isNull);
        });
      });
    });
  });

  group('addDocumentWithId', () {
    group('includeAdditionalFields', () {
      test('success', () async {
        firestoreHelper = FirestoreHelper.test(
          includeAdditionalFields: true,
          firebaseFirestore: mockFirebaseFirestore,
          loggingService: mockLoggingService,
        );
        final dateTime = DateTime(2020);
        final void Function() onDocument = () => mockFirebaseFirestore.doc('collection/docId');

        when(onDocument()).thenReturn(mockDocumentReference);
        when(mockDocumentReference.id).thenReturn('docId');

        await withClock(Clock.fixed(dateTime), () async {
          final String? documentId = await firestoreHelper.addDocumentWithId(
            ['collection', 'docId'],
            {'key': 'value'},
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

      group('failure', () {
        test('assertion', () async {
          firestoreHelper = FirestoreHelper.test(
            includeAdditionalFields: true,
            firebaseFirestore: mockFirebaseFirestore,
            loggingService: mockLoggingService,
          );

          expect(
            () async => await firestoreHelper.addDocumentWithId(['collection'], {'key': 'value'}),
            throwsAssertionError,
          );
        });

        test('exception', () async {
          firestoreHelper = FirestoreHelper.test(
            includeAdditionalFields: true,
            firebaseFirestore: mockFirebaseFirestore,
            loggingService: mockLoggingService,
          );
          when(mockFirebaseFirestore.collection('collection/docId')).thenThrow(Exception('error'));

          final String? documentId = await firestoreHelper.addDocumentWithId(['collection', 'docId'], {'key': 'value'});

          verifyNever(mockDocumentReference.set(any));
          expect(documentId, isNull);
        });
      });
    });

    group('!includeAdditionalFields', () {
      test('success', () async {
        final void Function() onDocument = () => mockFirebaseFirestore.doc('collection/docId');

        when(onDocument()).thenReturn(mockDocumentReference);
        when(mockDocumentReference.id).thenReturn('docId');

        final documentId = await firestoreHelper.addDocumentWithId(['collection', 'docId'], {'key': 'value'});

        verify(onDocument()).called(1);
        verify(mockDocumentReference.set({'key': 'value'})).called(1);
        expect(documentId, 'docId');
      });

      group('failure', () {
        test('assertion', () async {
          firestoreHelper = FirestoreHelper.test(
            includeAdditionalFields: true,
            firebaseFirestore: mockFirebaseFirestore,
            loggingService: mockLoggingService,
          );

          expect(
            () async => await firestoreHelper.addDocumentWithId(['collection'], {'key': 'value'}),
            throwsAssertionError,
          );
        });

        test('exception', () async {
          firestoreHelper = FirestoreHelper.test(
            includeAdditionalFields: true,
            firebaseFirestore: mockFirebaseFirestore,
            loggingService: mockLoggingService,
          );
          when(mockFirebaseFirestore.doc(any)).thenThrow(Exception('error'));

          final documentId = await firestoreHelper.addDocumentWithId(['collection', 'docId'], {'key': 'value'});

          verifyNever(mockDocumentReference.set(any));
          expect(documentId, isNull);
        });
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
        final dateTime = DateTime(2020);
        final void Function() onDocument = () => mockFirebaseFirestore.doc('collection/docId');

        when(onDocument()).thenReturn(mockDocumentReference);

        await withClock(Clock.fixed(dateTime), () async {
          final isSuccess = await firestoreHelper.updateDocument(['collection', 'docId'], {'key': 'value'});

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
        final dateTime = DateTime(2020);
        when(mockFirebaseFirestore.doc(any)).thenThrow(Exception('error'));

        await withClock(Clock.fixed(dateTime), () async {
          final isSuccess = await firestoreHelper.updateDocument(['collection', 'docId'], {'key': 'value'});

          verifyNever(mockDocumentReference.update(any));
          expect(isSuccess, isFalse);
        });
      });
    });

    group('!includeAdditionalFields', () {
      test('success', () async {
        final void Function() onDocument = () => mockFirebaseFirestore.doc('collection/docId');

        when(onDocument()).thenReturn(mockDocumentReference);

        final isSuccess = await firestoreHelper.updateDocument(['collection', 'docId'], {'key': 'value'});

        verify(onDocument()).called(1);
        verify(mockDocumentReference.update({'key': 'value'})).called(1);
        expect(isSuccess, isTrue);
      });

      test('failure', () async {
        when(mockFirebaseFirestore.doc(any)).thenThrow(Exception('error'));

        final isSuccess = await firestoreHelper.updateDocument(['collection', 'docId'], {'key': 'value'});

        verifyNever(mockDocumentReference.update(any));
        expect(isSuccess, isFalse);
      });
    });
  });

  group('deleteDocument', () {
    test('success', () async {
      final void Function() onDocument = () => mockFirebaseFirestore.doc('collection/docId');

      when(onDocument()).thenReturn(mockDocumentReference);

      final isSuccess = await firestoreHelper.deleteDocument(['collection', 'docId']);

      verify(onDocument()).called(1);
      verify(mockDocumentReference.delete()).called(1);
      expect(isSuccess, isTrue);
    });

    test('failure', () async {
      when(mockFirebaseFirestore.doc(any)).thenThrow(Exception('error'));

      final isSuccess = await firestoreHelper.deleteDocument(['collection', 'docId']);

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

      final isSuccess = await firestoreHelper.deleteDocumentsByQuery(mockQuery);

      verify(mockDocumentReference.delete()).called(2);
      expect(isSuccess, isTrue);
    });

    test('failed', () async {
      when(mockQuery.get()).thenThrow(Exception('error'));
      when(mockQuerySnapshot.docs).thenReturn([mockQueryDocumentSnapshot, mockQueryDocumentSnapshot]);
      when(mockQueryDocumentSnapshot.reference).thenReturn(mockDocumentReference);

      final isSuccess = await firestoreHelper.deleteDocumentsByQuery(mockQuery);

      verifyNever(mockDocumentReference.delete());
      expect(isSuccess, isFalse);
    });
  });

  group('getDocuments', () {
    group('success', () {
      test('some docs are null', () async {
        final Function() onQueryGet = () => mockQuery.get();

        when(mockQuery.parameters).thenReturn({});
        when(onQueryGet()).thenAnswer((_) async => mockQuerySnapshot);
        when(mockQuerySnapshot.docs).thenReturn([mockQueryDocumentSnapshot]);

        final documents = await firestoreHelper.getDocuments<String>(
          query: mockQuery,
          logReference: '',
          // hacky test, can't find proper way to insert null within the list
          onDocumentSnapshot: (docSnapshot) => null,
        );

        verifyNever(mockQuery.startAfterDocument(any));
        verify(onQueryGet()).called(1);
        expect(documents!.length, 0);
      });

      test('lastDocumentSnapshot is null', () async {
        final Function() onQueryGet = () => mockQuery.get();

        when(mockQuery.parameters).thenReturn({});
        when(onQueryGet()).thenAnswer((_) async => mockQuerySnapshot);
        when(mockQuerySnapshot.docs).thenReturn([mockQueryDocumentSnapshot]);

        final documents = await firestoreHelper.getDocuments<String>(
          query: mockQuery,
          logReference: '',
          onDocumentSnapshot: (docSnapshot) => docSnapshot.id,
        );

        verifyNever(mockQuery.startAfterDocument(any));
        verify(onQueryGet()).called(1);
        expect(documents!.length, 1);
        expect(documents.first, 'itemId');
      });

      test('lastDocumentSnapshot is not null', () async {
        final otherMockQuery = MockQuery();
        when(otherMockQuery.parameters).thenReturn({});
        final Function() onStartAfterDocument = () => mockQuery.startAfterDocument(mockDocumentSnapshot);

        when(mockQuery.parameters).thenReturn({});
        when(onStartAfterDocument()).thenReturn(otherMockQuery);
        when(otherMockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
        when(mockQuerySnapshot.docs).thenReturn([mockQueryDocumentSnapshot]);

        final documents = await firestoreHelper.getDocuments<String>(
          query: mockQuery,
          logReference: '',
          onDocumentSnapshot: (docSnapshot) => docSnapshot.id,
          lastDocumentSnapshot: mockDocumentSnapshot,
        );

        verify(onStartAfterDocument()).called(1);
        verify(otherMockQuery.get()).called(1);
        expect(documents!.length, 1);
        expect(documents.first, 'itemId');
      });

      test('lastDocumentSnapshot is not null', () async {
        final  otherMockQuery = MockQuery();
        when(otherMockQuery.parameters).thenReturn({});
        final Function() onStartAfterDocument = () => mockQuery.startAfterDocument(mockDocumentSnapshot);

        when(mockQuery.parameters).thenReturn({});
        when(onStartAfterDocument()).thenReturn(otherMockQuery);
        when(otherMockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
        when(mockQuerySnapshot.docs).thenReturn([mockQueryDocumentSnapshot, mockQueryDocumentSnapshot]);

        final documents = await firestoreHelper.getDocuments<String>(
          query: mockQuery,
          logReference: '',
          onDocumentSnapshot: (docSnapshot) => docSnapshot.id,
          lastDocumentSnapshot: mockDocumentSnapshot,
        );

        verify(onStartAfterDocument()).called(1);
        verify(otherMockQuery.get()).called(1);
        expect(documents!.length, 2);
        expect(documents.first, 'itemId');
        expect(documents.last, 'itemId');
      });
    });

    test('failed', () async {
      when(mockQuery.parameters).thenReturn({});
      final Function() onStartAfterDocument = () => mockQuery.startAfterDocument(mockDocumentSnapshot);
      final Function() onQueryGet = () => mockQuery.get();

      when(onStartAfterDocument()).thenReturn(mockQuery);
      when(onQueryGet()).thenThrow(Exception('error'));

      final documents = await firestoreHelper.getDocuments<String>(
        query: mockQuery,
        logReference: '',
        onDocumentSnapshot: (docSnapshot) => docSnapshot.id,
        lastDocumentSnapshot: mockDocumentSnapshot,
      );

      verify(onStartAfterDocument()).called(1);
      verify(onQueryGet()).called(1);
      expect(documents, isNull);
    });
  });

  group('getDocument', () {
    test('success non null', () async {
      final void Function() onDocument = () => mockFirebaseFirestore.doc('collection/docId');

      when(onDocument()).thenReturn(mockDocumentReference);
      when(mockDocumentReference.get()).thenAnswer((_) async => mockDocumentSnapshot);
      when(mockDocumentSnapshot.id).thenReturn('returnedDocIt');
      when(mockDocumentSnapshot.exists).thenReturn(true);

      final  documents = await firestoreHelper.getDocument<String>(
        ['collection', 'docId'],
        logReference: '',
        onDocumentSnapshot: (docSnapshot) => docSnapshot.id,
      );

      verify(onDocument()).called(1);
      verify(mockDocumentReference.get()).called(1);
      expect(documents, 'returnedDocIt');
    });

    test('success null', () async {
      final void Function() onDocument = () => mockFirebaseFirestore.doc('collection/docId');

      when(onDocument()).thenReturn(mockDocumentReference);
      when(mockDocumentReference.get()).thenAnswer((_) async => mockDocumentSnapshot);
      when(mockDocumentSnapshot.exists).thenReturn(true);
      when(mockDocumentSnapshot.id).thenReturn('returnedDocIt');

      final documents = await firestoreHelper.getDocument<String>(
        ['collection', 'docId'],
        logReference: '',
        onDocumentSnapshot: (docSnapshot) => null,
      );

      verify(onDocument()).called(1);
      verify(mockDocumentReference.get()).called(1);
      expect(documents, null);
    });

    test('success document does not exist', () async {
      final void Function() onDocument = () => mockFirebaseFirestore.doc('collection/docId');

      when(onDocument()).thenReturn(mockDocumentReference);
      when(mockDocumentReference.get()).thenAnswer((_) async => mockDocumentSnapshot);
      when(mockDocumentSnapshot.exists).thenReturn(false);
      when(mockDocumentSnapshot.id).thenReturn('returnedDocIt');

      final documents = await firestoreHelper.getDocument<String>(
        ['collection', 'docId'],
        logReference: '',
        onDocumentSnapshot: (docSnapshot) => null,
      );

      verify(onDocument()).called(1);
      verify(mockDocumentReference.get()).called(1);
      expect(documents, null);
    });

    test('failure', () async {
      when(mockFirebaseFirestore.doc(any)).thenThrow(Exception('error'));

      final  documents = await firestoreHelper.getDocument<String>(
        ['collection', 'docId'],
        logReference: '',
        onDocumentSnapshot: (docSnapshot) => docSnapshot.id,
      );

      verifyNever(mockDocumentReference.get());
      expect(documents, isNull);
    });
  });

  group('areMoreDocumentsAvailable', () {
    test('true', () async {
      final otherMockQuery = MockQuery();
      when(otherMockQuery.parameters).thenReturn({});
      final Function() onStartAfterDocument = () => mockQuery.startAfterDocument(mockDocumentSnapshot);

      when(otherMockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(mockQuerySnapshot.docs).thenReturn([mockQueryDocumentSnapshot]);

      when(mockQuery.parameters).thenReturn({});
      when(mockQuery.limit(1)).thenReturn(mockQuery);
      when(onStartAfterDocument()).thenReturn(otherMockQuery);
      when(mockQuerySnapshot.docs).thenReturn([mockQueryDocumentSnapshot]);
      when(mockDocumentSnapshot.id).thenReturn('docId');

      final result = await firestoreHelper.areMoreDocumentsAvailable(
        query: mockQuery,
        lastDocumentSnapshot: mockDocumentSnapshot,
        onDocumentSnapshot: (_) => '',
      );

      expect(result, isTrue);
    });

    test('false null', () async {
      final otherMockQuery = MockQuery();
      when(otherMockQuery.parameters).thenReturn({});
      final Function() onStartAfterDocument = () => mockQuery.startAfterDocument(mockDocumentSnapshot);

      when(otherMockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(mockQuerySnapshot.docs).thenReturn([mockQueryDocumentSnapshot]);

      when(mockQuery.parameters).thenReturn({});
      when(mockQuery.limit(1)).thenReturn(mockQuery);
      when(onStartAfterDocument()).thenReturn(otherMockQuery);
      when(mockQuerySnapshot.docs).thenReturn([mockQueryDocumentSnapshot]);
      when(mockDocumentSnapshot.id).thenReturn('docId');

      final  result = await firestoreHelper.areMoreDocumentsAvailable(
        query: mockQuery,
        lastDocumentSnapshot: mockDocumentSnapshot,
        onDocumentSnapshot: (_) => null,
      );

      expect(result, isFalse);
    });

    group('false', () {
      test('list is null', () async {
        final otherMockQuery = MockQuery();
        when(otherMockQuery.parameters).thenReturn({});
        final Function() onStartAfterDocument = () => mockQuery.startAfterDocument(mockDocumentSnapshot);

        when(otherMockQuery.get()).thenThrow(Exception('error'));

        when(mockQuery.parameters).thenReturn({});
        when(mockQuery.limit(1)).thenReturn(mockQuery);
        when(onStartAfterDocument()).thenReturn(otherMockQuery);
        when(mockQuerySnapshot.docs).thenReturn([mockQueryDocumentSnapshot]);
        when(mockDocumentSnapshot.id).thenReturn('docId');

        final  result = await firestoreHelper.areMoreDocumentsAvailable(
          query: mockQuery,
          lastDocumentSnapshot: mockDocumentSnapshot,
          onDocumentSnapshot: (_) => '',
        );

        expect(result, isFalse);
      });

      test('list is empty', () async {
        final otherMockQuery = MockQuery();
        when(otherMockQuery.parameters).thenReturn({});
        final Function() onStartAfterDocument = () => mockQuery.startAfterDocument(mockDocumentSnapshot);

        when(mockQuery.parameters).thenReturn({});
        when(mockQuery.limit(1)).thenReturn(mockQuery);
        when(onStartAfterDocument()).thenReturn(otherMockQuery);
        when(mockQuerySnapshot.docs).thenReturn([]);
        when(mockDocumentSnapshot.id).thenReturn('docId');

        final result = await firestoreHelper.areMoreDocumentsAvailable(
          query: mockQuery,
          lastDocumentSnapshot: mockDocumentSnapshot,
          onDocumentSnapshot: (_) => '',
        );

        expect(result, isFalse);
      });
    });
  });

  group('hasAnyDocuments', () {
    test('true', () async {
      when(mockQuery.parameters).thenReturn({});
      when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(mockQuerySnapshot.docs).thenReturn([mockQueryDocumentSnapshot]);
      when(mockQuery.limit(1)).thenReturn(mockQuery);

      final result = await firestoreHelper.hasAnyDocuments(
        query: mockQuery,
        onDocumentSnapshot: (_) => '',
      );

      expect(result, isTrue);
    });

    test('false', () async {
      when(mockQuery.parameters).thenReturn({});
      when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(mockQuerySnapshot.docs).thenReturn([]);
      when(mockQuery.limit(1)).thenReturn(mockQuery);

      final result = await firestoreHelper.hasAnyDocuments(
        query: mockQuery,
        onDocumentSnapshot: (_) => '',
      );

      expect(result, isFalse);
    });
  });

  test('getDocumentsCount', () async {
    final expectedCount = Random().nextInt(100);
    when(mockQuery.parameters).thenReturn({});
    when(mockQuery.count()).thenReturn(mockAggregateQuery);
    when(mockAggregateQuery.get()).thenAnswer((_) async => mockAggregateQuerySnapshot);
    when(mockAggregateQuerySnapshot.count).thenReturn(expectedCount);

    final count = await firestoreHelper.getDocumentsCount(query: mockQuery);

    expect(count, expectedCount);
  });

  group('listenToDocumentsStream', () {
    test('!isMoreQuery', () async {
      final StreamController<QuerySnapshot> streamController = StreamController()..add(mockQuerySnapshot);
      final mockFunction = MockFunction();
      final void Function(DocumentChange) onDocumentChange = (documentChange) {
        mockFunction.call(documentChange);
      };

      when(mockQuery.parameters).thenReturn({});
      when(mockQuery.snapshots()).thenAnswer((_) => streamController.stream);
      when(mockQuerySnapshot.docChanges).thenReturn([mockDocumentChange]);
      when(mockDocumentChange.type).thenReturn(DocumentChangeType.added);
      when(mockDocumentChange.doc).thenReturn(mockDocumentSnapshot);
      when(mockDocumentSnapshot.id).thenReturn('');

      final streamSubscription = await Future.value(firestoreHelper.listenToDocumentsStream(
        logReference: '',
        query: mockQuery,
        onDocumentChange: onDocumentChange,
      ));

      verify(mockFunction(mockDocumentChange)).called(1);
      expect(streamSubscription, isNotNull);

      streamController.close();
    });

    test('isMoreQuery', () async {
      final streamController = StreamController<QuerySnapshot>()..add(mockQuerySnapshot);
      final mockFunction = MockFunction();
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

      final streamSubscription = await Future.value(firestoreHelper.listenToDocumentsStream(
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
    final streamController = StreamController<DocumentSnapshot<Map<String, dynamic>>>()..add(mockDocumentSnapshot);
    final void Function() onDocument = () => mockFirebaseFirestore.doc('collection/documentId');
    final mockFunction = MockFunction();
    final void Function(DocumentSnapshot) onDocumentChange = (documentSnapshot) {
      mockFunction.call(documentSnapshot);
    };

    when(onDocument()).thenReturn(mockDocumentReference);
    when(mockDocumentReference.snapshots()).thenAnswer((_) => streamController.stream);

    final streamSubscription = await Future.value(firestoreHelper.listenToDocument(
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
