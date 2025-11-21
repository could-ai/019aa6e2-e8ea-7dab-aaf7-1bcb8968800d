class Product {
  final String id;
  final String name;
  final double price;
  final String category;
  final int color; // storing color as int (0xFF...)

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.color,
  });
}

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  double get total => product.price * quantity;
}
