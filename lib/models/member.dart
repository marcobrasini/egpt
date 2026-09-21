import 'dart:ui';
import 'package:calendar/calendar.dart';
import '../sources/source_register.dart';
import '../typedef.dart';
import 'product.dart';


class Member implements EGPTItem {
  static final register = RegisterSource();

  @override final String? id;
  String name;
  String firstName;
  String lastName;
  Color color;
  Date? birth;
  String? email;
  String? phone;
  String? photo;

  Member({
    this.id,
    required this.name,
    required this.firstName,
    required this.lastName,
    required this.color,
    this.birth,
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
    color: data['color'],
    birth: data['birth'],
    email: data['email'],
    phone: data['phone'],
    photo: data['photo'],
  );

  @override
  Map<String, dynamic> get() => {
    'name': name,
    'firstName': firstName,
    'lastName': lastName,
    'color': color,
    'birth': birth,
    'email': email,
    'phone': phone,
    'photo': photo,
  };

  @override
  Member set(Map<String, dynamic> data) {
    name = data['name'];
    firstName = data['firstName'];
    lastName = data['lastName'];
    color = data['color'];
    birth = data['birth'];
    email = data['email'];
    phone = data['phone'];
    return this;
  }

  final List<Product> products = [];
  Product product(String productId) =>
      products.firstWhere((p) => p.id == productId);

  int get age {
    if (birth == null) return -1;
    final today = Date.now();
    final age = today.year - birth!.year;
    return (today.month < birth!.month
        || (today.month == birth!.month && today.day < birth!.day))
        ? age - 1
        : age;
  }
  bool get training =>  products.any((product) => product.isOngoing() && !product.isWarning());
  bool get expiring =>  products.any((product) => product.isWarning());
  bool get finished => !products.any((product) => product.isOngoing());
}