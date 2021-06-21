// Mocks generated by Mockito 5.0.10 from annotations
// in firestore_helper/src/utils/mocked_classes.dart.
// Do not manually edit this file.

import 'dart:async' as _i8;
import 'dart:typed_data' as _i10;

import 'package:cloud_firestore/cloud_firestore.dart' as _i2;
import 'package:cloud_firestore_platform_interface/src/get_options.dart'
    as _i11;
import 'package:cloud_firestore_platform_interface/src/persistence_settings.dart'
    as _i9;
import 'package:cloud_firestore_platform_interface/src/platform_interface/platform_interface_document_change.dart'
    as _i7;
import 'package:cloud_firestore_platform_interface/src/set_options.dart'
    as _i12;
import 'package:cloud_firestore_platform_interface/src/settings.dart' as _i4;
import 'package:firebase_core/firebase_core.dart' as _i3;
import 'package:firestore_helper/src/log_type.dart' as _i6;
import 'package:firestore_helper/src/logging_service.dart' as _i5;
import 'package:firestore_helper/src/utils/mock_function.dart' as _i14;
import 'package:logger/src/logger.dart' as _i13;
import 'package:mockito/mockito.dart' as _i1;

// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: comment_references
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis

class _FakeDocumentReference<T extends Object?> extends _i1.Fake
    implements _i2.DocumentReference<T> {}

class _FakeSnapshotMetadata extends _i1.Fake implements _i2.SnapshotMetadata {}

class _FakeDocumentSnapshot<T extends Object?> extends _i1.Fake
    implements _i2.DocumentSnapshot<T> {}

class _FakeFirebaseApp extends _i1.Fake implements _i3.FirebaseApp {
  @override
  String toString() => super.toString();
}

class _FakeSettings extends _i1.Fake implements _i4.Settings {
  @override
  String toString() => super.toString();
}

class _FakeCollectionReference<T extends Object?> extends _i1.Fake
    implements _i2.CollectionReference<T> {}

class _FakeWriteBatch extends _i1.Fake implements _i2.WriteBatch {}

class _FakeLoadBundleTask extends _i1.Fake implements _i2.LoadBundleTask {}

class _FakeQuerySnapshot<T extends Object?> extends _i1.Fake
    implements _i2.QuerySnapshot<T> {}

class _FakeQuery<T extends Object?> extends _i1.Fake implements _i2.Query<T> {}

class _FakeFirebaseFirestore extends _i1.Fake implements _i2.FirebaseFirestore {
  @override
  String toString() => super.toString();
}

/// A class which mocks [LoggingService].
///
/// See the documentation for Mockito's code generation for more information.
class MockLoggingService extends _i1.Mock implements _i5.LoggingService {
  MockLoggingService() {
    _i1.throwOnMissingStub(this);
  }

