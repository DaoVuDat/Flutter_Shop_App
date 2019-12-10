import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/product.dart';
import '../providers/products.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = "/edit-product";

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _imageUrlFocusNode = FocusNode();

  var _isLoading = false;

  // creating a new Product to be updated
  var _existingProduct = Product(
      id: null, imageUrl: null, price: null, description: null, title: null);

  // this key is used to get widget, FormState in this situation (Form is stateful widget => FormState)
  final _keyForm = GlobalKey<FormState>();

  var _initValues = {
    'title': '',
    'description': '',
    'price': '',
    'imageUrl': '',
  };
  var _isInit = true;

  @override
  void initState() {
    super.initState();

    // this is the perfect location to bind method (addListener) into a ImageUrl FocusNode
    _imageUrlFocusNode.addListener(_updateImageUrl);
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();

    // ModalRoute needs placing didChangeDependencies
    if (_isInit) {
      final productId = ModalRoute.of(context).settings.arguments as String;

      if (productId != null) {
        _existingProduct =
            Provider.of<Products>(context, listen: false).findById(productId);
        _initValues = {
          'title': _existingProduct.title,
          'description': _existingProduct.description,
          'price': _existingProduct.price.toString(),
          // 'imageUrl': _existingProduct.imageUrl,
        };
        _imageUrlController.text = _existingProduct.imageUrl;
      }
    }
    _isInit = false;
  }

  @override
  void dispose() {
    // Removing all listener before disposing
    _imageUrlFocusNode.removeListener(_updateImageUrl);

    // We need to dispose all FocusNode and TextEditingController in memory
    _imageUrlFocusNode.dispose();
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageUrlController.dispose();

    super.dispose();
  }

  void _updateImageUrl() {
    // Checking the imageUrl is focused or not - illegal method to refresh the screen
    if (!_imageUrlFocusNode.hasFocus) {
      setState(() {});
    }
  }

  // this method would be triggered in submitting mode
  // after firing this method, onSaved in each TextFormField is triggered and data is stored in value
  Future<void> _saveForm() async {
    _keyForm.currentState.save();
    // print(_existingProduct.id);
    // print(_existingProduct.title);
    // print(_existingProduct.price);
    // print(_existingProduct.imageUrl);
    // print(_existingProduct.isFavorite);
    setState(() {
      _isLoading = true;
    });

    if (_existingProduct.id != null) {
      // update an existing product
      try {
        await Provider.of<Products>(context)
            .updateProduct(_existingProduct.id, _existingProduct);
      } catch (error) {
        await showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
                  title: Text('An error occurred!'),
                  content: Text('Something went wrong'),
                  actions: <Widget>[
                    FlatButton(
                      child: Text("Okay"),
                      onPressed: () {
                        Navigator.of(ctx).pop();
                      },
                    )
                  ],
                ));
      }
    } else {
      // add a new product into Products provider
      try {
        await Provider.of<Products>(context).addProduct(_existingProduct);
      } catch (error) {
        await showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
                  title: Text('An error occurred!'),
                  content: Text('Something went wrong'),
                  actions: <Widget>[
                    FlatButton(
                      child: Text("Okay"),
                      onPressed: () {
                        Navigator.of(ctx).pop();
                      },
                    )
                  ],
                ));
      }
    }
    setState(() {
      _isLoading = false;
    });
    Navigator.of(context).pop();

    // Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Product"),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _keyForm,
                child: ListView(
                  children: <Widget>[
                    TextFormField(
                      initialValue: _initValues['title'],
                      decoration: InputDecoration(labelText: 'Title'),
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value.isEmpty) {
                          return "Please input the Title.";
                        }

                        // return null for passing the validation
                        return null;
                      },
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_priceFocusNode);
                      },
                      onSaved: (value) => _existingProduct = Product(
                        id: _existingProduct.id,
                        title: value,
                        description: _existingProduct.description,
                        price: _existingProduct.price,
                        imageUrl: _existingProduct.imageUrl,
                        isFavorite: _existingProduct.isFavorite,
                      ),
                    ),
                    TextFormField(
                      initialValue: _initValues['price'],
                      decoration: InputDecoration(labelText: 'Price'),
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.number,
                      focusNode: _priceFocusNode,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context)
                            .requestFocus(_descriptionFocusNode);
                      },
                      onSaved: (value) => _existingProduct = Product(
                        id: _existingProduct.id,
                        title: _existingProduct.title,
                        description: _existingProduct.description,
                        price: double.parse(value),
                        imageUrl: _existingProduct.imageUrl,
                        isFavorite: _existingProduct.isFavorite,
                      ),
                    ),
                    TextFormField(
                      initialValue: _initValues['description'],
                      decoration: InputDecoration(labelText: 'Description'),
                      // textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.multiline,
                      maxLines: 3,
                      focusNode: _descriptionFocusNode,
                      onSaved: (value) => _existingProduct = Product(
                        id: _existingProduct.id,
                        title: _existingProduct.title,
                        description: value,
                        price: _existingProduct.price,
                        imageUrl: _existingProduct.imageUrl,
                        isFavorite: _existingProduct.isFavorite,
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Container(
                          width: 100,
                          height: 100,
                          margin: EdgeInsets.only(top: 8, right: 10),
                          decoration: BoxDecoration(
                            border: Border.all(width: 1, color: Colors.grey),
                          ),
                          child: _imageUrlController.text.isEmpty
                              ? Text(
                                  "Enter an Image URL",
                                )
                              : Image.network(
                                  _imageUrlController.text,
                                  fit: BoxFit.cover,
                                ),
                        ),
                        Expanded(
                          child: TextFormField(
                            decoration: InputDecoration(labelText: 'Image URL'),
                            keyboardType: TextInputType.url,
                            textInputAction: TextInputAction.done,
                            controller: _imageUrlController,
                            focusNode: _imageUrlFocusNode,
                            onFieldSubmitted: (_) {
                              _saveForm();
                            },
                            onSaved: (value) => _existingProduct = Product(
                              id: _existingProduct.id,
                              title: _existingProduct.title,
                              description: _existingProduct.description,
                              price: _existingProduct.price,
                              imageUrl: value,
                              isFavorite: _existingProduct.isFavorite,
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
