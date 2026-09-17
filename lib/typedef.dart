import 'package:egpt/sources/source_register.dart';
import 'package:equatable/equatable.dart';

typedef DataMap = Map<String, dynamic>;

typedef EGPTMake<T> = T Function(DataMap);


abstract interface class EGPTItem {
  static final register = RegisterSource();

  final String? id;
  EGPTItem({this.id});

  DataMap get();
  EGPTItem set(DataMap data);
}


abstract interface class EGPTData<T extends EGPTItem> {
  Map<String, T> get();
  void set(List<T> data);
  void add(List<T> items);
  void put(List<T> items);
  void del(List<T> items);
}
