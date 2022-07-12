import 'package:flutter_test/flutter_test.dart';
import 'package:pluto_grid/pluto_grid.dart';

class _ResizeItem {
  _ResizeItem({
    required this.index,
    required this.size,
    required this.minSize,
  });

  final int index;

  double size;

  final double minSize;
}

void main() {
  group('PlutoAutoSizeHelper', () {
    group('PlutoAutoSizeMode.none.', () {
      const mode = PlutoAutoSizeMode.none;

      test('mode 를 none 으로 호출하면 예외가 발생 되어야 한다.', () {
        expect(() {
          PlutoAutoSizeHelper.items(
            maxSize: 100,
            length: 1,
            itemMinSize: 80,
            mode: mode,
          );
        }, throwsException);
      });
    });

    group('PlutoAutoSizeMode.equal.', () {
      const mode = PlutoAutoSizeMode.equal;

      test('getItemSize 가 length 보다 많이 호출 되면 assertion 이 발생 되어야 한다.', () {
        final helper = PlutoAutoSizeHelper.items(
          maxSize: 100,
          length: 1,
          itemMinSize: 80,
          mode: mode,
        );

        expect(() {
          helper.getItemSize(100);
          helper.getItemSize(100);
        }, throwsAssertionError);
      });

      test('maxSize 범위에서 5번의 getItemSize 호출이 100 을 리턴해야 한다.', () {
        final helper = PlutoAutoSizeHelper.items(
          maxSize: 500,
          length: 5,
          itemMinSize: 80,
          mode: mode,
        );

        expect(helper.getItemSize(100), 100);
        expect(helper.getItemSize(100), 100);
        expect(helper.getItemSize(100), 100);
        expect(helper.getItemSize(100), 100);
        expect(helper.getItemSize(100), 100);
      });

      test('maxSize 가 length * itemMinSize 보다 작은 경우 itemMinSize.', () {
        final helper = PlutoAutoSizeHelper.items(
          maxSize: 380,
          length: 5,
          itemMinSize: 80,
          mode: mode,
        );

        expect(helper.getItemSize(100), 80);
        expect(helper.getItemSize(100), 80);
        expect(helper.getItemSize(100), 80);
        expect(helper.getItemSize(100), 80);
        expect(helper.getItemSize(100), 80);
      });

      test('maxSize 가 length * itemMinSize 보다 큰 경우 마지막 아이템은 남은 넓이.', () {
        final helper = PlutoAutoSizeHelper.items(
          maxSize: 502,
          length: 3,
          itemMinSize: 80,
          mode: mode,
        );

        double size = 502 / 3;
        double lastSize = 502 - (size + size);
        expect(helper.getItemSize(100), size);
        expect(helper.getItemSize(100), size);
        expect(helper.getItemSize(100), lastSize);
      });
    });

    group('PlutoAutoSizeMode.scale.', () {
      const mode = PlutoAutoSizeMode.scale;

      test('scale 이 null 이면 assertion 이 발생 되어야 한다.', () {
        expect(() {
          PlutoAutoSizeHelper.items(
            maxSize: 100,
            length: 1,
            itemMinSize: 80,
            mode: mode,
            scale: null,
          );
        }, throwsAssertionError);
      });

      test('getItemSize 가 length 보다 많이 호출 되면 assertion 이 발생 되어야 한다.', () {
        const mode = PlutoAutoSizeMode.scale;

        final helper = PlutoAutoSizeHelper.items(
          maxSize: 100,
          length: 1,
          itemMinSize: 80,
          mode: mode,
          scale: 1,
        );

        expect(() {
          helper.getItemSize(100);
          helper.getItemSize(100);
        }, throwsAssertionError);
      });

      test('maxSize 가 length * itemMinSize 보다 작으면 itemMinSize.', () {
        final helper = PlutoAutoSizeHelper.items(
          maxSize: 500,
          length: 5,
          itemMinSize: 120,
          mode: mode,
          scale: 1,
        );

        expect(helper.getItemSize(150), 120);
        expect(helper.getItemSize(150), 120);
        expect(helper.getItemSize(150), 120);
        expect(helper.getItemSize(150), 120);
        expect(helper.getItemSize(150), 120);
      });

      test('scale 2.', () {
        const maxSize = 1000.0;
        final originalSize = <double>[100, 150, 50, 80, 120];
        // scale 2 : maxSize 1000 / originalSize 500
        final scale =
            maxSize / originalSize.fold<double>(0, (pre, e) => pre + e);

        final helper = PlutoAutoSizeHelper.items(
          maxSize: maxSize,
          length: originalSize.length,
          itemMinSize: 50,
          mode: mode,
          scale: scale,
        );

        expect(helper.getItemSize(originalSize[0]), originalSize[0] * 2);
        expect(helper.getItemSize(originalSize[1]), originalSize[1] * 2);
        expect(helper.getItemSize(originalSize[2]), originalSize[2] * 2);
        expect(helper.getItemSize(originalSize[3]), originalSize[3] * 2);
        expect(helper.getItemSize(originalSize[4]), originalSize[4] * 2);
      });

      test('scale 0.5.', () {
        const maxSize = 250.0;
        final originalSize = <double>[100, 150, 50, 80, 120];
        // scale 2 : maxSize 250 / originalSize 500
        final scale =
            maxSize / originalSize.fold<double>(0, (pre, e) => pre + e);

        final helper = PlutoAutoSizeHelper.items(
          maxSize: maxSize,
          length: originalSize.length,
          itemMinSize: 25,
          mode: mode,
          scale: scale,
        );

        expect(helper.getItemSize(originalSize[0]), originalSize[0] / 2);
        expect(helper.getItemSize(originalSize[1]), originalSize[1] / 2);
        expect(helper.getItemSize(originalSize[2]), originalSize[2] / 2);
        expect(helper.getItemSize(originalSize[3]), originalSize[3] / 2);
        expect(helper.getItemSize(originalSize[4]), originalSize[4] / 2);
      });
    });
  });

  group('PlutoResizeHelper', () {
    group('PlutoResizeMode.none', () {
      const mode = PlutoResizeMode.none;

      test('mode 가 none 이면 exception 이 발생 되어야 한다.', () {
        final items = <_ResizeItem>[];
        expect(() {
          PlutoResizeHelper.items<_ResizeItem>(
            offset: 0,
            items: items,
            isMainItem: (i) => i.index == 0,
            getItemSize: (i) => i.size,
            getItemMinSize: (i) => i.minSize,
            setItemSize: (i, size) => i.size = size,
            mode: mode,
          );
        }, throwsException);
      });
    });

    group('PlutoResizeMode.normal', () {
      const mode = PlutoResizeMode.normal;

      test('mode 가 normal 이면 exception 이 발생 되어야 한다.', () {
        final items = <_ResizeItem>[];
        expect(() {
          PlutoResizeHelper.items<_ResizeItem>(
            offset: 0,
            items: items,
            isMainItem: (i) => i.index == 0,
            getItemSize: (i) => i.size,
            getItemMinSize: (i) => i.minSize,
            setItemSize: (i, size) => i.size = size,
            mode: mode,
          );
        }, throwsException);
      });
    });

    group('PlutoResizeMode.pushAndPull', () {
      const mode = PlutoResizeMode.pushAndPull;

      test('0번의 사이즈가 10 증가 하고 1번의 사이즈가 10 감소해야 한다.', () {
        final items = <_ResizeItem>[
          _ResizeItem(index: 0, size: 200, minSize: 80),
          _ResizeItem(index: 1, size: 200, minSize: 80),
          _ResizeItem(index: 2, size: 200, minSize: 80),
          _ResizeItem(index: 3, size: 200, minSize: 80),
          _ResizeItem(index: 4, size: 200, minSize: 80),
        ];

        final helper = PlutoResizeHelper.items<_ResizeItem>(
          offset: 10,
          items: items,
          isMainItem: (i) => i.index == 0,
          getItemSize: (i) => i.size,
          getItemMinSize: (i) => i.minSize,
          setItemSize: (i, size) => i.size = size,
          mode: mode,
        );

        expect(helper.update(), true);
        expect(items[0].size, 210);
        expect(items[1].size, 190);
        expect(items[2].size, 200);
        expect(items[3].size, 200);
        expect(items[4].size, 200);
      });

      test('1번의 사이즈가 10 증가 하고 2번의 사이즈가 10 감소해야 한다.', () {
        final items = <_ResizeItem>[
          _ResizeItem(index: 0, size: 200, minSize: 80),
          _ResizeItem(index: 1, size: 200, minSize: 80),
          _ResizeItem(index: 2, size: 200, minSize: 80),
          _ResizeItem(index: 3, size: 200, minSize: 80),
          _ResizeItem(index: 4, size: 200, minSize: 80),
        ];

        final helper = PlutoResizeHelper.items<_ResizeItem>(
          offset: 10,
          items: items,
          isMainItem: (i) => i.index == 1,
          getItemSize: (i) => i.size,
          getItemMinSize: (i) => i.minSize,
          setItemSize: (i, size) => i.size = size,
          mode: mode,
        );

        expect(helper.update(), true);
        expect(items[0].size, 200);
        expect(items[1].size, 210);
        expect(items[2].size, 190);
        expect(items[3].size, 200);
        expect(items[4].size, 200);
      });

      test('3번의 사이즈가 10 증가 하고 4번의 사이즈가 10 감소해야 한다.', () {
        final items = <_ResizeItem>[
          _ResizeItem(index: 0, size: 200, minSize: 80),
          _ResizeItem(index: 1, size: 200, minSize: 80),
          _ResizeItem(index: 2, size: 200, minSize: 80),
          _ResizeItem(index: 3, size: 200, minSize: 80),
          _ResizeItem(index: 4, size: 200, minSize: 80),
        ];

        final helper = PlutoResizeHelper.items<_ResizeItem>(
          offset: 10,
          items: items,
          isMainItem: (i) => i.index == 3,
          getItemSize: (i) => i.size,
          getItemMinSize: (i) => i.minSize,
          setItemSize: (i, size) => i.size = size,
          mode: mode,
        );

        expect(helper.update(), true);
        expect(items[0].size, 200);
        expect(items[1].size, 200);
        expect(items[2].size, 200);
        expect(items[3].size, 210);
        expect(items[4].size, 190);
      });

      test('4번의 사이즈가 10 증가 하고 3번의 사이즈가 10 감소해야 한다.', () {
        final items = <_ResizeItem>[
          _ResizeItem(index: 0, size: 200, minSize: 80),
          _ResizeItem(index: 1, size: 200, minSize: 80),
          _ResizeItem(index: 2, size: 200, minSize: 80),
          _ResizeItem(index: 3, size: 200, minSize: 80),
          _ResizeItem(index: 4, size: 200, minSize: 80),
        ];

        final helper = PlutoResizeHelper.items<_ResizeItem>(
          offset: 10,
          items: items,
          isMainItem: (i) => i.index == 4,
          getItemSize: (i) => i.size,
          getItemMinSize: (i) => i.minSize,
          setItemSize: (i, size) => i.size = size,
          mode: mode,
        );

        expect(helper.update(), true);
        expect(items[0].size, 200);
        expect(items[1].size, 200);
        expect(items[2].size, 200);
        expect(items[3].size, 190);
        expect(items[4].size, 210);
      });

      test('4번의 사이즈가 10 감소 하고 3번의 사이즈가 10 증가해야 한다.', () {
        final items = <_ResizeItem>[
          _ResizeItem(index: 0, size: 200, minSize: 80),
          _ResizeItem(index: 1, size: 200, minSize: 80),
          _ResizeItem(index: 2, size: 200, minSize: 80),
          _ResizeItem(index: 3, size: 200, minSize: 80),
          _ResizeItem(index: 4, size: 200, minSize: 80),
        ];

        final helper = PlutoResizeHelper.items<_ResizeItem>(
          offset: -10,
          items: items,
          isMainItem: (i) => i.index == 4,
          getItemSize: (i) => i.size,
          getItemMinSize: (i) => i.minSize,
          setItemSize: (i, size) => i.size = size,
          mode: mode,
        );

        expect(helper.update(), true);
        expect(items[0].size, 200);
        expect(items[1].size, 200);
        expect(items[2].size, 200);
        expect(items[3].size, 210);
        expect(items[4].size, 190);
      });

      test('1번의 사이즈가 10 감소 하고 2번의 사이즈가 10 증가해야 한다.', () {
        final items = <_ResizeItem>[
          _ResizeItem(index: 0, size: 200, minSize: 80),
          _ResizeItem(index: 1, size: 200, minSize: 80),
          _ResizeItem(index: 2, size: 200, minSize: 80),
          _ResizeItem(index: 3, size: 200, minSize: 80),
          _ResizeItem(index: 4, size: 200, minSize: 80),
        ];

        final helper = PlutoResizeHelper.items<_ResizeItem>(
          offset: -10,
          items: items,
          isMainItem: (i) => i.index == 1,
          getItemSize: (i) => i.size,
          getItemMinSize: (i) => i.minSize,
          setItemSize: (i, size) => i.size = size,
          mode: mode,
        );

        expect(helper.update(), true);
        expect(items[0].size, 200);
        expect(items[1].size, 190);
        expect(items[2].size, 210);
        expect(items[3].size, 200);
        expect(items[4].size, 200);
      });

      test('1번의 사이즈를 최소 크기로 줄였을 때, 0번의 크기가 줄고, 2번의 크기가 늘어나야 한다.', () {
        final items = <_ResizeItem>[
          _ResizeItem(index: 0, size: 200, minSize: 80),
          _ResizeItem(index: 1, size: 80, minSize: 80),
          _ResizeItem(index: 2, size: 200, minSize: 80),
          _ResizeItem(index: 3, size: 200, minSize: 80),
          _ResizeItem(index: 4, size: 200, minSize: 80),
        ];

        final helper = PlutoResizeHelper.items<_ResizeItem>(
          offset: -10,
          items: items,
          isMainItem: (i) => i.index == 1,
          getItemSize: (i) => i.size,
          getItemMinSize: (i) => i.minSize,
          setItemSize: (i, size) => i.size = size,
          mode: mode,
        );

        expect(helper.update(), true);
        expect(items[0].size, 190);
        expect(items[1].size, 80);
        expect(items[2].size, 210);
        expect(items[3].size, 200);
        expect(items[4].size, 200);
      });

      test('1번의 사이즈를 최소 크기로 줄였을 때, 좌측에 더이상 큰 사이즈가 없는 경우 사이즈 변동이 없어야 한다.', () {
        final items = <_ResizeItem>[
          _ResizeItem(index: 0, size: 80, minSize: 80),
          _ResizeItem(index: 1, size: 80, minSize: 80),
          _ResizeItem(index: 2, size: 200, minSize: 80),
          _ResizeItem(index: 3, size: 200, minSize: 80),
          _ResizeItem(index: 4, size: 200, minSize: 80),
        ];

        final helper = PlutoResizeHelper.items<_ResizeItem>(
          offset: -10,
          items: items,
          isMainItem: (i) => i.index == 1,
          getItemSize: (i) => i.size,
          getItemMinSize: (i) => i.minSize,
          setItemSize: (i, size) => i.size = size,
          mode: mode,
        );

        expect(helper.update(), false);
        expect(items[0].size, 80);
        expect(items[1].size, 80);
        expect(items[2].size, 200);
        expect(items[3].size, 200);
        expect(items[4].size, 200);
      });

      test('2번의 크기를 최대로 넓히면 좌우측 넓이가 최소로 줄어야 한다.', () {
        final items = <_ResizeItem>[
          _ResizeItem(index: 0, size: 200, minSize: 80),
          _ResizeItem(index: 1, size: 200, minSize: 80),
          _ResizeItem(index: 2, size: 200, minSize: 80),
          _ResizeItem(index: 3, size: 200, minSize: 80),
          _ResizeItem(index: 4, size: 200, minSize: 80),
        ];

        final helper = PlutoResizeHelper.items<_ResizeItem>(
          offset: 1000 - 320 - 200,
          items: items,
          isMainItem: (i) => i.index == 2,
          getItemSize: (i) => i.size,
          getItemMinSize: (i) => i.minSize,
          setItemSize: (i, size) => i.size = size,
          mode: mode,
        );

        expect(helper.update(), true);
        expect(items[0].size, 80);
        expect(items[1].size, 80);
        expect(items[2].size, 680);
        expect(items[3].size, 80);
        expect(items[4].size, 80);
      });

      test(
          '2번의 크기를 200 에서 최소크기보다 작게 40 으로 줄이면, '
          '2번의 크기가 80, 3번의 크기가 360, 1번의 크기가 160 으로 변경 되어야 한다.', () {
        final items = <_ResizeItem>[
          _ResizeItem(index: 0, size: 200, minSize: 80),
          _ResizeItem(index: 1, size: 200, minSize: 80),
          _ResizeItem(index: 2, size: 200, minSize: 80),
          _ResizeItem(index: 3, size: 200, minSize: 80),
          _ResizeItem(index: 4, size: 200, minSize: 80),
        ];

        final helper = PlutoResizeHelper.items<_ResizeItem>(
          offset: -160,
          items: items,
          isMainItem: (i) => i.index == 2,
          getItemSize: (i) => i.size,
          getItemMinSize: (i) => i.minSize,
          setItemSize: (i, size) => i.size = size,
          mode: mode,
        );

        expect(helper.update(), true);
        expect(items[0].size, 200);
        expect(items[1].size, 160);
        expect(items[2].size, 80);
        expect(items[3].size, 360);
        expect(items[4].size, 200);
      });

      test(
          '0번의 크기를 200 에서 최소크기보다 작게 40 으로 줄이면, '
          '0번의 크기가 80, 1번의 크기가 320 이어야 한다.', () {
        final items = <_ResizeItem>[
          _ResizeItem(index: 0, size: 200, minSize: 80),
          _ResizeItem(index: 1, size: 200, minSize: 80),
          _ResizeItem(index: 2, size: 200, minSize: 80),
          _ResizeItem(index: 3, size: 200, minSize: 80),
          _ResizeItem(index: 4, size: 200, minSize: 80),
        ];

        final helper = PlutoResizeHelper.items<_ResizeItem>(
          offset: -160,
          items: items,
          isMainItem: (i) => i.index == 0,
          getItemSize: (i) => i.size,
          getItemMinSize: (i) => i.minSize,
          setItemSize: (i, size) => i.size = size,
          mode: mode,
        );

        expect(helper.update(), true);
        expect(items[0].size, 80);
        expect(items[1].size, 320);
        expect(items[2].size, 200);
        expect(items[3].size, 200);
        expect(items[4].size, 200);
      });

      test(
          '4번의 크기를 200 에서 최소크기보다 작게 40 으로 줄이면, '
          '4번의 크기가 80, 3번의 크기가 320 이어야 한다.', () {
        final items = <_ResizeItem>[
          _ResizeItem(index: 0, size: 200, minSize: 80),
          _ResizeItem(index: 1, size: 200, minSize: 80),
          _ResizeItem(index: 2, size: 200, minSize: 80),
          _ResizeItem(index: 3, size: 200, minSize: 80),
          _ResizeItem(index: 4, size: 200, minSize: 80),
        ];

        final helper = PlutoResizeHelper.items<_ResizeItem>(
          offset: -160,
          items: items,
          isMainItem: (i) => i.index == 4,
          getItemSize: (i) => i.size,
          getItemMinSize: (i) => i.minSize,
          setItemSize: (i, size) => i.size = size,
          mode: mode,
        );

        expect(helper.update(), true);
        expect(items[0].size, 200);
        expect(items[1].size, 200);
        expect(items[2].size, 200);
        expect(items[3].size, 320);
        expect(items[4].size, 80);
      });

      test('0번의 크기를 최대로 넓히면 나머지 크기가 최소로 줄어야 한다.', () {
        final items = <_ResizeItem>[
          _ResizeItem(index: 0, size: 200, minSize: 80),
          _ResizeItem(index: 1, size: 200, minSize: 80),
          _ResizeItem(index: 2, size: 200, minSize: 80),
          _ResizeItem(index: 3, size: 200, minSize: 80),
          _ResizeItem(index: 4, size: 200, minSize: 80),
        ];

        final helper = PlutoResizeHelper.items<_ResizeItem>(
          offset: 1000,
          items: items,
          isMainItem: (i) => i.index == 0,
          getItemSize: (i) => i.size,
          getItemMinSize: (i) => i.minSize,
          setItemSize: (i, size) => i.size = size,
          mode: mode,
        );

        expect(helper.update(), true);
        expect(items[0].size, 680);
        expect(items[1].size, 80);
        expect(items[2].size, 80);
        expect(items[3].size, 80);
        expect(items[4].size, 80);
      });

      test('2번의 크기를 최대로 넓히면 나머지 크기가 최소로 줄어야 한다.', () {
        final items = <_ResizeItem>[
          _ResizeItem(index: 0, size: 200, minSize: 80),
          _ResizeItem(index: 1, size: 200, minSize: 80),
          _ResizeItem(index: 2, size: 200, minSize: 80),
          _ResizeItem(index: 3, size: 200, minSize: 80),
          _ResizeItem(index: 4, size: 200, minSize: 80),
        ];

        final helper = PlutoResizeHelper.items<_ResizeItem>(
          offset: 1000,
          items: items,
          isMainItem: (i) => i.index == 2,
          getItemSize: (i) => i.size,
          getItemMinSize: (i) => i.minSize,
          setItemSize: (i, size) => i.size = size,
          mode: mode,
        );

        expect(helper.update(), true);
        expect(items[0].size, 80);
        expect(items[1].size, 80);
        expect(items[2].size, 680);
        expect(items[3].size, 80);
        expect(items[4].size, 80);
      });

      test('4번의 크기를 최대로 넓히면 나머지 크기가 최소로 줄어야 한다.', () {
        final items = <_ResizeItem>[
          _ResizeItem(index: 0, size: 200, minSize: 80),
          _ResizeItem(index: 1, size: 200, minSize: 80),
          _ResizeItem(index: 2, size: 200, minSize: 80),
          _ResizeItem(index: 3, size: 200, minSize: 80),
          _ResizeItem(index: 4, size: 200, minSize: 80),
        ];

        final helper = PlutoResizeHelper.items<_ResizeItem>(
          offset: 1000,
          items: items,
          isMainItem: (i) => i.index == 4,
          getItemSize: (i) => i.size,
          getItemMinSize: (i) => i.minSize,
          setItemSize: (i, size) => i.size = size,
          mode: mode,
        );

        expect(helper.update(), true);
        expect(items[0].size, 80);
        expect(items[1].size, 80);
        expect(items[2].size, 80);
        expect(items[3].size, 80);
        expect(items[4].size, 680);
      });
    });
  });
}
