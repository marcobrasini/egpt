import 'dart:ui';
import 'package:test/test.dart';
import 'package:calendar/calendar.dart';
import 'package:egpt/models/member.dart';


void main() {

  final id = "member1";
  final name = "name1";
  final firstName = "firstName1";
  final lastName = "lastName1";
  final birth = Date(2000,1,1);
  final color = Color(0xFFFFFFFF);
  final email = "member@email.com";
  final phone = "0123456789";
  final data = {
    'name': name,
    'firstName': firstName,
    'lastName': lastName,
    'birth': birth,
    'color': color,
    'email': email,
    'phone': phone,
  };

  group('Member', () {

    test('Member constructor default', () {
      final member = Member(
        name: name,
        firstName: firstName,
        lastName: lastName,
        birth: birth,
        color: color,
      );
      expect(member.id, null);
      expect(member.name, name);
      expect(member.firstName, firstName);
      expect(member.lastName, lastName);
      expect(member.birth, birth);
      expect(member.color, color);
      expect(member.email, null);
      expect(member.phone, null);
    });

    test('Member constructor', () {
      final member = Member(
        id: id,
        name: name,
        firstName: firstName,
        lastName: lastName,
        birth: birth,
        color: color,
        email: email,
        phone: phone,
      );
      expect(member.id, id);
      expect(member.name, name);
      expect(member.firstName, firstName);
      expect(member.lastName, lastName);
      expect(member.birth, birth);
      expect(member.color, color);
      expect(member.email, email);
      expect(member.phone, phone);
    });

    test('Member make', () {
      final member = Member.make(id: id, data: data);
      expect(member.id, id);
      expect(member.name, name);
      expect(member.firstName, firstName);
      expect(member.lastName, lastName);
      expect(member.birth, birth);
      expect(member.color, color);
      expect(member.email, email);
      expect(member.phone, phone);
    });

    test('Member get', () {
      final member = Member(
        id: id,
        name: name,
        firstName: firstName,
        lastName: lastName,
        birth: birth,
        color: color,
        email: email,
        phone: phone,
      );
      expect(member.get(), data);
    });

    test('Member set', () {
      final member = Member(
        id: id,
        name: "",
        firstName: "",
        lastName: "",
        birth: Date.now(),
        color: Color(0x00000000),
        email: email,
        phone: phone,
      );
      member.set(data);
      expect(member.id, id);
      expect(member.name, name);
      expect(member.firstName, firstName);
      expect(member.lastName, lastName);
      expect(member.birth, birth);
      expect(member.color, color);
      expect(member.email, email);
      expect(member.phone, phone);
    });

  });

}
