import 'package:dwpn_3dcnc_rooster/data/app_data.dart';
import 'package:dwpn_3dcnc_rooster/event/app_events.dart';
import 'package:dwpn_3dcnc_rooster/model/app_models.dart';
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
  Device? _activeDevice;

  @override
  void initState() {
    AppEvents.onSpreadsheetReadyEvent(_onSpreadsheetReady);
    _body = _buildBody(context);
    _dataTable = _buildDataTable(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child:
          SingleChildScrollView(scrollDirection: Axis.horizontal, child: _body),
    ));
  }

  void _onSpreadsheetReady(SpreadsheetReadyEvent event) {
    if (mounted) {
      setState(() {
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
          // _buildSelectDeviceButtons(),
          _dataTable,
          // _buildBottomButtons(),
        ],
      ),
    );
  }

  ///---------------------------------
  Widget _buildSelectDeviceButtons() {
    List<Widget> deviceButtons = [];

    deviceButtons.add(const Text('Start'));

    for (Device device in AppData.instance.deviceList) {
      deviceButtons.add(TextButton(
          style: TextButton.styleFrom(
            backgroundColor: Colors.transparent,
          ),
          onPressed: () => _onSelectDevice(device),
          child: Text(device.name)));
    }
    return Row(children: deviceButtons);
  }

  //------------------------
  void _onSelectDevice(Device device) {
    setState(() {
      _activeDevice = device;
      _dataTable = _buildDataTable(context);
      _body = _buildBody(context);
    });
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
    if (_activeDevice == null) {
      List<DataColumn> result = [];
      result.add(const DataColumn(
        label: Text('Logboek pagina'),
      ));
      return result;
    } else {
      return _buildDataTableColumnsForLogbookItems();
    }
  }

  List<DataColumn> _buildDataTableColumnsForLogbookItems() {
    List<DataColumn> result = [];
    result.add(const DataColumn(
      label: Text('Wie'),
    ));
    result.add(const DataColumn(
      label: Text('Wanneer'),
    ));
    result.add(const DataColumn(
      label: Text('Hoeveel (gram filament)'),
    ));
    result.add(const DataColumn(
      label: Text('Kleur'),
    ));
    result.add(const DataColumn(
      label: Text('Wat omschrijving'),
    ));
    result.add(const DataColumn(
      label: Text('Foto (opt)'),
    ));

    return result;
  }

//--------------------------------
  List<DataRow> _buildDataRows() {
    List<DataRow> result = [];

    if (_activeDevice == null) {
      List<DataCell> cellList = [_buildStartText()];
      result.add(DataRow(
        cells: cellList,
      ));
    } else {
      result.add(DataRow(
        cells: _buildDataCellsForLogbookItems(),
      ));
    }
    return result;
  }

  //--------------------------------
  List<DataCell> _buildDataCellsForLogbookItems() {
    List<DataCell> result = [];
    result.add(const DataCell(Text('todo')));
    result.add(const DataCell(Text('todo')));
    result.add(const DataCell(Text('todo')));
    result.add(const DataCell(Text('todo')));
    result.add(const DataCell(Text('todo')));
    result.add(const DataCell(Text('todo')));

    return result;
  }

  //-----------------------------------
  DataCell _buildStartText() {
    return const DataCell(Text('Todo start tekst voor logboek'));
  }
}
