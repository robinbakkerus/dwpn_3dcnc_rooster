// ignore: depend_on_referenced_packages
import 'package:collection/collection.dart';
import 'package:dwpn_3dcnc_rooster/data/app_data.dart';
import 'package:dwpn_3dcnc_rooster/model/app_models.dart';
import 'package:dwpn_3dcnc_rooster/util/app_constants.dart';
import 'package:dwpn_3dcnc_rooster/util/app_helper.dart';
import 'package:dwpn_3dcnc_rooster/util/app_mixin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LogbookItemPage extends StatefulWidget {
  const LogbookItemPage({super.key});

  @override
  State<LogbookItemPage> createState() => _LogbookItemPageState();
}

enum TextCtrl { device, date, user, weight, description }

class _LogbookItemPageState extends State<LogbookItemPage> with AppMixin {
  final _formKey = GlobalKey<FormState>();
  final ah = AppHelper.instance;

  final _textCtrlList = [];

  // LogbookItem? _logbookItem;

  String _deviceValue = '';
  bool _isValid = false;

  @override
  void initState() {
    super.initState();

    for (int i = 0; i < TextCtrl.values.length; i++) {
      _textCtrlList.add(TextEditingController());
    }
    _textCtrlList[TextCtrl.date.index].text =
        AppHelper.instance.formatDate(DateTime.now());
    _textCtrlList[TextCtrl.user.index].text =
        AppData.instance.getUser().fullname;
  }

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    return Scaffold(
        body: Container(
      padding: const EdgeInsets.all(8),
      color: Colors.amber[100],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Form(
            key: _formKey,
            child: Column(children: _buildColumnWidgets()),
          )
        ],
      ),
    ));
  }

  //--------------------------------------------
  List<Widget> _buildColumnWidgets() {
    List<Widget> list = [];

    list.add(_header());
    list.add(wh.verSpace(10));
    list.add(_buildDeviceRow());
    list.add(_buildUsernameRow());
    list.add(_buildDateRow());
    list.add(wh.verSpace(10));
    list.add(_buildWeightRow());
    list.add(wh.verSpace(10));
    list.add(_buildDescriptionRow());
    list.add(wh.verSpace(20));
    list.add(_buildBottomMsg());
    list.add(wh.verSpace(10));
    list.add(_buildCloseButtons());

    return list;
  }

  //-------------------------------------------------
  Widget _header() {
    return const Text('Voeg een nieuw logbook item toe');
  }

  //--------------------------------------------------
  Widget _buildDeviceRow() {
    List<Widget> rowChilds = _buildTextFieldRowWidgets(
        'Device', c.w25, TextCtrl.device, 'Selecteer printer', true);
    rowChilds.add(
      wh.horSpace(10),
    );
    rowChilds.add(
      _buildDeviceDropdown(),
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: rowChilds,
    );
  }

  //----------------------------------------------
  Widget _buildDeviceDropdown() {
    var items = [
      '',
      DevicePK.lulliet.name,
      DevicePK.romeo.name,
      DevicePK.joe.name,
    ];

    return DropdownButton(
      // Initial Value
      value: _deviceValue,

      // Down Arrow Icon
      icon: const Icon(Icons.keyboard_arrow_down),

      // Array list of items
      items: items.map((String items) {
        return DropdownMenuItem(
          value: items,
          child: Text(items),
        );
      }).toList(),
      // After selecting the desired option,it will
      // change button value to selected value
      onChanged: (String? newValue) {
        setState(() {
          _deviceValue = newValue!;
          _textCtrlList[TextCtrl.device.index].text = _deviceValue;
        });

        _handleOnChanged(null);
      },
    );
  }

  //-----------------------------------------
  Widget _buildDateRow() {
    List<Widget> rowChilds = _buildTextFieldRowWidgets(
        'Wanneer', c.w25, TextCtrl.date, 'Wanneer is er geprint', true);

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: rowChilds,
    );
  }

  //-----------------------------------------------------------
  Widget _buildUsernameRow() {
    List<Widget> rowChilds = _buildTextFieldRowWidgets(
        'Device', c.w25, TextCtrl.user, 'Selecteer gebruiker', true);
    rowChilds.add(wh.horSpace(10));
    rowChilds.add(_buildUsernameDropdown());

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: rowChilds,
    );
  }

  //----------------------------------------------
  Widget _buildUsernameDropdown() {
    var items = AppData.instance
        .getAllUsers()
        .map(
          (e) => e.fullname,
        )
        .toList();

    return DropdownButton(
      // Initial Value
      value: _textCtrlList[TextCtrl.user.index].text,

      // Down Arrow Icon
      icon: const Icon(Icons.keyboard_arrow_down),

      // Array list of items
      items: items.map((String items) {
        return DropdownMenuItem(
          value: items,
          child: Text(items),
        );
      }).toList(),
      // After selecting the desired option,it will
      // change button value to selected value
      onChanged: (newValue) {
        setState(() {
          _textCtrlList[TextCtrl.user.index].text = newValue!;
        });

        _handleOnChanged(null);
      },
    );
  }

  //-----------------------------------------
  Widget _buildWeightRow() {
    List<Widget> rowChilds = _buildTextFieldRowWidgets(
        'Gewicht', c.w1, TextCtrl.weight, 'Hoeveel ', false,
        formatters: [FilteringTextInputFormatter.digitsOnly]);
    rowChilds.add(const Text('gram'));

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: rowChilds,
    );
  }

