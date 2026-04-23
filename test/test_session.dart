// import 'package:egpt/utils/datetime.dart';
// import 'package:egpt/models/session.dart';
// import 'package:test/test.dart';
//
//
// void main() {
//
//   const id = "session1";
//   const productId = "product1";
//   final date = Date.now();
//   final from = Time(10,30);
//   final to = Time(11,30);
//   const presence = true;
//   final data = {
//     'productId': productId,
//     'date': date,
//     'from': from,
//     'to': to,
//     'presence': presence,
//   };
//
//   group('Session data', () {
//
//     test('Session constructor default', () {
//       final session = Session(
//         productId: productId,
//         date: date,
//         from: from,
//         to: to,
//       );
//       expect(session.id, null);
//       expect(session.productId, productId);
//       expect(session.date, date);
//       expect(session.from, from);
//       expect(session.to, to);
//       expect(session.presence, null);
//     });
//
//     test('Session constructor', () {
//       final session = Session(
//         id: id,
//         productId: productId,
//         date: date,
//         from: from,
//         to: to,
//         presence: presence,
//       );
//       expect(session.id, id);
//       expect(session.productId, productId);
//       expect(session.presence, presence);
//       expect(session.date, date);
//       expect(session.from, from);
//       expect(session.to, to);
//     });
//
//     test('Session make', () {
//       final session = Session.make(id: id, data: data);
//       expect(session.id, id);
//       expect(session.productId, productId);
//       expect(session.presence, presence);
//       expect(session.date, date);
//       expect(session.from, from);
//       expect(session.to, to);
//     });
//
//     test('Session get', () {
//       final session = Session(
//         id: id,
//         productId: productId,
//         date: date,
//         from: from,
//         to: to,
//         presence: presence,
//       );
//       expect(session.get(), data);
//     });
//
//     test('Session set', () {
//       final session = Session(
//         id: id,
//         productId: productId,
//         date: date + 1,
//         from: Time.now(),
//         to: Time.now(),
//         presence: !presence,
//       );
//       session.set(data);
//       expect(session.id, id);
//       expect(session.productId, productId);
//       expect(session.presence, presence);
//       expect(session.date, date);
//       expect(session.from, from);
//       expect(session.to, to);
//     });
//
//   });
//
//   group("Session presence", () {
//
//     final session = Session(
//       productId: productId,
//       date: date,
//       from: from,
//       to: to,
//       presence: presence,
//     );
//
//     test('Session todo', () {
//       session.presence = null;
//       expect(session.todo, true);
//       session.presence = true;
//       expect(session.todo, false);
//       session.presence = false;
//       expect(session.todo, false);
//     });
//
//     test('Session redo', () {
//       session.presence = null;
//       expect(session.redo, false);
//       session.presence = true;
//       expect(session.redo, false);
//       session.presence = false;
//       expect(session.redo, true);
//     });
//
//     test('Session done', () {
//       session.presence = null;
//       expect(session.done, false);
//       session.presence = true;
//       expect(session.done, true);
//       session.presence = false;
//       expect(session.done, false);
//     });
//
//   });
//
// }
