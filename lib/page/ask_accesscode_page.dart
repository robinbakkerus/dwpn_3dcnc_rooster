import 'package:dwpn_3dcnc_rooster/controller/app_controler.dart';
import 'package:dwpn_3dcnc_rooster/data/app_data.dart';
import 'package:dwpn_3dcnc_rooster/event/app_events.dart';
import 'package:dwpn_3dcnc_rooster/util/app_mixin.dart';
import 'package:flutter/material.dart';
import 'package:dwpn_3dcnc_rooster/widget/send_accesscode_widget.dart';

class AskAccessCodePage extends StatefulWidget {
  const AskAccessCodePage({super.key});

  @override
  State<AskAccessCodePage> createState() => _AskAccessCodePageState();
}

class _AskAccessCodePageState extends State<AskAccessCodePage> with AppMixin {
  final List<TextEditingController> _textCtrls = [];
  final List<FocusNode> _focusNodes = [];

  bool _findTriggered = false;

  @override
  void initState() {
    _setup();
    AppEvents.onLogoutEvent(_onLogOut);
    super.initState();
  }

  void _setup() {
    for (int i = 0; i < 4; i++) {
      _textCtrls.add(TextEditingController());
      _textCtrls[i].addListener(_onTextFieldChanged);
      _focusNodes.add(FocusNode());
    }
  }

  @override
  void dispose() {
    for (int i = 0; i < _textCtrls.length; i++) {
      _textCtrls[i].dispose();
      _focusNodes[i].dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget scaffold = _buildScaffold();
    return scaffold;
  }

  Widget _buildScaffold() {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: SizedBox(
          width: AppData.instance.screenWidth,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                    '''Je kunt in dit prototype een van de volgende toegangscodes invoeren:\n
                BILL  JEFF  MARK  ELON\n\n'''),
                const Text('Vul je toegangscode in'),
                Container(
                  height: 20,
                ),
                SizedBox(
                  width: 500,
                  height: 100,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildTextField(0),
                      _buildTextField(1),
                      _buildTextField(2),
                      _buildTextField(3),
                    ],
                  ),
                ),
                wh.verSpace(10),
                TextButton(
                    onPressed: _onSendAccessCode,
                    child: const Text(
                      'Toegangscode vergeten ?',
                      style: TextStyle(color: Colors.red),
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(int index) {
    if (_textCtrls.isEmpty) {
      return const SizedBox.shrink();
    }

    bool autoFocus = index == 0;
    TextEditingController ctrl = _textCtrls[index];
    return SizedBox(
      width: 60,
      height: 60,
      child: Center(
        child: TextField(
          autofocus: autoFocus,
          textAlign: TextAlign.center,
          textAlignVertical: TextAlignVertical.top,
          focusNode: _focusNodes[index],
          controller: _textCtrls[index],
          textCapitalization: TextCapitalization.characters,
          onChanged: (value) {
            if (ctrl.text != value.toUpperCase()) {
              ctrl.value = ctrl.value.copyWith(text: value.toUpperCase());
            }

            if (index < 3 && ctrl.text.isNotEmpty) {
              _focusNodes[index + 1].requestFocus();
            }
          },
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 35),
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
        ),
      ),
    );
  }

  void _onTextFieldChanged() async {
    String text = '';
    for (TextEditingController ctrl in _textCtrls) {
      text += ctrl.text;
    }
    if (text.length == 4 && !_findTriggered) {
      String accessCode = text.toUpperCase();
      await _findActiveUser(accessCode);
    }
  }

  Future<void> _findActiveUser(String accesscode) async {
    _findTriggered = true;
    bool flag = await AppController.instance.findUser(accesscode);
    _findTriggered = false;
    if (!flag) {
      final String msg =
          'Kan geen trainer met toegangscode $accesscode vinden!';
      wh.showSnackbar(msg, color: Colors.orange);
    }
  }

  void _onSendAccessCode() {
    Widget closeButton = TextButton(
      onPressed: () {
        Navigator.of(context, rootNavigator: true)
            .pop(); // dismisses only the dialog and returns nothing
      },
      child: const Text("Close"),
    ); // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: const Text('Stuur toegangscode'),
      content: const SizedBox(
        height: 150,
        child: SendAccessCodeWidget(),
      ),
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

  void _onLogOut(LogoutEvent event) {
    for (TextEditingController ctrl in _textCtrls) {
      ctrl.text = '';
    }
  }
}
