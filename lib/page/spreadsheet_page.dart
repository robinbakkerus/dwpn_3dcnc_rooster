import 'package:dwpn_3dcnc_rooster/controller/app_controler.dart';
import 'package:dwpn_3dcnc_rooster/data/app_data.dart';
import 'package:dwpn_3dcnc_rooster/event/app_events.dart';
import 'package:dwpn_3dcnc_rooster/model/app_models.dart';
import 'package:dwpn_3dcnc_rooster/util/app_helper.dart';
import 'package:dwpn_3dcnc_rooster/util/app_mixin.dart';
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
    AppEvents.onReservationEvent(_onReservationEvent);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _dataGrid = _buildGrid(context);
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSelectWeekButtons(),
        _buildDataTable(context),
        _buildBottomButtons(),
      ],
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
      result.add(DataColumn(
          label: Text(device.name,
              style: const TextStyle(fontStyle: FontStyle.italic))));
    }

    return result;
  }

  //------------------------------
  List<DataRow> _buildDataRows() {
    List<DataRow> result = [];

    List<DateTime> dates = AppHelper.instance.getAllDatesInWeek(_activeWeekNr);

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
    List<Widget> weeks = weeknrs
        .map((e) => TextButton(
            onPressed: () => _onSelectWeek(e), child: Text(_getWeekText(e))))
        .toList();
    return Row(children: weeks);
  }

  String _getWeekText(int weeknr) {
    String result = 'Week $weeknr';
    DateTime date1 =
        dateTimeFromWeekNumber(AppData.instance.getActiveYear(), weeknr);
    DateTime date2 = date1.add(const Duration(days: 6));
    return result += ' (${date1.day} - ${date2.day})';
  }

  //----------------------------
  void _onSelectWeek(int weeknr) {
    setState(() {
      _activeWeekNr = weeknr;
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
            wh.horSpace(10),
            const InkWell(
                onTap: null,
                child: Icon(
                  Icons.info_outline,
                  size: 32,
                  color: Colors.lightBlue,
                )),
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

  // void _makeSpreadsheetFinal(BuildContext context) async {
  //   AppController.instance.finalizeSpreadsheet(_spreadSheet);
  //   AppData.instance.getSpreadsheet().status = SpreadsheetStatus.active;
  //   AppEvents.fireSpreadsheetReady();
  //   wh.showSnackbar('Training schema is nu definitief!');
  // }

  // void _buildDialogSpreadsheetInfo(BuildContext context) {
  //   Widget closeButton = TextButton(
  //     onPressed: () {
  //       Navigator.of(context, rootNavigator: true)
  //           .pop(); // dismisses only the dialog and returns nothing
  //     },
  //     child: const Text("Close"),
  //   ); // set up the AlertDialog
  //   AlertDialog alert = AlertDialog(
  //     title: const Text("Trainer inzet."),
  //     content: const Text('todo'),
  //     actions: [
  //       closeButton,
  //     ],
  //   ); // show the dialog
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return alert;
  //     },
  //   );
  // }

  //----------------------------------
//   void _buildOpenSchemaAlertDialog() {
//     String content = '''
// Dit schema is gepubliceerd!
// Weet je zeker dat je wijzigingen wilt aanbrengen?
// ''';
//     wh.showConfirmDialog(context,
//         title: 'Trainingschema',
//         content: content,
//         yesFunction: () => _handleYes());
//   }

  //-------------------------------
  // void _handleYes() {
  //   setState(() {
  //     AppData.instance.getSpreadsheet().status = SpreadsheetStatus.opened;
  //     AppEvents.fireSpreadsheetReady();
  //   });
  // }

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
              // _makeSpreadsheetFinal(context);

              Navigator.of(context, rootNavigator: true)
                  .pop(); // dismisses only the dialog and returns nothing
            }
          : null,
      child: const Text("Continue"),
    ); // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: const Text("Schema definitief maken"),
      content: Text(msg),
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
        // if (AppData.instance.getSpreadsheet().status ==
        //     SpreadsheetStatus.active) {
        //   wh.showSnackbar('Schema is al definitief!', color: Colors.orange);
        // } else if (AppData.instance.getSpreadsheet().status ==
        //     SpreadsheetStatus.old) {
        //   wh.showSnackbar('Schema is verlopen!', color: Colors.orange);
        // }
      });
    }
  }

  void _onReservationEvent(ReservationEvent event) {
    if (mounted) {
      Reservation reservation = Reservation(
          day: event.day,
          daySlotEnum: event.daySlotEnum,
          devicePk: event.devicePk,
          userPk: AppData.instance.getUser().pk);
      AppController.instance.saveReservation(reservation, event.addReservation);
    }
  }

  //--------------------------------
  bool _isSupervisor() {
    return AppData.instance.getUser().isSupervisor();
  }
}
