import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/dropdownProvider.dart';
import '../model/itemModel.dart';
import '../model/itemPractiseModel.dart';

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
  Future<List<ItemModel>> fetchItems() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    final url = Uri.parse('https://api-barrel.sooritechnology.com.np/api/v1/barrel-app/barrel-item');
    final response = await http.get(url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${preferences.getString("accessToken")}',
      },);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return ItemResponse.fromJson(data).results;
    } else {
      throw Exception('Failed to load items');
    }
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