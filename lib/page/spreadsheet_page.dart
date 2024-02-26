import 'package:dwpn_3dcnc_rooster/controller/app_controler.dart';
import 'package:dwpn_3dcnc_rooster/data/app_data.dart';
import 'package:dwpn_3dcnc_rooster/event/app_events.dart';
import 'package:dwpn_3dcnc_rooster/model/app_models.dart';
import 'package:dwpn_3dcnc_rooster/util/app_helper.dart';
import 'package:dwpn_3dcnc_rooster/util/app_mixin.dart';
import 'package:dwpn_3dcnc_rooster/widget/device_info_widget.dart';
import 'package:dwpn_3dcnc_rooster/widget/spreadsheet_cell.dart';
import 'package:dwpn_3dcnc_rooster/widget/spreadsheet_day_field.dart';
import 'package:flutter/material.dart';
import 'package:week_number/iso.dart';
// ignore: depend_on_referenced_packages
// import 'package:collection/collection.dart';

class SpreadsheetPage extends StatefulWidget {
  const SpreadsheetPage({super.key});

  @override
  State<SpreadsheetPage> createState() => _SpreadsheetPageState();
}

//-------------------
class _SpreadsheetPageState extends State<SpreadsheetPage> with AppMixin {
  Widget _dataGrid = Container();
  int _activeWeekNr = 0;

  _SpreadsheetPageState();

  @override
  void initState() {
    AppEvents.onSpreadsheetReadyEvent(_onSpreadsheetReady);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
    );
  }

  //---------------------------------
  Widget _buildBody() {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
          scrollDirection: Axis.horizontal, child: _dataGrid),
    );
  }

  //-----------------------
  bool _isEditable() {
    return ((AppData.instance.getSpreadsheet().status ==
            SpreadsheetStatus.underConstruction &&
        AppData.instance.getUser().isSupervisor()));
  }

  Widget _buildGrid(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSelectWeekButtons(),
          _buildDataTable(context),
          _buildBottomButtons(),
        ],
      ),
    );
  }

