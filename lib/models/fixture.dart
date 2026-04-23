import 'package:egpt/utils/datetime.dart';


class Fixture {

  Date date;
  Time from;
  Time to;

  Fixture({
    required this.date,
    required this.from,
    required this.to,
  });

  factory Fixture.make({
    required Map<String, dynamic> data,
  }) => Fixture(
    date: data['date'],
    from: data['from'],
    to: data['to'],
  );

  Map<String, dynamic> get() => {
    'date': date,
    'from': from,
    'to': to,
  };

  Fixture set(Map<String, dynamic> data) {
    date = data['date'];
    from = data['from'];
    to = data['to'];
    return this;
  }

  DateTime get start => date.toDateTime(from);
  DateTime get stop => date.toDateTime(to);

  int get duration => from % to.toDateTime();

}