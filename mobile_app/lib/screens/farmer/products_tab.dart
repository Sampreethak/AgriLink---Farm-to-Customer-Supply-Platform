import 'package:flutter/material.dart';
import '../../services/product_service.dart';
import 'products/add_product_screen.dart';
import 'products/edit_product_screen.dart';
import 'products/product_details_screen.dart';

class ProductsTab extends StatefulWidget {
  const ProductsTab({super.key});

  @override
  State<ProductsTab> createState() => _ProductsTabState();
}

class _ProductsTabState extends State<ProductsTab> {
  final ProductService _productService = ProductService();

  List<Map<String, dynamic>> _products = [];
  bool _isLoading = true;
  String _error = '';

  // Emoji map for crop category
  static const Map<String, String> _categoryEmoji = {
    'Vegetables': '🥬', 'Fruits': '🍎', 'Grains': '🌾',
    'Pulses': '🫘', 'Herbs': '🌿', 'Dairy': '🥛', 'default': '🌱',
  };

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });
    try {
      final data = await _productService.getProducts(limit: 50);
      final raw = data['products'] as List<dynamic>? ?? [];
      setState(() {
        _products = raw.map<Map<String, dynamic>>((p) {
          final category = (p['category'] ?? 'default').toString();
          return {
            'id': p['id']?.toString() ?? '',
            'name': p['name'] ?? 'Unknown Crop',
            'price': '₹${p['price'] ?? 0}/${p['unit'] ?? 'kg'}',
            'stock': '${p['stock_quantity'] ?? 0} ${p['unit'] ?? 'kg'} available',
            'category': category,
            'emoji': _categoryEmoji[category] ?? _categoryEmoji['default']!,
            'farmer': p['farmer_name'] ?? 'You',
            'status': (p['stock_quantity'] ?? 0) > 0 ? 'Available' : 'Out of Stock',
          };
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        // Demo fallback data
        _products = List.generate(5, (i) => {
          'id': 'demo-$i',
          'name': 'Tomato ${i + 1}',
          'price': '₹${40 + i * 5}/kg',
          'stock': '${10 + i * 5} kg available',
          'category': 'Vegetables',
          'emoji': '🍅',
          'farmer': 'You',
          'status': 'Available',
        });
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _deleteProduct(int index) async {
    final product = _products[index];
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Product"),
        content: Text("Are you sure you want to delete \"${product['name']}\"?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      setState(() => _products.removeAt(index));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Product removed successfully")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isLoading ? "My Products" : "My Products (${_products.length})"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadProducts,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text("Loading products from backend...", style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : _products.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.eco_outlined, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text(
                        "No products listed yet",
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      if (_error.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            "Backend may be offline. Using demo mode.",
                            style: TextStyle(fontSize: 12, color: Colors.orange.shade700),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const AddProductScreen()),
                        ),
                        icon: const Icon(Icons.add),
                        label: const Text("Add First Product"),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadProducts,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _products.length,
                    itemBuilder: (context, index) {
                      final product = _products[index];
                      final isAvailable = product['status'] == 'Available';

                      return Card(
                        elevation: 3,
                        margin: const EdgeInsets.only(bottom: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(14),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const ProductDetailsScreen()),
                            );
                          },
                          leading: CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.green.shade100,
                            child: Text(
                              product['emoji'] ?? '🌱',
                              style: const TextStyle(fontSize: 24),
                            ),
                          ),
                          title: Text(
                            product['name'],
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                "${product['price']} • ${product['stock']}",
                                style: const TextStyle(color: Colors.grey),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isAvailable ? Colors.green.shade50 : Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isAvailable ? Colors.green.shade200 : Colors.red.shade200,
                                  ),
                                ),
                                child: Text(
                                  product['status'],
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: isAvailable ? Colors.green.shade700 : Colors.red.shade700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          isThreeLine: true,
                          trailing: PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert),
                            onSelected: (value) {
                              if (value == "Edit") {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const EditProductScreen()),
                                );
                              } else if (value == "Delete") {
                                _deleteProduct(index);
                              } else if (value == "Unavailable") {
                                setState(() {
                                  _products[index]['status'] = 'Out of Stock';
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Product marked as unavailable")),
                                );
                              }
                            },
                            itemBuilder: (context) => const [
                              PopupMenuItem(
                                value: "Edit",
                                child: Row(
                                  children: [Icon(Icons.edit), SizedBox(width: 10), Text("Edit")],
                                ),
                              ),
                              PopupMenuItem(
                                value: "Delete",
                                child: Row(
                                  children: [
                                    Icon(Icons.delete, color: Colors.red),
                                    SizedBox(width: 10),
                                    Text("Delete"),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: "Unavailable",
                                child: Row(
                                  children: [
                                    Icon(Icons.visibility_off),
                                    SizedBox(width: 10),
                                    Text("Mark Unavailable"),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.green,
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddProductScreen()),
          );
          _loadProducts(); // Refresh after adding
        },
        icon: const Icon(Icons.add),
        label: const Text("Add Product"),
      ),
    );
  }
}