//-----------------------------------------
  Widget _buildDescriptionRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: _buildTextFieldRowWidgets(
          'Wat', c.w40, TextCtrl.description, '', false),
    );
  }

//-----------------------------------------
  List<Widget> _buildTextFieldRowWidgets(String label, double width,
      TextCtrl texCtrlIndex, String hintText, bool readonly,
      {formatters}) {
    List<TextInputFormatter> useFormatter = formatters ?? [];
    List<Widget> result = [
      SizedBox(
        width: c.w1,
        child: Text('$label :'),
      ),
      wh.horSpace(10),
      SizedBox(
        width: width,
        child: TextField(
          onChanged: (text) => _handleOnChanged(text),
          readOnly: readonly,
          controller: _textCtrlList[texCtrlIndex.index],
          inputFormatters: useFormatter,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[300],
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 1, vertical: 1),
            isDense: true,
            hintText: hintText,
            border: InputBorder.none,
            // focusedBorder: InputBorder.none,
            // enabledBorder: InputBorder.none,
            // errorBorder: InputBorder.none,
            // disabledBorder: InputBorder.none,
          ),
        ),
      ),
    ];

    return result;
  }

  //-------------------------------------------
  void _handleOnChanged(String? text) {
    var elem = _textCtrlList.firstWhereOrNull((e) => e.text.isEmpty);
    if (elem == null) {
      setState(() {
        _isValid = true;
      });
    } else {
      if (_isValid) {
        setState(() {
          _isValid = false;
        });
      }
    }
  }

  //----------------------------------------
  Widget _buildBottomMsg() {
    if (_isValid) {
      return Container();
    } else {
      return const Text(
        'Nog niet alle verplichte velden zijn ingevuld',
        style: TextStyle(color: Colors.orange),
      );
    }
  }

  //----------------------------------------
  Widget _buildCloseButtons() {
    return Row(
      children: [
        ElevatedButton(
          child: const Text('Annuleer'),
          onPressed: () => Navigator.pop(context, null),
        ),
        ElevatedButton(
            child: const Text('Sla op en sluit'),
            onPressed: () => _isValid ? _makeLogbookItemAndClose() : null),
      ],
    );
  }

  void _makeLogbookItemAndClose() {
    int id = DateTime.now().millisecondsSinceEpoch;
    String devicePk =
        ah.findDeviceByName(_textCtrlList[TextCtrl.device.index].text).name;
    DateTime date = DateTime.parse(_textCtrlList[TextCtrl.date.index].text);
    String userPk =
        ah.findUserByFulltName(_textCtrlList[TextCtrl.user.index].text).pk;
    int weight = int.parse(_textCtrlList[TextCtrl.weight.index].text);
    LogbookItem logbookItem = LogbookItem(
        id: id,
        devicePk: devicePk,
        date: date,
        userPk: userPk,
        weight: weight,
        description: _textCtrlList[TextCtrl.description.index].text,
        image: "");
    Navigator.pop(context, logbookItem);
  }
}
