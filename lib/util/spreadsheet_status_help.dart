import 'package:dwpn_3dcnc_rooster/data/app_data.dart';
import 'package:dwpn_3dcnc_rooster/model/app_models.dart';

String helpText() {
  if (AppData.instance.getSpreadsheet().status == SpreadsheetStatus.active) {
    return _helpActive;
  } else if (AppData.instance.getSpreadsheet().status ==
      SpreadsheetStatus.underConstruction) {
    return _helpUnderConstruction;
  }
  return _helpUnknown;
}

String _helpActive = '''
Actief betekend dat dit schema al definitief is gemaakt.
todo verder uitwerken
''';

String _helpUnderConstruction = '''
Onderhanden betekent dat dit schema nog niet definitief is.

''';

String _helpUnknown = '''
Onbekende status,
neem contact op met beheerder want dit zou niet mogelijk moeten zijn.
''';
