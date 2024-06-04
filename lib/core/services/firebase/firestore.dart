import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:talker_flutter/talker_flutter.dart';

class Firestore {
  static final instance = Firestore();
  static late final FirebaseFirestore db;
  final talker = Talker();

  static Future<void> init() async {
    db = FirebaseFirestore.instance;
  }

  void addData(Map<String, dynamic> data, String collection) {
    db.collection(collection).add(data).then((DocumentReference doc) =>
        talker.info('DocumentSnapshot added with ID: ${doc.id}'));
  }

  Future<List<Map<String, dynamic>>> readAllData(String collection) async {
    var result = <Map<String, dynamic>>[];
    await db.collection(collection).get().then((event) {
      for (var doc in event.docs) {
        // final docId = doc.id;
        final docData = doc.data();
        result.add(docData);
      }
    });
    return result;
  }

  Future<Map<String, dynamic>> readSpecificData(
      String collection, String id) async {
    var result = <String, dynamic>{};
    try {
      await db.collection(collection).where('id', isEqualTo: id).get().then((event) {
        for (var doc in event.docs) {
          result = doc.data();
          return result;
        }
      });
    } catch (e) {
      return result;
    }
  return result;
  }
}
