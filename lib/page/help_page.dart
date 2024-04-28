import 'package:flutter/material.dart';
import 'package:dwpn_3dcnc_rooster/data/app_version.dart';
import 'package:dwpn_3dcnc_rooster/util/app_mixin.dart';
import 'package:url_launcher/link.dart';
import 'package:universal_html/html.dart' as html;

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
                      'http://www.dorpswerkplaatsnuenen.nl/site/wp-content/uploads/2024/02/Handleiding-3D-CNC-rooster.mp4'),
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
          wh.verSpace(10),
          OutlinedButton(
              onPressed: _removeCookie, child: const Text('Remove cookie')),
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

  ///----------------------------
  void _removeCookie() {
    html.document.cookie = "ac=";
  }
}
