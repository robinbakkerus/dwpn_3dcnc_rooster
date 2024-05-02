import 'package:dwpn_3dcnc_rooster/controller/app_controler.dart';
import 'package:dwpn_3dcnc_rooster/data/app_data.dart';
import 'package:dwpn_3dcnc_rooster/event/app_events.dart';
import 'package:dwpn_3dcnc_rooster/model/app_models.dart';
import 'package:dwpn_3dcnc_rooster/page/logbook_item_page.dart';
import 'package:dwpn_3dcnc_rooster/util/app_helper.dart';
import 'package:dwpn_3dcnc_rooster/util/app_mixin.dart';
import 'package:flutter/material.dart';

class LogbookPage extends StatefulWidget {
  const LogbookPage({super.key});

  @override
  State<LogbookPage> createState() => _LogbookPageState();
}

class _LogbookPageState extends State<LogbookPage> with AppMixin {
  Widget _body = Container();
  Widget _dataTable = Container();

  @override
  void initState() {
    AppEvents.onLogbookReadyEvent(_onLogbookReady);
    _body = _buildBody(context);
    _dataTable = _buildDataTable(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var scaffold = Scaffold(
        floatingActionButton: _buildFab(),
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: SingleChildScrollView(
              scrollDirection: Axis.horizontal, child: _body),
        ));
    return scaffold;
  }

  FloatingActionButton _buildFab() {
    return FloatingActionButton(
      backgroundColor: const Color.fromRGBO(82, 170, 94, 1.0),
      tooltip: 'Voeg logboek item toe',
      onPressed: () => _onAddItemClicked(),
      child: const Icon(Icons.add, color: Colors.white, size: 28),
    );
  }

  void _onLogbookReady(LogbookReadyEvent event) {
    if (mounted) {
      setState(() {
        _dataTable = _buildDataTable(context);
        _body = _buildBody(context);
      });
    }
  }

  Widget _buildBody(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _dataTable,
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
    result.add(_buildDataColumn('Device', 50));
    result.add(_buildDataColumn('Wie', 50));
    result.add(_buildDataColumn('Wanneer', 70));
    result.add(_buildDataColumn('Gewicht', 70));
    result.add(_buildDataColumn('Wat', 100));
    result.add(_buildDataColumn('Foto', 100));
    return result;
  }

  DataColumn _buildDataColumn(String title, double size) {
    return DataColumn(
      label: SizedBox(
          width: size,
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Text(title),
          )),
    );
  }

//--------------------------------
  List<DataRow> _buildDataRows() {
    List<DataRow> result = [];

    for (LogbookItem item in AppData.instance.logbook.items) {
      result.add(DataRow(
        cells: _buildDataCellsForLogbookItems(item),
      ));
    }

    return result;
  }

  //--------------------------------
  List<DataCell> _buildDataCellsForLogbookItems(LogbookItem item) {
    List<DataCell> result = [];

    result.add(DataCell(_buildDataCellWidget(item.devicePk)));
    User user = AppHelper.instance.findUserByPk(item.userPk);
    result.add(DataCell(_buildDataCellWidget(user.fullname)));
    result.add(DataCell(
        _buildDataCellWidget(AppHelper.instance.formatDate(item.date))));
    result.add(DataCell(_buildDataCellWidget(item.weight.toString())));
    result.add(DataCell(_buildDataCellWidget(item.description)));
    result.add(const DataCell(Text('')));

    return result;
  }

//----------------------------
  Widget _buildDataCellWidget(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 2, 4, 2),
      child: Text(text),
    );
  }

  //-----------------------------------
  void _onAddItemClicked() async {
    await _dialogBuilder(context);
  }

  //----------------------------------
  Future<void> _dialogBuilder(BuildContext context) async {
    await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: LogbookItemPage(
            key: UniqueKey(),
          ),
        );
      },
    ).then((value) => _handleLogbookItem(value));
  }

  //---------------------------------
  void _handleLogbookItem(LogbookItem? logbookItem) {
    if (logbookItem == null) {
      return;
    }

    AppController.instance.addLogbookItem(logbookItem);
  }
}
