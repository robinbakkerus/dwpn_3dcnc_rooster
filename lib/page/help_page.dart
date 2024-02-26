import 'package:flutter/material.dart';
import 'package:dwpn_3dcnc_rooster/data/app_version.dart';
import 'package:dwpn_3dcnc_rooster/util/app_mixin.dart';
import 'package:url_launcher/link.dart';

class HelpPage extends StatelessWidget with AppMixin {
  HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                  'Een korte video over het gebruik van deze app vind je'),
              Link(
                  uri: Uri.parse(
                      'https://drive.google.com/file/d/1P1VRW5GXnh7jFimqcddL_0VJlvLq3Qrs/view'),
                  target: LinkTarget.blank,
                  builder: (context, followLink) {
                    return TextButton(
                      onPressed: followLink,
                      child: const Text(
                        'hier',
                        style: TextStyle(color: Colors.blue),
                      ),
                    );
                  }),
            ],
          ),
          wh.verSpace(10),
          _buildFaq(),
          wh.verSpace(10),
          Text('Versie: $appVersion'),
        ],
      ),
    );
  }

  Widget _buildFaq() {
    return RichText(text: const TextSpan(text: _faq, children: []));
  }

  static const String _faq = '''
Faq TODO

''';
}
