import '../../pluto_grid.dart';

class ExcelFilters{

  PlutoGridStateManager? stateManager;
  List<PlutoRow?> rows = [];

  ExcelFilters({required this.stateManager}){
    // rows = stateManager.rows;
    rows = stateManager!.refRows!.originalList;
  }

  List<int> dateFilter({required int filterValue, required List<int> filterIndex, required bool isBefore, String? column}) {

    filterIndex.removeWhere((index) {
      String element = rows[index]!.cells[column]!.value.toString();
      if (element == 'Select All') {
        return false;
      }

      bool isRemove = true;

      if (isBefore) {
        isRemove = DateTime.parse(element).millisecondsSinceEpoch > filterValue;
      } else {
        isRemove = DateTime.parse(element).millisecondsSinceEpoch < filterValue;
      }

      if (isRemove) {
        // checkedList.remove(element);
        return true;
      } else {
        // if (!checkedList.contains(element)) {
        //   checkedList.add(element);
        // }
        return false;
      }
    });

    return filterIndex;
  }

  List<int> numberFilter({required String filterValue, required List<int> filterIndex, required bool isGreater, String? column}) {

    double number = double.parse(filterValue);
    filterIndex.removeWhere((index) {
      String element = rows[index]!.cells[column]!.value.toString();

      if (element == 'Select All') {
        return false;
      }

      bool isRemove = true;

      if (isGreater) {
        isRemove = double.parse(element) < number;
      } else {
        isRemove = double.parse(element) > number;
      }

      if (isRemove) {
        // checkedList.remove(element);
        return true;
      } else {
        // if (!checkedList.contains(element)) {
        //   checkedList.add(element);
        // }
        return false;
      }
    });
    return filterIndex;
  }

  List<int> containsFilter({required String filterValue, required List<int> filterIndex, String? column}) {

    print('Contains Filter');
    print(filterValue);
    print(column);

    filterIndex.removeWhere((index) {
      String element = rows[index]!.cells[column]!.value.toString();

      if (element == 'Select All') {
        return false;
      }
      if (!element.toLowerCase().contains(filterValue.toLowerCase())) {
        // checkedList.remove(element);
        return true;
      } else {
        // if (!checkedList.contains(element)) {
        //   checkedList.add(element);
        // }
        return false;
      }
    });
    return filterIndex;
  }
}