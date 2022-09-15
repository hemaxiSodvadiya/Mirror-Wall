import 'package:flutter/material.dart';

import 'detail_page.dart';
import 'list.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey,
      appBar: AppBar(
        backgroundColor: Colors.black54,
        centerTitle: true,
        title: const Text(
          "OTT Platform",
          style: TextStyle(
            fontSize: 22,
            color: Colors.white,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: GridView.builder(
        itemCount: id.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 5.0,
          mainAxisSpacing: 5.0,
        ),
        itemBuilder: (context, i) {
          var Page = id[i];
          return InkWell(
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => PageD(Page)));
            },
            child: GridTile(
              child: Container(
                padding: EdgeInsets.all(10),
                child: Image(
                  image: NetworkImage(Page.image),
                  fit: BoxFit.fill,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
