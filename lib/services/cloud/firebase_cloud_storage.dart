import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mynotes/services/cloud/cloud_storage_constants.cart.dart';
import 'package:mynotes/services/cloud/cloud_storage_exceptions.dart';

import 'cloud_note.dart';

class FirebaseCloudStorage {
  final notes = FirebaseFirestore.instance.collection("notes");

  Future<void> deleteNote({required String documentId}) async {
    try {
      await notes.doc(documentId).delete();
    } catch (e) {
      CouldNotDeleteNoteException();
    }
  }

  Future<void> updateNote({
    required String documentId,
    required String text,
  }) async {
    try {
      await notes.doc(documentId).update({textFieldName: text});
    } catch (e) {
      throw CouldNotUpdateNoteException();
    }
  }

  Stream<Iterable<CloudNote>> allNotes({required String ownerUserId}) =>
      notes.where (ownerUserId, isEqualTo: ownerUserId).snapshots().map((event) => event.docs
          .map((doc) => CloudNote.fromSnapshot(doc)));

  Future<CloudNote> createNewNote({required String ownerUserId}) async {
    final document = await notes.add(
      {
        ownerUserIdFieldName: ownerUserId,
        textFieldName: "",
      },
    );
    final fetchedNote = await document.get();
    return CloudNote(
      documentId: fetchedNote.id,
      ownerUserId: ownerUserId,
      text: "",
    );
  }
  //Singleton
  FirebaseCloudStorage._privateConstructor();

  static final FirebaseCloudStorage _sharedInstance =
      FirebaseCloudStorage._privateConstructor();

  factory FirebaseCloudStorage() => _sharedInstance;
}
