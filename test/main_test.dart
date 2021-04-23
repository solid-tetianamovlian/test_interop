// @TestOn('node')
import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import '../node/main.dart';

void main() {
  group(('onBuildAddedHandler'), () {
    const projectId = 'projectId';
    const duration = 123;

    final buildDay = Timestamp.fromDateTime(DateTime.now());
    final build = {
      'duration': duration,
      'projectId': projectId,
      'buildStatus': 'BuildStatus.successful',
      'startedAt': buildDay,
      'coverage': 100,
      'url': 'url',
      'workflowName': 'workflowName',
    };

    final buildDayData = {
      'projectId': projectId,
      'successful': _incrementField(1),
      'totalDuration': _incrementField(duration),
      'day': _getDateTimeUTC(buildDay),
    };

    final _documentSnapshotMock = DocumentSnapshotMock();
    final _eventContextMock = EventContextMock();
    final _firestoreMock = FirestoreMock();
    final _collectionReferenceMock = CollectionReferenceMock();
    final _documentReferenceMock = DocumentReferenceMock();

    setUp(() {
      reset(_documentSnapshotMock);
      reset(_eventContextMock);
      reset(_firestoreMock);
      reset(_collectionReferenceMock);
      reset(_documentReferenceMock);
    });

    tearDown(() {
      reset(_documentSnapshotMock);
      reset(_eventContextMock);
      reset(_firestoreMock);
      reset(_collectionReferenceMock);
      reset(_documentReferenceMock);
    });

    test('adds build day data for the given project', () async {
      when(_documentSnapshotMock.firestore).thenReturn(_firestoreMock);
      when(_firestoreMock.collection(any)).thenReturn(_collectionReferenceMock);
      when(_collectionReferenceMock.document(any))
          .thenReturn(_documentReferenceMock);

      when(_documentSnapshotMock.data).thenReturn(
        DocumentData.fromMap(build),
      );
      await onBuildAddedHandler(_documentSnapshotMock, _eventContextMock);

      print('BuildTestData: $buildDayData');

      verify(_documentReferenceMock.setData(
              DocumentData.fromMap(buildDayData), any))
          .called(1);
    });
  });
}

DateTime _getDateTimeUTC(Timestamp buildDay) {
  final dateTime = buildDay.toDateTime().toUtc();

  return DateTime.utc(dateTime.year, dateTime.month, dateTime.day);
}

FieldValue _incrementField(int value) {
  return Firestore.fieldValues.increment(value);
}

class FirestoreMock extends Mock implements Firestore {}

class CollectionReferenceMock extends Mock implements CollectionReference {}

class DocumentReferenceMock extends Mock implements DocumentReference {}

class DocumentSnapshotMock extends Mock implements DocumentSnapshot {}

class EventContextMock extends Mock implements EventContext {}
