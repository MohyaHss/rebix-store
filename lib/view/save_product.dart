import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rebix_shop/model/product_database.dart';
import 'dart:io';
import '../main.dart';
import '../model/product_model.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class SaveProduct extends StatefulWidget {
  final  bool lightMode , persianMode , updateMode;
  ProductModel? product ;

   SaveProduct({Key? key , required this.lightMode , required this.persianMode ,
     this.product , required this.updateMode}) : super(key: key);

  @override
  State<SaveProduct> createState() => _SaveProductState(lightMode , persianMode , product , updateMode );

}

class _SaveProductState extends State<SaveProduct> {
  var primaryColor ;
  var secondaryColor ;
  var productTxtFieldLabel ;
  var ownerTxtFieldLabel ;
  var priceTxtFieldLabel;
  var doneButtonTxt ;
  late String noImgError ;
  bool lightMode , persianMode , updateMode ;
  final productController = TextEditingController();
  final sellerController = TextEditingController();
  final priceController = TextEditingController();
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  bool _productValidate = false;
  bool _sellerValidate = false;
  bool _priceValidate = false;
  String emptyFieldErr ="این فیلد نمیتواند خالی باشد";
  String doneMessage ="ثبت با موفقیت انجام شد";
  var productName, seller;
  var price;
  File? imageFile;
  ProductModel? product;
  final ImagePicker imgpicker = ImagePicker();
  String imagePath="" ;
  String fillBlank="" ;
  static const Color errorColor = Colors.red;

  _SaveProductState(this.lightMode, this.persianMode,this.product ,this.updateMode ){

    ownerTxtFieldLabel = persianMode == false ? 'Seller Name' : 'فروشنده';
    productTxtFieldLabel = persianMode == false ? 'Product Name' : 'نام محصول';
    priceTxtFieldLabel = persianMode == false ? 'Price(Rial)' : 'قیمت(ريال)';
    doneButtonTxt = persianMode == false ? 'Done' : 'ثبت';
    noImgError = persianMode == false ? "No Image has chosen" : 'عکسی انتخاب نشده';
    emptyFieldErr= persianMode ? "این فیلد نمیتواند خالی باشد" :"This field cannot be empty";
    doneMessage = persianMode ? "ثبت با موفقیت انجام شد" :"Saved Successfully";
    fillBlank = persianMode ? 'فیلد های خالی را مقداردهی کنید' : "Fill Blank Fields";
    primaryColor = lightMode == true ? Colors.white : Colors.black87;
    secondaryColor = lightMode == true ? Colors.deepPurple.shade400 : Colors.pink;
  }


