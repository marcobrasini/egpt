// import 'package:egpt/models/fixture.dart';
//
//
// class Session extends Fixture {
//
//   final String? id;
//   final String productId;
//
//   Session({
//     this.id,
//     required this.productId,
//     required super.date,
//     required super.from,
//     required super.to,
//   });
//
//   factory Session.make({
//     String? id,
//     required Map<String, dynamic> data,
//   }) => Session(
//     id: id,
//     productId: data['productId'],
//     date: data['date'],
//     from: data['from'],
//     to: data['to'],
//   );
//
//   Map<String, dynamic> get() => {
//     'productId': productId,
//     'date': date,
//     'from': from,
//     'to': to,
//   };
//
//   void set(Map<String, dynamic> data) => {
//     date = data['date'],
//     from = data['from'],
//     to = data['to'],
//   };
//
//   // bool get todo => presence == null ? true : false;
//   // bool get done => presence == null ? false : presence!;
//   // bool get redo => presence == null ? false : !presence!;
// }
//
