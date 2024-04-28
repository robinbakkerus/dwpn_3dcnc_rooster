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
  bool _showWeeks = true;

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
    return DataTable(
      headingRowHeight: 26,
      horizontalMargin: 1.0,
      headingRowColor:
          MaterialStateColor.resolveWith((states) => c.ssRowHeader),
      columnSpacing: 1.0,
      dataRowMinHeight: 15,
      dataRowMaxHeight: 26,
      columns: _buildDataTableColumns(),
      rows: _buildDataRows(),
    );
  }

  //-------------------------
  List<DataColumn> _buildDataTableColumns() {
    List<DataColumn> result = [];

    List<DateTime> dates = _showWeeks
        ? AppHelper.instance.getAllDatesInWeek(_activeWeekNr)
        : AppHelper.instance
            .getAllDatesInMonth(AppData.instance.getActiveDate());

    DateTime firstDate = dates[0];
    String dag = AppHelper.instance
        .weekDayStringFromDate(date: firstDate, locale: c.localNL, length: 3);

    result.add(DataColumn(
      label: Text(dag),
    ));

    for (Device device in AppData.instance.deviceList) {
      result.add(DataColumn(
        label: _buildHeaderCell(device.name),
      ));
    }

    return result;
  }

  //----------------------------
  Widget _buildHeaderCell(String devicePk) {
    if (_isLargeScreen()) {
      Device device = AppHelper.instance.findDeviceByName(devicePk);
      return ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: c.ssRowHeader,
        ),
        onPressed: () => _onDeviceHeaderClicked(devicePk),
        icon: Image.asset('assets/${device.type.name}.png'),

        label: Text(devicePk), // <-- Text
      );
    } else {
      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: c.ssRowHeader,
        ),
        onPressed: () => _onDeviceHeaderClicked(devicePk),
        child: Text(devicePk), // <-- Text
      );
    }
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

    List<DateTime> dates = [];
    if (_showWeeks) {
      dates = AppHelper.instance.getAllDatesInWeek(_activeWeekNr);
      dates = dates
          .where((e) => e.month == AppData.instance.getActiveMonth())
          .toList();
    } else {
      dates = AppHelper.instance
          .getAllDatesInMonth(AppData.instance.getActiveDate());
    }

    int rowNr = 0;
    for (DateTime dateTime in dates) {
      List<WeekdaySlot> slots =
          AppHelper.instance.getWeekDaySlotsAtDate(dateTime);

      if (slots.isNotEmpty) {
        MaterialStateColor headerColor =
            MaterialStateColor.resolveWith((states) => c.ssRowHeader);
        MaterialStateColor color = _getRowColor(dateTime);

        // row with date and repeating header
        if (rowNr > 0) {
          DataRow dataRow = DataRow(
            color: headerColor,
            cells: buildDataCells(dateTime, null, headerColor),
          );
          result.add(dataRow);
        }
        rowNr++;

        for (WeekdaySlot weekdaySlot in slots) {
          DataRow dataRow = DataRow(
            color: color,
            cells: buildDataCells(dateTime, weekdaySlot, color),
          );
          result.add(dataRow);
        }
      }
    }
    return result;
  }

  MaterialStateColor _getRowColor(DateTime date) {
    return !date.isBefore(DateTime.now().add(const Duration(days: -1)))
        ? MaterialStateColor.resolveWith((states) => c.ssActiveRowColor)
        : MaterialStateColor.resolveWith((states) => c.ssInactiveRowColor);
    // MaterialStateColor col =
    //     MaterialStateColor.resolveWith((states) => Colors.white);
    // if (date.weekday == DateTime.monday) {
    //   col = MaterialStateColor.resolveWith((states) => c.ssRowMonday);
    // } else if (date.weekday == DateTime.tuesday) {
    //   col = MaterialStateColor.resolveWith((states) => c.ssRowTuesday);
    // } else if (date.weekday == DateTime.thursday) {
    //   col = MaterialStateColor.resolveWith((states) => c.ssRowThursday);
    // } else if (date.weekday == DateTime.wednesday) {
    //   col = MaterialStateColor.resolveWith((states) => c.ssRowWednesday);
    // } else if (date.weekday == DateTime.friday) {
    //   col = MaterialStateColor.resolveWith((states) => c.ssRowFriday);
    // }
    // return col;
  }

  //------------------------------
  List<DataCell> buildDataCells(
      DateTime dateTime, WeekdaySlot? weekdaySlot, Color color) {
    List<DataCell> result = [];

    result.add(buildDayCell(dateTime, weekdaySlot));

    if (weekdaySlot == null) {
      for (int i = 0; i < AppData.instance.deviceList.length; i++) {
        result.add(
            DataCell(repeatHeaderCell(AppData.instance.deviceList[i].name)));
      }
    } else {
      for (int i = 0; i < AppData.instance.deviceList.length; i++) {
        String devicePk = AppData.instance.deviceList[i].name;
        result.add(
            buildUserReservationCell(dateTime, weekdaySlot, devicePk, color));
      }
    }

    return result;
  }

  Widget repeatHeaderCell(String text) {
    return Center(child: Text(text));
  }

  //----------------------------
  DataCell buildUserReservationCell(DateTime dateTime, WeekdaySlot weekdaySlot,
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
  DataCell buildDayCell(DateTime dateTime, WeekdaySlot? weekdaySlot) {
    return DataCell(SpreadsheetDayColumn(
        key: UniqueKey(), dateTime: dateTime, weekdaySlot: weekdaySlot));
  }

  //----------------------------
  Widget _buildSelectWeekButtons() {
    List<Widget> weekButtons = [];
    if (_showWeeks) {
      List<int> weeknrs = AppHelper.instance
          .getWeekNumbersForMonth(AppData.instance.getActiveDate());
      weekButtons
          .addAll(weeknrs.map((e) => _buildSelectWeekWidget(e)).toList());
    }

    weekButtons.add(_buildToggleMonthButton());
    return Row(children: weekButtons);
  }

//----------------------------
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
        onPressed: () => onSelectWeek(weeknr),
        child: textWidget);
  }

