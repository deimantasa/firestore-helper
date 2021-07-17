part of firestore_helper;

class FirestoreHelper {
  final FirebaseFirestore _firebaseFirestore;
  final LoggingService _loggingService;

  /// Flag to determine, if extra fields should be included. Read more
  /// in [_includeAdditionalFieldsIntoMap].
  final bool _includeAdditionalFields;

  /// Exclude from coverage since we are using special `test` constructor.
  // coverage:ignore-start
  FirestoreHelper({
    required bool includeAdditionalFields,
    required bool isLoggingEnabled,
  })  : this._includeAdditionalFields = includeAdditionalFields,
        this._firebaseFirestore = FirebaseFirestore.instance,
        this._loggingService = LoggingService(
          isLoggingEnabled,
          logger: Logger(printer: PrettyPrinter(methodCount: 2)),
        );
  // coverage:ignore-end

  @visibleForTesting
  FirestoreHelper.test({
    required bool includeAdditionalFields,
    required FirebaseFirestore firebaseFirestore,
    required LoggingService loggingService,
  })  : this._includeAdditionalFields = includeAdditionalFields,
        this._firebaseFirestore = firebaseFirestore,
        this._loggingService = loggingService;

  /// Updates existing data map with `createdAt` and `updatedAt`.
  ///
  /// [dataMap] is original data map which shall be updated.
  /// [includeCreatedAt] is the toggle for whether we should add `createdAt` field.
  /// Generally we don't want to update this field when we update data set. Thus
  /// this field shall be included only when we create a new document.
  void _includeAdditionalFieldsIntoMap(Map<String, dynamic> dataMap, {bool includeCreatedAt = false}) {
    // Don't use `FieldValue.serverTimestamp()` because it takes time to initialise
    // time thus for some millis createdAt and updatedAt can be null.
    final Timestamp timeStamp = Timestamp.fromDate(clock.now());

    if (includeCreatedAt) dataMap.addAll({'createdAt': timeStamp});
    dataMap.addAll({'updatedAt': timeStamp});
  }

  /// Adds a new document into the collection in Firebase.
  ///
  /// [collection] is the name of the collection.
  /// [update] is the data which will be added to the document.
  /// [documentId] is the optional ID. If it is specified - document will be created.
  /// with exactly that ID. Otherwise, random ID will be generated.
  Future<String?> addDocument(
    String collection,
    Map<String, dynamic> update, {
    String? documentId,
  }) async {
    try {
      if (_includeAdditionalFields) _includeAdditionalFieldsIntoMap(update, includeCreatedAt: true);
      final DocumentReference documentReference;

      if (documentId != null) {
        documentReference = _firebaseFirestore.collection(collection).doc(documentId);
        await documentReference.set(update);
      } else {
        documentReference = await _firebaseFirestore.collection(collection).add(update);
      }
      _loggingService.log('FirestoreHelper.addDocument: Collection $collection, DocID: ${documentReference.id}, Update: $update');
      return documentReference.id;
    } catch (e, s) {
      _loggingService.log(
        'FirestoreHelper.addDocument: Failed. Update: $update, Exception: ${e.toString()}. StackTrace: $s',
        logType: LogType.error,
      );
      return null;
    }
  }

  /// Adds a new document into the sub-collection in Firebase.
  ///
  /// [collection] is the name of the collection.
  /// [documentId] is the ID of the document within that collection.
  /// [subCollection] is the name of the sub collection within that document.
  /// [update] is the data which will be added to the document.
  /// [subCollectionDocumentId] is the optional ID. If it is specified - document will be created.
  /// with exactly that ID. Otherwise, random ID will be generated.
  Future<String?> addSubCollectionDocument({
    required String collection,
    required String documentId,
    required String subCollection,
    required Map<String, dynamic> update,
    String? subCollectionDocumentId,
  }) async {
    try {
      if (_includeAdditionalFields) _includeAdditionalFieldsIntoMap(update, includeCreatedAt: true);
      final DocumentReference documentReference;

      if (subCollectionDocumentId != null) {
        documentReference =
            _firebaseFirestore.collection(collection).doc(documentId).collection(subCollection).doc(subCollectionDocumentId);
        await documentReference.set(update);
      } else {
        documentReference = await _firebaseFirestore.collection(collection).doc(documentId).collection(subCollection).add(update);
      }

      _loggingService.log(
          'FirestoreHelper.addSubCollectionDocument: Collection $collection, DocID: ${documentReference.id}, Update: $update');
      return documentReference.id;
    } catch (e, s) {
      _loggingService.log(
        'FirestoreHelper.addSubCollectionDocument: Failed. Update: $update, Exception: ${e.toString()}. StackTrace: $s',
        logType: LogType.error,
      );
      return null;
    }
  }

