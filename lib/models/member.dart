import 'dart:ui';
import 'package:calendar/calendar.dart';
import 'package:egpt/models/product.dart';


class Member {

  final String? id;
  String name;
  String firstName;
  String lastName;
  Date birth;
  Color color;
  String? email;
  String? phone;
  //String? photo;

  Member({
    this.id,
    required this.name,
    required this.firstName,
    required this.lastName,
    required this.birth,
    required this.color,
    this.email,
    this.phone,
    //this.photo,
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
    //photo: data['photo'],
  );

  Map<String, dynamic> get() => {
    'name': name,
    'firstName': firstName,
    'lastName': lastName,
    'birth': birth,
    'color': color,
    'email': email,
    'phone': phone,
    //'photo': photo,
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
  Product product(String productId) => products.firstWhere(
          (p) => p.id == productId
  );

}