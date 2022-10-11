import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rebix_shop/model/product_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rebix_shop/view/save_product.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'model/product_model.dart';

ThemeData appTheme(bool lightMode) {
  return ThemeData(
      brightness: lightMode == true ? Brightness.light : Brightness.dark,
      backgroundColor: lightMode == true ? Colors.white : Colors.black,
      scaffoldBackgroundColor:
          lightMode == true ? Colors.white : Colors.grey.shade900,
      appBarTheme: AppBarTheme(
          titleTextStyle: TextStyle(fontFamily: "Yekan"),
          iconTheme: IconThemeData(
            size: 35,
            color: lightMode == true ? Colors.deepPurple.shade400 : Colors.pink,
          ),
          backgroundColor: lightMode == true ? Colors.white : Colors.black87),
      primaryColor: lightMode == true
          ? Colors.deepPurple.shade300
          : Colors.lightGreenAccent,
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: lightMode == true
            ? Colors.deepPurple.shade400.withOpacity(0.9)
            : Colors.pink.withOpacity(0.9),
      ),
      textTheme: TextTheme(
          bodyText1: TextStyle(
            color: lightMode == true ? Colors.black54 : Colors.white70,
            fontFamily: "Yekan",
          ),
          bodyText2: TextStyle(
              color: lightMode == true ? Colors.black54 : Colors.white70,
              fontFamily: "Yekan",
              fontSize: 30)));
}

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Store(),
  ));
}

class Store extends StatefulWidget {
  const Store({Key? key}) : super(key: key);

  @override
  _StoreState createState() => _StoreState();
}

class _StoreState extends State<Store> {
  var appName = "فروشگاه";
  int chosenType = 0;
  Color primaryColor = Colors.deepPurple.shade400;
  Color backgroundColor = Colors.white;
  Color? onModeColor = Colors.yellow.shade600;

  bool persianLanguage = true; //true is for persian & vice versa
  bool firsTimeEntrance = true;
  String sellerNameLabel = 'فروشنده : ';
  String lightModeLabel = 'حالت روشنایی';
  String languageModeLabel = 'زبان برنامه';
  String language = 'فا';
  String delete = 'حذف';
  String cancel = 'لغو';
  String deleteDialogText = 'آیا میخواهید این محصول را حذف کنید ؟';
  String welCome = "به فروشگاه ریبیکس خوش آمدید . برای ثبت محصول روی دکمه + کلیک کنید";
  IconData modeIcon = CupertinoIcons.lightbulb_fill;
  late List<ProductModel>? products;
  bool isLoading = false;
  late ProductModel chosenProduct;
  var lightMode;

  final GlobalKey<ScaffoldState> _key = GlobalKey(); // Create a key

  @override
  initState() {
    super.initState();
    refreshProducts();
    lightMode = true;
  }