  /// Updates existing document in Firebase.
  ///
  /// [collection] is the name of the collection.
  /// [documentId] is the ID of the document within that collection
  /// [update] is the data which will be updated within that document.
  Future<bool> updateDocument(String collection, String documentId, Map<String, dynamic> update) async {
    try {
      if (_includeAdditionalFields) _includeAdditionalFieldsIntoMap(update);
      await _firebaseFirestore.collection(collection).doc(documentId).update(update);
      _loggingService.log('FirestoreHelper.updateDocument: Collection $collection,'
          ' DocID: $documentId, Update: $update');
      return true;
    } catch (e, s) {
      _loggingService.log(
        'FirestoreHelper.updateDocument: Failed. Update: $update, Exception: ${e.toString()}. StackTrace: $s',
        logType: LogType.error,
      );
      return false;
    }
  }

  /// Updates existing sub-collection document in Firebase.
  ///
  /// [collection] is the name of the collection.
  /// [documentId] is the ID of the document within that collection.
  /// [subCollection] is the name of the document within that collection.
  /// [subCollectionDocumentId] is the ID of the document within that collection.
  /// [update] is the data which will be updated within that document.
  Future<bool> updateSubCollectionsDocument({
    required String collection,
    required String documentId,
    required String subCollection,
    required String subCollectionDocumentId,
    required Map<String, dynamic> update,
  }) async {
    try {
      if (_includeAdditionalFields) _includeAdditionalFieldsIntoMap(update);
      await _firebaseFirestore
          .collection(collection)
          .doc(documentId)
          .collection(subCollection)
          .doc(subCollectionDocumentId)
          .update(update);
      _loggingService.log('FirestoreHelper.updateSubCollectionsDocument: Collection $collection, CollectionDocID: $documentId,'
          ' SubCollection: $subCollection, SubCollectionDocId: $subCollectionDocumentId, Update: $update');
      return true;
    } catch (e, s) {
      _loggingService.log(
        'FirestoreHelper.updateSubCollectionsDocument: Collection $collection, CollectionDocID: $documentId,'
        ' SubCollection: $subCollection, SubCollectionDocId: $subCollectionDocumentId,'
        ' Update: $update, Exception: ${e.toString()}. StackTrace: $s',
        logType: LogType.error,
      );
      return false;
    }
  }

  /// Deletes existing document from Firebase.
  ///
  /// [collection] is the name of the collection.
  /// [documentId] is the ID of the document within that collection.
  Future<bool> deleteDocument(String collection, String documentId) async {
    try {
      _loggingService.log('FirestoreHelper.deleteDocument: Deleting. Collection $collection, DocId: $documentId');
      await _firebaseFirestore.collection(collection).doc(documentId).delete();
      _loggingService.log('FirestoreHelper.deleteDocument: Deleted. Collection $collection, DocId: $documentId');
      return true;
    } catch (e, s) {
      _loggingService.log('FirestoreHelper.deleteDocument: Exception: $e. StackTrace: $s', logType: LogType.error);
      return false;
    }
  }

