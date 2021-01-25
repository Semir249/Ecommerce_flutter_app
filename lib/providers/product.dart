import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/http_exception.dart';
import 'package:flutter_config/flutter_config.dart';

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavourite;

  Product({
    @required this.id,
    @required this.title,
    @required this.description,
    @required this.price,
    @required this.imageUrl,
    this.isFavourite = false,
  });

  Future<void> toggleFavourite(
      String productId, String authToken, String userId) async {
    final url =
        '${FlutterConfig.get('BASE_URL')}/userFavourites/$userId/$productId.json?auth=$authToken';
    final oldStatus = isFavourite;
    isFavourite = !isFavourite;
    notifyListeners();
    try {
      final updateValue = await http.put(url, body: json.encode(isFavourite));
      if (updateValue.statusCode >= 400) {
        isFavourite = oldStatus;
        notifyListeners();
        throw HttpException('There seems to be a problem');
      }
    } catch (error) {
      isFavourite = oldStatus;
      notifyListeners();
    }
  }
}
