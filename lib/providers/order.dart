import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

import 'dart:convert';

import 'package:http/http.dart' as http;

import './cart.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({
    @required this.id,
    @required this.amount,
    @required this.products,
    @required this.dateTime,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];

  List<OrderItem> get orders {
    return [..._orders];
  }

  // add order to server
  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    const url = "https://flutter-shop-app-e6531.firebaseio.com/orders.json";

    try {
      final dayTime = DateTime.now();
      final response = http.post(url, body: json.encode({
        'items':[]
      }));
    } catch (error) {
      print(error);
      throw error;
    }
  
    _orders.insert(
      0,
      OrderItem(
          id: DateTime.now().toString(),
          amount: total,
          dateTime: DateTime.now(),
          products: cartProducts),
    );
    notifyListeners();
  }
}
