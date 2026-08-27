import 'package:flutter/material.dart';
import '../../core/colors.dart';
import '../../services/db_service.dart';

class DatabaseConsoleScreen extends StatefulWidget {
  const DatabaseConsoleScreen({super.key});

  @override
  State<DatabaseConsoleScreen> createState() => _DatabaseConsoleScreenState();
}

class _DatabaseConsoleScreenState extends State<DatabaseConsoleScreen> with SingleTickerProviderStateMixin {
  final DbService _dbService = DbService();
  
  late TabController _tabController;
  
  bool _isLoadingStats = true;
  String _errorMessage = '';
  List<String> _tables = [];
  Map<String, dynamic> _rowCounts = {};
  
  String _selectedTable = '';
  List<Map<String, dynamic>> _columns = [];
  List<Map<String, dynamic>> _foreignKeys = [];
  List<Map<String, dynamic>> _rows = [];
  bool _isLoadingTableDetails = false;

  // SQL Playground State
  final TextEditingController _sqlController = TextEditingController(
    text: "SELECT * FROM users JOIN role ON users.role_id = role.role_id LIMIT 5;"
  );
  List<String> _queryColumns = [];
  List<Map<String, dynamic>> _queryRows = [];
  bool _isRunningQuery = false;
  String _queryError = '';

  // Module groupings matching our 47 tables
  final Map<String, List<String>> _tableModules = {
    'Core & Access': ['role', 'users', 'party', 'location', 'customer_address', 'customer'],
    'Farmer & Farm': ['farmer', 'farm', 'crop_category', 'crop', 'farmer_crop'],
    'Aggregator & Warehouse': ['aggregator', 'warehouse', 'procurement', 'aggregator_inventory', 'inventory_reservation', 'quality_check'],
    'Order & Fulfillment': ['orders', 'order_item', 'fulfillment_source', 'order_allocation', 'order_tracking'],
    'Delivery Logistics': ['delivery', 'delivery_partner', 'delivery_assignment', 'vehicle', 'delivery_route', 'delivery_proof'],
    'Payments & Settlement': ['payment', 'settlement', 'settlement_detail'],
    'Customer Engagement': ['cart', 'cart_item', 'wishlist', 'review', 'coupon', 'coupon_usage'],
    'Notifications': ['notification', 'notification_status'],
    'Price & Analytics': ['price_history', 'ml_price_prediction'],
    'Returns & Refunds': ['returns', 'return_item', 'refund'],
    'Ledger & Movements': ['inventory_movement', 'inventory_adjustment', 'batch_expiry_alert']
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadStats();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _sqlController.dispose();
    super.dispose();
  }

  Future<void> _loadStats() async {
    setState(() {
      _isLoadingStats = true;
      _errorMessage = '';
    });
    try {
      final stats = await _dbService.getDbStats();
      setState(() {
        _tables = List<String>.from(stats['tablesList'] ?? []);
        _rowCounts = Map<String, dynamic>.from(stats['rowCounts'] ?? {});
        _isLoadingStats = false;
        
        // Select first table by default
        if (_tables.contains('users')) {
          _selectTable('users');
        } else if (_tables.isNotEmpty) {
          _selectTable(_tables.first);
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoadingStats = false;
      });
    }
  }

  Future<void> _selectTable(String tableName) async {
    setState(() {
      _selectedTable = tableName;
      _isLoadingTableDetails = true;
      _columns = [];
      _foreignKeys = [];
      _rows = [];
    });

    try {
      // Load Schema
      final schemaData = await _dbService.getTableSchema(tableName);
      // Load Rows
      final rowsData = await _dbService.getTableData(tableName);

      setState(() {
        _columns = List<Map<String, dynamic>>.from(schemaData['columns'] ?? []);
        _foreignKeys = List<Map<String, dynamic>>.from(schemaData['foreignKeys'] ?? []);
        _rows = List<Map<String, dynamic>>.from(rowsData['rows'] ?? []);
        _isLoadingTableDetails = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingTableDetails = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error loading table details: $e")),
        );
      }
    }
  }

  Future<void> _runQuery() async {
    setState(() {
      _isRunningQuery = true;
      _queryError = '';
      _queryColumns = [];
      _queryRows = [];
    });

    try {
      final data = await _dbService.runSqlQuery(_sqlController.text);
      setState(() {
        _queryColumns = List<String>.from(data['columns'] ?? []);
        _queryRows = List<Map<String, dynamic>>.from(data['rows'] ?? []);
        _isRunningQuery = false;
      });
    } catch (e) {
      setState(() {
        _queryError = e.toString();
        _isRunningQuery = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final bool isWideScreen = width > 800;

    return Scaffold(
      appBar: AppBar(
        title: const Text("AgriLink Schema Console"),
        backgroundColor: AppColors.primaryGreen,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.explore), text: "Explorer"),
            Tab(icon: Icon(Icons.code), text: "SQL Playground"),
            Tab(icon: Icon(Icons.info_outline), text: "Schema Summary"),
          ],
        ),
      ),
      body: _isLoadingStats
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Failed to connect to backend:\n$_errorMessage",
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadStats,
                        child: const Text("Retry Connection"),
                      )
                    ],
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    // Tab 1: Explorer
                    isWideScreen
                        ? Row(
                            children: [
                              SizedBox(
                                width: 280,
                                child: _buildTablesSidebar(),
                              ),
                              const VerticalDivider(width: 1),
                              Expanded(
                                child: _buildTableDetailsExplorer(),
                              )
                            ],
                          )
                        : _buildMobileExplorer(),

