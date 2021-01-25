import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import './cart.dart';
import 'package:flutter_config/flutter_config.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTIme;

  OrderItem(
    @required this.id,
    @required this.amount,
    @required this.products,
    @required this.dateTIme,
  );
}

class Orders with ChangeNotifier {
  String authToken;
  String userId;
  List<OrderItem> _orders = [];

  void update(String token, String id) {
    authToken = token;
    userId = id;
  }

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> fetchOrders() async {
    final url =
        '${FlutterConfig.get('BASE_URL')}/orders/$userId.json?auth=$authToken';
    final response = await http.get(url);
    final List<OrderItem> loadedOrders = [];
    final extractedData = json.decode(response.body) as Map<String, dynamic>;
    if (extractedData == null) {
      return null;
    }
    extractedData.forEach((orderId, order) {
      loadedOrders.add(OrderItem(
          orderId,
          order['amount'],
          (order['products'] as List<dynamic>)
              .map((item) => CartItem(
                  id: item['id'],
                  price: item['price'],
                  quantity: item['quantity'],
                  title: item['title']))
              .toList(),
          DateTime.parse(order['dateTime'])));
    });
    _orders = loadedOrders.reversed.toList();
    notifyListeners();
  }

  Future<void> addOrder(List<CartItem> cartProducts, double amount) async {
    final url =
        '${FlutterConfig.get('BASE_URL')}/orders/$userId.json?auth=$authToken';
    final timeStamp = DateTime.now();
    final response = await http.post(url,
        body: json.encode({
          'amount': amount,
          'dateTime': timeStamp.toIso8601String(),
          'products': cartProducts
              .map((e) => {
                    'title': e.title,
                    'quantity': e.quantity,
                    'price': e.price,
                    'id': e.id
                  })
              .toList()
        }));
    _orders.insert(
        0,
        OrderItem(json.decode(response.body)['name'], amount, cartProducts,
            timeStamp));
    notifyListeners();
  }
}
