class LoginModel{
  String? user_id;
  String? password;
  String? user_name;
  String? city;
  dynamic designation;
  dynamic brand;
  dynamic images;
  dynamic RSM;
  dynamic SM;
  dynamic NSM;
  dynamic RSM_ID;
  dynamic SM_ID;
  dynamic NSM_ID;

  LoginModel({
    this.user_id,
    this.password,
    this.user_name,
    this.city,
    this.designation,
    this.brand,
    this.images,
    this.NSM,
    this.NSM_ID,
    this.RSM,
    this.RSM_ID,
    this.SM,
    this.SM_ID

  });
  factory
  LoginModel.fromMap(Map<dynamic,dynamic>json){
    return LoginModel(
        user_id: json['user_id'],
        password: json['password'],
        user_name: json['user_name'],
        city: json['city'],
        RSM_ID: json['RSM_ID'],
        RSM: json['RSM'],
        NSM_ID: json['NSM_ID'],
        NSM: json['NSM'],
        SM_ID: json['SM_ID'],
        SM: json['SM'],
        designation: json['designation'],
        brand: json['brand'],
        images: json['images'],

    );
  }
  Map<String,dynamic>toMap(){
    return{
      'user_id':user_id,
      'userPassword':password,
      'user_name':user_name,
      'city': city,
      'brand': brand,
      'designation': designation,
      'images': images,
      'NSM': NSM,
      'NSM_ID': NSM_ID,
      'RSM': RSM,
      'RSM_ID': RSM_ID,
      'SM': SM,
      'SM_ID': SM_ID,
    };
    
  }
}