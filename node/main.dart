import 'package:firebase_functions_interop/firebase_functions_interop.dart';

void main() {
  functions['onBuildAdded'] = functions.firestore
      .document('build/{buildId}')
      .onCreate(onBuildAddedHandler);
}

Future<void> onBuildAddedHandler(
    DocumentSnapshot snapshot, EventContext context) async {
  final buildData = snapshot.data;

  final projectId = buildData.getString('projectId');
  final buildDay = buildData.getTimestamp('startedAt');
  final buildDuration = buildData.getInt('duration');

  final utcDay = _getDateTimeUTC(buildDay);
  final buildDayStatusFieldName = _getBuildDayStatusFieldName(buildData);
  final documentId = '${projectId}_${utcDay.millisecondsSinceEpoch}';

  final data = {
    'projectId': projectId,
    buildDayStatusFieldName: incrementField(1),
    'totalDuration': incrementField(buildDuration),
    'day': utcDay,
  };

  try {
    await snapshot.firestore
        .collection('/build_days')
        .document(documentId)
        .setData(
          DocumentData.fromMap(data),
          SetOptions(merge: true),
        );
  } catch (error) {
    await addTask('build_days_created', snapshot, error, utcDay);
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

FieldValue incrementField(int value) {
  return Firestore.fieldValues.increment(value);
}

void addTask(
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
