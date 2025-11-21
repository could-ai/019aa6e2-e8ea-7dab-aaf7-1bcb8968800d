import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/pos_models.dart';

class POSScreen extends StatefulWidget {
  const POSScreen({super.key});

  @override
  State<POSScreen> createState() => _POSScreenState();
}

class _POSScreenState extends State<POSScreen> {
  // Mock Data
  final List<Product> _products = [
    Product(id: '1', name: 'Burger', price: 5.99, category: 'Food', color: 0xFFFFCC80),
    Product(id: '2', name: 'Fries', price: 2.99, category: 'Food', color: 0xFFFFE082),
    Product(id: '3', name: 'Soda', price: 1.99, category: 'Drink', color: 0xFFEF9A9A),
    Product(id: '4', name: 'Coffee', price: 2.49, category: 'Drink', color: 0xFFBCAAA4),
    Product(id: '5', name: 'Salad', price: 6.49, category: 'Food', color: 0xFFA5D6A7),
    Product(id: '6', name: 'Ice Cream', price: 3.99, category: 'Dessert', color: 0xFFF48FB1),
    Product(id: '7', name: 'Pizza', price: 8.99, category: 'Food', color: 0xFFFFAB91),
    Product(id: '8', name: 'Water', price: 0.99, category: 'Drink', color: 0xFF90CAF9),
  ];

  final List<CartItem> _cart = [];
  String _selectedCategory = 'All';

  List<String> get _categories => ['All', ..._products.map((p) => p.category).toSet().toList()];

  List<Product> get _filteredProducts => _selectedCategory == 'All'
      ? _products
      : _products.where((p) => p.category == _selectedCategory).toList();

  double get _totalAmount => _cart.fold(0, (sum, item) => sum + item.total);

  void _addToCart(Product product) {
    setState(() {
      final existingIndex = _cart.indexWhere((item) => item.product.id == product.id);
      if (existingIndex >= 0) {
        _cart[existingIndex].quantity++;
      } else {
        _cart.add(CartItem(product: product));
      }
    });
  }

  void _removeFromCart(CartItem item) {
    setState(() {
      if (item.quantity > 1) {
        item.quantity--;
      } else {
        _cart.remove(item);
      }
    });
  }

  void _clearCart() {
    setState(() {
      _cart.clear();
    });
  }

  void _processCheckout() {
    if (_cart.isEmpty) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Checkout Success'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 64),
            const SizedBox(height: 16),
            Text('Total Paid: ${NumberFormat.currency(symbol: '\$').format(_totalAmount)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _clearCart();
            },
            child: const Text('New Sale'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Sale'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _cart.isEmpty ? null : _clearCart,
          )
        ],
      ),
      body: Column(
        children: [
          // Category Filter
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = category == _selectedCategory;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                  ),
                );
              },
            ),
          ),
          
          // Main Content Area
          Expanded(
            child: Row(
              children: [
                // Product Grid
                Expanded(
                  flex: 3,
                  child: GridView.builder(
                    padding: const EdgeInsets.all(8),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // Adjust for tablet/mobile
                      childAspectRatio: 0.8,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: _filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = _filteredProducts[index];
                      return Card(
                        color: Color(product.color),
                        child: InkWell(
                          onTap: () => _addToCart(product),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Placeholder for image
                              Icon(Icons.fastfood, size: 40, color: Colors.black54),
                              const SizedBox(height: 8),
                              Text(
                                product.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                NumberFormat.currency(symbol: '\$').format(product.price),
                                style: const TextStyle(fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                
                // Cart Summary (Sidebar for larger screens, or just visible here)
                // For a mobile POS, a bottom sheet is often better, but let's try a split view 
                // if screen width allows, or just a persistent bottom bar.
                // Let's do a persistent bottom sheet style for the cart.
              ],
            ),
          ),
        ],
      ),
      // Using a BottomSheet for the Cart to maximize product space
      bottomSheet: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        height: _cart.isEmpty ? 0 : 300, // Collapsed when empty
        child: Column(
          children: [
            // Cart Header
            Container(
              padding: const EdgeInsets.all(12),
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Cart (${_cart.length} items)',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Total: ${NumberFormat.currency(symbol: '\$').format(_totalAmount)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ],
              ),
            ),
            // Cart Items List
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(8),
                itemCount: _cart.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final item = _cart[index];
                  return ListTile(
                    dense: true,
                    title: Text(item.product.name),
                    subtitle: Text('${item.quantity} x ${NumberFormat.currency(symbol: '\$').format(item.product.price)}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          NumberFormat.currency(symbol: '\$').format(item.total),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                          onPressed: () => _removeFromCart(item),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Checkout Button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _processCheckout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('CHECKOUT', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
