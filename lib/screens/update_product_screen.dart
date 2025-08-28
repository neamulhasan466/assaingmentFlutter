import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:assaingment/widgets/snackbar_message.dart' show showSnackBarMessage;

class UpdateProductScreen extends StatefulWidget {
  const UpdateProductScreen({
    super.key,
    required this.productId,
    required this.productName,
    required this.productCode,
    required this.quantity,
    required this.unitPrice,
    required this.imageUrl,
    this.onProductUpdated,
  });

  final String productId;
  final String productName;
  final String productCode;
  final int quantity;
  final int unitPrice;
  final String imageUrl;
  final VoidCallback? onProductUpdated;

  @override
  State<UpdateProductScreen> createState() => _UpdateProductScreenState();
}

class _UpdateProductScreenState extends State<UpdateProductScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _codeController;
  late TextEditingController _quantityController;
  late TextEditingController _priceController;
  late TextEditingController _imageController;

  bool _updating = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.productName);
    _codeController = TextEditingController(text: widget.productCode);
    _quantityController = TextEditingController(text: widget.quantity.toString());
    _priceController = TextEditingController(text: widget.unitPrice.toString());
    _imageController = TextEditingController(text: widget.imageUrl);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Update Product')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(_nameController, 'Product Name'),
              _buildTextField(_codeController, 'Product Code'),
              _buildTextField(_quantityController, 'Quantity', isNumber: true),
              _buildTextField(_priceController, 'Unit Price', isNumber: true),
              _buildTextField(_imageController, 'Image URL'),
              const SizedBox(height: 16),
              Visibility(
                visible: !_updating,
                replacement: const Center(child: CircularProgressIndicator()),
                child: FilledButton(
                  onPressed: _onUpdateProduct,
                  child: const Text('Update Product'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) => value == null || value.trim().isEmpty ? 'Please enter $label' : null,
      ),
    );
  }

  Future<void> _onUpdateProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _updating = true);

    try {
      // PUT method ব্যবহার করা হচ্ছে, যেটা server expect করে
      final uri = Uri.parse('http://35.73.30.144:2008/api/v1/UpdateProduct/${widget.productId}');
      final totalPrice = int.parse(_priceController.text) * int.parse(_quantityController.text);

      final body = {
        "ProductName": _nameController.text,
        "ProductCode": _codeController.text,
        "Img": _imageController.text,
        "Qty": int.parse(_quantityController.text),
        "UnitPrice": int.parse(_priceController.text),
        "TotalPrice": totalPrice,
      };

      final response = await http.put(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      debugPrint("Sending update: ${jsonEncode(body)}");
      debugPrint("Response status: ${response.statusCode}");
      debugPrint("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded['status'].toString().toLowerCase() == 'success') {
          showSnackBarMessage(context, 'Product updated successfully');
          widget.onProductUpdated?.call();
          Navigator.pop(context, true);
        } else {
          showSnackBarMessage(context, decoded['data']?.toString() ?? 'Update failed');
        }
      } else {
        showSnackBarMessage(context, 'Server Error: ${response.statusCode}');
      }
    } catch (e) {
      showSnackBarMessage(context, 'Error: $e');
    } finally {
      setState(() => _updating = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    _imageController.dispose();
    super.dispose();
  }
}