                    // Tab 2: SQL Playground
                    _buildSqlPlayground(),

                    // Tab 3: Summary
                    _buildSchemaSummaryTab(),
                  ],
                ),
    );
  }

  Widget _buildTablesSidebar() {
    return Container(
      color: Colors.grey.shade50,
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: _tableModules.entries.map((entry) {
          final moduleName = entry.key;
          final moduleTables = entry.value.where((t) => _tables.contains(t)).toList();

          if (moduleTables.isEmpty) return const SizedBox.shrink();

          return ExpansionTile(
            title: Text(
              moduleName,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
            initiallyExpanded: true,
            children: moduleTables.map((t) {
              final rowCount = _rowCounts[t] ?? 0;
              final isActive = _selectedTable == t;
              return ListTile(
                dense: true,
                selected: isActive,
                selectedColor: AppColors.primaryGreen,
                title: Text(t, style: const TextStyle(fontFamily: 'monospace')),
                trailing: Text(
                  "$rowCount rows",
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                ),
                onTap: () => _selectTable(t),
              );
            }).toList(),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTableDetailsExplorer() {
    if (_selectedTable.isEmpty) {
      return const Center(child: Text("Select a table to begin"));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.green.shade50,
          child: Row(
            children: [
              const Icon(Icons.table_chart, color: AppColors.primaryGreen),
              const SizedBox(width: 8),
              Text(
                "TABLE: $_selectedTable",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                ),
              ),
              const Spacer(),
              Chip(
                label: Text(
                  "${_rowCounts[_selectedTable] ?? 0} rows seeded",
                  style: const TextStyle(fontSize: 11),
                ),
                backgroundColor: Colors.white,
              ),
            ],
          ),
        ),
        Expanded(
          child: _isLoadingTableDetails
              ? const Center(child: CircularProgressIndicator())
              : DefaultTabController(
                  length: 2,
                  child: Column(
                    children: [
                      Container(
                        color: Colors.grey.shade100,
                        child: const TabBar(
                          labelColor: AppColors.primaryGreen,
                          unselectedLabelColor: Colors.grey,
                          indicatorColor: AppColors.primaryGreen,
                          tabs: [
                            Tab(text: "Schema Definition"),
                            Tab(text: "Browse Seeded Records"),
                          ],
                        ),
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            _buildSchemaDefinitionView(),
                            _buildSeededRecordsView(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
        )
      ],
    );
  }

  Widget _buildSchemaDefinitionView() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _columns.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final col = _columns[index];
        final bool isPk = col['pk'] == true;
        final String colName = col['name'] ?? '';
        final String colType = col['type'] ?? '';
        final bool notNull = col['notnull'] == true;

        // Check if FK
        final fk = _foreignKeys.firstWhere(
          (f) => f['from'] == colName,
          orElse: () => {},
        );

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          colName,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        if (isPk) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade200,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              "PK",
                              style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                        if (fk.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: Colors.cyan.shade200,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Tooltip(
                              message: "FK -> ${fk['toTable']}.${fk['toColumn']}",
                              child: const Text(
                                "FK",
                                style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      colType.toUpperCase(),
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              if (notNull)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: const Text("NOT NULL", style: TextStyle(fontSize: 10, color: Colors.grey)),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSeededRecordsView() {
    if (_rows.isEmpty) {
      return const Center(child: Text("No records found in this table"));
    }

    final keys = _rows.first.keys.toList();

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(Colors.grey.shade100),
          columns: keys.map((key) {
            return DataColumn(
              label: Text(
                key,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryGreen,
                ),
              ),
            );
          }).toList(),
          rows: _rows.map((row) {
            return DataRow(
              cells: keys.map((key) {
                final val = row[key];
                return DataCell(
                  Text(
                    val != null ? val.toString() : 'NULL',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      color: val == null ? Colors.red : Colors.black87,
                      fontSize: 12,
                    ),
                  ),
                );
              }).toList(),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildMobileExplorer() {
    return _selectedTable.isEmpty
        ? _buildTablesSidebar()
        : PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, result) {
              if (!didPop) {
                setState(() {
                  _selectedTable = '';
                });
              }
            },
            child: _buildTableDetailsExplorer(),
          );
  }

  Widget _buildSqlPlayground() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            "SQL Sandbox Terminal",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const Text(
            "Exposed SELECT endpoint. Tables joined via key definitions.",
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _sqlController,
            maxLines: 4,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              hintText: "Enter SELECT query...",
              fillColor: Colors.grey.shade50,
              filled: true,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Wrap(
                spacing: 8,
                children: [
                  _shortcutBtn("Crops", "SELECT * FROM crop LIMIT 5;"),
                  _shortcutBtn("History", "SELECT crop_name, old_price, new_price FROM price_history JOIN crop ON price_history.crop_id = crop.crop_id LIMIT 3;"),
                  _shortcutBtn("Farms", "SELECT farm_name, total_area, organic_certified FROM farm LIMIT 3;"),
                ],
              ),
              ElevatedButton.icon(
                onPressed: _isRunningQuery ? null : _runQuery,
                icon: _isRunningQuery
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.play_arrow),
                label: const Text("Execute"),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen),
              )
            ],
          ),
          const Divider(height: 24),
          Expanded(
            child: _isRunningQuery
                ? const Center(child: CircularProgressIndicator())
                : _queryError.isNotEmpty
                    ? Container(
                        padding: const EdgeInsets.all(16),
                        color: Colors.red.shade50,
                        child: Text(
                          "SQL Error:\n$_queryError",
                          style: const TextStyle(color: Colors.red, fontFamily: 'monospace'),
                        ),
                      )
                    : _queryRows.isEmpty
                        ? const Center(child: Text("Run a SELECT query to view output"))
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Text(
                                  "Query Results: ${_queryRows.length} rows returned",
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                              ),
                              Expanded(
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.vertical,
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: DataTable(
                                      headingRowColor: WidgetStateProperty.all(Colors.grey.shade100),
                                      columns: _queryColumns.map((colName) {
                                        return DataColumn(
                                          label: Text(
                                            colName,
                                            style: const TextStyle(
                                              fontFamily: 'monospace',
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.primaryGreen,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                      rows: _queryRows.map((row) {
                                        return DataRow(
                                          cells: _queryColumns.map((colName) {
                                            final val = row[colName];
                                            return DataCell(
                                              Text(
                                                val != null ? val.toString() : 'NULL',
                                                style: TextStyle(
                                                  fontFamily: 'monospace',
                                                  color: val == null ? Colors.red : Colors.black87,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
          )
        ],
      ),
    );
  }

  Widget _shortcutBtn(String label, String sql) {
    return ActionChip(
      label: Text(label, style: const TextStyle(fontSize: 11)),
      onPressed: () {
        setState(() {
          _sqlController.text = sql;
        });
      },
    );
  }

  Widget _buildSchemaSummaryTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text("Database Enterprise Design Overview", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        const Text("47 tables are mapped completely matching system architecture.", style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 20),
        _summaryTile("Core Modules (Tables 1-6)", "System roles, users, and mapping address locations.", Colors.green),
        _summaryTile("Farmer & Crop Production (Tables 7-11)", "Holds farm plots, certified organic statuses, and harvest crops.", Colors.blue),
        _summaryTile("Warehouse & Aggregators (Tables 12-17)", "Enables collections, cold storages, quality check, and batch reserves.", Colors.orange),
        _summaryTile("Order & Logistics Flow (Tables 18-28)", "Allocation split engines, delivery routes, proof, and assignment records.", Colors.purple),
        _summaryTile("Price Predictor & Analytics (Tables 40-41)", "Tracks crop market price histories and stores ML price predictions.", Colors.teal),
        _summaryTile("Movements & Movements (Tables 45-47)", "Audit logs of inventory movements, adjustments, and expiry alerts.", Colors.red),
      ],
    );
  }

  Widget _summaryTile(String title, String desc, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(Icons.schema, color: color),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(desc),
      ),
    );
  }
}