//----------------------------
  TextButton _buildToggleMonthButton() {
    String txt = _showWeeks ? 'Maand' : 'Week';
    return TextButton(
        style: TextButton.styleFrom(
          backgroundColor: Colors.transparent,
        ),
        onPressed: _toggleMonth,
        child: Text(txt));
  }

  //----------------------------
  void onSelectWeek(int weeknr) {
    setState(() {
      _activeWeekNr = weeknr;
      _dataGrid = _buildGrid(context);
    });
  }

  //----------------------------
  void _toggleMonth() {
    setState(() {
      _showWeeks = !_showWeeks;
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
            InkWell(
                onTap: _onShowSpreadsheetInfo,
                child: const Icon(
                  Icons.info_outline,
                  size: 32,
                  color: Colors.lightBlue,
                )),
            wh.horSpace(10),
            buildActionButton(context),
          ],
        ),
      ],
    );
  }

  // ----------------------------
  Widget buildActionButton(BuildContext context) {
    if (AppData.instance.getSpreadsheet().status ==
        SpreadsheetStatus.underConstruction) {
      return buildActionButtonsNewSpreadsheet();
    } else {
      return Container();
    }
  }

  // ----------------------------
  Widget buildActionButtonsNewSpreadsheet() {
    if (isSupervisor()) {
      return OutlinedButton(
          onPressed: onConfirmFinalizeSpreadsheet,
          child: const Text('Maak schema definitief'));
    } else {
      return Container();
    }
  }

  ///--------------------------------------------------------
  // void _onShowSpreadsheetInfo() {
  //   _buildDialogSpreadsheetInfo(context);
  // }

  void onConfirmFinalizeSpreadsheet() {
    buildDialogConfirm(context, true);
  }

  void makeSpreadsheetFinal(BuildContext context) async {
    AppController.instance.finalizeSpreadsheet();
    AppEvents.fireSpreadsheetReady();
    wh.showSnackbar('Training schema is nu definitief!');
  }

  //----------------
  void buildDialogConfirm(BuildContext context, bool allProgramFieldSet) {
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
              makeSpreadsheetFinal(context);

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
  bool isSupervisor() {
    return AppData.instance.getUser().isSupervisor();
  }

  void _onShowSpreadsheetInfo() {
    _buildDialogSpreadsheetInfo(context);
  }

  void _buildDialogSpreadsheetInfo(BuildContext context) {
    Widget closeButton = TextButton(
      onPressed: () {
        Navigator.of(context, rootNavigator: true)
            .pop(); // dismisses only the dialog and returns nothing
      },
      child: const Text("Close"),
    ); // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: const Text("Reserveringen"),
      content: Text(_getReservations()),
      actions: [
        closeButton,
      ],
    ); // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  String _getReservations() {
    String result = 'Van  ${AppData.instance.getUser().fullname} : ';
    for (Device dev in AppData.instance.deviceList) {
      List<Reservation> reservations = AppData.instance
          .getSpreadsheet()
          .reservations
          .where((e) => e.devicePk == dev.name)
          .toList();

      if (reservations.isNotEmpty) {
        result += "\n${dev.name}: ${reservations.length}";
      }
    }
    return result;
  }

  bool _isLargeScreen() {
    return (MediaQuery.of(context).size.width > 800);
  }
}
