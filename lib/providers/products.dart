import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import './product.dart';
import '../models/http_exception.dart';
import 'package:flutter_config/flutter_config.dart';

class Products with ChangeNotifier {
  List<Product> _items = [];
  String authToken;
  String userId;
  void update(String token, String id) {
    authToken = token;
    userId = id;
  }

  // var isFavouritesOnly = false;
  List<Product> get items {
    // if (isFavouritesOnly) {
    //   return _items.where((prod) => prod.isFavourite).toList();
    // }
    return [..._items];
  }

  List<Product> get onlyFavourites {
    return _items.where((item) => item.isFavourite).toList();
  }

  Product findById(String id) {
    return items.firstWhere((prod) => prod.id == id);
  }

  Future<void> addProduct(Product product) async {
    final url =
        '${FlutterConfig.get('BASE_URL')}/products.json?auth=$authToken';

    try {
      final response = await http.post(url,
          body: json.encode({
            'title': product.title,
            'price': product.price,
            'description': product.description,
            'imageUrl': product.imageUrl,
            'creatorId': userId
          }));

      final newProduct = Product(
        description: product.description,
        title: product.title,
        imageUrl: product.imageUrl,
        price: product.price,
        id: json.decode(response.body)['name'],
      );
      _items.add(newProduct);
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> fetchProducts([bool filter = false]) async {
    final filterString = filter ? 'orderBy="creatorId"&equalTo="$userId"' : '';
    try {
      var url =
          '${FlutterConfig.get('BASE_URL')}/products.json?auth=$authToken&$filterString';
      final response = await http.get(url);
      final decodedData = json.decode(response.body) as Map<String, dynamic>;
      if (decodedData == null) {
        return;
      }
      url =
          '${FlutterConfig.get('BASE_URL')}/userFavourites/$userId.json?auth=$authToken';

      final favouriteResponse = await http.get(url);
      final favouriteData = json.decode(favouriteResponse.body);
      final List<Product> loadedData = [];
      decodedData.forEach((prodId, product) {
        loadedData.add(Product(
            id: prodId,
            title: product['title'],
            price: product['price'],
            description: product['description'],
            imageUrl: product['imageUrl'],
            isFavourite: favouriteData == null
                ? false
                : favouriteData[prodId] ?? false));
      });
      _items = loadedData;
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  void editProduct(String id, Product editedProduct) async {
    final toBeEditedIndex = _items.indexWhere((prod) => prod.id == id);

    if (toBeEditedIndex >= 0) {
      final url =
          '${FlutterConfig.get('BASE_URL')}/products/$id.json?auth=$authToken';
      await http.patch(url,
          body: json.encode({
            'title': editedProduct.title,
            'price': editedProduct.price,
            'description': editedProduct.description,
            'imageUrl': editedProduct.imageUrl
          }));
      _items[toBeEditedIndex] = editedProduct;
      notifyListeners();
    }
  }

  Future<void> deleteProduct(String id) async {
    final url =
        '${FlutterConfig.get('BASE_URL')}/products/$id.json?auth=$authToken';

    final existingProductIndex = _items.indexWhere((prod) => prod.id == id);
    var existingProduct = _items[existingProductIndex];
    _items.removeWhere((prod) => prod.id == id);
    notifyListeners();

    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException('Item Couldnt be deleted');
    }
    existingProduct = null;
  }
}
