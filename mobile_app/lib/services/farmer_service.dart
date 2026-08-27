import 'user_service.dart';
import 'product_service.dart';

class FarmerService {
  final UserService _userService = UserService();
  final ProductService _productService = ProductService();

  Future<Map<String, dynamic>> getDashboard() => _userService.getFarmerDashboard();
  Future<bool> updateStock(String id, double qty) => _productService.updateStock(id, qty);
  Future<Map<String, dynamic>> addProduct(Map<String, dynamic> data) => _productService.createProduct(data);
  Future<Map<String, dynamic>> editProduct(String id, Map<String, dynamic> data) => _productService.updateProduct(id, data);
}