  @override
  bool get isEnabled =>
      (super.noSuchMethod(Invocation.getter(#isEnabled), returnValue: false)
          as bool);
  @override
  void log(String? message, {_i6.LogType? logType = _i6.LogType.debug}) => super
      .noSuchMethod(Invocation.method(#log, [message], {#logType: logType}),
          returnValueForMissingStub: null);
}

/// A class which mocks [DocumentSnapshot].
///
/// See the documentation for Mockito's code generation for more information.
class MockDocumentSnapshot<T extends Object?> extends _i1.Mock
    implements _i2.DocumentSnapshot<T> {
  MockDocumentSnapshot() {
    _i1.throwOnMissingStub(this);
  }

  @override
  String get id =>
      (super.noSuchMethod(Invocation.getter(#id), returnValue: '') as String);
  @override
  _i2.DocumentReference<T> get reference => (super.noSuchMethod(
      Invocation.getter(#reference),
      returnValue: _FakeDocumentReference<T>()) as _i2.DocumentReference<T>);
  @override
  _i2.SnapshotMetadata get metadata =>
      (super.noSuchMethod(Invocation.getter(#metadata),
          returnValue: _FakeSnapshotMetadata()) as _i2.SnapshotMetadata);
  @override
  bool get exists =>
      (super.noSuchMethod(Invocation.getter(#exists), returnValue: false)
          as bool);
  @override
  dynamic get(Object? field) =>
      super.noSuchMethod(Invocation.method(#get, [field]));
  @override
  dynamic operator [](Object? field) =>
      super.noSuchMethod(Invocation.method(#[], [field]));
}

/// A class which mocks [DocumentChange].
///
/// See the documentation for Mockito's code generation for more information.
class MockDocumentChange<T extends Object?> extends _i1.Mock
    implements _i2.DocumentChange<T> {
  MockDocumentChange() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i7.DocumentChangeType get type =>
      (super.noSuchMethod(Invocation.getter(#type),
          returnValue: _i7.DocumentChangeType.added) as _i7.DocumentChangeType);
  @override
  int get oldIndex =>
      (super.noSuchMethod(Invocation.getter(#oldIndex), returnValue: 0) as int);
  @override
  int get newIndex =>
      (super.noSuchMethod(Invocation.getter(#newIndex), returnValue: 0) as int);
  @override
  _i2.DocumentSnapshot<T> get doc =>
      (super.noSuchMethod(Invocation.getter(#doc),
          returnValue: _FakeDocumentSnapshot<T>()) as _i2.DocumentSnapshot<T>);
}

/// A class which mocks [FirebaseFirestore].
///
/// See the documentation for Mockito's code generation for more information.
class MockFirebaseFirestore extends _i1.Mock implements _i2.FirebaseFirestore {
  MockFirebaseFirestore() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i3.FirebaseApp get app => (super.noSuchMethod(Invocation.getter(#app),
      returnValue: _FakeFirebaseApp()) as _i3.FirebaseApp);
  @override
  set app(_i3.FirebaseApp? _app) =>
      super.noSuchMethod(Invocation.setter(#app, _app),
          returnValueForMissingStub: null);
  @override
  set settings(_i4.Settings? settings) =>
      super.noSuchMethod(Invocation.setter(#settings, settings),
          returnValueForMissingStub: null);
  @override
  _i4.Settings get settings => (super.noSuchMethod(Invocation.getter(#settings),
      returnValue: _FakeSettings()) as _i4.Settings);
  @override
  Map<dynamic, dynamic> get pluginConstants =>
      (super.noSuchMethod(Invocation.getter(#pluginConstants),
          returnValue: <dynamic, dynamic>{}) as Map<dynamic, dynamic>);
  @override
  _i2.CollectionReference<Map<String, dynamic>> collection(
          String? collectionPath) =>
      (super.noSuchMethod(Invocation.method(#collection, [collectionPath]),
              returnValue: _FakeCollectionReference<Map<String, dynamic>>())
          as _i2.CollectionReference<Map<String, dynamic>>);
  @override
  _i2.WriteBatch batch() => (super.noSuchMethod(Invocation.method(#batch, []),
      returnValue: _FakeWriteBatch()) as _i2.WriteBatch);
  @override
  _i8.Future<void> clearPersistence() =>
      (super.noSuchMethod(Invocation.method(#clearPersistence, []),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future.value()) as _i8.Future<void>);
  @override
  _i8.Future<void> enablePersistence(
          [_i9.PersistenceSettings? persistenceSettings]) =>
      (super.noSuchMethod(
          Invocation.method(#enablePersistence, [persistenceSettings]),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future.value()) as _i8.Future<void>);
  @override
  _i2.LoadBundleTask loadBundle(_i10.Uint8List? bundle) =>
      (super.noSuchMethod(Invocation.method(#loadBundle, [bundle]),
          returnValue: _FakeLoadBundleTask()) as _i2.LoadBundleTask);
  @override
  _i8.Future<_i2.QuerySnapshot<Map<String, dynamic>>> namedQueryGet(
          String? name,
          {_i11.GetOptions? options = const _i11.GetOptions()}) =>
      (super.noSuchMethod(
          Invocation.method(#namedQueryGet, [name], {#options: options}),
          returnValue: Future<_i2.QuerySnapshot<Map<String, dynamic>>>.value(
              _FakeQuerySnapshot<Map<String, dynamic>>())) as _i8
          .Future<_i2.QuerySnapshot<Map<String, dynamic>>>);
  @override
  _i2.Query<Map<String, dynamic>> collectionGroup(String? collectionPath) =>
      (super.noSuchMethod(Invocation.method(#collectionGroup, [collectionPath]),
              returnValue: _FakeQuery<Map<String, dynamic>>())
          as _i2.Query<Map<String, dynamic>>);
  @override
  _i8.Future<void> disableNetwork() =>
      (super.noSuchMethod(Invocation.method(#disableNetwork, []),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future.value()) as _i8.Future<void>);
  @override
  _i2.DocumentReference<Map<String, dynamic>> doc(String? documentPath) =>
      (super.noSuchMethod(Invocation.method(#doc, [documentPath]),
              returnValue: _FakeDocumentReference<Map<String, dynamic>>())
          as _i2.DocumentReference<Map<String, dynamic>>);
  @override
  _i8.Future<void> enableNetwork() =>
      (super.noSuchMethod(Invocation.method(#enableNetwork, []),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future.value()) as _i8.Future<void>);
  @override
  _i8.Stream<void> snapshotsInSync() =>
      (super.noSuchMethod(Invocation.method(#snapshotsInSync, []),
          returnValue: Stream<void>.empty()) as _i8.Stream<void>);
  @override
  _i8.Future<T> runTransaction<T>(_i2.TransactionHandler<T>? transactionHandler,
          {Duration? timeout = const Duration(seconds: 30)}) =>
      (super.noSuchMethod(
          Invocation.method(
              #runTransaction, [transactionHandler], {#timeout: timeout}),
          returnValue: Future<T>.value(null)) as _i8.Future<T>);
  @override
  _i8.Future<void> terminate() =>
      (super.noSuchMethod(Invocation.method(#terminate, []),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future.value()) as _i8.Future<void>);
  @override
  _i8.Future<void> waitForPendingWrites() =>
      (super.noSuchMethod(Invocation.method(#waitForPendingWrites, []),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future.value()) as _i8.Future<void>);
  @override
  String toString() => super.toString();
}

/// A class which mocks [CollectionReference].
///
/// See the documentation for Mockito's code generation for more information.
// ignore: must_be_immutable
class MockCollectionReference<T extends Object?> extends _i1.Mock
    implements _i2.CollectionReference<T> {
  MockCollectionReference() {
    _i1.throwOnMissingStub(this);
  }

  @override
  String get id =>
      (super.noSuchMethod(Invocation.getter(#id), returnValue: '') as String);
  @override
  String get path =>
      (super.noSuchMethod(Invocation.getter(#path), returnValue: '') as String);
  @override
  _i2.FirebaseFirestore get firestore =>
      (super.noSuchMethod(Invocation.getter(#firestore),
          returnValue: _FakeFirebaseFirestore()) as _i2.FirebaseFirestore);
  @override
  Map<String, dynamic> get parameters =>
      (super.noSuchMethod(Invocation.getter(#parameters),
          returnValue: <String, dynamic>{}) as Map<String, dynamic>);
  @override
  _i8.Future<_i2.DocumentReference<T>> add(T? data) =>
      (super.noSuchMethod(Invocation.method(#add, [data]),
              returnValue: Future<_i2.DocumentReference<T>>.value(
                  _FakeDocumentReference<T>()))
          as _i8.Future<_i2.DocumentReference<T>>);
  @override
  _i2.DocumentReference<T> doc([String? path]) => (super.noSuchMethod(
      Invocation.method(#doc, [path]),
      returnValue: _FakeDocumentReference<T>()) as _i2.DocumentReference<T>);
  @override
  _i2.CollectionReference<R> withConverter<R extends Object?>(
          {_i2.FromFirestore<R>? fromFirestore,
          _i2.ToFirestore<R>? toFirestore}) =>
      (super.noSuchMethod(
              Invocation.method(#withConverter, [],
                  {#fromFirestore: fromFirestore, #toFirestore: toFirestore}),
              returnValue: _FakeCollectionReference<R>())
          as _i2.CollectionReference<R>);
  @override
  _i2.Query<T> endAtDocument(_i2.DocumentSnapshot<Object?>? documentSnapshot) =>
      (super.noSuchMethod(Invocation.method(#endAtDocument, [documentSnapshot]),
          returnValue: _FakeQuery<T>()) as _i2.Query<T>);
  @override
  _i2.Query<T> endAt(List<Object?>? values) =>
      (super.noSuchMethod(Invocation.method(#endAt, [values]),
          returnValue: _FakeQuery<T>()) as _i2.Query<T>);
  @override
  _i2.Query<T> endBeforeDocument(
          _i2.DocumentSnapshot<Object?>? documentSnapshot) =>
      (super.noSuchMethod(
          Invocation.method(#endBeforeDocument, [documentSnapshot]),
          returnValue: _FakeQuery<T>()) as _i2.Query<T>);
  @override
  _i2.Query<T> endBefore(List<Object?>? values) =>
      (super.noSuchMethod(Invocation.method(#endBefore, [values]),
          returnValue: _FakeQuery<T>()) as _i2.Query<T>);
  @override
  _i8.Future<_i2.QuerySnapshot<T>> get([_i11.GetOptions? options]) =>
      (super.noSuchMethod(Invocation.method(#get, [options]),
              returnValue:
                  Future<_i2.QuerySnapshot<T>>.value(_FakeQuerySnapshot<T>()))
          as _i8.Future<_i2.QuerySnapshot<T>>);
  @override
  _i2.Query<T> limit(int? limit) =>
      (super.noSuchMethod(Invocation.method(#limit, [limit]),
          returnValue: _FakeQuery<T>()) as _i2.Query<T>);
  @override
  _i2.Query<T> limitToLast(int? limit) =>
      (super.noSuchMethod(Invocation.method(#limitToLast, [limit]),
          returnValue: _FakeQuery<T>()) as _i2.Query<T>);
  @override
  _i8.Stream<_i2.QuerySnapshot<T>> snapshots(
          {bool? includeMetadataChanges = false}) =>
      (super.noSuchMethod(
              Invocation.method(#snapshots, [],
                  {#includeMetadataChanges: includeMetadataChanges}),
              returnValue: Stream<_i2.QuerySnapshot<T>>.empty())
          as _i8.Stream<_i2.QuerySnapshot<T>>);
  @override
  _i2.Query<T> orderBy(Object? field, {bool? descending = false}) =>
      (super.noSuchMethod(
          Invocation.method(#orderBy, [field], {#descending: descending}),
          returnValue: _FakeQuery<T>()) as _i2.Query<T>);
  @override
  _i2.Query<T> startAfterDocument(
          _i2.DocumentSnapshot<Object?>? documentSnapshot) =>
      (super.noSuchMethod(
          Invocation.method(#startAfterDocument, [documentSnapshot]),
          returnValue: _FakeQuery<T>()) as _i2.Query<T>);
  @override
  _i2.Query<T> startAfter(List<Object?>? values) =>
      (super.noSuchMethod(Invocation.method(#startAfter, [values]),
          returnValue: _FakeQuery<T>()) as _i2.Query<T>);
  @override
  _i2.Query<T> startAtDocument(
          _i2.DocumentSnapshot<Object?>? documentSnapshot) =>
      (super.noSuchMethod(
          Invocation.method(#startAtDocument, [documentSnapshot]),
          returnValue: _FakeQuery<T>()) as _i2.Query<T>);
  @override
  _i2.Query<T> startAt(List<Object?>? values) =>
      (super.noSuchMethod(Invocation.method(#startAt, [values]),
          returnValue: _FakeQuery<T>()) as _i2.Query<T>);
  @override
  _i2.Query<T> where(Object? field,
          {Object? isEqualTo,
          Object? isNotEqualTo,
          Object? isLessThan,
          Object? isLessThanOrEqualTo,
          Object? isGreaterThan,
          Object? isGreaterThanOrEqualTo,
          Object? arrayContains,
          List<Object?>? arrayContainsAny,
          List<Object?>? whereIn,
          List<Object?>? whereNotIn,
          bool? isNull}) =>
      (super.noSuchMethod(
          Invocation.method(#where, [
            field
          ], {
            #isEqualTo: isEqualTo,
            #isNotEqualTo: isNotEqualTo,
            #isLessThan: isLessThan,
            #isLessThanOrEqualTo: isLessThanOrEqualTo,
            #isGreaterThan: isGreaterThan,
            #isGreaterThanOrEqualTo: isGreaterThanOrEqualTo,
            #arrayContains: arrayContains,
            #arrayContainsAny: arrayContainsAny,
            #whereIn: whereIn,
            #whereNotIn: whereNotIn,
            #isNull: isNull
          }),
          returnValue: _FakeQuery<T>()) as _i2.Query<T>);
}

/// A class which mocks [DocumentReference].
///
/// See the documentation for Mockito's code generation for more information.
// ignore: must_be_immutable
class MockDocumentReference<T extends Object?> extends _i1.Mock
    implements _i2.DocumentReference<T> {
  MockDocumentReference() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i2.FirebaseFirestore get firestore =>
      (super.noSuchMethod(Invocation.getter(#firestore),
          returnValue: _FakeFirebaseFirestore()) as _i2.FirebaseFirestore);
  @override
  String get id =>
      (super.noSuchMethod(Invocation.getter(#id), returnValue: '') as String);
  @override
  _i2.CollectionReference<T> get parent =>
      (super.noSuchMethod(Invocation.getter(#parent),
              returnValue: _FakeCollectionReference<T>())
          as _i2.CollectionReference<T>);
  @override
  String get path =>
      (super.noSuchMethod(Invocation.getter(#path), returnValue: '') as String);
  @override
  _i2.CollectionReference<Map<String, dynamic>> collection(
          String? collectionPath) =>
      (super.noSuchMethod(Invocation.method(#collection, [collectionPath]),
              returnValue: _FakeCollectionReference<Map<String, dynamic>>())
          as _i2.CollectionReference<Map<String, dynamic>>);
  @override
  _i8.Future<void> delete() =>
      (super.noSuchMethod(Invocation.method(#delete, []),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future.value()) as _i8.Future<void>);
  @override
  _i8.Future<void> update(Map<String, Object?>? data) =>
      (super.noSuchMethod(Invocation.method(#update, [data]),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future.value()) as _i8.Future<void>);
  @override
  _i8.Future<_i2.DocumentSnapshot<T>> get([_i11.GetOptions? options]) =>
      (super.noSuchMethod(Invocation.method(#get, [options]),
              returnValue: Future<_i2.DocumentSnapshot<T>>.value(
                  _FakeDocumentSnapshot<T>()))
          as _i8.Future<_i2.DocumentSnapshot<T>>);
  @override
  _i8.Stream<_i2.DocumentSnapshot<T>> snapshots(
          {bool? includeMetadataChanges = false}) =>
      (super.noSuchMethod(
              Invocation.method(#snapshots, [],
                  {#includeMetadataChanges: includeMetadataChanges}),
              returnValue: Stream<_i2.DocumentSnapshot<T>>.empty())
          as _i8.Stream<_i2.DocumentSnapshot<T>>);
  @override
  _i8.Future<void> set(T? data, [_i12.SetOptions? options]) =>
      (super.noSuchMethod(Invocation.method(#set, [data, options]),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future.value()) as _i8.Future<void>);
  @override
  _i2.DocumentReference<R> withConverter<R>(
          {_i2.FromFirestore<R>? fromFirestore,
          _i2.ToFirestore<R>? toFirestore}) =>
      (super.noSuchMethod(
              Invocation.method(#withConverter, [],
                  {#fromFirestore: fromFirestore, #toFirestore: toFirestore}),
              returnValue: _FakeDocumentReference<R>())
          as _i2.DocumentReference<R>);
}

/// A class which mocks [Query].
///
/// See the documentation for Mockito's code generation for more information.
class MockQuery<T extends Object?> extends _i1.Mock implements _i2.Query<T> {
  MockQuery() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i2.FirebaseFirestore get firestore =>
      (super.noSuchMethod(Invocation.getter(#firestore),
          returnValue: _FakeFirebaseFirestore()) as _i2.FirebaseFirestore);
  @override
  Map<String, dynamic> get parameters =>
      (super.noSuchMethod(Invocation.getter(#parameters),
          returnValue: <String, dynamic>{}) as Map<String, dynamic>);
  @override
  _i2.Query<T> endAtDocument(_i2.DocumentSnapshot<Object?>? documentSnapshot) =>
      (super.noSuchMethod(Invocation.method(#endAtDocument, [documentSnapshot]),
          returnValue: _FakeQuery<T>()) as _i2.Query<T>);
  @override
  _i2.Query<T> endAt(List<Object?>? values) =>
      (super.noSuchMethod(Invocation.method(#endAt, [values]),
          returnValue: _FakeQuery<T>()) as _i2.Query<T>);
  @override
  _i2.Query<T> endBeforeDocument(
          _i2.DocumentSnapshot<Object?>? documentSnapshot) =>
      (super.noSuchMethod(
          Invocation.method(#endBeforeDocument, [documentSnapshot]),
          returnValue: _FakeQuery<T>()) as _i2.Query<T>);
  @override
  _i2.Query<T> endBefore(List<Object?>? values) =>
      (super.noSuchMethod(Invocation.method(#endBefore, [values]),
          returnValue: _FakeQuery<T>()) as _i2.Query<T>);
  @override
  _i8.Future<_i2.QuerySnapshot<T>> get([_i11.GetOptions? options]) =>
      (super.noSuchMethod(Invocation.method(#get, [options]),
              returnValue:
                  Future<_i2.QuerySnapshot<T>>.value(_FakeQuerySnapshot<T>()))
          as _i8.Future<_i2.QuerySnapshot<T>>);
  @override
  _i2.Query<T> limit(int? limit) =>
      (super.noSuchMethod(Invocation.method(#limit, [limit]),
          returnValue: _FakeQuery<T>()) as _i2.Query<T>);
  @override
  _i2.Query<T> limitToLast(int? limit) =>
      (super.noSuchMethod(Invocation.method(#limitToLast, [limit]),
          returnValue: _FakeQuery<T>()) as _i2.Query<T>);
  @override
  _i8.Stream<_i2.QuerySnapshot<T>> snapshots(
          {bool? includeMetadataChanges = false}) =>
      (super.noSuchMethod(
              Invocation.method(#snapshots, [],
                  {#includeMetadataChanges: includeMetadataChanges}),
              returnValue: Stream<_i2.QuerySnapshot<T>>.empty())
          as _i8.Stream<_i2.QuerySnapshot<T>>);
  @override
  _i2.Query<T> orderBy(Object? field, {bool? descending = false}) =>
      (super.noSuchMethod(
          Invocation.method(#orderBy, [field], {#descending: descending}),
          returnValue: _FakeQuery<T>()) as _i2.Query<T>);
  @override
  _i2.Query<T> startAfterDocument(
          _i2.DocumentSnapshot<Object?>? documentSnapshot) =>
      (super.noSuchMethod(
          Invocation.method(#startAfterDocument, [documentSnapshot]),
          returnValue: _FakeQuery<T>()) as _i2.Query<T>);
  @override
  _i2.Query<T> startAfter(List<Object?>? values) =>
      (super.noSuchMethod(Invocation.method(#startAfter, [values]),
          returnValue: _FakeQuery<T>()) as _i2.Query<T>);
  @override
  _i2.Query<T> startAtDocument(
          _i2.DocumentSnapshot<Object?>? documentSnapshot) =>
      (super.noSuchMethod(
          Invocation.method(#startAtDocument, [documentSnapshot]),
          returnValue: _FakeQuery<T>()) as _i2.Query<T>);
  @override
  _i2.Query<T> startAt(List<Object?>? values) =>
      (super.noSuchMethod(Invocation.method(#startAt, [values]),
          returnValue: _FakeQuery<T>()) as _i2.Query<T>);
  @override
  _i2.Query<T> where(Object? field,
          {Object? isEqualTo,
          Object? isNotEqualTo,
          Object? isLessThan,
          Object? isLessThanOrEqualTo,
          Object? isGreaterThan,
          Object? isGreaterThanOrEqualTo,
          Object? arrayContains,
          List<Object?>? arrayContainsAny,
          List<Object?>? whereIn,
          List<Object?>? whereNotIn,
          bool? isNull}) =>
      (super.noSuchMethod(
          Invocation.method(#where, [
            field
          ], {
            #isEqualTo: isEqualTo,
            #isNotEqualTo: isNotEqualTo,
            #isLessThan: isLessThan,
            #isLessThanOrEqualTo: isLessThanOrEqualTo,
            #isGreaterThan: isGreaterThan,
            #isGreaterThanOrEqualTo: isGreaterThanOrEqualTo,
            #arrayContains: arrayContains,
            #arrayContainsAny: arrayContainsAny,
            #whereIn: whereIn,
            #whereNotIn: whereNotIn,
            #isNull: isNull
          }),
          returnValue: _FakeQuery<T>()) as _i2.Query<T>);
  @override
  _i2.Query<R> withConverter<R>(
          {_i2.FromFirestore<R>? fromFirestore,
          _i2.ToFirestore<R>? toFirestore}) =>
      (super.noSuchMethod(
          Invocation.method(#withConverter, [],
              {#fromFirestore: fromFirestore, #toFirestore: toFirestore}),
          returnValue: _FakeQuery<R>()) as _i2.Query<R>);
}

/// A class which mocks [QuerySnapshot].
///
/// See the documentation for Mockito's code generation for more information.
class MockQuerySnapshot<T extends Object?> extends _i1.Mock
    implements _i2.QuerySnapshot<T> {
  MockQuerySnapshot() {
    _i1.throwOnMissingStub(this);
  }

  @override
  List<_i2.QueryDocumentSnapshot<T>> get docs =>
      (super.noSuchMethod(Invocation.getter(#docs),
              returnValue: <_i2.QueryDocumentSnapshot<T>>[])
          as List<_i2.QueryDocumentSnapshot<T>>);
  @override
  List<_i2.DocumentChange<T>> get docChanges => (super.noSuchMethod(
      Invocation.getter(#docChanges),
      returnValue: <_i2.DocumentChange<T>>[]) as List<_i2.DocumentChange<T>>);
  @override
  _i2.SnapshotMetadata get metadata =>
      (super.noSuchMethod(Invocation.getter(#metadata),
          returnValue: _FakeSnapshotMetadata()) as _i2.SnapshotMetadata);
  @override
  int get size =>
      (super.noSuchMethod(Invocation.getter(#size), returnValue: 0) as int);
}

/// A class which mocks [StreamSubscription].
///
/// See the documentation for Mockito's code generation for more information.
class MockStreamSubscription<T> extends _i1.Mock
    implements _i8.StreamSubscription<T> {
  MockStreamSubscription() {
    _i1.throwOnMissingStub(this);
  }

  @override
  bool get isPaused =>
      (super.noSuchMethod(Invocation.getter(#isPaused), returnValue: false)
          as bool);
  @override
  _i8.Future<void> cancel() =>
      (super.noSuchMethod(Invocation.method(#cancel, []),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future.value()) as _i8.Future<void>);
  @override
  void onData(void Function(T)? handleData) =>
      super.noSuchMethod(Invocation.method(#onData, [handleData]),
          returnValueForMissingStub: null);
  @override
  void onError(Function? handleError) =>
      super.noSuchMethod(Invocation.method(#onError, [handleError]),
          returnValueForMissingStub: null);
  @override
  void onDone(void Function()? handleDone) =>
      super.noSuchMethod(Invocation.method(#onDone, [handleDone]),
          returnValueForMissingStub: null);
  @override
  void pause([_i8.Future<void>? resumeSignal]) =>
      super.noSuchMethod(Invocation.method(#pause, [resumeSignal]),
          returnValueForMissingStub: null);
  @override
  void resume() => super.noSuchMethod(Invocation.method(#resume, []),
      returnValueForMissingStub: null);
  @override
  _i8.Future<E> asFuture<E>([E? futureValue]) =>
      (super.noSuchMethod(Invocation.method(#asFuture, [futureValue]),
          returnValue: Future<E>.value(null)) as _i8.Future<E>);
}

/// A class which mocks [Logger].
///
/// See the documentation for Mockito's code generation for more information.
class MockLogger extends _i1.Mock implements _i13.Logger {
  MockLogger() {
    _i1.throwOnMissingStub(this);
  }

  @override
  void v(dynamic message, [dynamic error, StackTrace? stackTrace]) =>
      super.noSuchMethod(Invocation.method(#v, [message, error, stackTrace]),
          returnValueForMissingStub: null);
  @override
  void d(dynamic message, [dynamic error, StackTrace? stackTrace]) =>
      super.noSuchMethod(Invocation.method(#d, [message, error, stackTrace]),
          returnValueForMissingStub: null);
  @override
  void i(dynamic message, [dynamic error, StackTrace? stackTrace]) =>
      super.noSuchMethod(Invocation.method(#i, [message, error, stackTrace]),
          returnValueForMissingStub: null);
  @override
  void w(dynamic message, [dynamic error, StackTrace? stackTrace]) =>
      super.noSuchMethod(Invocation.method(#w, [message, error, stackTrace]),
          returnValueForMissingStub: null);
  @override
  void e(dynamic message, [dynamic error, StackTrace? stackTrace]) =>
      super.noSuchMethod(Invocation.method(#e, [message, error, stackTrace]),
          returnValueForMissingStub: null);
  @override
  void wtf(dynamic message, [dynamic error, StackTrace? stackTrace]) =>
      super.noSuchMethod(Invocation.method(#wtf, [message, error, stackTrace]),
          returnValueForMissingStub: null);
  @override
  void log(_i13.Level? level, dynamic message,
          [dynamic error, StackTrace? stackTrace]) =>
      super.noSuchMethod(
          Invocation.method(#log, [level, message, error, stackTrace]),
          returnValueForMissingStub: null);
  @override
  void close() => super.noSuchMethod(Invocation.method(#close, []),
      returnValueForMissingStub: null);
}

/// A class which mocks [FunctionMock].
///
/// See the documentation for Mockito's code generation for more information.
class MockFunction<T> extends _i1.Mock implements _i14.FunctionMock<T> {
  MockFunction() {
    _i1.throwOnMissingStub(this);
  }

  @override
  void call([T? object]) =>
      super.noSuchMethod(Invocation.method(#call, [object]),
          returnValueForMissingStub: null);
}
