import 'package:flutter/material.dart';
import 'package:shopping/models/grocery_item.dart';
import 'package:shopping/screens/new_item.dart';
import 'package:shopping/widgets/grocery_item_widget.dart';

class Groceries extends StatefulWidget {
  const Groceries({super.key});

  @override
  State<StatefulWidget> createState() {
    return _GroceriesState();
  }
}

class _GroceriesState extends State<Groceries> {
  final groceryItems = <GroceryItem>[];

  void _addItem() async {
    final newItem = await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(builder: (ctx) => const NewItemScreen()),
    );

    if (newItem != null) {
      setState(() {
        groceryItems.add(newItem);
      });
    }
  }

  void _removeItem(GroceryItem item) {
    setState(() {
      groceryItems.remove(item);
    });
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
