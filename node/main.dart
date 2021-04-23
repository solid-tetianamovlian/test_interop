import 'package:firebase_functions_interop/firebase_functions_interop.dart';

void main() {
  functions['onBuildAdded'] = functions.firestore
      .document('build/{buildId}')
      .onCreate(onBuildAddedHandler);
}

Future<void> onBuildAddedHandler(
    DocumentSnapshot snapshot, EventContext context) async {
  print('onBuildAddedHandler');
  final buildData = snapshot.data;
  print(buildData.toMap());

  final projectId = buildData.getString('projectId');
  print('projectId: $projectId');
  final buildDay = buildData.getTimestamp('startedAt');
  final buildDuration = buildData.getInt('duration');
  print('duration: $buildDuration');

  final utcDay = _getDateTimeUTC(buildDay);
  print(utcDay);
  final buildDayStatusFieldName = _getBuildDayStatusFieldName(buildData);
  print('buildDayStatusFieldName: $buildDayStatusFieldName');
  final documentId = '${projectId}_${utcDay.millisecondsSinceEpoch}';
  print('documentId: $documentId');

  final data = {
    'projectId': projectId,
    buildDayStatusFieldName: _incrementField(1),
    'totalDuration': _incrementField(buildDuration),
    'day': utcDay,
  };

  print(data);

  try {
    print('in try 1');
    await snapshot.firestore
        .collection('/build_days')
        .document(documentId)
        .setData(
          DocumentData.fromMap(data),
          SetOptions(merge: true),
        );
    print('in try 2');
  } catch (error) {
    print('in error');
    await _addTask('build_days_created', snapshot, error, utcDay);
  }
}

DateTime _getDateTimeUTC(Timestamp buildDay) {
  final dateTime = buildDay.toDateTime().toUtc();

  return DateTime.utc(dateTime.year, dateTime.month, dateTime.day);
}

String _getBuildDayStatusFieldName(DocumentData documentData) {
  final buildStatus = documentData.getString('buildStatus');

  return buildStatus.split('.').last;
}

FieldValue _incrementField(int value) {
  print('in field increment');
  return Firestore.fieldValues.increment(value);
}

void _addTask(
  String code,
  DocumentSnapshot snapshot,
  String error,
  DateTime day,
) async {
  print('ADD TASK');
  final taskData = {
    'code': code,
    'data': snapshot.data.toMap(),
    'context': error.toString(),
    'createdAt': day,
  };

  await snapshot.firestore
      .collection('tasks')
      .add(DocumentData.fromMap(taskData));
}
