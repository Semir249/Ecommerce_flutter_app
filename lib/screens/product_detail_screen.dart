import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/products.dart';

class ProductDetailScreen extends StatelessWidget {
  // final String title;

  // ProductDetailScreen(this.title);
  static const routeName = '/product-detail';
  @override
  Widget build(BuildContext context) {
    final productId = ModalRoute.of(context).settings.arguments as String;
    final loadedProduct =
        Provider.of<Products>(context, listen: false).findById(productId);
    return Scaffold(
        // appBar: AppBar(
        //   title: Text(loadedProduct.title),
        // ),
        body: CustomScrollView(
      slivers: <Widget>[
        SliverAppBar(
          expandedHeight: 300,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            title: Text(loadedProduct.title),
            background: Hero(
              tag: loadedProduct.id,
              child: Image.network(loadedProduct.imageUrl, fit: BoxFit.cover),
            ),
          ),
        ),
        SliverList(
            delegate: SliverChildListDelegate([
          SizedBox(
            height: 10,
          ),
          Text(
            '\$${loadedProduct.price}',
            style: TextStyle(
              // color: Theme.of(context).accentColor,
              fontSize: 20,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(
            height: 5,
          ),
          // Expanded(
          // child:
          Container(
            // color: Theme.of(context).accentColor,
            padding: EdgeInsets.symmetric(horizontal: 10),
            width: double.infinity,
            child: Text(
              loadedProduct.description,
              textAlign: TextAlign.center,
              softWrap: true,
              style:
                  TextStyle(color: Theme.of(context).accentColor, fontSize: 20),
            ),
          ),
          // ),
          SizedBox(
            height: 800,
          )
        ]))
      ],
    )

        // Card(
        //   elevation: 10,
        //   margin: EdgeInsets.fromLTRB(50, 50, 50, 100),
        //   child: Column(
        //     children: <Widget>[
        //       Container(
        //           height: 300,
        //           width: double.infinity,
        //           child:

        //     ],
        //   ),
        // ),
        );
  }
}
