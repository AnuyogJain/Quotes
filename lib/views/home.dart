import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:quotes_app/services/crud.dart';

import 'create_quote.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  CrudMethods crudMethods = new CrudMethods();

  Stream? quotesSnapshot = null;

  Widget QuotesList() {
    return Container(
      child: quotesSnapshot != null
          ? Column(
              children: <Widget>[
                StreamBuilder(
                    stream: quotesSnapshot,
                    builder: ((context, AsyncSnapshot snapshot) {
                      return SizedBox(
                        height: MediaQuery.of(context).size.height - 80,
                        child: ListView.builder(
                            shrinkWrap: true,
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            itemCount: snapshot.data!.docs.length,
                            itemBuilder: (context, index) {
                              return QuotesTile(
                                imgUrl: snapshot.data.docs[index]['imgUrl'],
                                quote: snapshot.data.docs[index]['quote'],
                                desc: snapshot.data.docs[index]['desc'],
                                authorName: snapshot.data.docs[index]
                                    ['authorName'],
                              );
                            }),
                      );
                    }))
              ],
            )
          : Container(
              alignment: Alignment.center,
              child: CircularProgressIndicator(),
            ),
    );
  }

  @override
  void initState() {
    crudMethods.getData().then((result) {
      quotesSnapshot = result;
      //print(quotesSnapshot?.length.toString());

      setState(() {
        quotesSnapshot = result;
      });
      super.initState();
    });
  }

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
      ),
      body: QuotesList(),
      floatingActionButton: Container(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            FloatingActionButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => CreateQuote()));
              },
              child: Icon(Icons.add),
            )
          ],
        ),
      ),
    );
  }
}

class QuotesTile extends StatelessWidget {
  String imgUrl, quote, desc, authorName;

  QuotesTile(
      {required this.imgUrl,
      required this.quote,
      required this.desc,
      required this.authorName});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 8, top: 8),
      child: Stack(
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: CachedNetworkImage(
              imageUrl: imgUrl,
              width: MediaQuery.of(context).size.width,
              fit: BoxFit.cover,
              height: 200,
            ),
          ),
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.black45.withOpacity(0.3),
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            width: MediaQuery.of(context).size.width,
            height: 200,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                // Text(
                //   desc,
                //   style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
                // ),
                // SizedBox(
                //   height: 4,
                // ),
                Text(
                  quote,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
                ),
                SizedBox(
                  height: 4,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '- $authorName',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                SizedBox(
                  height: 4,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
