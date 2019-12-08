import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/http_exception.dart';

import './product.dart';

class Products with ChangeNotifier {
  List<Product> _items = [
    //   Product(
    //     id: 'p1',
    //     title: 'Red Shirt',
    //     description: 'A red shirt - it is pretty red!',
    //     price: 29.99,
    //     imageUrl:
    //         'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    //   ),
    //   Product(
    //     id: 'p2',
    //     title: 'Trousers',
    //     description: 'A nice pair of trousers.',
    //     price: 59.99,
    //     imageUrl:
    //         'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    //   ),
    //   Product(
    //     id: 'p3',
    //     title: 'Yellow Scarf',
    //     description: 'Warm and cozy - exactly what you need for the winter.',
    //     price: 19.99,
    //     imageUrl:
    //         'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    //   ),
    //   Product(
    //     id: 'p4',
    //     title: 'A Pan',
    //     description: 'Prepare any meal you want.',
    //     price: 49.99,
    //     imageUrl:
    //         'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    //   ),
  ];

  List<Product> get items {
    return [..._items];
  }

  List<Product> get favoriteItems {
    return _items.where((prodItem) => prodItem.isFavorite).toList();
  }

  Future<void> fetchAndSetProducts() async {
    const url = "https://flutter-shop-app-e6531.firebaseio.com/products.json";

    try {
      final response = await http.get(url);
      // print(json.decode(response.body));

      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData == null) return;
      final List<Product> loadedProducts = [];

      extractedData.forEach((prodId, prodData) => {
            loadedProducts.add(Product(
              id: prodId,
              title: prodData['title'],
              description: prodData['description'],
              price: prodData['price'],
              imageUrl: prodData['imageUrl'],
              isFavorite: prodData['isFavorite'],
            ))
          });
      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> addProduct(Product newProduct) async {
    // _items.add(newProduct);

    const url = "https://flutter-shop-app-e6531.firebaseio.com/products.json";

    try {
      final response = await http.post(url,
          body: json.encode({
            'title': newProduct.title,
            'description': newProduct.description,
            'imageUrl': newProduct.imageUrl,
            'price': newProduct.price,
            'isFavorite': newProduct.isFavorite,
          }));

      final a = Product(
        id: json.decode(response.body)['name'],
        imageUrl: newProduct.imageUrl,
        price: newProduct.price,
        description: newProduct.description,
        title: newProduct.title,
      );

      _items.add(a);
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  // update data in server
  Future<void> updateProduct(String id, Product newProduct) async {
    final prodIndex = _items.indexWhere((prod) => prod.id == id);

    // checking the id index is existing or not in the list
    if (prodIndex >= 0) {
      final url =
          "https://flutter-shop-app-e6531.firebaseio.com/products/$id.json";
      try {
        await http.patch(url,
            body: json.encode({
              'title': newProduct.title,
              'imageUrl': newProduct.imageUrl,
              'price': newProduct.price,
              'description': newProduct.description,
            }));

        _items[prodIndex] = newProduct;
        notifyListeners();
      } catch (error) {
        print('Failed to update');
        throw error;
      }
    } else {
      print("...");
    }
  }

  Future<void> deleteProduct(String id) async {
    final url =
        "https://flutter-shop-app-e6531.firebaseio.com/products/$id.json";
    // save a temp data to rollback
    final _existingProductIndex = _items.indexWhere((prod) => prod.id == id);
    var _existingProduct = _items[_existingProductIndex];

    // delete product in memory - we will rollback if there is an error
    _items.removeWhere((prod) => prod.id == id);
    notifyListeners();

    final response = await http.delete(url);

    // if we can't delete product on server
    if (response.statusCode >= 400) {
      // insert back to list in memory
      _items.insert(_existingProductIndex, _existingProduct);
      notifyListeners();
      throw HttpException('Could not delete the product');
    }
    _existingProduct = null;
  }

  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }
}
