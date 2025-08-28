import 'package:assaingment/models/product_model.dart';
import 'package:assaingment/screens/update_product_screen.dart';
import 'package:assaingment/screens/utils/urls.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

class ProductItem extends StatefulWidget {
  const ProductItem({
    super.key,
    required this.product,
    required this.refreshProductList,
  });

  final ProductModel product;
  final VoidCallback refreshProductList;

  @override
  State<ProductItem> createState() => _ProductItemState();
}

class _ProductItemState extends State<ProductItem> {
  bool _deleteInProgress = false;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Image.network(
        widget.product.image,
        width: 30,
        errorBuilder: (_, __, ___) {
          return const Icon(Icons.error_outline, size: 30);
        },
      ),
      title: Text(widget.product.name),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Code: ${widget.product.code}'),
          Row(
            children: [
              Text('Quantity: ${widget.product.quantity}'),
              const SizedBox(width: 16),
              Text('Unit Price: ${widget.product.unitPrice}'),
            ],
          ),
        ],
      ),
      trailing: Visibility(
        visible: !_deleteInProgress,
        replacement: const SizedBox(
          height: 24,
          width: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        child: PopupMenuButton<ProductOption>(
          onSelected: (ProductOption selectedOption) {
            if (selectedOption == ProductOption.delete) {
              _deleteProduct();
            } else if (selectedOption == ProductOption.update) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UpdateProductScreen(
                    productId: widget.product.id,
                    productName: widget.product.name,
                    productCode: widget.product.code.toString(),

                    quantity: widget.product.quantity,
                    unitPrice: widget.product.unitPrice,
                    imageUrl: widget.product.image,
                    onProductUpdated: widget.refreshProductList,
                  ),
                ),
              );
            }
          },
          itemBuilder: (context) {
            return const [
              PopupMenuItem(
                value: ProductOption.update,
                child: Text('Update'),
              ),
              PopupMenuItem(
                value: ProductOption.delete,
                child: Text('Delete'),
              ),
            ];
          },
        ),
      ),
    );
  }

  Future<void> _deleteProduct() async {
    setState(() {
      _deleteInProgress = true;
    });

    Uri uri = Uri.parse(Urls.deleteProductUrl(widget.product.id));
    Response response = await get(uri);
    debugPrint(response.statusCode.toString());
    debugPrint(response.body);

    if (response.statusCode == 200) {
      widget.refreshProductList();
    }

    setState(() {
      _deleteInProgress = false;
    });
  }
}

enum ProductOption { update, delete }
