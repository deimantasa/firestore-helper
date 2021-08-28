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
    final Timestamp timeStamp = Timestamp.fromDate(clock.now());

    if (includeCreatedAt) dataMap.addAll({'createdAt': timeStamp});
    dataMap.addAll({'updatedAt': timeStamp});
  }

  /// Adds a new document into the collection in Firebase.
  ///
  /// [paths] is the list of paths to the document. For example: `myCollection, documentId` which will
  /// be constructed to `myCollection/documentId`.
  /// [update] is the data which will be added to the document.
  /// [documentId] is the optional ID. If it is specified - [paths] will be amended with your specified [documentId].

  Future<String?> addDocument(
    List<String> paths,
    Map<String, dynamic> update, {
    String? documentId,
  }) async {
    assert(
      paths.length % 2 == 1,
      'paths must be uneven number since it has to point to the collection. If you want to specify documentId, provide'
      'it as a parameter [documentId]',
    );

    try {
      if (_includeAdditionalFields) _includeAdditionalFieldsIntoMap(update, includeCreatedAt: true);
      final String pathToDocument;
      // If docId exists, set document with this particular ID
      if (documentId != null) {
        paths.add(documentId);
        pathToDocument = paths.join('/');

        await _firebaseFirestore.doc(pathToDocument).set(update);
        _loggingService.log('FirestoreHelper.addDocument: Path: $pathToDocument, Update: $update');
        return documentId;
      }
      // If docId doesn't exist, add new document
      else {
        pathToDocument = paths.join('/');
        final DocumentReference documentReference = await _firebaseFirestore.collection(pathToDocument).add(update);
        _loggingService.log('FirestoreHelper.addDocument: Path: $pathToDocument, Update: $update');

        return documentReference.id;
      }
    } catch (e, s) {
      _loggingService.log(
        'FirestoreHelper.addDocument: Failed. Path: $paths, Update: $update, Exception: ${e.toString()}. StackTrace: $s',
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
    final String pathToDocument = getPathToDocument(paths);

    try {
      if (_includeAdditionalFields) _includeAdditionalFieldsIntoMap(update);
      await _firebaseFirestore.doc(pathToDocument).update(update);
      _loggingService.log('FirestoreHelper.updateDocument: Path: $pathToDocument, Update: $update');
      return true;
    } catch (e, s) {
      _loggingService.log(
        'FirestoreHelper.updateDocument: Failed. Path: $pathToDocument, Update: $update, Exception: ${e.toString()}. StackTrace: $s',
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
    final String pathToDocument = getPathToDocument(paths);

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
    required T Function(DocumentSnapshot documentSnapshot) onDocumentSnapshot,
    DocumentSnapshot? lastDocumentSnapshot,
  }) async {
    final bool isMoreQuery = lastDocumentSnapshot != null;
    final Query currentQuery = isMoreQuery ? query.startAfterDocument(lastDocumentSnapshot) : query;

    _loggingService.log('FirestoreHelper.getDocuments.$logReference: More: $isMoreQuery');
    try {
      final QuerySnapshot querySnapshot = await currentQuery.get();
      final List<T> elements = querySnapshot.docs.map((e) {
        final T element = onDocumentSnapshot(e);

        return element;
      }).toList();

      _loggingService.log('FirestoreHelper.getDocuments.$logReference: Total: ${elements.length}');
      return elements;
    } catch (e, s) {
      _loggingService.log(
        'FirestoreTransactionsService.getDocuments: Exception: $e. StackTrace: $s',
        logType: LogType.error,
      );
      return null;
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
    final String pathToDocument = getPathToDocument(paths);

    try {
      _loggingService.log('FirestoreHelper.getDocument.$logReference: Path: $pathToDocument');
      final DocumentSnapshot documentSnapshot = await _firebaseFirestore.doc(pathToDocument).get();
      final T element = onDocumentSnapshot(documentSnapshot)!;

      return element;
    } catch (e, s) {
      _loggingService.log(
        'FirestoreHelper.getDocument.$logReference: Path: $pathToDocument, Exception: $e. StackTrace: $s',
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
  Future<bool> areMoreDocumentsAvailable<T>({
    required Query query,
    required DocumentSnapshot lastDocumentSnapshot,
    required T Function(DocumentSnapshot documentSnapshot) onDocumentSnapshot,
  }) async {
    _loggingService.log('FirestoreHelper.areMoreDocumentsAvailable: Last Document ID: ${lastDocumentSnapshot.id}');

    final List<T>? elements = await getDocuments<T>(
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
    final bool isMoreQuery = lastDocumentSnapshot != null;
    final Query currentQuery = isMoreQuery ? query.startAfterDocument(lastDocumentSnapshot) : query;

    _loggingService
        .log('FirestoreHelper.listenToDocumentsStream.$logReference: Query: ${query.parameters}, IsMoreQuery: $isMoreQuery');

    final StreamSubscription<QuerySnapshot> streamSubscription = currentQuery.snapshots().listen((event) {
      event.docChanges.forEach((docChange) {
        _loggingService.log('FirestoreHelper.listenToDocumentsStream.$logReference:'
            ' Type: ${docChange.type}. DocId: ${docChange.doc.id}');
        onDocumentChange(docChange);
      });
    });

    return streamSubscription;
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
    final String pathToDocument = getPathToDocument(paths);
    final StreamSubscription<DocumentSnapshot> streamSubscription =
        _firebaseFirestore.doc(pathToDocument).snapshots().listen((documentSnapshot) {
      _loggingService.log('FirestoreHelper.listenToDocument.$logReference: New event. Path: $pathToDocument');
      onDocumentChange(documentSnapshot);
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
