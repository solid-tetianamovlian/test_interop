import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

// import '../node/main.dart';
void main() {
  group(('onBuildAddedHandler'), () {
    test('x', () {
      final a = 3;
      final b = 4;

      expect(a + b, equals(7));
    });
  });
}

// // class DocumentSnapshotMock extends Mock implements DocumentSnapshot {}

// // class EventContextMock extends Mock implements EventContext {}

// // class FirebaseAdminInteropMock extends Mock implements FirebaseAdmin {}

// // class FirebaseInteropMock extends Mock implements FirestoreFunctions {}
