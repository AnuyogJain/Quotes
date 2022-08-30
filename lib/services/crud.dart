import 'package:cloud_firestore/cloud_firestore.dart';

class CrudMethods {
  Future<void> addData(quoteData) async {
    FirebaseFirestore.instance
        .collection("quotes")
        .add(quoteData)
        .catchError((e) {
      print(e);
    });
  }

  getData() async {
    return await FirebaseFirestore.instance.collection("quotes").snapshots();
  }
}
