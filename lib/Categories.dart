import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Categories extends StatefulWidget {
  //const Categories({Key? key}) : super(key: key);

  @override
  _CategoriesState createState() => _CategoriesState();
}

class _CategoriesState extends State<Categories> {
  Firestore _firestore = Firestore.instance;
  List<DocumentSnapshot> _categories = [];

  getCategories() async {
    Query q = _firestore
        .collection("categories");
    QuerySnapshot querySnapshot = await q.getDocuments();
    _categories = querySnapshot.documents;
  }

  @override
  void initState() {

    getCategories();
    print(_categories.length);
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
            child: Text(
          'CATEGORIES',
          style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold, color: Colors.yellow),
        )),
        actions: [
          IconButton(onPressed: (){}, icon: Icon(Icons.ac_unit_outlined, color: Colors.transparent,))
        ],
      ),
      body: ListView.builder(itemCount: _categories.length,
      itemBuilder: (BuildContext context, int index){
        return CategoryTile(_categories[index].data["categories"], _categories[index].data["imageurl"]);
      },
      ),

    );



  }

}

class CategoryTile extends StatelessWidget {

  String imageurl;
  String category;
  CategoryTile(@required this.category, @required this.imageurl);
 // const CategoryTile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Container(
        //color: Colors.red,
        alignment: Alignment.topCenter,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(6)),
//        margin: EdgeInsets.only(bottom: 16, right: 10, left: 10),
//        width: MediaQuery.of(context).size.width,
        child: Stack(
          children: <Widget>[


            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.network(
                imageurl,
                height: 50,
                width: 400,
                fit: BoxFit.cover,
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 15),
                child: Text(category, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.black ),),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

