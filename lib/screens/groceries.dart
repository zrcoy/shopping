// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shopping/data/categories.dart';
import 'package:shopping/models/grocery_item.dart';
import 'package:shopping/screens/new_item.dart';
import 'package:shopping/widgets/grocery_item_widget.dart';
import 'package:http/http.dart' as http;

class Groceries extends StatefulWidget {
  const Groceries({super.key});

  @override
  State<StatefulWidget> createState() {
    return _GroceriesState();
  }
}

class _GroceriesState extends State<Groceries> {
  List<GroceryItem> groceryItems = [];
  var _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    final url = Uri.https(
        'flutter-prep-ebd1c-default-rtdb.firebaseio.com', 'shopping-list.json');
    final data = await http.get(url);
    if (data.statusCode >= 400) {
      setState(() {
        _error = 'No data fetched. Please try again later.';
      });
    }

    final Map<String, dynamic> formattedData = json.decode(data.body);

    final List<GroceryItem> loadedItems = [];
    for (var item in formattedData.entries) {
      final categoryItem = categories.entries
          .firstWhere((cat) => cat.value.title == item.value['category'])
          .value;
      loadedItems.add(
        GroceryItem(
          id: item.key,
          name: item.value['name'],
          quantity: int.parse(item.value['quantity']),
          category: categoryItem,
        ),
      );
    }
    setState(() {
      groceryItems = loadedItems;
      _isLoading = false;
    });
  }

  void _addItem() async {
    final item = await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(builder: (ctx) => const NewItemScreen()),
    );
    if (item == null) {
      return;
    }
    setState(() {
      groceryItems.add(item);
    });
  }

  void _removeItem(GroceryItem item) async {
    final index = groceryItems.indexOf(item);
    setState(() {
      groceryItems.remove(item);
    });

    final url = Uri.https('flutter-prep-ebd1c-default-rtdb.firebaseio.com',
        'shopping-list/${item.id}.json');

    final response = await http.delete(url);
    if (response.statusCode >= 400 && context.mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not delete item. Please try again later.',
          ),
          duration: Duration(seconds: 3),
        ),
      );
      setState(() {
        groceryItems.insert(index, item);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content;
    if (groceryItems.isNotEmpty) {
      content = ListView.builder(
        itemBuilder: (ctx, index) => Dismissible(
            onDismissed: (direction) {
              _removeItem(groceryItems[index]);
            },
            key: ValueKey(groceryItems[index].id),
            child: GroceryItemWidget(groceryItem: groceryItems[index])),
        itemCount: groceryItems.length,
      );
    } else {
      content = Center(
        child: Text(
          'You don\'t have anything yet. Add one!',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      );
    }

    if (_isLoading) {
      content = const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      content = Center(
        child: Text(
          _error!,
          style: Theme.of(context).textTheme.titleLarge,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Your Groceries',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addItem,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: content,
      ),
    );
  }
}
