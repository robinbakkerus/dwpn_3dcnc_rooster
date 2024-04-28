import 'package:dwpn_3dcnc_rooster/data/app_data.dart';
import 'package:dwpn_3dcnc_rooster/util/app_constants.dart';
import 'package:dwpn_3dcnc_rooster/util/app_helper.dart';
import 'package:dwpn_3dcnc_rooster/util/app_mixin.dart';
import 'package:flutter/material.dart';

class LogbookItemPage extends StatefulWidget {
  const LogbookItemPage({super.key});

  @override
  State<LogbookItemPage> createState() => _LogbookItemPageState();
}

class _LogbookItemPageState extends State<LogbookItemPage> with AppMixin {
  final _textDeviceCtrl = TextEditingController();
  final _textDateCtrl = TextEditingController();
  final _textUsernameCtrl = TextEditingController();
  final _textWeightCtrl = TextEditingController();
  final _textDescriptionCtrl = TextEditingController();

  // LogbookItem? _logbookItem;

  String _deviceValue = '';

  @override
  void initState() {
    super.initState();
    _textDateCtrl.text = AppHelper.instance.formatDate(DateTime.now());
    _textUsernameCtrl.text = AppData.instance.getUser().fullname;
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
          children: _buildColumnWidgets(),
        ),
      ),
    );
  }

  //-----------------------------------------------

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
        'Device', c.w25, _textDeviceCtrl, 'Selecteer printer', true);
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
          _textDeviceCtrl.text = _deviceValue;
        });
      },
    );
  }

  //-----------------------------------------
  Widget _buildDateRow() {
    List<Widget> rowChilds = _buildTextFieldRowWidgets(
        'Wanneer', c.w25, _textDateCtrl, 'Wanneer is er geprint', true);

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: rowChilds,
    );
  }

  //-----------------------------------------------------------
  Widget _buildUsernameRow() {
    List<Widget> rowChilds = _buildTextFieldRowWidgets(
        'Device', c.w25, _textUsernameCtrl, 'Selecteer gebruiker', true);
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
      value: _textUsernameCtrl.text,

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
          _textUsernameCtrl.text = newValue!;
        });
      },
    );
  }

  //-----------------------------------------
  Widget _buildWeightRow() {
    List<Widget> rowChilds = _buildTextFieldRowWidgets(
        'Gewicht', c.w25, _textWeightCtrl, 'Hoeveel gram filament', false);
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
          'Wat', c.w40, _textDescriptionCtrl, '', false),
    );
  }

//-----------------------------------------
  List<Widget> _buildTextFieldRowWidgets(String label, double width,
      TextEditingController controller, String hintText, bool readonly) {
    List<Widget> result = [
      SizedBox(
        width: c.w1,
        child: Text('$label :'),
      ),
      wh.horSpace(10),
      SizedBox(
        width: width,
        child: TextField(
          readOnly: readonly,
          controller: controller,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[300],
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 1, vertical: 1),
            isDense: true,
            hintText: hintText,
            // border: InputBorder.none,
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

  //----------------------------------------
  Widget _buildBottomMsg() {
    return const Text(
      'Nog niet alle verplichte velden zijn ingevuld',
      style: TextStyle(color: Colors.orange),
    );
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
            onPressed: () => Navigator.pop(context, "value")),
      ],
    );
  }
}
