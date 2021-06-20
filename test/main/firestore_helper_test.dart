import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_helper/main/firestore_helper.dart';
import 'package:firebase_helper/mocked_classes.mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

// ignore: subtype_of_sealed_class
class MockQueryDocumentSnapshot extends Mock implements QueryDocumentSnapshot {
  @override
  String get id {
    return 'itemId';
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
  final MockQueryDocumentSnapshot mockQueryDocumentSnapshot = MockQueryDocumentSnapshot();
  final MockDocumentSnapshot<Map<String, dynamic>> mockDocumentSnapshot = MockDocumentSnapshot();
  final MockStreamSubscription mockStreamSubscription = MockStreamSubscription();
  final MockDocumentChange mockDocumentChange = MockDocumentChange();

  late FirestoreHelper firestoreHelper;

  setUp(() {
    firestoreHelper = FirestoreHelper(firebaseFirestore: mockFirebaseFirestore, loggingService: mockLoggingService);
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
    group('success', () {
      test('documentId is null', () async {
        final void Function() onCollection = () => mockFirebaseFirestore.collection('collection');
        final void Function() onDocument = () => mockCollectionReference.doc(null);

        when(onCollection()).thenReturn(mockCollectionReference);
        when(onDocument()).thenReturn(mockDocumentReference);
        when(mockDocumentReference.id).thenReturn('docId');

        final String? documentId = await firestoreHelper.addDocument('collection', {'key': 'value'});

        verify(onCollection()).called(1);
        verify(onDocument()).called(1);
        verify(mockDocumentReference.set({'key': 'value'})).called(1);
        expect(documentId, 'docId');
      });
      test('documentId is not null', () async {
        final void Function() onCollection = () => mockFirebaseFirestore.collection('collection');
        final void Function() onDocument = () => mockCollectionReference.doc('docId');

        when(onCollection()).thenReturn(mockCollectionReference);
        when(onDocument()).thenReturn(mockDocumentReference);
        when(mockDocumentReference.id).thenReturn('docId');

        final String? documentId = await firestoreHelper.addDocument('collection', {'key': 'value'}, documentId: 'docId');

        verify(onCollection()).called(1);
        verify(onDocument()).called(1);
        verify(mockDocumentReference.set({'key': 'value'})).called(1);
        expect(documentId, 'docId');
      });
    });
    test('failure', () async {
      final void Function() onCollection = () => mockFirebaseFirestore.collection('collection');
      final void Function() onDocument = () => mockCollectionReference.doc(any);

      when(mockFirebaseFirestore.collection('collection')).thenThrow(Exception('error'));

      final String? documentId = await firestoreHelper.addDocument('collection', {'key': 'value'}, documentId: 'docId');

      verify(onCollection()).called(1);
      verifyNever(onDocument());
      verifyNever(mockDocumentReference.set(any));
      expect(documentId, isNull);
    });
  });

  group('addSubCollectionDocument', () {
    group('success', () {
      test('subCollectionDocumentId is null', () async {
        final void Function() onCollection = () => mockFirebaseFirestore.collection('collection');
        final void Function() onDocument = () => mockCollectionReference.doc('documentId');
        final void Function() onSubCollection = () => mockDocumentReference.collection('subCollection');
        final void Function() onSubCollectionDocument = () => mockSubCollectionReference.doc(null);

        when(onCollection()).thenReturn(mockCollectionReference);
        when(onDocument()).thenReturn(mockDocumentReference);
        when(onSubCollection()).thenReturn(mockSubCollectionReference);
        when(onSubCollectionDocument()).thenReturn(mockSubCollectionDocumentReference);
        when(mockSubCollectionDocumentReference.id).thenReturn('docId');

        final String? documentId = await firestoreHelper.addSubCollectionDocument(
          collection: 'collection',
          documentId: 'documentId',
          subCollection: 'subCollection',
          update: {'key': 'value'},
        );

        verify(onCollection()).called(1);
        verify(onDocument()).called(1);
        verify(onSubCollection()).called(1);
        verify(onSubCollectionDocument()).called(1);
        verify(mockSubCollectionDocumentReference.set({'key': 'value'})).called(1);
        expect(documentId, 'docId');
      });
      test('subCollectionDocumentId is not null', () async {
        final void Function() onCollection = () => mockFirebaseFirestore.collection('collection');
        final void Function() onDocument = () => mockCollectionReference.doc('documentId');
        final void Function() onSubCollection = () => mockDocumentReference.collection('subCollection');
        final void Function() onSubCollectionDocument = () => mockSubCollectionReference.doc('docId');

        when(onCollection()).thenReturn(mockCollectionReference);
        when(onDocument()).thenReturn(mockDocumentReference);
        when(onSubCollection()).thenReturn(mockSubCollectionReference);
        when(onSubCollectionDocument()).thenReturn(mockSubCollectionDocumentReference);
        when(mockSubCollectionDocumentReference.id).thenReturn('docId');

        final String? documentId = await firestoreHelper.addSubCollectionDocument(
            collection: 'collection',
            documentId: 'documentId',
            subCollection: 'subCollection',
            update: {'key': 'value'},
            subCollectionDocumentId: 'docId');

        verify(onCollection()).called(1);
        verify(onDocument()).called(1);
        verify(onSubCollection()).called(1);
        verify(onSubCollectionDocument()).called(1);
        verify(mockSubCollectionDocumentReference.set({'key': 'value'})).called(1);
        expect(documentId, 'docId');
      });
    });
    test('failure', () async {
      final void Function() onCollection = () => mockFirebaseFirestore.collection('collection');
      final void Function() onDocument = () => mockCollectionReference.doc(any);
      final void Function() onSubCollection = () => mockDocumentReference.collection(any);
      final void Function() onSubCollectionDocument = () => mockSubCollectionReference.doc(any);

      when(onCollection()).thenThrow(Exception('error'));

      final String? documentId = await firestoreHelper.addSubCollectionDocument(
          collection: 'collection',
          documentId: 'documentId',
          subCollection: 'subCollection',
          update: {'key': 'value'},
          subCollectionDocumentId: 'docId');

      verify(onCollection()).called(1);
      verifyNever(onDocument());
      verifyNever(onSubCollection());
      verifyNever(onSubCollectionDocument());
      verifyNever(mockDocumentReference.set({'key': 'value'}));
      expect(documentId, isNull);
    });
  });

  group('updateDocument', () {
    test('success', () async {
      final void Function() onCollection = () => mockFirebaseFirestore.collection('collection');
      final void Function() onDocument = () => mockCollectionReference.doc('docId');

      when(onCollection()).thenReturn(mockCollectionReference);
      when(onDocument()).thenReturn(mockDocumentReference);

      final bool isSuccess = await firestoreHelper.updateDocument('collection', 'docId', {'key': 'value'});

      verify(onCollection()).called(1);
      verify(onDocument()).called(1);
      verify(mockDocumentReference.update({'key': 'value'})).called(1);
      expect(isSuccess, isTrue);
    });
    test('failure', () async {
      final void Function() onCollection = () => mockFirebaseFirestore.collection('collection');
      final void Function() onDocument = () => mockCollectionReference.doc(any);

      when(onCollection()).thenThrow(Exception('error'));

      final bool isSuccess = await firestoreHelper.updateDocument('collection', 'docId', {'key': 'value'});

      verify(onCollection()).called(1);
      verifyNever(onDocument());
      verifyNever(mockDocumentReference.update(any));
      expect(isSuccess, isFalse);
    });
  });

  group('updateSubCollectionsDocument', () {
    test('success', () async {
      final void Function() onCollection = () => mockFirebaseFirestore.collection('collection');
      final void Function() onDocument = () => mockCollectionReference.doc('docId');
      final void Function() onSubCollection = () => mockDocumentReference.collection('subCollection');
      final void Function() onSubCollectionDocument = () => mockSubCollectionReference.doc('subCollectionDocId');

      when(onCollection()).thenReturn(mockCollectionReference);
      when(onDocument()).thenReturn(mockDocumentReference);
      when(onSubCollection()).thenReturn(mockSubCollectionReference);
      when(onSubCollectionDocument()).thenReturn(mockSubCollectionDocumentReference);

      final bool isSuccess = await firestoreHelper.updateSubCollectionsDocument(
        collection: 'collection',
        documentId: 'docId',
        subCollection: 'subCollection',
        subCollectionDocumentId: 'subCollectionDocId',
        update: {'key': 'value'},
      );

      verify(onCollection()).called(1);
      verify(onDocument()).called(1);
      verify(onSubCollection()).called(1);
      verify(onSubCollectionDocument()).called(1);
      verify(mockSubCollectionDocumentReference.update({'key': 'value'})).called(1);
      expect(isSuccess, isTrue);
    });
    test('failure', () async {
      final void Function() onCollection = () => mockFirebaseFirestore.collection('collection');
      final void Function() onDocument = () => mockCollectionReference.doc('docId');
      final void Function() onSubCollection = () => mockDocumentReference.collection('subCollection');
      final void Function() onSubCollectionDocument = () => mockSubCollectionReference.doc('subCollectionDocId');

      when(onCollection()).thenThrow(Exception('error'));

      final bool isSuccess = await firestoreHelper.updateSubCollectionsDocument(
        collection: 'collection',
        documentId: 'docId',
        subCollection: 'subCollection',
        subCollectionDocumentId: 'subCollectionDocId',
        update: {'key': 'value'},
      );

      verify(onCollection()).called(1);
      verifyNever(onDocument());
      verifyNever(onSubCollection());
      verifyNever(onSubCollectionDocument());
      verifyNever(mockSubCollectionDocumentReference.update(any));
      expect(isSuccess, isFalse);
    });
  });

  group('deleteDocument', () {
    test('success', () async {
      final void Function() onCollection = () => mockFirebaseFirestore.collection('collection');
      final void Function() onDocument = () => mockCollectionReference.doc('docId');

      when(onCollection()).thenReturn(mockCollectionReference);
      when(onDocument()).thenReturn(mockDocumentReference);

      final bool isSuccess = await firestoreHelper.deleteDocument('collection', 'docId');

      verify(onCollection()).called(1);
      verify(onDocument()).called(1);
      verify(mockDocumentReference.delete()).called(1);
      expect(isSuccess, isTrue);
    });
    test('failure', () async {
      final void Function() onCollection = () => mockFirebaseFirestore.collection('collection');
      final void Function() onDocument = () => mockCollectionReference.doc(any);

      when(onCollection()).thenThrow(Exception('error'));

      final bool isSuccess = await firestoreHelper.deleteDocument('collection', 'docId');

      verify(onCollection()).called(1);
      verifyNever(onDocument());
      verifyNever(mockDocumentReference.delete());
      expect(isSuccess, isFalse);
    });
  });

  group('deleteSubCollectionsDocument', () {
    test('success', () async {
      final void Function() onCollection = () => mockFirebaseFirestore.collection('collection');
      final void Function() onDocument = () => mockCollectionReference.doc('docId');
      final void Function() onSubCollection = () => mockDocumentReference.collection('subCollection');
      final void Function() onSubCollectionDocument = () => mockSubCollectionReference.doc('subCollectionDocId');

      when(onCollection()).thenReturn(mockCollectionReference);
      when(onDocument()).thenReturn(mockDocumentReference);
      when(onSubCollection()).thenReturn(mockSubCollectionReference);
      when(onSubCollectionDocument()).thenReturn(mockSubCollectionDocumentReference);

      final bool isSuccess = await firestoreHelper.deleteSubCollectionDocument(
        collection: 'collection',
        documentId: 'docId',
        subCollection: 'subCollection',
        subCollectionDocumentId: 'subCollectionDocId',
      );

      verify(onCollection()).called(1);
      verify(onDocument()).called(1);
      verify(onSubCollection()).called(1);
      verify(onSubCollectionDocument()).called(1);
      verify(mockSubCollectionDocumentReference.delete()).called(1);
      expect(isSuccess, isTrue);
    });
    test('failure', () async {
      final void Function() onCollection = () => mockFirebaseFirestore.collection('collection');
      final void Function() onDocument = () => mockCollectionReference.doc('docId');
      final void Function() onSubCollection = () => mockDocumentReference.collection('subCollection');
      final void Function() onSubCollectionDocument = () => mockSubCollectionReference.doc('subCollectionDocId');

      when(onCollection()).thenThrow(Exception('error'));

      final bool isSuccess = await firestoreHelper.deleteSubCollectionDocument(
        collection: 'collection',
        documentId: 'docId',
        subCollection: 'subCollection',
        subCollectionDocumentId: 'subCollectionDocId',
      );

      verify(onCollection()).called(1);
      verifyNever(onDocument());
      verifyNever(onSubCollection());
      verifyNever(onSubCollectionDocument());
      verifyNever(mockSubCollectionDocumentReference.delete());
      expect(isSuccess, isFalse);
    });
  });

  group('getElements', () {
    group('success', () {
      test('lastDocumentSnapshot is null', () async {
        final Function() onQueryGet = () => mockQuery.get();

        when(onQueryGet()).thenAnswer((_) async => mockQuerySnapshot);
        when(mockQuerySnapshot.docs).thenReturn([mockQueryDocumentSnapshot]);

        final List<String>? elements = await firestoreHelper.getElements<String>(
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

        final List<String>? elements = await firestoreHelper.getElements<String>(
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

      final List<String>? elements = await firestoreHelper.getElements<String>(
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

  group('getElement', () {
    test('success', () async {
      final void Function() onCollection = () => mockFirebaseFirestore.collection('collection');
      final void Function() onDocument = () => mockCollectionReference.doc('docId');

      when(onCollection()).thenReturn(mockCollectionReference);
      when(onDocument()).thenReturn(mockDocumentReference);
      when(mockDocumentReference.get()).thenAnswer((_) async => mockDocumentSnapshot);
      when(mockDocumentSnapshot.id).thenReturn('returnedDocIt');

      final String? element = await firestoreHelper.getElement<String>(
        'collection',
        'docId',
        '',
        onDocumentSnapshot: (docSnapshot) => docSnapshot.id,
      );

      verify(onCollection()).called(1);
      verify(onDocument()).called(1);
      verify(mockDocumentReference.get()).called(1);
      expect(element, 'returnedDocIt');
    });
    test('failure', () async {
      final void Function() onCollection = () => mockFirebaseFirestore.collection('collection');

      when(onCollection()).thenThrow(Exception('error'));

      final String? element = await firestoreHelper.getElement<String>(
        'collection',
        'docId',
        '',
        onDocumentSnapshot: (docSnapshot) => docSnapshot.id,
      );

      verify(onCollection()).called(1);
      verifyNever(mockCollectionReference.doc('docId'));
      verifyNever(mockDocumentReference.get());
      expect(element, isNull);
    });
  });

  group('areMoreElementsAvailable', () {
    test('true', () async {
      final MockQuery otherMockQuery = MockQuery();
      final Function() onStartAfterDocument = () => mockQuery.startAfterDocument(mockDocumentSnapshot);

      when(otherMockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(mockQuerySnapshot.docs).thenReturn([mockQueryDocumentSnapshot]);

      when(mockQuery.limit(1)).thenReturn(mockQuery);
      when(onStartAfterDocument()).thenReturn(otherMockQuery);
      when(mockQuerySnapshot.docs).thenReturn([mockQueryDocumentSnapshot]);
      when(mockDocumentSnapshot.id).thenReturn('docId');

      final bool result = await firestoreHelper.areMoreElementsAvailable(
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

        final bool result = await firestoreHelper.areMoreElementsAvailable(
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

        final bool result = await firestoreHelper.areMoreElementsAvailable(
          query: mockQuery,
          lastDocumentSnapshot: mockDocumentSnapshot,
          onDocumentSnapshot: (_) => '',
        );

        expect(result, isFalse);
      });
    });
  });

  group('listenToElementsStream', () {
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

      final StreamSubscription streamSubscription = await firestoreHelper.listenToElementsStream(
        logReference: '',
        query: mockQuery,
        onDocumentChange: onDocumentChange,
      );

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

      final StreamSubscription streamSubscription = await firestoreHelper.listenToElementsStream(
        logReference: '',
        query: mockQuery,
        onDocumentChange: onDocumentChange,
        lastDocumentSnapshot: mockDocumentSnapshot,
      );

      verify(mockFunction(mockDocumentChange)).called(1);
      expect(streamSubscription, isNotNull);

      streamController.close();
    });
  });

  test('listenToElementsCountStream', () async {
    final StreamController<QuerySnapshot> streamController = StreamController()..add(mockQuerySnapshot);
    final MockFunction mockFunction = MockFunction();
    final void Function(int) onCountChange = (count) {
      mockFunction.call(count);
    };

    when(mockQuery.snapshots()).thenAnswer((_) => streamController.stream);
    when(mockQuerySnapshot.size).thenReturn(-1);

    final StreamSubscription streamSubscription = await firestoreHelper.listenToElementsCountStream(
      logReference: '',
      query: mockQuery,
      onCountChange: onCountChange,
    );

    verify(mockFunction(-1)).called(1);
    expect(streamSubscription, isNotNull);

    streamController.close();
  });

  test('listenToDocument', () async {
    final StreamController<DocumentSnapshot<Map<String, dynamic>>> streamController = StreamController()
      ..add(mockDocumentSnapshot);
    final void Function() onCollection = () => mockFirebaseFirestore.collection('collection');
    final void Function() onDocument = () => mockCollectionReference.doc('documentId');
    final MockFunction mockFunction = MockFunction();
    final void Function(DocumentSnapshot) onDocumentChange = (documentSnapshot) {
      mockFunction.call(documentSnapshot);
    };

    when(onCollection()).thenReturn(mockCollectionReference);
    when(onDocument()).thenReturn(mockDocumentReference);
    when(mockDocumentReference.snapshots()).thenAnswer((_) => streamController.stream);

    final StreamSubscription streamSubscription = await firestoreHelper.listenToDocument(
      'collection',
      'documentId',
      '',
      onDocumentChange: onDocumentChange,
    );

    verify(mockFunction(mockDocumentSnapshot)).called(1);
    expect(streamSubscription, isNotNull);

    streamController.close();
  });

  test('listenToSubCollectionDocument', () async {
    final StreamController<DocumentSnapshot<Map<String, dynamic>>> streamController = StreamController()
      ..add(mockDocumentSnapshot);
    final void Function() onCollection = () => mockFirebaseFirestore.collection('collection');
    final void Function() onDocument = () => mockCollectionReference.doc('docId');
    final void Function() onSubCollection = () => mockDocumentReference.collection('subCollection');
    final void Function() onSubCollectionDocument = () => mockSubCollectionReference.doc('subCollectionDocId');

    final MockFunction mockFunction = MockFunction();
    final void Function(DocumentSnapshot) onDocumentChange = (documentSnapshot) {
      mockFunction.call(documentSnapshot);
    };

    when(onCollection()).thenReturn(mockCollectionReference);
    when(onDocument()).thenReturn(mockDocumentReference);
    when(onSubCollection()).thenReturn(mockSubCollectionReference);
    when(onSubCollectionDocument()).thenReturn(mockSubCollectionDocumentReference);
    when(mockSubCollectionDocumentReference.snapshots()).thenAnswer((_) => streamController.stream);

    final StreamSubscription streamSubscription = await firestoreHelper.listenToSubCollectionDocument(
      collection: 'collection',
      documentId: 'docId',
      subCollection: 'subCollection',
      subCollectionDocumentId: 'subCollectionDocId',
      logReference: '',
      onDocumentChange: onDocumentChange,
    );

    verify(mockFunction(mockDocumentSnapshot)).called(1);
    expect(streamSubscription, isNotNull);

    streamController.close();
  });
}
