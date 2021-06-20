import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';

import 'homepage.dart';

class Internship extends StatefulWidget {
  //const Internship({Key? key}) : super(key: key);

  @override
  _InternshipState createState() => _InternshipState();
}

class _InternshipState extends State<Internship> {

  Firestore _firestore = Firestore.instance;
  List<DocumentSnapshot> _news = [];
  bool _loadingNews = true;

  // ignore: non_constant_identifier_names
  int _per_page = 6;
  DocumentSnapshot _lastnews;
  bool _gettingmoreNews = false;
  bool _moreNewsavailable = true;
  int _index = 0;
  var imageurl;
  var title;
  var category1;
  var category2;

  getNews() async {
    Query q = _firestore
        .collection("news")
        .orderBy("timestamps", descending: true)
        .limit(_per_page);
    setState(() {
      _loadingNews = true;
    });

    QuerySnapshot querySnapshot = await q.getDocuments();
    _news = querySnapshot.documents;
    _lastnews = querySnapshot.documents[querySnapshot.documents.length - 1];
    setState(() {
      _loadingNews = false;
    });
  }

  getMoreNews() async {
    print("getmorenews is called");
    try {
      if (_moreNewsavailable == false) {
        print("No More News");
        return;
      }

      if (_gettingmoreNews == true) {
        return;
      }
      _gettingmoreNews = true;

      Query q = _firestore
          .collection("news")
          .orderBy("timestamps", descending: true)
          .startAfter([_lastnews.data["timestamps"]]).limit(_per_page);

      QuerySnapshot querySnapshot = await q.getDocuments();

      if (querySnapshot.documents.length < _per_page) {
        _moreNewsavailable = false;
      }
      _news.addAll(querySnapshot.documents);
      _lastnews = querySnapshot.documents[querySnapshot.documents.length - 1];
      setState(() {
        _gettingmoreNews = false;
      });
    } catch (e) {
      RangeError('Range Exception');
    }
  }

  @override
  void initState() {
    //addData(blogData)
    // TODO: implement initState
    super.initState();

    getNews();
    //uploadToken();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _loadingNews == true
          ? Container(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      )
          : Container(
          child: _news.length == 0
              ? Center(
            child: CircularProgressIndicator(),
          )
              : SafeArea(
            child: RefreshIndicator(
              child: Swiper(
                duration: 1000,
                autoplay: false,
                autoplayDisableOnInteraction: false,
                autoplayDelay: 7000,
                scrollDirection: Axis.vertical,
                itemCount: _news.length,
                onIndexChanged: (int cIndex) {
                  _index = cIndex;
                  print(_index);
                  if (_news.length - 2 == cIndex) {
                    getMoreNews();
                  }
                },
                itemBuilder: (BuildContext context, int index) {
                  imageurl = _news[_index].data["imgUrl"];
                  title = _news[_index].data["headline"];
                  category1 = _news[_index].data["category1"];
                  category2 = _news[_index].data["category2"];

                  return NewsPics(
                      imgUrl: _news[index].data["imgUrl"],
                      link: _news[index].data["link"]);
                },
                fade: 0.5,
                viewportFraction: 0.99,
                scale: 0.85,
                loop: false,
              ),
              onRefresh: getdata,
            ),
          )),
    );
  }

  Future<dynamic> getdata() async {
    setState(() {
      _gettingmoreNews = false;
      _moreNewsavailable = true;
    });
    await getNews();
  }

  Future<void> _shareImageFromUrl() async {
    try {
      var request = await HttpClient().getUrl(Uri.parse('$imageurl'));
      var response = await request.close();
      Uint8List bytes = await consolidateHttpClientResponseBytes(response);
      await Share.file('ESYS $title', '$title.jpg', bytes, 'image/jpg',
          text:
          "Save time. Download INPIX, India's highest rated news magazine app, https://bit.ly/2QhAc2Z ");
    } catch (e) {
      print('error: $e');
    }
  }
}