  @override
  void dispose() {
    // ProductDatabase.instance.closeDB();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final  appLocalization = AppLocalizations.of(context);
    // var name = appLocalization!.price;
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate, // Add this line
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', ''), // English, no country code
          Locale('fa', '') // Farsi, no country code
        ],=-p
        locale: persianLanguage ? Locale('fa') : Locale('en'),
        debugShowCheckedModeBanner: false,
        theme: appTheme(lightMode),
        home: Scaffold(
          key: _key,
          appBar: appBar(width),
          drawer: drawerContainer(width, height),
          floatingActionButton: floatingActionBtn(width),
          body: Container(
            child: firsTimeEntrance == true
                ? entranceText()
                : ListView(
                    //padding: EdgeInsets.all(width*0.09),
                    children: [
                      firstProductContainer(width, height),
                      Divider(),
                      productListContainer(width, height)
                    ],
                  ),
          ),
        ));
  }

  AppBar appBar(width) => AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          appName,
          style: TextStyle(
              color: primaryColor,
              fontSize: width * 0.08,
              fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      );

  Container entranceText() {
    return Container(
      padding: EdgeInsets.all(20),
      child: Center(
        child: Text(welCome),
      ),
    );
  }

  Container drawerContainer(width, height) => Container(
        decoration: BoxDecoration(
            color: lightMode == true ? Colors.white : Colors.black,
            borderRadius: BorderRadius.only(topLeft: Radius.circular(25))),
        height: height,
        width: width * 0.45,
        child: ListView(
          children: [
            SizedBox(height: height * 0.5),
            InkWell(
                onTap: () {
                  setState(() {
                    setlightModeValue(lightMode);
                    if (lightMode) {
                      lightMode = false;
                      primaryColor = Colors.pink;
                      onModeColor = Colors.grey;
                      backgroundColor = Colors.black45;
                      modeIcon = CupertinoIcons.lightbulb_slash;
                    } else {
                      lightMode = true;
                      primaryColor = Colors.deepPurple.shade400;
                      onModeColor = Colors.yellow.shade600;
                      backgroundColor = Colors.white;
                      modeIcon = CupertinoIcons.lightbulb_fill;
                    }
                  });
                },
              child: Container(
                  width: width,
                  margin: EdgeInsets.symmetric(
                      horizontal: width * 0.01, vertical: width * 0.04),
                  padding: EdgeInsets.all(width * 0.05),
                  decoration: BoxDecoration(
                    // border: Border.all(color: primaryColor.withOpacity(0.4) , width: 2),
                    color: primaryColor.withOpacity(0.4),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    modeIcon,
                    color: onModeColor,
                  )),
            ),
            Container(
              alignment: Alignment.center,
              child: Text(
                lightModeLabel,
                style: TextStyle(fontSize: width * 0.04),
              ),
            ),
            InkWell(
              onTap: (){
                setState(() {
                  if (persianLanguage) {
                    persianLanguage = false;
                    language = "En";
                    languageModeLabel = 'app Language';
                    lightModeLabel = 'Light Mode';
                    sellerNameLabel = 'Seller : ';
                    appName = "Store";
                    deleteDialogText = "Do you want to delete this product ?";
                    delete = "Delete";
                    cancel = "Cancel";
                    welCome = 'Welcome to RebixStore , to add product press + button ';
                  } else {
                    persianLanguage = true;
                    language = "فا";
                    languageModeLabel = 'زبان برنامه';
                    lightModeLabel = 'حالت روشنایی';
                    sellerNameLabel = 'فروشنده : ';
                    appName = "فروشگاه";
                    deleteDialogText = "آیا میخواهید محصول را حذف کنید ؟";
                    delete = "حذف";
                    cancel = "لغو";
                    welCome = "به فروشگاه ریبیکس خوش آمدید . برای ثبت محصول روی دکمه + کلیک کنید";
                  }
                });
              },
              child: Container(
                alignment: Alignment.center,
                width: width,
                margin: EdgeInsets.only(bottom: width * 0.02, top: width * 0.1),
                padding: EdgeInsets.all(width * 0.05),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.4),
                  shape: BoxShape.circle,
                ),
                child: Text(language),
              ),
            ),
            Container(
              alignment: Alignment.center,
              margin: EdgeInsets.only(top: width * 0.02),
              child: Text(
                languageModeLabel,
                style: TextStyle(fontSize: width * 0.04),
              ),
            ),
          ],
        ),
      );

  Container floatingActionBtn(width) => Container(
        width: width * 0.2,
        height: width * 0.2,
        margin: EdgeInsets.symmetric(
            horizontal: width * 0.05, vertical: width * 0.05),
        child: FloatingActionButton(
          child: Icon(
            Icons.add,
            size: width * 0.07,
          ),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => SaveProduct(
                          lightMode: lightMode,
                          persianMode: persianLanguage,
                          product: null,
                          updateMode: false,
                        ))).then((value) => refreshProducts());
          },
        ),
      );

  Container firstProductContainer(width, height) => Container(
      //First PRODUCT CONTAINER
      clipBehavior: Clip.hardEdge,
      height: height * 0.45,
      margin: EdgeInsets.only(
          top: width * 0.07,
          bottom: width * 0.03,
          left: width * 0.05,
          right: width * 0.05),
      decoration: BoxDecoration(
          border: Border.all(
              color: lightMode == true
                  ? Colors.blueGrey.shade100.withOpacity(0.4)
                  : Colors.grey.shade700.withOpacity(0.2),
              width: width * 0.003),
          borderRadius: BorderRadius.all(Radius.circular(width * 0.08))),
      child: InkWell(
        onLongPress: () {
          deleteDialog();
        },
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => SaveProduct(
                        lightMode: lightMode,
                        persianMode: persianLanguage,
                        product: chosenProduct,
                        updateMode: true,
                      ))).then((value) => refreshProducts());
        },
        child: Column(
          children: [
            Stack(
                alignment: persianLanguage
                    ? Alignment.bottomLeft
                    : Alignment.bottomRight,
                children: [
                  Container(
                    //CHOSEN PRODUCT PICTURE CONTAINER
                    height: height * 0.3,
                    width: width,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(width * 0.08),
                            topRight: Radius.circular(width * 0.08))
                        // borderRadius: BorderRadius.circular(30)
                        ),
                    child: Container(
                        child: Image.file(
                      File(chosenProduct.image),
                      fit: BoxFit.cover,
                    )),
                  ),
                  Container(
                    padding: EdgeInsets.all(width * 0.02),
                    margin: EdgeInsets.symmetric(
                        horizontal: width * 0.02, vertical: width * 0.02),
                    decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.6),
                        borderRadius:
                            BorderRadius.all(Radius.circular(width * 0.03))),
                    child: Text(" ${chosenProduct.price}  ریال ",
                        style: TextStyle(
                            fontSize: width * 0.06,
                            // color: primaryColor ,
                            fontWeight: FontWeight.bold)),
                  ),
                ]),
            Container(
              //CHOSEN PRODUCT NAME
              alignment:
                  persianLanguage ? Alignment.topRight : Alignment.topLeft,
              margin: EdgeInsets.symmetric(
                  horizontal: width * 0.04, vertical: width * 0.05),
              child: Text(
                chosenProduct.productName,
                style: TextStyle(
                    fontSize: width * 0.08,
                    fontWeight: FontWeight.bold,
                    color: lightMode ? Colors.black : Colors.white70),
              ),
            ),
            Container(
              alignment:
                  persianLanguage ? Alignment.topRight : Alignment.topLeft,
              //SELLER NAME CONT
              margin: EdgeInsets.symmetric(horizontal: width * 0.04),
              child: Text(
                sellerNameLabel + chosenProduct.sellerName,
                style: TextStyle(
                    fontSize: width * 0.06,
                    color: lightMode ? Colors.black : Colors.white70),
              ),
            )
          ],
        ),
      ));

  Container productListContainer(width, height) => Container(
        //PRODUCT LIST
        margin: EdgeInsets.only(
            bottom: width * 0.01,
            top: width * 0.03,
            left: width * 0.03,
            right: width * 0.03),
        height: height * 0.35,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(35),
            topLeft: Radius.circular(35),
          ),
        ),
        child: ListView.builder(
          // MAIN LIST]
          scrollDirection: Axis.horizontal,
          itemCount: products!.length,
          itemBuilder: (c, i) {
            return InkWell(
              onTap: () {
                setState(() {
                  chosenProduct = products![i];
                });
              },
              child: Container(
                clipBehavior: Clip.hardEdge,
                alignment:
                    persianLanguage ? Alignment.topRight : Alignment.topLeft,
                height: height * 0.6,
                margin: EdgeInsets.symmetric(horizontal: width * 0.02),
                decoration: BoxDecoration(
                    //border: Border.all(color: Colors.deepPurpleAccent),
                    borderRadius:
                        BorderRadius.all(Radius.circular(width * 0.07))),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      // PICTURE CONTAINER
                      clipBehavior: Clip.hardEdge,
                      height: height * 0.22,
                      width: width * 0.5,
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.all(Radius.circular(width * 0.07)),
                      ),
                      child: Image.file(
                        File(products![i].image),
                        fit: BoxFit.cover,
                      ),
                    ),
                    Align(
                      alignment: persianLanguage
                          ? Alignment.topRight
                          : Alignment.topLeft,
                      child: Container(
                        margin: EdgeInsets.only(right: width * 0.01),
                        child: Text(
                          products![i].productName,
                          style: TextStyle(
                              fontSize: width * 0.06,
                              fontWeight: FontWeight.bold,
                              color: lightMode ? Colors.black54 : Colors.grey),
                        ),
                      ),
                    ),
                    Align(
                      alignment: persianLanguage
                          ? Alignment.bottomLeft
                          : Alignment.bottomRight,
                      child: Container(
                        padding: EdgeInsets.all(width * 0.008),
                        decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.7),
                            borderRadius: BorderRadius.all(
                                Radius.circular(width * 0.01))),
                        child: Text(products![i].price + " ریال",
                            style: TextStyle(
                                fontSize: width * 0.03,
                                color: backgroundColor,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );

  setlightModeValue(bool lightMode) async {
    SharedPreferences sharedLightMode = await SharedPreferences.getInstance();
    sharedLightMode.setBool('light_mode', lightMode);
  }

  getLightMode() async {
    SharedPreferences sharedLightMode = await SharedPreferences.getInstance();
    bool? lightMode = await sharedLightMode.getBool('light_mode');
    if (lightMode == null) {
      return true;
    } else {
      return lightMode;
    }
  }

  Future deleteProduct() async {
    var id = chosenProduct!.id;
    await ProductDatabase.instance.delete(id!);
    refreshProducts();
  }

  Future refreshProducts() async {
    setState(() {
      isLoading = true;
    });
    products = await ProductDatabase.instance.selectAllProducts();
    if (products == null) {
      firsTimeEntrance = true;
    } else {
      firsTimeEntrance = false;
      chosenProduct = products![0];
    }
    setState(() {
      isLoading = false;
    });
  }

  deleteDialog() {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)),
            child: Container(
              height: 200,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: persianLanguage
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  Container(
                    alignment: persianLanguage
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.all(5),
                    decoration: const BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20))),
                    child: const Icon(
                      CupertinoIcons.delete,
                      size: 35,
                      color: Colors.grey,
                    ),
                  ),
                  Align(
                      alignment: Alignment.center,
                      child: Text(deleteDialogText,
                          style: TextStyle(fontFamily: "Yekan", fontSize: 20))),
                  Padding(
                    padding: const EdgeInsets.all(1.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.all(5),
                            alignment: Alignment.center,
                            height: 40,
                            decoration: const BoxDecoration(
                                color: Colors.grey,
                                borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(20))),
                            child: InkWell(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Text(
                                cancel,
                                style: TextStyle(fontFamily: "Yekan" , fontSize: 20 , color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.all(5),
                            alignment: Alignment.center,
                            height: 40,
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.only(bottomRight:  Radius.circular(20)),
                                color: Colors.redAccent,
                                ),
                            child: InkWell(
                              onTap: () {
                                deleteProduct();
                                Navigator.pop(context);
                              },
                              child: Text(
                                delete,
                                style: TextStyle(fontFamily: "Yekan" , fontSize: 20 , color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }


}
