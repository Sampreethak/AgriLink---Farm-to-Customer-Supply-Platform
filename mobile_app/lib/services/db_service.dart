import 'package:dio/dio.dart';
import '../core/config.dart';

class DbService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: AppConfig.baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  // Get general stats (tables list and row counts)
  Future<Map<String, dynamic>> getDbStats() async {
    try {
      final response = await _dio.get('/db/stats');
      return response.data ?? {};
    } catch (e) {
      throw Exception(_handleError(e));
    }
  }

  // Get table schema/metadata
  Future<Map<String, dynamic>> getTableSchema(String tableName) async {
    try {
      final response = await _dio.get('/db/schema/$tableName');
      return response.data ?? {};
    } catch (e) {
      throw Exception(_handleError(e));
    }
  }

  // Get table rows/records
  Future<Map<String, dynamic>> getTableData(String tableName) async {
    try {
      final response = await _dio.get('/db/data/$tableName');
      return response.data ?? {};
    } catch (e) {
      throw Exception(_handleError(e));
    }
  }

  // Execute custom read-only SQL query
  Future<Map<String, dynamic>> runSqlQuery(String sql) async {
    try {
      final response = await _dio.post(
        '/db/query',
        data: {'sql': sql},
      );
      return response.data ?? {};
    } catch (e) {
      throw Exception(_handleError(e));
    }
  }

  String _handleError(dynamic error) {
    if (error is DioException) {
      if (error.response != null && error.response?.data != null) {
        return error.response?.data['error'] ?? 'Server error';
      }
      return error.message ?? 'Network connection failed';
    }
    return error.toString();
  }
}
