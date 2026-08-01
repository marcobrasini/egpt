// import 'dart:ui';
// import 'package:test/test.dart';
// import 'package:calendar/calendar.dart';
// import 'package:egpt/models/member.dart';
// import 'package:egpt/admin/source_admin.dart';
//
//
// void main() {
//
//   final id = "member1";
//   final name = "name1";
//   final firstName = "firstName1";
//   final lastName = "lastName1";
//   final birth = Date(2000,1,1);
//   final color = Color(0xFFFFFFFF);
//   final email = "member@email.com";
//   final phone = "0123456789";
//   final data = {
//     'name': name,
//     'firstName': firstName,
//     'lastName': lastName,
//     'birth': birth,
//     'color': color,
//     'email': email,
//     'phone': phone,
//   };
//
//   final member = Member(
//       name: name,
//       firstName: firstName,
//       lastName: lastName,
//       birth: birth,
//       color: color
//   );
//
//   group('Member', () {
//
//     test('create Member', () {
//       final admin = AdminSource();
//       final register = admin.register;
//       expect(register.members.length, 0);
//       admin.createMember(member);
//       expect(register.members.length, 1);
//       assert (register.members[0].id != null);
//       expect(register.members[0].get(), member.get());
//     });
//
//   });
//
// }
