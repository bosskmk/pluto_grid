import 'package:flutter_test/flutter_test.dart';
import 'package:pluto_grid/pluto_grid.dart';

void main() {
  group('exists', () {
    test('field 가 columnGroup.fields 리스트에 존재하면 true 를 반환해야 한다.', () {
      final title = 'title';

      final field = 'DUMMY_FIELD';

      final fields = ['DUMMY_FIELD'];

      final columnGroup = PlutoColumnGroup(
        title: title,
        fields: fields,
      );

      expect(
        PlutoColumnGroupHelper.exists(field: field, columnGroup: columnGroup),
        true,
      );
    });

    test('field 가 columnGroup.fields 리스트에 존재하지 않으면 false 를 반환해야 한다.', () {
      final title = 'title';

      final field = 'NON_EXISTS_DUMMY_FIELD';

      final fields = ['DUMMY_FIELD'];

      final columnGroup = PlutoColumnGroup(
        title: title,
        fields: fields,
      );

      expect(
        PlutoColumnGroupHelper.exists(field: field, columnGroup: columnGroup),
        false,
      );
    });

    test('field 가 columnGroup.children 리스트에 존재하면 true 를 반환해야 한다.', () {
      final title = 'title';

      final field = 'DUMMY_FIELD';

      final children = [
        PlutoColumnGroup(title: 'title', fields: ['DUMMY_FIELD']),
      ];

      final columnGroup = PlutoColumnGroup(
        title: title,
        children: children,
      );

      expect(
        PlutoColumnGroupHelper.exists(field: field, columnGroup: columnGroup),
        true,
      );
    });

    test('field 가 columnGroup.children 리스트에 존재하지 않으면 false 를 반환해야 한다.', () {
      final title = 'title';

      final field = 'NON_EXISTS_DUMMY_FIELD';

      final children = [
        PlutoColumnGroup(title: 'title', fields: ['DUMMY_FIELD']),
      ];

      final columnGroup = PlutoColumnGroup(
        title: title,
        children: children,
      );

      expect(
        PlutoColumnGroupHelper.exists(field: field, columnGroup: columnGroup),
        false,
      );
    });

    test('field 가 columnGroup.children 의 2뎁스 하위에 존재하면 true 를 반환해야 한다.', () {
      final title = 'title';

      final field = 'DUMMY_FIELD';

      final children = [
        PlutoColumnGroup(title: 'title', children: [
          PlutoColumnGroup(title: 'title', fields: ['DUMMY_FIELD']),
        ]),
      ];

      final columnGroup = PlutoColumnGroup(
        title: title,
        children: children,
      );

      expect(
        PlutoColumnGroupHelper.exists(field: field, columnGroup: columnGroup),
        true,
      );
    });
  });

  group('maxDepth', () {
    test('그룹의 깊이가 1인 경우 1을 리턴해야 한다.', () {
      final expectedDepth = 1;

      final columnGroupList = [
        PlutoColumnGroup(title: 'title', fields: ['column1', 'column2']),
        PlutoColumnGroup(title: 'title', fields: ['column3', 'column4']),
        PlutoColumnGroup(title: 'title', fields: ['column5', 'column6']),
      ];

      expect(
        PlutoColumnGroupHelper.maxDepth(columnGroupList: columnGroupList),
        expectedDepth,
      );
    });

    test('그룹의 깊이가 2인 경우 2를 리턴해야 한다.', () {
      final expectedDepth = 2;

      final columnGroupList = [
        PlutoColumnGroup(
          title: 'title',
          children: [
            PlutoColumnGroup(title: 'title', fields: ['column1']),
            PlutoColumnGroup(title: 'title', fields: ['column2']),
          ],
        ),
        PlutoColumnGroup(title: 'title', fields: ['column3', 'column4']),
        PlutoColumnGroup(title: 'title', fields: ['column5', 'column6']),
      ];

      expect(
        PlutoColumnGroupHelper.maxDepth(columnGroupList: columnGroupList),
        expectedDepth,
      );
    });

    test('그룹의 깊이가 3인 경우 3를 리턴해야 한다.', () {
      final expectedDepth = 3;

      final columnGroupList = [
        PlutoColumnGroup(
          title: 'title',
          children: [
            PlutoColumnGroup(title: 'title', fields: ['column1']),
            PlutoColumnGroup(
              title: 'title',
              children: [
                PlutoColumnGroup(title: 'title', fields: ['column2']),
                PlutoColumnGroup(title: 'title', fields: ['column3']),
              ],
            ),
          ],
        ),
        PlutoColumnGroup(title: 'title', fields: ['column4']),
        PlutoColumnGroup(title: 'title', fields: ['column5', 'column6']),
      ];

      expect(
        PlutoColumnGroupHelper.maxDepth(columnGroupList: columnGroupList),
        expectedDepth,
      );
    });

    test('그룹의 깊이가 3인 경우 3를 리턴해야 한다.', () {
      final expectedDepth = 3;

      final columnGroupList = [
        PlutoColumnGroup(
          title: 'title',
          children: [
            PlutoColumnGroup(
              title: 'title',
              children: [
                PlutoColumnGroup(title: 'title', fields: ['column2']),
                PlutoColumnGroup(title: 'title', fields: ['column3']),
              ],
            ),
            PlutoColumnGroup(title: 'title', fields: ['column1']),
          ],
        ),
        PlutoColumnGroup(title: 'title', fields: ['column4']),
        PlutoColumnGroup(title: 'title', fields: ['column5', 'column6']),
      ];

      expect(
        PlutoColumnGroupHelper.maxDepth(columnGroupList: columnGroupList),
        expectedDepth,
      );
    });

    test('그룹의 깊이가 4인 경우 4를 리턴해야 한다.', () {
      final expectedDepth = 4;

      final columnGroupList = [
        PlutoColumnGroup(
          title: 'title',
          children: [
            PlutoColumnGroup(
              title: 'title',
              children: [
                PlutoColumnGroup(title: 'title', fields: ['column2']),
                PlutoColumnGroup(
                  title: 'title',
                  children: [
                    PlutoColumnGroup(title: 'title', fields: ['column3']),
                    PlutoColumnGroup(title: 'title', fields: ['column5']),
                  ],
                ),
              ],
            ),
            PlutoColumnGroup(title: 'title', fields: ['column1']),
          ],
        ),
        PlutoColumnGroup(title: 'title', fields: ['column4']),
        PlutoColumnGroup(title: 'title', fields: ['column6']),
      ];

      expect(
        PlutoColumnGroupHelper.maxDepth(columnGroupList: columnGroupList),
        expectedDepth,
      );
    });

    test('그룹의 깊이가 5인 경우 5를 리턴해야 한다.', () {
      final expectedDepth = 5;

      final columnGroupList = [
        PlutoColumnGroup(
          title: 'title',
          children: [
            PlutoColumnGroup(
              title: 'title',
              children: [
                PlutoColumnGroup(title: 'title', fields: ['column2']),
                PlutoColumnGroup(
                  title: 'title',
                  children: [
                    PlutoColumnGroup(title: 'title', fields: ['column3']),
                    PlutoColumnGroup(
                      title: 'title',
                      children: [
                        PlutoColumnGroup(title: 'title', fields: ['column5']),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            PlutoColumnGroup(title: 'title', fields: ['column1']),
          ],
        ),
        PlutoColumnGroup(title: 'title', fields: ['column4']),
        PlutoColumnGroup(title: 'title', fields: ['column6']),
      ];

      expect(
        PlutoColumnGroupHelper.maxDepth(columnGroupList: columnGroupList),
        expectedDepth,
      );
    });
  });
}
