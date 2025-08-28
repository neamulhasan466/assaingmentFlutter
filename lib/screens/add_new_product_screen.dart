import 'dart:convert';
import 'package:assaingment/widgets/snackbar_message.dart' show showSnackBarMessage;
import 'package:flutter/material.dart';
import 'package:http/http.dart';

class AddNewProductScreen extends StatefulWidget {
  const AddNewProductScreen({super.key});

  @override
  State<AddNewProductScreen> createState() => _AddNewProductScreenState();
}

class _AddNewProductScreenState extends State<AddNewProductScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nameTEController = TextEditingController();
  final TextEditingController _codeTEController = TextEditingController();
  final TextEditingController _priceTEController = TextEditingController();
  final TextEditingController _quantityTEController = TextEditingController();
  final TextEditingController _imageUrlTEController = TextEditingController();

  bool _addProductInProgress = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add New Product')),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextFormField(
                  controller: _nameTEController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    hintText: 'Product name',
                    labelText: 'Product name',
                  ),
                  validator: (value) =>
                  value!.trim().isEmpty ? 'Enter your value' : null,
                ),
                TextFormField(
                  controller: _codeTEController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    hintText: 'Product code',
                    labelText: 'Product code',
                  ),
                  validator: (value) =>
                  value!.trim().isEmpty ? 'Enter your value' : null,
                ),
                TextFormField(
                  controller: _quantityTEController,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    hintText: 'Quantity',
                    labelText: 'Quantity',
                  ),
                  validator: (value) =>
                  value!.trim().isEmpty ? 'Enter your value' : null,
                ),
                TextFormField(
                  controller: _priceTEController,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    hintText: 'Unit Price',
                    labelText: 'Unit Price',
                  ),
                  validator: (value) =>
                  value!.trim().isEmpty ? 'Enter your value' : null,
                ),
                TextFormField(
                  controller: _imageUrlTEController,
                  decoration: const InputDecoration(
                    hintText: 'Image Url',
                    labelText: 'Image Url',
                  ),
                  validator: (value) =>
                  value!.trim().isEmpty ? 'Enter your value' : null,
                ),
                const SizedBox(height: 12),
                Visibility(
                  visible: !_addProductInProgress,
                  replacement: const Center(child: CircularProgressIndicator()),
                  child: FilledButton(
                    onPressed: _onTapAddProductButton,
                    child: const Text('Add Product'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onTapAddProductButton() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _addProductInProgress = true);

    Uri uri = Uri.parse('http://35.73.30.144:2008/api/v1/CreateProduct');

    int unitPrice = int.parse(_priceTEController.text);
    int quantity = int.parse(_quantityTEController.text);
    int totalPrice = unitPrice * quantity;

    Map<String, dynamic> requestBody = {
      "ProductName": _nameTEController.text,
      "ProductCode": int.parse(_codeTEController.text),
      "Img": _imageUrlTEController.text,
      "Qty": quantity,
      "UnitPrice": unitPrice,
      "TotalPrice": totalPrice,
    };

    try {
      Response response = await post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      print(response.statusCode);
      print(response.body);

      if (response.statusCode == 200) {
        final decodedJson = jsonDecode(response.body);
        if (decodedJson['status'] == 'success') {
          _clearTextFields();
          showSnackBarMessage(context, 'Product created successfully');
        } else {
          String errorMessage = decodedJson['data'] ?? 'Unknown error';
          showSnackBarMessage(context, errorMessage);
        }
      } else {
        showSnackBarMessage(context, 'Something went wrong! (${response.statusCode})');
      }
    } catch (e) {
      showSnackBarMessage(context, 'Error: $e');
    }

    setState(() => _addProductInProgress = false);
  }

  void _clearTextFields() {
    _nameTEController.clear();
    _codeTEController.clear();
    _quantityTEController.clear();
    _priceTEController.clear();
    _imageUrlTEController.clear();
  }

  @override
  void dispose() {
    _nameTEController.dispose();
    _codeTEController.dispose();
    _quantityTEController.dispose();
    _priceTEController.dispose();
    _imageUrlTEController.dispose();
    super.dispose();
  }
}
