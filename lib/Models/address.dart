class AddressModel {
  String name = "";
  String phoneNumber = "";
  String homeName = "";
  String place = "";
  String city = "";
  String pinCode = "";

  AddressModel(
      {required this.name,
      required this.phoneNumber,
      required this.homeName,
      required this.place,
      required this.city,
      required this.pinCode});

  AddressModel.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    phoneNumber = json['phoneNumber'];
    homeName = json['homeName'];
    place = json['place'];
    city = json['city'];
    pinCode = json['pincode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['phoneNumber'] = this.phoneNumber;
    data['homeName'] = this.homeName;
    data['place'] = this.place;
    data['city'] = this.city;
    data['pincode'] = this.pinCode;
    return data;
  }
}
