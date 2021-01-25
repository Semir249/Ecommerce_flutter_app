import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './screens/products_overview_screen.dart';
import './screens/product_detail_screen.dart';
import './providers/products.dart';
import './providers/cart.dart';
import './screens/cart_screen.dart';
import './providers/orders.dart';
import './screens/orders_screen.dart';
import './screens/manage_products.dart';
import './screens/edit_product_screen.dart';
import './screens/auth_screen.dart';
import './providers/auth.dart';
import './widgets/splash_screen.dart';
import 'package:flutter_config/flutter_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterConfig.loadEnvVariables();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final Color kShrinePink50 = Color(0xFFFEEAE6);
  final Color kShrinePink100 = Color(0xFFFEDBD0);
  final Color kShrinePink300 = Color(0xFFFBB8AC);
  final Color kShrinePink400 = Color(0xFFEAA4A4);
  final kShrineBrown900 = Color(0xFF442B2D);

  final kShrineErrorRed = Color(0xFFC5032B);

  final kShrineSurfaceWhite = Color(0xFFFFFBFA);
  final kShrineBackgroundWhite = Colors.white;
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (ctx) => Auth(),
          ),
          ChangeNotifierProxyProvider<Auth, Products>(
            create: (context) => Products(),
            update: (context, authData, previousProducts) =>
                previousProducts..update(authData.token, authData.userId),
          ),
          ChangeNotifierProvider(
            create: (ctx) => Cart(),
          ),
          ChangeNotifierProxyProvider<Auth, Orders>(
              create: (context) => Orders(),
              update: (context, authData, previousOrders) =>
                  previousOrders..update(authData.token, authData.userId))
        ],
        child: Consumer<Auth>(
          builder: (context, auth, child) => MaterialApp(
            title: 'My Shop',
            theme: ThemeData(
                primaryColor: kShrinePink400,
                accentColor: kShrineBrown900,
                primaryColorLight: kShrinePink100,
                fontFamily: 'Lato',
                canvasColor: kShrineBackgroundWhite,
                textTheme: ThemeData.light()
                    .textTheme
                    .copyWith(title: TextStyle(color: kShrineBrown900))),
            home: auth.isAuth
                ? ProductOverviewScreen()
                : FutureBuilder(
                    future: auth.autoLogin(),
                    builder: (context, snapshot) {
                      return snapshot.connectionState == ConnectionState.waiting
                          ? SplashScreen()
                          : AuthScreen();
                    }),
            routes: {
              ProductOverviewScreen.routeName: (ctx) => ProductOverviewScreen(),
              ProductDetailScreen.routeName: (ctx) => ProductDetailScreen(),
              CartScreen.routeName: (ctx) => CartScreen(),
              OrdersScreen.routeName: (ctx) => OrdersScreen(),
              ManageProductsScreen.routeName: (ctx) => ManageProductsScreen(),
              EditProductScreen.routeName: (ctx) => EditProductScreen(),
            },
          ),
        ));
  }
}
