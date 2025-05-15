import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../model/itemPractiseModel.dart';

class ItemDropdownPage extends StatefulWidget {
  const ItemDropdownPage({super.key});

  @override
  State<ItemDropdownPage> createState() => _ItemDropdownPageState();
}

class _ItemDropdownPageState extends State<ItemDropdownPage> {
  ItemModel? _selectedItem;
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
            FutureBuilder<List<ItemModel>>(
              future: fetchItems(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No items found.'));
                } else {
                  final items = snapshot.data!;
                  return DropdownButton<ItemModel>(
                    hint: const Text('Select an Item'),
                    value: _selectedItem,
                    isExpanded: true,
                    items: items.map((item) {
                      return DropdownMenuItem<ItemModel>(
                        value: item,
                        child: Text(item.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedItem = value;
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Selected: ${value?.name}')),
                      );
                    },
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}