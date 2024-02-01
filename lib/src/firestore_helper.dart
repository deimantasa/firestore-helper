part of firestore_helper;

class FirestoreHelper {
  final FirebaseFirestore _firebaseFirestore;
  final LoggingService _loggingService;

  /// Flag to determine, if extra fields should be included. Read more
  /// in [_includeAdditionalFieldsIntoMap].
  final bool _includeAdditionalFields;

  /// Exclude from coverage since we are using special `test` constructor.
  ///
  /// [includeAdditionalFields] determines if extra fields (createdAt, etc.) will be included.
  /// [isLoggingEnabled] determines if logging is enabled. By default it is disabled in Release mode.
  // coverage:ignore-start
  FirestoreHelper({
    required bool includeAdditionalFields,
    bool isLoggingEnabled = !kReleaseMode,
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
    final timeStamp = Timestamp.fromDate(clock.now());

    if (includeCreatedAt) dataMap.addAll({'createdAt': timeStamp});
    dataMap.addAll({'updatedAt': timeStamp});
  }

  /// Adds a new document into the collection in Firebase.
  ///
  /// [paths] is the list of paths to the document. For example: `myCollection, documentId, mySubCollection` which will
  /// be constructed to `myCollection/documentId/mySubCollection`.
  /// Last item in [paths] must be collection.
  /// [update] is the data which will be added to the document.

  Future<String?> addDocument(List<String> paths, Map<String, dynamic> update) async {
    assert(
        paths.length % 2 == 1,
        'paths must be uneven number since it has to point to the collection. If you want'
        'to include specific documentId, use [addDocumentWithId] method.');

    try {
      if (_includeAdditionalFields) _includeAdditionalFieldsIntoMap(update, includeCreatedAt: true);

      final pathToDocument = paths.join('/');
      final documentReference = await _firebaseFirestore.collection(pathToDocument).add(update);
      _loggingService.log('FirestoreHelper.addDocument: Path: $pathToDocument, Update: $update');

      return documentReference.id;
    } catch (e, s) {
      _loggingService.log(
        'FirestoreHelper.addDocument: Failed. Path: $paths, Update: $update, Exception: ${e.toString()}. StackTrace: $s',
        logType: LogType.error,
      );
      return null;
    }
  }

  /// Adds a new document into the collection in Firebase.
  ///
  /// [paths] is the list of paths to the document. For example: `myCollection, documentId` which will
  /// be constructed to `myCollection/documentId`.
  /// Last item in [paths] must be documentId.
  /// [update] is the data which will be added to the document.

  Future<String?> addDocumentWithId(List<String> paths, Map<String, dynamic> update) async {
    assert(
        paths.length % 2 == 0,
        'paths must be even number since it has to point to the document. If you want'
        'to not include specific documentId, use [addDocument] method.');

    try {
      if (_includeAdditionalFields) _includeAdditionalFieldsIntoMap(update, includeCreatedAt: true);
      final pathToDocument = getPathToDocument(paths);

      await _firebaseFirestore.doc(pathToDocument).set(update);
      _loggingService.log('FirestoreHelper.addDocumentWithId: Path: $pathToDocument, Update: $update');
      return paths.last;
    } catch (e, s) {
      _loggingService.log(
        'FirestoreHelper.addDocumentWithId: Failed. Path: $paths, Update: $update, Exception: ${e.toString()}. StackTrace: $s',
        logType: LogType.error,
      );
      return null;
    }
  }

  /// Updates existing document in Firebase.
  ///
  /// [paths] is the list of paths to the document. For example: `myCollection, documentId` which will
  /// be constructed to `myCollection/documentId`.
  /// [update] is the data which will be updated within that document.
  Future<bool> updateDocument(List<String> paths, Map<String, dynamic> update) async {
    final pathToDocument = getPathToDocument(paths);

    try {
      if (_includeAdditionalFields) _includeAdditionalFieldsIntoMap(update);
      await _firebaseFirestore.doc(pathToDocument).update(update);
      _loggingService.log('FirestoreHelper.updateDocument: Path: $pathToDocument, Update: $update');
      return true;
    } catch (e, s) {
      _loggingService.log(
        'FirestoreHelper.updateDocument: '
        'Failed. Path: $pathToDocument, Update: $update, Exception: ${e.toString()}. StackTrace: $s',
        logType: LogType.error,
      );
      return false;
    }
  }

  /// Deletes existing document from Firebase.
  ///
  /// [paths] is the list of paths to the document. For example: `myCollection, documentId` which will
  /// be constructed to `myCollection/documentId`.
  Future<bool> deleteDocument(List<String> paths) async {
    final pathToDocument = getPathToDocument(paths);

    try {
      await _firebaseFirestore.doc(pathToDocument).delete();
      _loggingService.log('FirestoreHelper.deleteDocument: Deleted. Path: $pathToDocument');
      return true;
    } catch (e, s) {
      _loggingService.log(
        'FirestoreHelper.deleteDocument: Path: $pathToDocument, Exception: $e. StackTrace: $s',
        logType: LogType.error,
      );
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
      final querySnapshot = await query.get();
      final futures = <Future>[];

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

  /// Retrieves a document from Firestore.
  ///
  /// [paths] is the list of paths to the document. For example: `myCollection, documentId` which will
  /// be constructed to `myCollection/documentId`.
  /// [logReference] is reference string for logging purposes so we know when this query gets executed
  /// and what executes it.
  /// [onDocumentSnapshot] is a method with return type of an object.
  Future<T?> getDocument<T>(
    List<String> paths, {
    required String logReference,
    required T? Function(DocumentSnapshot documentSnapshot) onDocumentSnapshot,
  }) async {
    final pathToDocument = getPathToDocument(paths);

    try {
      _loggingService.log('FirestoreHelper.getDocument.$logReference: Path: $pathToDocument');
      final documentSnapshot = await _firebaseFirestore.doc(pathToDocument).get();
      if (!documentSnapshot.exists) {
        _loggingService.log(
          'FirestoreHelper.getDocument.$logReference: Path: $pathToDocument. Document does not exist',
          logType: LogType.warning,
        );
        return null;
      }

      final element = onDocumentSnapshot(documentSnapshot);

      return element;
    } catch (e, s) {
      _loggingService.log(
        'FirestoreHelper.getDocument.$logReference: Path: $pathToDocument, Exception: $e. StackTrace: $s',
        logType: LogType.error,
      );
      return null;
    }
  }

  /// Retrieves list of documents from Firestore. It simplifies pagination flow, so services doesn't need
  /// to contain boilerplate code.
  ///
  /// [query] is the query used for the firestore.
  /// [logReference] is reference string for logging purposes so we know when this query gets executed
  /// and what executes it.
  /// [onDocumentSnapshot] is a method with return type of an object.
  /// [lastDocumentSnapshot] must not be null if pagination is required as it is an indicator of where to
  /// continue query.
  Future<List<T>?> getDocuments<T>({
    required Query query,
    required String logReference,
    required T? Function(DocumentSnapshot documentSnapshot) onDocumentSnapshot,
    DocumentSnapshot? lastDocumentSnapshot,
  }) async {
    final isMoreQuery = lastDocumentSnapshot != null;
    final currentQuery = isMoreQuery ? query.startAfterDocument(lastDocumentSnapshot) : query;

    _loggingService.log('FirestoreHelper.getDocuments.$logReference: More: $isMoreQuery, Query: ${currentQuery.parameters}');
    try {
      final querySnapshot = await currentQuery.get();
      final elements = querySnapshot.docs.map((e) => onDocumentSnapshot(e)).toList();

      _loggingService.log('FirestoreHelper.getDocuments.$logReference: Total: ${elements.length}');
      return List<T>.from(elements.where((element) => element != null));
    } catch (e, s) {
      _loggingService.log(
        'FirestoreTransactionsService.getDocuments: Exception: $e. StackTrace: $s',
        logType: LogType.error,
      );
      return null;
    }
  }

  /// Retrieves [true] if there are more items and [false] if there are no more items for the
  /// specific [query]. This method is mostly used for pagination purpose.
  ///
  /// [query] is a query.
  /// [lastDocumentSnapshot] is the last [DocumentSnapshot] contained within the list of items.
  /// If [lastDocumentSnapshot] is null, then it checks if at least 1 document exists in the collection.
  /// [onDocumentSnapshot] is a method with return type of an object.
  Future<bool> areMoreDocumentsAvailable<T>({
    required Query query,
    required DocumentSnapshot lastDocumentSnapshot,
    required T? Function(DocumentSnapshot documentSnapshot) onDocumentSnapshot,
  }) async {
    _loggingService.log('FirestoreHelper.areMoreDocumentsAvailable: Last Document ID: ${lastDocumentSnapshot.id}');

    final elements = await getDocuments<T>(
      query: query.limit(1),
      logReference: 'FirestoreHelper.areMoreDocumentsAvailable',
      onDocumentSnapshot: (documentSnapshot) => onDocumentSnapshot(documentSnapshot),
      lastDocumentSnapshot: lastDocumentSnapshot,
    );

    if (elements == null || elements.isEmpty) {
      _loggingService.log('FirestoreHelper.areMoreDocumentsAvailable: No more elements');
      return false;
    } else {
      _loggingService.log('FirestoreHelper.areMoreDocumentsAvailable: More elements exists.');
      return true;
    }
  }

  /// Retrieves [true] if there are more than one document within specific [query].
  ///
  /// [query] is a query.
  /// [onDocumentSnapshot] is a method with return type of an object.
  Future<bool> hasAnyDocuments<T>({
    required Query query,
    required T? Function(DocumentSnapshot documentSnapshot) onDocumentSnapshot,
  }) async {
    _loggingService.log('FirestoreHelper.hasAnyDocuments');

    final elements = await getDocuments<T>(
      query: query.limit(1),
      logReference: 'FirestoreHelper.hasAnyDocuments',
      onDocumentSnapshot: (documentSnapshot) => onDocumentSnapshot(documentSnapshot),
    );

    if (elements == null || elements.isEmpty) {
      _loggingService.log('FirestoreHelper.hasAnyDocuments: No more elements');
      return false;
    } else {
      _loggingService.log('FirestoreHelper.hasAnyDocuments: More elements exists.');
      return true;
    }
  }

  /// Retrieves [int] count of the documents within specific [query].
  ///
  /// [query] is a query.
  /// [onDocumentSnapshot] is a method with return type of an object.
  Future<int?> getDocumentsCount({
    required Query query,
  }) async {
    _loggingService.log('FirestoreHelper.getDocumentsCount: Query: ${query.parameters}');

    final querySnap = await query.count().get();
    final count = querySnap.count;

    return count;
  }

  /// Listening for the stream of [DocumentSnapshot] from Firestore.
  /// In case of any changes - [onDocumentChange] will get fired.
  ///
  /// [paths] is the list of paths to the document. For example: `myCollection, documentId` which will
  /// be constructed to `myCollection/documentId`.
  /// [logReference] is some string for logging purpose.
  /// [onDocumentChange] is a [ValueSetter] which will return object that was changed within
  /// that particular stream.
  StreamSubscription<DocumentSnapshot> listenToDocument<T>(
    List<String> paths, {
    required String logReference,
    required ValueSetter<DocumentSnapshot> onDocumentChange,
  }) {
    final pathToDocument = getPathToDocument(paths);
    final streamSubscription = _firebaseFirestore.doc(pathToDocument).snapshots().listen((documentSnapshot) {
      _loggingService.log('FirestoreHelper.listenToDocument.$logReference: New event. Path: $pathToDocument');
      onDocumentChange(documentSnapshot);
    });

    return streamSubscription;
  }

  /// Listening for the stream of [QuerySnapshot] from Firestore.
  ///
  /// [logReference] is some string for logging purpose.
  /// [query] is query used for this particular call.
  /// [onDocumentChange] is a [ValueSetter] which will return [DocumentChange] object from firestore.
  /// [lastDocumentSnapshot] is the snapshot of the last document. If [lastDocumentSnapshot] is null, it means
  /// there will be no pagination.
  StreamSubscription<QuerySnapshot> listenToDocumentsStream({
    required String logReference,
    required Query query,
    required ValueSetter<DocumentChange> onDocumentChange,
    DocumentSnapshot? lastDocumentSnapshot,
  }) {
    final isMoreQuery = lastDocumentSnapshot != null;
    final currentQuery = isMoreQuery ? query.startAfterDocument(lastDocumentSnapshot) : query;

    _loggingService.log('FirestoreHelper.listenToDocumentsStream.$logReference: '
        'Query: ${query.parameters}, IsMoreQuery: $isMoreQuery');

    final streamSubscription = currentQuery.snapshots().listen((event) {
      event.docChanges.forEach((docChange) {
        _loggingService.log('FirestoreHelper.listenToDocumentsStream.$logReference:'
            ' Type: ${docChange.type}. DocId: ${docChange.doc.id}');
        onDocumentChange(docChange);
      });
    });

    return streamSubscription;
  }

  @visibleForTesting
  String getPathToDocument(List<String> paths) {
    assert(paths.isNotEmpty, 'paths cannot be empty. It at least has to contain of `collection` and `document` pair.');
    assert(
      paths.length % 2 == 0,
      'paths must not be even number. It seems you are pointing to the collection instead of the document. Double check if ${paths.last} is a document.',
    );
    return paths.join('/');
  }
}
