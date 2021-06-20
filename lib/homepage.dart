import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:peeku/Categories.dart';
import 'package:peeku/Finance.dart';
import 'package:peeku/internship.dart';
import 'package:peeku/webView.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //final FirebaseMessaging _messaging = FirebaseMessaging();

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
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(tabs: <Widget>[
            Tab(
              text: 'All',
            ),
            Tab(
              text: 'Internship',
            ),
            Tab(
              text: 'Finance',
            ),
          ]),

          // leading: IconButton(
          //   icon: Icon(Icons.ac_unit, color: Colors.transparent,),
          //   onPressed: () { },
          // ),
          // backgroundColor: Colors.transparent,
          // // toolbarHeight: 40.0,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "IN",
                style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold),
              ),
              Text(
                "PIX",
                style: TextStyle(
                    fontSize: 25.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.yellow),
              )
            ],
          ),
          // actions: [
          //   IconButton(icon: Icon(Icons.share_outlined, color: Colors.yellow, size: 25,), onPressed: (){_shareImageFromUrl();})
          // ],
        ),
        // floatingActionButton: FloatingActionButton(
        //   child: Icon(Icons.share),
        //   onPressed: (){},
        //
        // ),
        bottomNavigationBar: BottomAppBar(
            shape: CircularNotchedRectangle(),
            color: Colors.transparent,
            child: Padding(
              padding: EdgeInsets.only(bottom: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(onPressed: (){
                    Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Categories()));
                        }, icon: Icon(Icons.category_sharp, color: Colors.yellow,)),
                  IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Icons.home,
                        color: Colors.yellow,
                      )),
                  IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Icons.share,
                        color: Colors.yellow,
                      )),
                ],
              ),
            )),
        body: TabBarView(
          children: [
            _loadingNews == true
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
            Internship(),
            Finance()
          ],
        )
      ),
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

// ignore: must_be_immutable
class NewsPics extends StatelessWidget {
  String imgUrl;
  String link;

  NewsPics({@required this.imgUrl, @required this.link});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ArticleView(
                      postUrl: link,
                    )));
      },
      child: Container(
        alignment: Alignment.topCenter,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(6)),
//        margin: EdgeInsets.only(bottom: 16, right: 10, left: 10),
//        width: MediaQuery.of(context).size.width,
        child: Stack(
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.network(
                imgUrl,
//                height: MediaQuery.of(context).size.height,
                //width: MediaQuery.of(context).size.width,
                fit: BoxFit.cover,
              ),
            )
          ],
        ),
      ),
    );
  }
}
