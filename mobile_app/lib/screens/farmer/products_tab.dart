import 'package:flutter/material.dart';
import '../../services/product_service.dart';
import '../../services/platform_state.dart';
import '../../services/translation_service.dart';
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
      final currentFarmer = PlatformState().currentUser;
      final localProducts = PlatformState().getProductsForFarmer(currentFarmer.fullName);
      
      final data = await _productService.getProducts(limit: 50);
      final raw = data['products'] as List<dynamic>? ?? [];
      
      final apiProducts = raw.where((p) {
        final fName = (p['farmer_name'] ?? '').toString().toLowerCase();
        final cName = currentFarmer.fullName.toLowerCase();
        // Match active farmer or load seed for Ramesh Kumar
        return fName == cName || (cName.contains("ramesh") && fName.contains("ramesh"));
      }).map<Map<String, dynamic>>((p) {
        final category = (p['category'] ?? 'default').toString();
        final double qty = double.tryParse((p['stock_quantity'] ?? p['available_quantity'] ?? 0).toString()) ?? 0.0;
        final bool inStock = p['in_stock'] == true || (qty > 0 && p['status'] != 'OUT_OF_STOCK');
        return {
          'id': p['id']?.toString() ?? '',
          'name': p['name'] ?? p['title'] ?? 'Unknown Crop',
          'price': '₹${p['price'] ?? p['price_per_unit'] ?? 0}/${p['unit'] ?? 'kg'}',
          'stock': '${qty.toStringAsFixed(qty.truncateToDouble() == qty ? 0 : 1)} ${p['unit'] ?? 'kg'} available',
          'category': category,
          'emoji': _categoryEmoji[category] ?? _categoryEmoji['default']!,
          'farmer': p['farmer_name'] ?? currentFarmer.fullName,
          'in_stock': inStock,
          'status': inStock ? 'In Stock' : 'Out of Stock',
        };
      }).toList();

      final combined = [...localProducts, ...apiProducts];
      
      // Deduplicate by name/id
      final seen = <String>{};
      final uniqueList = <Map<String, dynamic>>[];
      for (final p in combined) {
        final key = (p['name'] ?? p['id']).toString();
        if (!seen.contains(key)) {
          seen.add(key);
          uniqueList.add(p);
        }
      }

      setState(() {
        _products = uniqueList;
        _isLoading = false;
      });
    } catch (e) {
      final currentFarmer = PlatformState().currentUser;
      final localProducts = PlatformState().getProductsForFarmer(currentFarmer.fullName);
      setState(() {
        _products = localProducts;
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleStock(int index, bool newValue) async {
    final product = _products[index];
    final prevInStock = product['in_stock'] == true || product['status'] == 'In Stock' || product['status'] == 'Available';
    setState(() {
      _products[index]['in_stock'] = newValue;
      _products[index]['status'] = newValue ? 'In Stock' : 'Out of Stock';
    });
    try {
      final idStr = (product['id'] ?? '').toString();
      if (idStr.isNotEmpty) {
        final res = await _productService.toggleStock(idStr, newValue);
        if (mounted && res['available_quantity'] != null) {
          final qty = double.tryParse(res['available_quantity'].toString()) ?? (newValue ? 100 : 0);
          setState(() {
            _products[index]['stock'] = '${qty.toStringAsFixed(qty.truncateToDouble() == qty ? 0 : 1)} kg available';
          });
        }
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(newValue
                ? "\"${product['name']}\" marked In Stock"
                : "\"${product['name']}\" marked Out of Stock"),
            backgroundColor: newValue ? Colors.green : Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _products[index]['in_stock'] = prevInStock;
          _products[index]['status'] = prevInStock ? 'In Stock' : 'Out of Stock';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Could not update stock in DB: $e"), backgroundColor: Colors.red),
        );
      }
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
          const PersonaLanguageSelector(persona: 'FARMER'),
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
                      final isAvailable = product['in_stock'] == true || product['status'] == 'In Stock' || product['status'] == 'Available';

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
                              const SizedBox(height: 6),
                              Row(
                                children: [
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
                                      isAvailable ? 'In Stock' : 'Out of Stock',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: isAvailable ? Colors.green.shade700 : Colors.red.shade700,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Transform.scale(
                                    scale: 0.78,
                                    child: Switch(
                                      value: isAvailable,
                                      activeColor: Colors.green,
                                      onChanged: (val) => _toggleStock(index, val),
                                    ),
                                  ),
                                ],
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
                              } else if (value == "ToggleStock") {
                                _toggleStock(index, !isAvailable);
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: "Edit",
                                child: Row(
                                  children: [Icon(Icons.edit), SizedBox(width: 10), Text("Edit")],
                                ),
                              ),
                              PopupMenuItem(
                                value: "ToggleStock",
                                child: Row(
                                  children: [
                                    Icon(isAvailable ? Icons.visibility_off : Icons.check_circle,
                                        color: isAvailable ? Colors.orange : Colors.green),
                                    const SizedBox(width: 10),
                                    Text(isAvailable ? "Mark Out of Stock" : "Mark In Stock"),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: "Delete",
                                child: Row(
                                  children: [
                                    Icon(Icons.delete, color: Colors.red),
                                    SizedBox(width: 10),
                                    Text("Delete"),
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