  /// Deletes existing documents from Firebase.
  ///
  /// [query] is query. If document will match that particular [query]
  /// it will be deleted.
  Future<bool> deleteDocumentsByQuery(Query query) async {
    try {
      _loggingService.log('FirestoreHelper.deleteDocumentsByQuery: Deleting. Query: ${query.parameters}');
      final QuerySnapshot querySnapshot = await query.get();
      final List<Future> futures = [];

      querySnapshot.docs.forEach((element) {
        _loggingService.log('FirestoreHelper.deleteDocumentsByQuery: Deleting. DocId: ${element.id}');
        futures.add(element.reference.delete());
      });

      await Future.wait(futures);

      return true;
    } catch (e, s) {
      _loggingService.log('FirestoreHelper.deleteDocumentsByQuery: Exception: $e. StackTrace: $s', logType: LogType.error);
      return false;
    }
  }

  /// Deletes existing document from sub-collection in Firebase.
  ///
  /// [collection] is the name of the collection.
  /// [documentId] is the ID of the document within that collection.
  /// [subCollection] is the name of the document within that collection.
  /// [subCollectionDocumentId] is the ID of the document within that collection.
  Future<bool> deleteSubCollectionDocument({
    required String collection,
    required String documentId,
    required String subCollection,
    required String subCollectionDocumentId,
  }) async {
    try {
      _loggingService.log('FirestoreHelper.deleteSubCollectionDocument: Deleting. Collection $collection, DocId: $documentId'
          ' SubCollection $subCollection, SubCollectionDocId: $subCollectionDocumentId');
      await _firebaseFirestore
          .collection(collection)
          .doc(documentId)
          .collection(subCollection)
          .doc(subCollectionDocumentId)
          .delete();
      _loggingService.log('FirestoreHelper.deleteSubCollectionDocument: Deleted. Collection $collection, DocId: $documentId');
      return true;
    } catch (e, s) {
      _loggingService.log('FirestoreHelper.deleteSubCollectionDocument: Exception: $e. StackTrace: $s', logType: LogType.error);
      return false;
    }
  }

  /// Retrieves list of items from Firestore. It simplifies pagination flow, so services doesn't need
  /// to contain boilerplate code.
  ///
  /// [userId] is document id of the [User].
  /// [query] is the query used for the firestore.
  /// [logReference] is reference string for logging purposes so we know when this query gets executed
  /// and what executes it.
  /// [onDocumentSnapshot] is a method with return type of an object.
  /// [lastDocumentSnapshot] must not be null if pagination is required as it is an indicator of where to
  /// continue query.
  Future<List<T>?> getElements<T>({
    required Query query,
    required String logReference,
    required T Function(DocumentSnapshot documentSnapshot) onDocumentSnapshot,
    DocumentSnapshot? lastDocumentSnapshot,
  }) async {
    final bool isMoreQuery = lastDocumentSnapshot != null;
    final Query currentQuery = isMoreQuery ? query.startAfterDocument(lastDocumentSnapshot) : query;

    _loggingService.log('FirestoreHelper.getElements.$logReference: More: $isMoreQuery');
    try {
      final QuerySnapshot querySnapshot = await currentQuery.get();
      final List<T> elements = querySnapshot.docs.map((e) {
        final T element = onDocumentSnapshot(e);

        return element;
      }).toList();

      _loggingService.log('FirestoreHelper.getElements.$logReference: Total: ${elements.length}');
      return elements;
    } catch (e, s) {
      _loggingService.log(
        'FirestoreTransactionsService.getElements: Exception: $e. StackTrace: $s',
        logType: LogType.error,
      );
      return null;
    }
  }

  /// Retrieves an item from Firestore.
  ///
  /// [collection] is the name of the collection.
  /// [documentId] is the ID of the document within that collection.
  /// [logReference] is reference string for logging purposes so we know when this query gets executed
  /// and what executes it.
  /// [onDocumentSnapshot] is a method with return type of an object.
  Future<T?> getElement<T>(
    String collection,
    String documentId,
    String logReference, {
    required T? Function(DocumentSnapshot documentSnapshot) onDocumentSnapshot,
  }) async {
    try {
      _loggingService.log('FirestoreHelper.getElement.$logReference: Collection: $collection, DocId: $documentId');
      final DocumentSnapshot documentSnapshot = await _firebaseFirestore.collection(collection).doc(documentId).get();
      final T element = onDocumentSnapshot(documentSnapshot)!;

      return element;
    } catch (e, s) {
      _loggingService.log(
        'FirestoreHelper.getElement.$logReference: Collection: $collection, DocId: $documentId, Exception: $e. StackTrace: $s',
        logType: LogType.error,
      );
      return null;
    }
  }

