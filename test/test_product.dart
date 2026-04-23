import 'package:egpt/utils/datetime.dart';
import 'package:egpt/models/product.dart';
import 'package:egpt/models/session.dart';
import 'package:test/test.dart';


List<bool?> test_presences(done, redo, todo) {
  List<bool?> presences = [
    ...List<bool?>.filled(done, true),
    ...List<bool?>.filled(redo, false)
  ]; presences.shuffle();
  return [...presences, ...List<bool?>.filled(todo, null)];
}


void main() {

  const id = "product1";
  const memberId = "member1";
  const summary = "summary";
  const duration = 10;
  const length = 8;
  final start = Date.now();
  final stop = Date.now() + duration;
  final data = {
    'memberId': memberId,
    'length': length,
    'start': start,
    'stop': stop,
    'summary': summary,
  };


  group('Product data', () {

    test('Product constructor default', () {
      final product = Product(
        memberId: memberId,
        summary: summary,
        length: length,
        start: start,
        stop: stop,
      );
      expect(product.id, null);
      expect(product.memberId, memberId);
      expect(product.summary, summary);
      expect(product.length, length);
      expect(product.start, start);
      expect(product.stop, stop);
      expect(product.todo, 0);
      expect(product.redo, 0);
      expect(product.done, 0);
    });

    test('Product constructor', () {
      final product = Product(
        id: id,
        memberId: memberId,
        summary: summary,
        length: length,
        start: start,
        stop: stop,
      );
      expect(product.id, id);
      expect(product.memberId, memberId);
      expect(product.length, length);
      expect(product.start, start);
      expect(product.stop, stop);
      expect(product.summary, summary);
    });

    test('Product make', () {
      final product = Product.make(id: id, data: data);
      expect(product.id, id);
      expect(product.memberId, memberId);
      expect(product.summary, summary);
      expect(product.length, length);
      expect(product.start, start);
      expect(product.stop, stop);
    });

    test('Product get', () {
      final product = Product(
        id: id,
        memberId: memberId,
        summary: summary,
        length: length,
        start: start,
        stop: stop,
      );
      expect(product.get(), data);
    });

    test('Product set', () {
      final product = Product(
        id: id,
        memberId: memberId,
        summary: "",
        length: length + 1,
        start: start + 1,
        stop: stop + 1,
      );
      product.set(data);
      expect(product.id, id);
      expect(product.memberId, memberId);
      expect(product.summary, summary);
      expect(product.length, length);
      expect(product.start, start);
      expect(product.stop, stop);
    });
  });

}
