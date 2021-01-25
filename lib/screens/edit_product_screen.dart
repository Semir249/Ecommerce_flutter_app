import 'package:flutter/material.dart';
import '../providers/product.dart';
import 'package:provider/provider.dart';
import '../providers/products.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = '/edit-product';
  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _descriptionNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _imageUrlFocusNode = FocusNode();
  final _forms = GlobalKey<FormState>();
  var _isLoading = false;
  var editedProduct =
      Product(id: null, title: '', description: '', price: 0.0, imageUrl: '');
  var init = false;
  var _initialValues = {
    'title': '',
    'price': '',
    'description': '',
    'imageUrl': ''
  };
  @override
  void initState() {
    _imageUrlFocusNode.addListener(_updateListener);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (!init) {
      final productId = ModalRoute.of(context).settings.arguments as String;

      if (productId != null) {
        editedProduct = Provider.of<Products>(context).findById(productId);
        _initialValues = {
          'title': editedProduct.title,
          'price': editedProduct.price.toString(),
          'description': editedProduct.description,
          'imageUrl': ''
        };
        _imageUrlController.text = editedProduct.imageUrl;
      }
    }
    init = true;
    super.didChangeDependencies();
  }

  void _updateListener() {
    if (_imageUrlController.text.isEmpty ||
        (!_imageUrlController.text.startsWith('http') &&
            !_imageUrlController.text.startsWith('https'))) {
      return;
    }
    if (!_imageUrlFocusNode.hasFocus) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _imageUrlFocusNode.removeListener(_updateListener);
    _imageUrlFocusNode.dispose();
    _priceFocusNode.dispose();
    _descriptionNode.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    final isValid = _forms.currentState.validate();
    if (!isValid) {
      return;
    }
    _forms.currentState.save();
    setState(() {
      _isLoading = true;
    });
    if (editedProduct.id != null) {
      await Provider.of<Products>(context, listen: false)
          .editProduct(editedProduct.id, editedProduct);
    } else {
      try {
        await Provider.of<Products>(context, listen: false)
            .addProduct(editedProduct);
      } catch (error) {
        return showDialog<Null>(
            context: context,
            builder: (ctx) => AlertDialog(
                  title: Text('An error occured'),
                  content: Text('Something went wrong'),
                  actions: <Widget>[
                    FlatButton(
                      child: Text('close'),
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: editedProduct.id == null
            ? Text('Add Products')
            : Text('Edit Product'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _submitForm,
          )
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: EdgeInsets.all(16),
              child: Form(
                  key: _forms,
                  child: SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        TextFormField(
                          initialValue: _initialValues['title'],
                          decoration: InputDecoration(labelText: 'Title'),
                          textInputAction: TextInputAction.next,
                          onFieldSubmitted: (_) {
                            FocusScope.of(context)
                                .requestFocus(_priceFocusNode);
                          },
                          onSaved: (value) {
                            editedProduct = Product(
                              id: editedProduct.id,
                              title: value,
                              description: editedProduct.description,
                              price: editedProduct.price,
                              imageUrl: editedProduct.imageUrl,
                              isFavourite: editedProduct.isFavourite,
                            );
                          },
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please enter a Title';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          initialValue: _initialValues['price'],
                          decoration: InputDecoration(labelText: 'Price'),
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.number,
                          focusNode: _priceFocusNode,
                          onFieldSubmitted: (_) {
                            FocusScope.of(context)
                                .requestFocus(_descriptionNode);
                          },
                          onSaved: (value) {
                            editedProduct = Product(
                              id: editedProduct.id,
                              title: editedProduct.title,
                              description: editedProduct.description,
                              price: double.parse(value),
                              imageUrl: editedProduct.imageUrl,
                              isFavourite: editedProduct.isFavourite,
                            );
                          },
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please enter a Price';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Please enter a valid number';
                            }
                            if (double.parse(value).isNegative) {
                              return 'Please enter a postive number';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          initialValue: _initialValues['description'],
                          decoration: InputDecoration(labelText: 'Description'),
                          keyboardType: TextInputType.multiline,
                          maxLines: 3,
                          focusNode: _descriptionNode,
                          onSaved: (value) {
                            editedProduct = Product(
                              id: editedProduct.id,
                              title: editedProduct.title,
                              description: value,
                              price: editedProduct.price,
                              imageUrl: editedProduct.imageUrl,
                              isFavourite: editedProduct.isFavourite,
                            );
                          },
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please enter a description';
                            }
                            if (value.length < 10) {
                              return 'Please enter more than 10 characters';
                            }
                            return null;
                          },
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            Container(
                              width: 100,
                              height: 100,
                              margin: EdgeInsets.only(
                                top: 8,
                                right: 10,
                              ),
                              decoration: BoxDecoration(
                                  border: Border.all(
                                width: 1,
                                color: Colors.grey,
                              )),
                              child: _imageUrlController.text.isEmpty
                                  ? Text('Enter a URL')
                                  : FittedBox(
                                      child: Image.network(
                                        _imageUrlController.text,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                            ),
                            Expanded(
                              child: TextFormField(
                                decoration:
                                    InputDecoration(labelText: 'Image Url'),
                                keyboardType: TextInputType.url,
                                textInputAction: TextInputAction.done,
                                controller: _imageUrlController,
                                onEditingComplete: () {
                                  setState(() {});
                                },
                                focusNode: _imageUrlFocusNode,
                                onFieldSubmitted: (_) {
                                  _submitForm();
                                },
                                onSaved: (value) {
                                  editedProduct = Product(
                                    id: editedProduct.id,
                                    title: editedProduct.title,
                                    description: editedProduct.description,
                                    price: editedProduct.price,
                                    imageUrl: value,
                                    isFavourite: editedProduct.isFavourite,
                                  );
                                },
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'Please enter an imageUrl';
                                  }
                                  if (!value.startsWith('http') &&
                                      !value.startsWith('https')) {
                                    return 'Please enter a valid URL';
                                  }
                                },
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  )),
            ),
    );
  }
}