  /// Retrieves [true] if there are more items and [false] if there are no more items for the
  /// specific [query]. This method is mostly used for pagination purpose.
  ///
  /// [query] is a query (creativity is not my best strength).
  /// [lastDocumentSnapshot] is the last [DocumentSnapshot] contained within the list of items.
  /// [onDocumentSnapshot] is a method with return type of an object.
  Future<bool> areMoreElementsAvailable<T>({
    required Query query,
    required DocumentSnapshot lastDocumentSnapshot,
    required T Function(DocumentSnapshot documentSnapshot) onDocumentSnapshot,
  }) async {
    _loggingService.log('FirestoreHelper.areMoreElementsAvailable: Last Document ID: ${lastDocumentSnapshot.id}');

    final List<T>? elements = await getElements<T>(
      query: query..limit(1),
      logReference: 'FirestoreHelper.areMoreElementsAvailable',
      onDocumentSnapshot: (documentSnapshot) => onDocumentSnapshot(documentSnapshot),
      lastDocumentSnapshot: lastDocumentSnapshot,
    );

    if (elements == null || elements.isEmpty) {
      _loggingService.log('FirestoreHelper.areMoreElementsAvailable: No more elements');
      return false;
    } else {
      _loggingService.log('FirestoreHelper.areMoreElementsAvailable: More elements exists.');
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

    _loggingService
        .log('FirestoreHelper.listenToElementsStream.$logReference: Query: ${query.parameters}, IsMoreQuery: $isMoreQuery');

    final StreamSubscription<QuerySnapshot> streamSubscription = currentQuery.snapshots().listen((event) {
      event.docChanges.forEach((docChange) {
        _loggingService.log('FirestoreHelper.listenToElementsStream.$logReference:'
            ' Type: ${docChange.type}. DocId: ${docChange.doc.id}');
        onDocumentChange(docChange);
      });
    });

    return streamSubscription;
  }

  /// Listening for the stream of [DocumentSnapshot] from Firestore.
  /// In case of any changes - [onDocumentChange] will get fired.
  ///
  /// [collection] is the name of the collection.
  /// [documentId] is the ID of the document within that collection.
  /// [logReference] is some string for logging purpose.
  /// [onDocumentChange] is a [ValueSetter] which will return object that was changed within
  /// that particular stream.
  StreamSubscription<DocumentSnapshot> listenToDocument<T>(
    String collection,
    String documentId,
    String logReference, {
    required ValueSetter<DocumentSnapshot> onDocumentChange,
  }) {
    final StreamSubscription<DocumentSnapshot> streamSubscription =
        _firebaseFirestore.collection(collection).doc(documentId).snapshots().listen((documentSnapshot) {
      _loggingService.log('FirestoreHelper.listenToDocument.$logReference: New event.'
          ' Collection: $collection, DocId: $documentId');
      onDocumentChange(documentSnapshot);
    });

    return streamSubscription;
  }

  /// Listening for the stream of [DocumentSnapshot] from Firestore.
  /// In case of any changes - [onDocumentChange] will get fired.
  ///
  /// [collection] is the name of the collection.
  /// [documentId] is the ID of the document within that collection.
  /// [subCollection] is the name of the collection.
  /// [subCollectionDocumentId] is the ID of the document within that collection.
  /// [logReference] is some string for logging purpose.
  /// [onDocumentChange] is a [ValueSetter] which will return object that was changed within
  /// that particular stream.
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
      _loggingService.log('FirestoreHelper.listenToSubCollectionDocument.$logReference: New event. Collection: $collection, '
          'DocId: $documentId, SubCollection: $subCollection, SubCollectionDocId: $subCollectionDocumentId');
      onDocumentChange(event);
    });

    return streamSubscription;
  }
}
