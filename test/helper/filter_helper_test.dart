import 'package:flutter_test/flutter_test.dart';
import 'package:pluto_grid/pluto_grid.dart';

void main() {
  Function makeCompareFunction;

  setUp(() {
    makeCompareFunction = (PlutoFilterType filterType) {
      return (dynamic a, dynamic b) {
        return FilterHelper.compareByFilterType(filterType, a, b);
      };
    };
  });

  group('startsWith', () {
    Function compare;

    setUp(() {
      compare = makeCompareFunction(PlutoFilterType.startsWith);
    });

    test('apple startsWith ap', () {
      expect(compare('apple', 'ap'), isTrue);
    });

    test('apple is not startsWith banana', () {
      expect(compare('apple', 'banana'), isFalse);
    });
  });

  group('endsWith', () {
    Function compare;

    setUp(() {
      compare = makeCompareFunction(PlutoFilterType.endsWith);
    });

    test('apple endsWith le', () {
      expect(compare('apple', 'le'), isTrue);
    });

    test('apple is not endsWith app', () {
      expect(compare('apple', 'app'), isFalse);
    });
  });

  group('contains', () {
    Function compare;

    setUp(() {
      compare = makeCompareFunction(PlutoFilterType.contains);
    });

    test('apple contains le', () {
      expect(compare('apple', 'le'), isTrue);
    });

    test('apple is not contains banana', () {
      expect(compare('apple', 'banana'), isFalse);
    });
  });

  group('equals', () {
    Function compare;

    setUp(() {
      compare = makeCompareFunction(PlutoFilterType.contains);
    });

    test('apple equals apple', () {
      expect(compare('apple', 'apple'), isTrue);
    });

    test('apple is not equals banana', () {
      expect(compare('apple', 'banana'), isFalse);
    });
  });
}