//--------------------------------
  Widget _buildDataTable(BuildContext context) {
    double colSpace = AppHelper.instance.isWindows() ? 1 : 1;
    return DataTable(
      headingRowHeight: 30,
      horizontalMargin: 1,
      headingRowColor:
          MaterialStateColor.resolveWith((states) => c.ssRowHeader),
      columnSpacing: colSpace,
      dataRowMinHeight: 15,
      dataRowMaxHeight: 30,
      columns: _buildHeader(),
      rows: _buildDataRows(),
    );
  }

  //-------------------------
  List<DataColumn> _buildHeader() {
    List<DataColumn> result = [];

    result.add(const DataColumn(
        label:
            Text('Dag deel', style: TextStyle(fontStyle: FontStyle.italic))));

    for (Device device in AppData.instance.deviceList) {
      result.add(DataColumn(label: _buildHeaderCell(device.name)));
    }

    return result;
  }

  //----------------------------
  Widget _buildHeaderCell(String devicePk) {
    return TextButton(
        onPressed: () => _onDeviceHeaderClicked(devicePk),
        child: Text(devicePk));
  }

  //----------------------------
  void _onDeviceHeaderClicked(String devicePk) async {
    String title = 'Device $devicePk';
    Widget closeButton = TextButton(
      onPressed: () {
        Navigator.of(context, rootNavigator: true)
            .pop(); // dismisses only the dialog and returns nothing
      },
      child: const Text("Close"),
    );

    AlertDialog alert = AlertDialog(
      title: Text(title),
      content: DeviceInfo(
        devicePk: devicePk,
      ),
      actions: [
        closeButton,
      ],
    ); //
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        });
  }

  //------------------------------
  List<DataRow> _buildDataRows() {
    List<DataRow> result = [];

    List<DateTime> dates = AppHelper.instance.getAllDatesInWeek(_activeWeekNr);
    dates = dates
        .where((e) => e.month == AppData.instance.getActiveMonth())
        .toList();

    for (DateTime dateTime in dates) {
      List<WeekdaySlot> slots =
          AppHelper.instance.getWeekDaySlotsAtDate(dateTime);
      if (slots.isNotEmpty) {
        MaterialStateColor color = _getRowColor(dateTime);

        // row with date and repeating header
        DataRow dataRow = DataRow(
          color: color,
          cells: _buildDataCells(dateTime, null, color),
        );
        result.add(dataRow);

        for (WeekdaySlot weekdaySlot in slots) {
          DataRow dataRow = DataRow(
            color: color,
            cells: _buildDataCells(dateTime, weekdaySlot, color),
          );
          result.add(dataRow);
        }
      }
    }
    return result;
  }

  MaterialStateColor _getRowColor(DateTime date) {
    MaterialStateColor col =
        MaterialStateColor.resolveWith((states) => Colors.white);
    if (date.weekday == DateTime.monday) {
      col = MaterialStateColor.resolveWith((states) => c.ssRowMonday);
    } else if (date.weekday == DateTime.tuesday) {
      col = MaterialStateColor.resolveWith((states) => c.ssRowTuesday);
    } else if (date.weekday == DateTime.thursday) {
      col = MaterialStateColor.resolveWith((states) => c.ssRowThursday);
    } else if (date.weekday == DateTime.wednesday) {
      col = MaterialStateColor.resolveWith((states) => c.ssRowWednesday);
    } else if (date.weekday == DateTime.friday) {
      col = MaterialStateColor.resolveWith((states) => c.ssRowFriday);
    }
    return col;
  }

  //------------------------------
  List<DataCell> _buildDataCells(
      DateTime dateTime, WeekdaySlot? weekdaySlot, Color color) {
    List<DataCell> result = [];

    result.add(_buildDayCell(dateTime, weekdaySlot));

    if (weekdaySlot == null) {
      for (int i = 0; i < AppData.instance.deviceList.length; i++) {
        result.add(
            DataCell(_repeatHeaderCell(AppData.instance.deviceList[i].name)));
      }
    } else {
      for (int i = 0; i < AppData.instance.deviceList.length; i++) {
        String devicePk = AppData.instance.deviceList[i].name;
        result.add(
            _buildUserReservationCell(dateTime, weekdaySlot, devicePk, color));
      }
    }

    return result;
  }

  Widget _repeatHeaderCell(String text) {
    return Container(
        width: c.w1,
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey)),
        ),
        child: Text(text));
  }

  //----------------------------
  DataCell _buildUserReservationCell(DateTime dateTime, WeekdaySlot weekdaySlot,
      String devicePk, Color color) {
    return DataCell(SpreadsheetCell(
        key: UniqueKey(),
        dateTime: dateTime,
        weekDaySlot: weekdaySlot,
        devicePk: devicePk,
        color: color,
        isEditable: _isEditable()));
  }

  //----------------------------
  DataCell _buildDayCell(DateTime dateTime, WeekdaySlot? weekdaySlot) {
    return DataCell(SpreadsheetDayColumn(
        key: UniqueKey(), dateTime: dateTime, weekdaySlot: weekdaySlot));
  }

  //----------------------------
  Widget _buildSelectWeekButtons() {
    List<int> weeknrs = AppHelper.instance
        .getWeekNumbersForMonth(AppData.instance.getActiveDate());
    List<Widget> weeks = weeknrs.map((e) => _buildSelectWeekWidget(e)).toList();
    return Row(children: weeks);
  }

  TextButton _buildSelectWeekWidget(int weeknr) {
    String result = 'Week $weeknr';
    DateTime date1 =
        dateTimeFromWeekNumber(AppData.instance.getActiveYear(), weeknr);
    DateTime date2 = date1.add(const Duration(days: 6));
    Widget textWidget = Text(result += ' (${date1.day} - ${date2.day})');
    Color color =
        _activeWeekNr == weeknr ? Colors.blue[200]! : Colors.transparent;
    return TextButton(
        style: TextButton.styleFrom(
          backgroundColor: color,
        ),
        onPressed: () => _onSelectWeek(weeknr),
        child: textWidget);
  }

  //----------------------------
  void _onSelectWeek(int weeknr) {
    setState(() {
      _activeWeekNr = weeknr;
      _dataGrid = _buildGrid(context);
    });
  }

  // ----------------------------
  Widget _buildBottomButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        wh.verSpace(10),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            wh.horSpace(20),
            _buildActionButton(context),
          ],
        ),
      ],
    );
  }

  // ----------------------------
  Widget _buildActionButton(BuildContext context) {
    if (AppData.instance.getSpreadsheet().status ==
        SpreadsheetStatus.underConstruction) {
      return _buildActionButtonsNewSpreadsheet();
    } else {
      return Container();
    }
  }

  // ----------------------------
  Widget _buildActionButtonsNewSpreadsheet() {
    if (_isSupervisor()) {
      return OutlinedButton(
          onPressed: _onConfirmFinalizeSpreadsheet,
          child: const Text('Maak schema definitief'));
    } else {
      return Container();
    }
  }

  ///--------------------------------------------------------
  // void _onShowSpreadsheetInfo() {
  //   _buildDialogSpreadsheetInfo(context);
  // }

  void _onConfirmFinalizeSpreadsheet() {
    _buildDialogConfirm(context, true);
  }

  void _makeSpreadsheetFinal(BuildContext context) async {
    AppController.instance.finalizeSpreadsheet();
    AppEvents.fireSpreadsheetReady();
    wh.showSnackbar('Training schema is nu definitief!');
  }

  //----------------
  void _buildDialogConfirm(BuildContext context, bool allProgramFieldSet) {
    String msg =
        "Weet je zeker dat je het schema van ${AppData.instance.getActiveMonthAsString()} definitief wilt maken";
    Widget cancelButton = TextButton(
      child: const Text("Cancel"),
      onPressed: () {
        Navigator.of(context, rootNavigator: true)
            .pop(); // dismisses only the dialog and returns nothing
      },
    );
    Widget continueButton = TextButton(
      onPressed: allProgramFieldSet
          ? () {
              _makeSpreadsheetFinal(context);

              Navigator.of(context, rootNavigator: true)
                  .pop(); // dismisses only the dialog and returns nothing
            }
          : null,
      child: const Text("Yes", style: TextStyle(color: Colors.green)),
    ); // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: const Text("Schema definitief maken"),
      content: Text(
        msg,
      ),
      actions: [
        continueButton,
        cancelButton,
      ],
    ); // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void _onSpreadsheetReady(SpreadsheetReadyEvent event) {
    if (mounted) {
      setState(() {
        _activeWeekNr = DateTime(AppData.instance.getActiveYear(),
                AppData.instance.getActiveMonth(), 1)
            .weekNumber;
        _dataGrid = _buildGrid(context);
      });
    }
  }

  //--------------------------------
  bool _isSupervisor() {
    return AppData.instance.getUser().isSupervisor();
  }
}