  @override
  void initState() {
    super.initState();
    refreshProduct(updateMode);
  }
  @override
  void dispose() {
    super.dispose();
    productController.dispose();
    sellerController.dispose();
    priceController.dispose();
    // ProductDatabase.instance.closeDB();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        AppLocalizations.delegate, // Add this line
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ] ,
      supportedLocales: const [
        Locale('en', ''), // English, no country code
        Locale('fa', '') // Farsi, no country code
      ],
      locale: persianMode ? Locale('fa') : Locale('en'),
      theme: appTheme(lightMode),
      home: ScaffoldMessenger(
        key: scaffoldMessengerKey,
        child: Scaffold(
          body: Container(
            width: width,
            height: height,
            //margin: EdgeInsets.only(top: height*0.01),
            child: ListView(
              children: [
                headerImage(width , height),
                customTextField(context, productTxtFieldLabel,
                    Icons.production_quantity_limits_sharp, 15, true , productController , _productValidate),
                customTextField(
                    context, ownerTxtFieldLabel, Icons.person_add_alt, 15, true , sellerController , _sellerValidate),
                customTextField(
                    context, priceTxtFieldLabel, Icons.sell_outlined, 9, false , priceController , _priceValidate),
                InkWell(
                  onTap:(){
                    productName = productController.text;
                    seller = sellerController.text;
                    price = priceController.text;
                    setState(() {
                      _productValidate = productController.text.isEmpty ? true : false;
                      _sellerValidate = sellerController.text.isEmpty ? true : false;
                      _priceValidate = priceController.text.isEmpty ? true : false;
                    });
                    if( imagePath.isEmpty || productController.text.isEmpty
                        || sellerController.text.isEmpty || priceController.text.isEmpty  ){
                      scaffoldMessengerKey.currentState?.showSnackBar(SnackBar(
                        content: Text( fillBlank ) ,
                        backgroundColor:errorColor ,
                        duration: const Duration(seconds: 3),
                      ));
                    }
                    else  {
                      if(updateMode){
                        updateProduct();
                      }
                      else {
                        addProduct();
                      }
                      scaffoldMessengerKey.currentState?.showSnackBar(SnackBar(
                        content: Text(doneMessage ,
                        ) ,
                        backgroundColor:Colors.lightGreen ,
                        duration: const Duration(seconds: 3),
                      ));
                      _onLoading(width);
                      setState(() {
                        imagePath="";
                        productController.clear();
                        sellerController.clear();
                        priceController.clear();
                      });

                    }
                  },
                  child: Container(
                    alignment: Alignment.center,
                    margin: EdgeInsets.symmetric(
                        vertical: height * 0.05, horizontal: width * .1),
                    height: height * 0.07,
                    decoration: BoxDecoration(
                        borderRadius:
                        BorderRadius.all(Radius.circular(width * 0.03)),
                        color: secondaryColor),
                    child: Text(
                      doneButtonTxt,
                      style: TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: width * 0.05),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget headerImage(width , height){
    return Container(
      width: width,
      height: height * 0.4,
      color: secondaryColor,
      child: InkWell(
          child: imagePath.isEmpty
              ? Icon(
            Icons.add_a_photo,
            color: primaryColor,
            size: width * 0.5,
          )
              : Image.file(File(imagePath) , fit: BoxFit.cover,),
          onTap: () => pickImageFromGallery(context)),
    );
  }
  Widget customTextField(context, label, icon, txtLimit, bool txtKeyboard, TextEditingController controller , bool validate) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: width * 0.02, vertical: width * 0.01),
      margin: EdgeInsets.symmetric(
          vertical: height * 0.02, horizontal: width * 0.1),
      alignment: Alignment.center,
      height: height * 0.1,
      decoration: BoxDecoration(
          border: Border.all(color: secondaryColor),
          borderRadius: BorderRadius.all(Radius.circular(width * 0.05))),
      child: TextField(
        controller: controller,
        keyboardType: txtKeyboard ? TextInputType.text : TextInputType.number,
        maxLength: txtLimit,
        style: TextStyle(
          fontFamily: "Yekan",
            color: lightMode==true ? Colors.black54 : Colors.white70,
            fontSize: width * 0.06),
        // textAlign: persianLang ? TextAlign.right : TextAlign.left,
        autofocus: false,
        decoration: InputDecoration(
          errorText: validate ? emptyFieldErr : null ,
            border: InputBorder.none,
            contentPadding: EdgeInsets.only(top: width * 0.01),
            icon: Icon(
              icon,
               color: lightMode==true ? secondaryColor : Colors.grey,
            ),
            // labelStyle: TextStyle(color: secondaryColor),
            label: Text(
              label,
              style: TextStyle(fontSize: width * 0.04,
                  color: lightMode==true ? secondaryColor : Colors.grey,
              ),
            )),
      ),
    );
  }

  pickImageFromGallery(context) async {
    try {
      var pickedFile = await imgpicker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        // File imgFile = File(imagepath); //convert Path to File
        // Uint8List imagebytes = await imgFile.readAsBytes(); //convert to bytes
        // String base64string =
        //     base64.encode(imagebytes); //convert bytes to base64 string
        // Uint8List decodedbytes = base64.decode(base64string);
        setState(() {
          imagePath = pickedFile.path;
          // imageFile = imgFile;
          // imageBase64 = base64string;
        });
      } else {
        var snackBar = SnackBar(content: Text(noImgError));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    } catch (e) {
      var snackBar = SnackBar(content: Text('error while picking file.'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }
  done(width){

  }

  refreshProduct(bool updateMode){
    if (updateMode){
      imagePath = product!.image;
      productController.text = product!.productName;
      sellerController.text = product!.sellerName;
      priceController.text = product!.price;
  }
  }
  Future addProduct() async {
    final product = ProductModel(
        productName: productName,
        sellerName: seller,
        price: price,
        image: imagePath );
   await ProductDatabase.instance.insert(product);
  }
  Future updateProduct() async {
    final product = ProductModel(
      id: this.product?.id,
        productName: productName,
        sellerName: seller,
        price: price,
        image: imagePath );
    await ProductDatabase.instance.update(product);
    // await ProductDatabase.instance.closeDB();

  }
  void _onLoading(width) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: const [
               CircularProgressIndicator(color: Colors.indigoAccent),
               Text("Loading ... "),
            ],
          ),
        );
      },
    );
    new Future.delayed(new Duration(seconds: 1), () {
      Navigator.pop(context); //pop dialog
    });
  }

}
