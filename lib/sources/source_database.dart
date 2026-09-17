import 'package:egpt/typedef.dart';


class DatabaseData<T extends EGPTItem> {
  final create = <T>[];
  final update = <T>[];
  final delete = <T>[];

  bool get isEmpty => create.isEmpty && update.isEmpty && delete.isEmpty;
  @override
  String toString() => {
    "create": create.map((t) => t.toString()).toList(),
    "update": update.map((t) => t.toString()).toList(),
    "delete": delete.map((t) => t.toString()).toList(),
  }.toString();
}


class DatabaseSource<T extends EGPTItem> {

  final EGPTData<T> source;
  final EGPTMake<T> fromDatabase;

  DatabaseSource(this.source, this.fromDatabase);

  bool _initial = true;

  DatabaseData<T>? call(Iterable<Map<String, Object?>> rows) {
    final data = DatabaseData<T>();
    final cache = Map.of(source.get());

    for (final row in rows) {
      final object = fromDatabase(DataMap.from(row));
      final item = cache.remove(object.id!);
      if (item == null) {
        data.create.add(object);
      } else if (item != object) {
        data.update.add(object);
      }
    }
    data.delete.addAll(cache.values);

    if (!_initial && data.isEmpty) return null;
    _initial = false;
    source
      ..del(data.delete)
      ..add(data.create)
      ..put(data.update);
    return data;
  }
}
