import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pluto_grid/pluto_grid.dart';

void main() {
  testWidgets(
    'dark 생성자를 호출 할 수 있어야 한다.',
    (WidgetTester tester) async {
      const PlutoGridConfiguration configuration = PlutoGridConfiguration.dark(
        style: PlutoGridStyleConfig(
          enableColumnBorderVertical: false,
        ),
      );

      expect(configuration.style.enableColumnBorderVertical, false);
    },
  );

  group('PlutoGridStyleConfig.copyWith', () {
    test('oddRowColor 를 null 로 설정하면 값이 변경 되어야 한다.', () {
      const style = PlutoGridStyleConfig(
        oddRowColor: Colors.cyan,
      );

      final copiedStyle = style.copyWith(
        oddRowColor: const PlutoOptional<Color?>(null),
      );

      expect(copiedStyle.oddRowColor, null);
    });

    test('evenRowColor 를 null 로 설정하면 값이 변경 되어야 한다.', () {
      const style = PlutoGridStyleConfig(
        evenRowColor: Colors.cyan,
      );

      final copiedStyle = style.copyWith(
        evenRowColor: const PlutoOptional<Color?>(null),
      );

      expect(copiedStyle.evenRowColor, null);
    });
  });

  group('PlutoGridColumnSizeConfig.copyWith', () {
    test('autoSizeMode 를 scale 설정하면 값이 변경 되어야 한다.', () {
      const size = PlutoGridColumnSizeConfig(
        autoSizeMode: PlutoAutoSizeMode.none,
      );

      final copiedSize = size.copyWith(autoSizeMode: PlutoAutoSizeMode.scale);

      expect(copiedSize.autoSizeMode, PlutoAutoSizeMode.scale);
    });

    test('resizeMode 를 none 으로 설정하면 값이 변경 되어야 한다.', () {
      const size = PlutoGridColumnSizeConfig(
        resizeMode: PlutoResizeMode.normal,
      );

      final copiedSize = size.copyWith(resizeMode: PlutoResizeMode.pushAndPull);

      expect(copiedSize.resizeMode, PlutoResizeMode.pushAndPull);
    });
  });

  test('PlutoGridColumnSizeConfig 의 속성이 동일한 경우 동등 비교가 true 여야 한다.', () {
    const sizeA = PlutoGridColumnSizeConfig(
      autoSizeMode: PlutoAutoSizeMode.scale,
      resizeMode: PlutoResizeMode.none,
      restoreAutoSizeAfterHideColumn: true,
      restoreAutoSizeAfterFrozenColumn: false,
      restoreAutoSizeAfterMoveColumn: true,
      restoreAutoSizeAfterInsertColumn: false,
      restoreAutoSizeAfterRemoveColumn: false,
    );

    const sizeB = PlutoGridColumnSizeConfig(
      autoSizeMode: PlutoAutoSizeMode.scale,
      resizeMode: PlutoResizeMode.none,
      restoreAutoSizeAfterHideColumn: true,
      restoreAutoSizeAfterFrozenColumn: false,
      restoreAutoSizeAfterMoveColumn: true,
      restoreAutoSizeAfterInsertColumn: false,
      restoreAutoSizeAfterRemoveColumn: false,
    );

    expect(sizeA == sizeB, true);
  });

  test('PlutoGridColumnSizeConfig 의 속성이 다른 경우 동등 비교가 false 여야 한다.', () {
    const sizeA = PlutoGridColumnSizeConfig(
      autoSizeMode: PlutoAutoSizeMode.none,
      resizeMode: PlutoResizeMode.none,
      restoreAutoSizeAfterHideColumn: true,
      restoreAutoSizeAfterFrozenColumn: false,
      restoreAutoSizeAfterMoveColumn: true,
      restoreAutoSizeAfterInsertColumn: false,
      restoreAutoSizeAfterRemoveColumn: false,
    );

    const sizeB = PlutoGridColumnSizeConfig(
      autoSizeMode: PlutoAutoSizeMode.scale,
      resizeMode: PlutoResizeMode.none,
      restoreAutoSizeAfterHideColumn: true,
      restoreAutoSizeAfterFrozenColumn: false,
      restoreAutoSizeAfterMoveColumn: true,
      restoreAutoSizeAfterInsertColumn: false,
      restoreAutoSizeAfterRemoveColumn: false,
    );

    expect(sizeA == sizeB, false);
  });
}
