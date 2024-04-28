// ignore: depend_on_referenced_packages
import 'package:collection/collection.dart';
import 'package:dwpn_3dcnc_rooster/data/app_version.dart';
import 'package:dwpn_3dcnc_rooster/model/app_models.dart';

class AppData {
  AppData._() {
    _initialize();
  }

  static final instance = AppData._();

  void _initialize() {}

  /// these contains the current active values
  RunMode runMode = appRunModus;

  double screenWidth = 600.0; //assume
  double screenHeight = 600.0; //assume
  double shortestSide = 600; //assume
  String trainerId = "";

  int _stackIndex = 0;
  int getStackIndex() => _stackIndex;
  void setStackIndex(int value) {
    _stackIndex = value;
  }

  User _user = User.empty();
  User getUser() {
    return _user;
  }

  void setUser(User user) {
    _user = user;
  }

  List<User> _allUsers = [];
  List<User> getAllUsers() {
    return _allUsers;
  }

  void setAllUsers(List<User> users) {
    _allUsers = users;
  }

  List<WeekdaySlot> weekdaySlotList = [];
  List<Device> deviceList = [];

  String lastSnackbarMsg = '';

  // this is set in the start_page when you click on the showSpreadsheet, or next/prev month
  final List<SpreadSheet> _spreadSheetList = [];
  List<SpreadSheet> getSpreadSheetList() => _spreadSheetList;

  int _activeSpreadSheetIndex = -1;
  int getActiveSpreadSheetIndex() => _activeSpreadSheetIndex;
  void setActiveSpreadSheetIndex(int index) {
    _activeSpreadSheetIndex = index;
  }

  SpreadSheet getSpreadsheet() {
    if (_spreadSheetList.isEmpty) {
      return SpreadSheet(
          year: DateTime.now().year, month: DateTime.now().month);
    } else {
      if (_activeSpreadSheetIndex < _spreadSheetList.length &&
          _activeSpreadSheetIndex >= 0) {
        return _spreadSheetList[_activeSpreadSheetIndex];
      } else {
        return _spreadSheetList[0];
      }
    }
  }

  DateTime getSpreadsheetDate() {
    return DateTime(getSpreadsheet().year, getSpreadsheet().month, 1);
  }

  void addSpreadsheets(SpreadSheet spreadSheet) {
    SpreadSheet? sheet = _spreadSheetList.firstWhereOrNull(
        (e) => e.year == spreadSheet.year && e.month == spreadSheet.month);
    if (sheet == null) {
      _spreadSheetList.add(spreadSheet);
    }
  }

  // ---

  DateTime getActiveDate() {
    if (_spreadSheetList.length > _activeSpreadSheetIndex) {
      return DateTime(getSpreadsheet().year, getSpreadsheet().month, 1);
    } else {
      return DateTime.now();
    }
  }

  int getActiveMonth() {
    return getActiveDate().month;
  }

  int getActiveYear() {
    return getActiveDate().year;
  }

  ///
  String getActiveMonthAsString() {
    return maanden[getActiveMonth() - 1];
  }

  Logbook logbook = Logbook(items: []);

  ///-----------------------------------
  bool isSchemaDirty() {
    return false;
  }

  List<String> maanden = [
    'Januari',
    'Februari',
    'Maart',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Augustus',
    'September',
    'Oktober',
    'November',
    'December'
  ];

  //---------- private --------------
}
