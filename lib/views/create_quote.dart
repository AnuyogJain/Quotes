import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:quotes_app/services/crud.dart';
import 'package:random_string/random_string.dart';

class CreateQuote extends StatefulWidget {
  const CreateQuote({Key? key}) : super(key: key);

  @override
  State<CreateQuote> createState() => _CreateQuoteState();
}

class _CreateQuoteState extends State<CreateQuote> {
  String authorName = "", quote = "", desc = "";
  bool randomQuote = false;
  late XFile? selectedImage = null;
  bool _isLoading = false;
  CrudMethods crudMethods = new CrudMethods();

  //getting image from gallery
  Future getImage() async {
    final ImagePicker _picker = ImagePicker();
    // Pick an image
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    setState(() {
      selectedImage = image;
    });
  }

  uploadQuote() async {
    if (selectedImage != null) {
      //Loading Screen
      setState(() {
        _isLoading = true;
      });

      //Uploading image to firebase
      FirebaseStorage storage = FirebaseStorage.instance;

      Reference firebaseStorageRef = storage
          .ref()
          .child("quoteImages")
          .child("${randomAlphaNumeric(9)}.jpg");
      UploadTask uploadTask =
          firebaseStorageRef.putFile(File(selectedImage!.path));

      String downloadUrl = "";

      //Getting image URL
      uploadTask.then((res) async {
        res.ref.getDownloadURL();
        downloadUrl = await firebaseStorageRef.getDownloadURL();
        //print("this is url $downloadUrl");

        //Adding data to firebase
        Map<String, String> quoteMap = {
          "imgUrl": downloadUrl,
          "authorName": authorName,
          "quote": quote,
          "desc": desc,
        };
        crudMethods.addData(quoteMap).then((result) {});
      });

      Navigator.pop(context);
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Text(
            //   "Flutter",
            //   style: TextStyle(
            //     fontSize: 20,
            //   ),
            // ),
            Text(
              "Quotes",
              style: TextStyle(fontSize: 22, color: Colors.blue),
            )
          ],
        ),
        actions: <Widget>[
          GestureDetector(
            onTap: () {
              uploadQuote();
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Icon(Icons.file_upload),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? Container(
              alignment: Alignment.center,
              child: CircularProgressIndicator(),
            )
          : Container(
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: 10,
                  ),
                  GestureDetector(
                    onTap: () {
                      getImage();
                    },
                    child: selectedImage != null
                        ? Container(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.file(
                                File(selectedImage!.path),
                                fit: BoxFit.cover,
                              ),
                            ),
                            width: MediaQuery.of(context).size.width,
                            margin: EdgeInsets.symmetric(horizontal: 15),
                            height: 200,
                          )
                        : Container(
                            margin: EdgeInsets.symmetric(horizontal: 15),
                            height: 200,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(6)),
                            width: MediaQuery.of(context).size.width,
                            child: Icon(
                              Icons.add_a_photo,
                              color: Colors.black45,
                            ),
                          ),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 15),
                    child: randomQuote == false
                        ? Column(
                            children: [
                              TextField(
                                decoration: InputDecoration(hintText: "Quote"),
                                onChanged: (val) {
                                  quote = val;
                                },
                              ),
                              TextField(
                                decoration:
                                    InputDecoration(hintText: "Author Name"),
                                onChanged: (val) {
                                  authorName = val;
                                },
                              ),
                              // TextField(
                              //   decoration: InputDecoration(hintText: "Description"),
                              //   onChanged: (val) {
                              //     desc = val;
                              //   },
                              // ),
                            ],
                          )
                        : Column(
                            children: [
                              SizedBox(
                                height: 8,
                              ),
                              Text(
                                quote,
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w400),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  '- $authorName',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w400),
                                ),
                              ),

                              // TextField(
                              //   decoration: InputDecoration(hintText: "Description"),
                              //   onChanged: (val) {
                              //     desc = val;
                              //   },
                              // ),
                            ],
                          ),
                  ),
                ],
              ),
            ),
      floatingActionButton: Container(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            FloatingActionButton(
              onPressed: () async {
                //using api to get data using http package
                var url = Uri.parse(
                    'https://www.quotepub.com/api/widget/?type=rand&limit=1');
                var response = await http.get(url);
                //print('Response body: ${response.body}');

                //parsing json data to flutter data and filtering quotes and author
                var data = jsonDecode(response.body);
                // var quotes = data[0]["quote_body"];
                //print(quotes);

                setState(() {
                  quote = data[0]["quote_body"];
                  authorName = data[0]["quote_author"];
                  randomQuote = true;
                  // print(quote);
                  // print(authorName);
                });
              },
              child: Icon(Icons.receipt_long),
            )
          ],
        ),
      ),
    );
  }
}
