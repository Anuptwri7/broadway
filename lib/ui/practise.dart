import 'package:flutter/material.dart';

class ProductDetailPage extends StatefulWidget {
  String name;
  String price;
  String image;
  ProductDetailPage(this.name,this.image,this.price);

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Orders"),

      ),
      body: Column(
        children: [
          GestureDetector(
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>ProductDetailPage("Mobile", 'assets/image.jpg', "200")));
              },
              child: Card()),

          Text("name:${widget.name}"),
          Text("price:${widget.price}"),
          Image.asset(widget.image),
          Container(
              child:Column(
                  children : [
                    Image.asset('asset/bg.jpg'),
                  ]
              )
          ),

          ElevatedButton(
             style: ElevatedButton.styleFrom(
    backgroundColor:Colors.blue
    ),
    onPressed: (){}, child: Text("sjdkhad"))

        ],
      ),
    );
  }
}
