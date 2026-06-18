import 'package:flutter/material.dart';
import '../../data/database_helper.dart';

class FormulaVaultScreen extends StatefulWidget {
  const FormulaVaultScreen({super.key});

  @override
  State<FormulaVaultScreen> createState() => _FormulaVaultScreenState();
}

class _FormulaVaultScreenState extends State<FormulaVaultScreen> {
  List<Map<String, dynamic>> _formulas = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFormulas();
  }

  Future<void> _loadFormulas() async {
    final list = await DatabaseHelper.instance.getFormulas();
    setState(() {
      _formulas = list;
      _isLoading = false;
    });
  }

  Future<void> _toggleFavorite(int id, int currentFav) async {
    await DatabaseHelper.instance.updateFormulaFavorite(id, currentFav == 0);
    _loadFormulas();
  }

  void _showAddFormulaDialog() {
    final nameController = TextEditingController();
    final formulaController = TextEditingController();
    final descController = TextEditingController();
    final catController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Custom Formula'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Formula Name'),
              ),
              TextField(
                controller: formulaController,
                decoration: const InputDecoration(labelText: 'Equation (e.g. y = mx + c)'),
              ),
              TextField(
                controller: descController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              TextField(
                controller: catController,
                decoration: const InputDecoration(labelText: 'Category'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text('Add'),
            onPressed: () async {
              if (nameController.text.isNotEmpty && formulaController.text.isNotEmpty) {
                await DatabaseHelper.instance.insertFormula({
                  'name': nameController.text,
                  'formula': formulaController.text,
                  'description': descController.text,
                  'category': catController.text.isEmpty ? 'General' : catController.text,
                  'is_favorite': 0,
                });
                Navigator.pop(context);
                _loadFormulas();
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Formula Vault'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddFormulaDialog,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _formulas.isEmpty
              ? const Center(child: Text('No formulas found.'))
              : ListView.builder(
                  itemCount: _formulas.length,
                  itemBuilder: (context, index) {
                    final item = _formulas[index];
                    final isFav = item['is_favorite'] == 1;
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: ListTile(
                        title: Text(
                          item['name'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              item['formula'],
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.blueGrey,
                                fontFamily: 'monospace',
                              ),
                            ),
                            if (item['description'] != null) ...[
                              const SizedBox(height: 4),
                              Text(item['description']),
                            ],
                            const SizedBox(height: 4),
                            Chip(
                              label: Text(
                                item['category'],
                                style: const TextStyle(fontSize: 10),
                              ),
                              padding: EdgeInsets.zero,
                              visualDensity: VisualDensity.compact,
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: Icon(
                            isFav ? Icons.star : Icons.star_border,
                            color: isFav ? Colors.amber : Colors.grey,
                          ),
                          onPressed: () => _toggleFavorite(item['id'], item['is_favorite']),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
