import 'dart:convert';

import 'package:assaingment/models/product_model.dart';
import 'package:assaingment/screens/add_new_product_screen.dart';
import 'package:assaingment/screens/utils/urls.dart';
import 'package:assaingment/widgets/product_item.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {


  final List<ProductModel> _productList = [];
  bool _getProductInProgress = false;
@override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getProductList();
  }


  Future<void>_getProductList() async{
  _productList.clear();
  _getProductInProgress = true;
  setState(() {});
    Uri uri = Uri.parse(Urls.getProductsUrl);
    Response response = await get(uri);
    debugPrint(response.statusCode.toString());
    debugPrint(response.body);

    if(response.statusCode == 200){
      final decodedJson = jsonDecode(response.body);
      for(Map<String, dynamic> productJson in decodedJson['data']){

        ProductModel productModel= ProductModel.fromJson(productJson);


       _productList.add(productModel);

      }
    }
  _getProductInProgress = false;
    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Product List'),actions: [
        IconButton(onPressed: (){
          _getProductList();
        }, icon: Icon(Icons.refresh))
      ],),
      body: Visibility(
        visible: _getProductInProgress == false,
        replacement: Center(
          child: CircularProgressIndicator(),
        ),
        child: ListView.separated(
          itemCount: _productList.length,
          itemBuilder: (context, index) {
            return ProductItem(product: _productList[index], refreshProductList: () {
              _getProductList();
            },);
          },
          separatorBuilder: (context, index) {
            return const Divider(indent: 70);
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddNewProductScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
