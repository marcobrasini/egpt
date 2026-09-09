import 'dart:ui';
import 'package:calendar/calendar.dart';
import '../sources/source_register.dart';
import 'product.dart';


class Member implements EGPTData {
  static final register = RegisterSource();

  final String? id;
  String name;
  String firstName;
  String lastName;
  Date birth;
  Color color;
  String? email;
  String? phone;
  String? photo;

  Member({
    this.id,
    required this.name,
    required this.firstName,
    required this.lastName,
    required this.birth,
    required this.color,
    this.email,
    this.phone,
    this.photo,
  });

  factory Member.make({
    String? id,
    required Map<String, dynamic> data,
  }) => Member(
    id: id,
    name: data['name'],
    firstName: data['firstName'],
    lastName: data['lastName'],
    birth: data['birth'],
    color: data['color'],
    email: data['email'],
    phone: data['phone'],
    photo: data['photo'],
  );

  Map<String, dynamic> get() => {
    'name': name,
    'firstName': firstName,
    'lastName': lastName,
    'birth': birth,
    'color': color,
    'email': email,
    'phone': phone,
    'photo': photo,
  };

  Member set(Map<String, dynamic> data) {
    name = data['name'];
    firstName = data['firstName'];
    lastName = data['lastName'];
    birth = data['birth'];
    color = data['color'];
    return this;
  }

  final List<Product> products = [];
  Product product(String productId) =>
      products.firstWhere((p) => p.id == productId);

  int get age {
    final today = Date.now();
    final age = today.year - birth.year;
    return (today.month < birth.month
        || (today.month == birth.month && today.day < birth.day))
        ? age - 1
        : age;
  }
  bool get training =>  products.any((product) => product.isOngoing() && !product.isWarning());
  bool get expiring =>  products.any((product) => product.isWarning());
  bool get finished => !products.any((product) => product.isOngoing());

}