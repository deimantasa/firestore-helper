library firebase_helper_package;

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_helper/models/log_type.dart';
import 'package:firebase_helper/main/logging_service.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class FirestoreHelper {
  final FirebaseFirestore _firebaseFirestore;
  final LoggingService _loggingService;

  FirestoreHelper({FirebaseFirestore? firebaseFirestore, LoggingService? loggingService})
      : this._firebaseFirestore = firebaseFirestore ?? FirebaseFirestore.instance,
        this._loggingService = loggingService ?? LoggingService(logger: Logger(printer: PrettyPrinter(methodCount: 2)));

  Future<String?> addDocument(
    String collection,
    Map<String, dynamic> update, {
    String? documentId,
  }) async {
    try {
      final DocumentReference documentReference = _firebaseFirestore.collection(collection).doc(documentId);
      await documentReference.set(update);

      _loggingService.log(
          'FirestoreGenericService.setDocument: Set. Collection $collection, DocID: ${documentReference.id}, Update: $update');
      return documentReference.id;
    } catch (e) {
      _loggingService.log(
        'FirestoreGenericService.setDocument: Set failed. Update: $update, Exception: ${e.toString()}',
        logType: LogType.error,
      );
      return null;
    }
  }

  Future<String?> addSubCollectionDocument({
    required String collection,
    required String documentId,
    required String subCollection,
    required Map<String, dynamic> update,
    String? subCollectionDocumentId,
  }) async {
    try {
      final DocumentReference documentReference =
          _firebaseFirestore.collection(collection).doc(documentId).collection(subCollection).doc(subCollectionDocumentId);

      await documentReference.set(update);
      _loggingService.log(
          'FirestoreGenericService.setDocument: Set. Collection $collection, DocID: ${documentReference.id}, Update: $update');
      return documentReference.id;
    } catch (e) {
      _loggingService.log(
        'FirestoreGenericService.setDocument: Set failed. Update: $update, Exception: ${e.toString()}',
        logType: LogType.error,
      );
      return null;
    }
  }

  Future<bool> updateDocument(String collection, String documentId, Map<String, dynamic> update) async {
    try {
      await _firebaseFirestore.collection(collection).doc(documentId).update(update);
      _loggingService.log('FirestoreGenericService.setDocument: Update. Collection $collection,'
          ' DocID: $documentId, Update: $update');
      return true;
    } catch (e) {
      _loggingService.log(
        'FirestoreGenericService.setDocument: Update failed. Update: $update, Exception: ${e.toString()}',
        logType: LogType.error,
      );
      return false;
    }
  }

  Future<bool> updateSubCollectionsDocument({
    required String collection,
    required String documentId,
    required String subCollection,
    required String subCollectionDocumentId,
    required Map<String, dynamic> update,
  }) async {
    try {
      await _firebaseFirestore
          .collection(collection)
          .doc(documentId)
          .collection(subCollection)
          .doc(subCollectionDocumentId)
          .update(update);
      _loggingService.log('FirestoreGenericService.setDocument: Update. Collection $collection, CollectionDocID: $documentId,'
          ' SubCollection: $subCollection, SubCollectionDocId: $subCollectionDocumentId, Update: $update');
      return true;
    } catch (e) {
      _loggingService.log(
        'FirestoreGenericService.setDocument: Update. Collection $collection, CollectionDocID: $documentId,'
        ' SubCollection: $subCollection, SubCollectionDocId: $subCollectionDocumentId,'
        ' Update: $update, Exception: ${e.toString()}',
        logType: LogType.error,
      );
      return false;
    }
  }

  Future<bool> deleteDocument(String collection, String documentId) async {
    try {
      _loggingService.log('FirestoreGenericService.deleteDocument: Deleting. Collection $collection, DocId: $documentId');
      await _firebaseFirestore.collection(collection).doc(documentId).delete();
      _loggingService.log('FirestoreGenericService.deleteDocument: Deleted. Collection $collection, DocId: $documentId');
      return true;
    } catch (e) {
      _loggingService.log(
        'FirestoreGenericService.deleteDocument: Exception: $e',
        logType: LogType.error,
      );
      return false;
    }
  }

  Future<bool> deleteSubCollectionDocument({
    required String collection,
    required String documentId,
    required String subCollection,
    required String subCollectionDocumentId,
  }) async {
    try {
      _loggingService.log('FirestoreGenericService.deleteDocument: Deleting. Collection $collection, DocId: $documentId'
          ' SubCollection $subCollection, SubCollectionDocId: $subCollectionDocumentId');
      await _firebaseFirestore
          .collection(collection)
          .doc(documentId)
          .collection(subCollection)
          .doc(subCollectionDocumentId)
          .delete();
      _loggingService.log('FirestoreGenericService.deleteDocument: Deleted. Collection $collection, DocId: $documentId');
      return true;
    } catch (e) {
      _loggingService.log(
        'FirestoreGenericService.deleteDocument: Exception: $e',
        logType: LogType.error,
      );
      return false;
    }
  }

  ///Generic method used for retrieving items. It simplifies pagination flow, so services doesn't need
  ///to contain boilerplate code.
  ///
  ///[userId] is document id of the [User].
  ///[query] is the query used for the firestore.
  ///[logReference] is reference string for logging purposes so we know when this query gets executed
  ///and what executes it.
  ///[onDocumentSnapshot] is a method with return type of an object.
  ///[lastDocumentSnapshot] must not be null if pagination is required as it is an indicator of where to
  ///continue query.
  Future<List<T>?> getElements<T>({
    required Query query,
    required String logReference,
    required T Function(DocumentSnapshot documentSnapshot) onDocumentSnapshot,
    DocumentSnapshot? lastDocumentSnapshot,
  }) async {
    final bool isMoreQuery = lastDocumentSnapshot != null;
    final Query currentQuery = isMoreQuery ? query.startAfterDocument(lastDocumentSnapshot) : query;

    _loggingService.log('FirestoreGenericService.getElements.$logReference: More: $isMoreQuery');
    try {
      final QuerySnapshot querySnapshot = await currentQuery.get();
      final List<T> elements = querySnapshot.docs.map((e) {
        final T element = onDocumentSnapshot(e);

        return element;
      }).toList();

      _loggingService.log('FirestoreGenericService.getElements.$logReference: Total: ${elements.length}');
      return elements;
    } catch (e) {
      _loggingService.log(
        'FirestoreTransactionsService.getElements: Exception: $e',
        logType: LogType.error,
      );
      return null;
    }
  }

  Future<T?> getElement<T>(
    String collection,
    String documentId,
    String logReference, {
    required T? Function(DocumentSnapshot documentSnapshot) onDocumentSnapshot,
  }) async {
    try {
      _loggingService.log('FirestoreGenericService.getElement.$logReference: Collection: $collection, DocId: $documentId');
      final DocumentSnapshot documentSnapshot = await _firebaseFirestore.collection(collection).doc(documentId).get();
      final T element = onDocumentSnapshot(documentSnapshot)!;

      return element;
    } catch (e) {
      _loggingService.log(
        'FirestoreGenericService.getElement.$logReference: Collection: $collection, DocId: $documentId, Exception: $e',
        logType: LogType.error,
      );
      return null;
    }
  }

  Future<bool> areMoreElementsAvailable<T>({
    required Query query,
    required DocumentSnapshot lastDocumentSnapshot,
    required T Function(DocumentSnapshot documentSnapshot) onDocumentSnapshot,
  }) async {
    _loggingService.log('FirestoreGenericService.areMoreElementsAvailable: Last Document ID: ${lastDocumentSnapshot.id}');

    final List<T>? elements = await getElements<T>(
      query: query..limit(1),
      logReference: 'FirestoreGenericService.areMoreElementsAvailable',
      onDocumentSnapshot: (documentSnapshot) => onDocumentSnapshot(documentSnapshot),
      lastDocumentSnapshot: lastDocumentSnapshot,
    );

    if (elements == null || elements.isEmpty) {
      _loggingService.log('FirestoreGenericService.areMoreElementsAvailable: No more elements');
      return false;
    } else {
      _loggingService.log('FirestoreGenericService.areMoreElementsAvailable: More elements exists.');
      return true;
    }
  }

  /// Listening for the stream of [QuerySnapshot] from Firestore.
  ///
  /// [logReference] is some string for logging purpose.
  /// [query] is query used for this particular call.
  /// [onDocumentChange] is a [ValueSetter] which will return [DocumentChange] object from firestore.
  /// [lastDocumentSnapshot] is the snapshot of the last document. If [lastDocumentSnapshot] is null, it means
  /// there will be no pagination.
  StreamSubscription<QuerySnapshot> listenToElementsStream({
    required String logReference,
    required Query query,
    required ValueSetter<DocumentChange> onDocumentChange,
    DocumentSnapshot? lastDocumentSnapshot,
  }) {
    final bool isMoreQuery = lastDocumentSnapshot != null;
    final Query currentQuery = isMoreQuery ? query.startAfterDocument(lastDocumentSnapshot) : query;

    _loggingService.log(
        'FirestoreGenericService.listenToElementsStream.$logReference: Query: ${query.parameters}, IsMoreQuery: $isMoreQuery');

    final StreamSubscription<QuerySnapshot> streamSubscription = currentQuery.snapshots().listen((event) {
      event.docChanges.forEach((docChange) {
        _loggingService.log('FirestoreGenericService.listenToElementsStream.$logReference:'
            ' Type: ${docChange.type}. DocId: ${docChange.doc.id}');
        onDocumentChange(docChange);
      });
    });

    return streamSubscription;
  }

  StreamSubscription<QuerySnapshot> listenToElementsCountStream({
    required String logReference,
    required Query query,
    required ValueSetter<int> onCountChange,
  }) {
    _loggingService.log('FirestoreGenericService.listenToElementsCountStream.$logReference');

    final StreamSubscription<QuerySnapshot> streamSubscription = query.snapshots().listen((querySnapshot) {
      _loggingService.log('FirestoreGenericService.listenToElementsCountStream: Count:${querySnapshot.size}');
      onCountChange(querySnapshot.size);
    });

    return streamSubscription;
  }

  StreamSubscription<DocumentSnapshot> listenToDocument<T>(
    String collection,
    String documentId,
    String logReference, {
    required ValueSetter<DocumentSnapshot> onDocumentChange,
  }) {
    final StreamSubscription<DocumentSnapshot> streamSubscription =
        _firebaseFirestore.collection(collection).doc(documentId).snapshots().listen((documentSnapshot) {
      _loggingService.log('FirestoreGenericService.listenToDocument.$logReference: New event.'
          ' Collection: $collection, DocId: $documentId');
      onDocumentChange(documentSnapshot);
    });

    return streamSubscription;
  }

  StreamSubscription<DocumentSnapshot> listenToSubCollectionDocument<T>({
    required String collection,
    required String documentId,
    required String subCollection,
    required String subCollectionDocumentId,
    required String logReference,
    required ValueSetter<DocumentSnapshot> onDocumentChange,
  }) {
    final StreamSubscription<DocumentSnapshot> streamSubscription = _firebaseFirestore
        .collection(collection)
        .doc(documentId)
        .collection(subCollection)
        .doc(subCollectionDocumentId)
        .snapshots()
        .listen((event) {
      _loggingService
          .log('FirestoreGenericService.listenToSubCollectionDocument.$logReference: New event. Collection: $collection, '
              'DocId: $documentId, SubCollection: $subCollection, SubCollectionDocId: $subCollectionDocumentId');
      onDocumentChange(event);
    });

    return streamSubscription;
  }
}
