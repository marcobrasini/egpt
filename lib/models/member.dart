import 'dart:ui';
import 'package:equatable/equatable.dart';
import 'package:calendar/calendar.dart';
import 'package:egpt/sources/sources.dart';
import 'package:egpt/models/models.dart';
import 'package:egpt/types.dart';


class Member extends Equatable implements EGPTItem {
  static final register = RegisterSource();
  static final schedule = ScheduleSource();

  @override final String? id;
  final String name;
  final String firstName;
  final String lastName;
  final Color color;
  final Date? birth;
  final String? email;
  final String? phone;
  final String? photo;

  const Member({
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
    required DataMap data,
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
  DataMap get() => {
    'name': name,
    'firstName': firstName,
    'lastName': lastName,
    'color': color,
    'birth': ?birth,
    'email': ?email,
    'phone': ?phone,
    'photo': ?photo,
  };

  @override
  Member set(DataMap data) => Member(
    id: id,
    name: data['name'] ?? name,
    firstName: data['firstName'] ?? firstName,
    lastName: data['lastName'] ?? lastName,
    color: data['color'] ?? color,
    birth: data['birth'] ?? birth,
    email: data['email'] ?? email,
    phone: data['phone'] ?? phone,
    photo: data['photo'] ?? photo,
  );

  List<Product> get products => register.products(id!);
  Product product(String productId) => register.product(productId, id!);

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

  @override
  List<Object?> get props =>
      [id, name, firstName, lastName, color, birth, email, phone, photo];

}