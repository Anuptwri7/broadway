
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/dropdownProvider.dart';
import '../model/itemModel.dart';


class ItemDropdownPage extends StatefulWidget {
  const ItemDropdownPage({super.key});

  @override
  State<ItemDropdownPage> createState() => _ItemDropdownPageState();
}

class _ItemDropdownPageState extends State<ItemDropdownPage> {
  String? _selectedItem = "Select Item";
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.microtask(() =>
        Provider.of<StockProvider>(context, listen: false).fetchStockData());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Item Dropdown')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Consumer<StockProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  // return const CircularProgressIndicator();
                } else if (provider.error != null) {
                  return Text("Error: ${provider.error}");
                } else if (provider.stockList.isEmpty) {
                  return const Text("No data found");
                }
                return DropdownButtonFormField<BarrelStock>(
                  hint:  Text(_selectedItem!),
                  items: provider.stockList.map((stock) {
                    return DropdownMenuItem(
                      value: stock,
                      child: Text(stock.item.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedItem = value!.item.name;
                    });
                    print(
                        "Selected: ${value!.item.name}, Batch: ${value.batchNo}, Qty: ${value.quantity}");
                  },
                );
              },
            ),

          ],
        ),
      ),
    );
  }
}