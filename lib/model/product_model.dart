

final String productTable = "product";

class ProductFields{
  static final List<String> values = [
    id , image , productName , sellerName , price
  ];

  static final String id = "_id";
  static final String image = "image";
  static final String productName = "productName";
  static final String sellerName = "sellerName";
  static final String price = "price";
}
class ProductModel{
  final int? id;
  final String image ;
  final String productName ;
  final String sellerName ;
  final String price ;

  const ProductModel({
    this.id ,
    required this.productName,
    required this.sellerName,
    required this.price,
    required this.image,
  });

  Map<String , Object?> toMap() =>{
    ProductFields.id : id,
    ProductFields.image : image,
    ProductFields.productName : productName,
    ProductFields.sellerName : sellerName,
    ProductFields.price : price,
  };

  static ProductModel fromMap(Map<String , Object?> map )=> ProductModel(
      id: map[ProductFields.id] as int, //converting object type to integer
      image: map[ProductFields.image] as String,
      productName:map[ProductFields.productName] as String ,
      sellerName: map[ProductFields.sellerName] as String,
      price: map[ProductFields.price] as String
  );

  ProductModel copy({
    int? id ,
    String? image ,
    String? productName ,
    String? sellerName ,
    String? price
  })=>ProductModel(
      id : id ?? this.id,
      image : image ?? this.image,
      productName : productName ?? this.productName,
      sellerName : sellerName ?? this.sellerName,
      price : price ?? this.price
  );
}












