import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/scientific_constants.dart';

class ConstantsScreen extends StatefulWidget {
  const ConstantsScreen({super.key});

  @override
  State<ConstantsScreen> createState() => _ConstantsScreenState();
}

class _ConstantsScreenState extends State<ConstantsScreen> {
  List<ScientificConstant> _filteredConstants = ScientificConstants.list;

  void _filterConstants(String query) {
    setState(() {
      _filteredConstants = ScientificConstants.list.where((constant) {
        final symbolMatch = constant.symbol.toLowerCase().contains(query.toLowerCase());
        final nameMatch = constant.name.toLowerCase().contains(query.toLowerCase());
        final categoryMatch = constant.category.toLowerCase().contains(query.toLowerCase());
        return symbolMatch || nameMatch || categoryMatch;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scientific Constants'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Search constants (e.g. c, G, pi)',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: _filterConstants,
            ),
          ),
          Expanded(
            child: _filteredConstants.isEmpty
                ? const Center(child: Text('No constants found.'))
                : ListView.builder(
                    itemCount: _filteredConstants.length,
                    itemBuilder: (context, index) {
                      final constant = _filteredConstants[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        child: ListTile(
                          title: Row(
                            children: [
                              Text(
                                constant.symbol,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  constant.name,
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Value: ${constant.value}',
                                style: const TextStyle(fontWeight: FontWeight.w500),
                              ),
                              Text('Unit: ${constant.unit}'),
                              Text(
                                'Category: ${constant.category}',
                                style: const TextStyle(fontSize: 11, color: Colors.grey),
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.copy),
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: constant.value.toString()));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Copied ${constant.name} value to clipboard')),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
