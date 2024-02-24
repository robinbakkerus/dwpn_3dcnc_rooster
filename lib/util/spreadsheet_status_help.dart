import 'package:dwpn_3dcnc_rooster/data/app_data.dart';
import 'package:dwpn_3dcnc_rooster/model/app_models.dart';

String helpText() {
  if (AppData.instance.getSpreadsheet().status == SpreadsheetStatus.active) {
    return _helpActive;
  } else if (AppData.instance.getSpreadsheet().status ==
      SpreadsheetStatus.underConstruction) {
    return _helpUnderConstruction;
  } else if (AppData.instance.getSpreadsheet().status ==
      SpreadsheetStatus.old) {
    return _helpOld;
  }
  return _helpUnknown;
}

String _helpActive = '''
Actief betekend dat dit schema al definitief is gemaakt.
Het is dan ook zichtbaar voor iedereen op de Lonu website.
Er kunnen geen verhinderingen meer worden opgegeven.
Maar er kunnen wel trainingen worden geruild.
''';

String _helpUnderConstruction = '''
Onderhanden betekent dat dit schema nog niet definitief is, het is ook nog niet zichtbaar op de Lonu Website. 
Het is voor deze maand nog mogelijk om voorkeuren en verhinderingen door te geven. 
Op basis van input van trainers zal dit programma willekeurig beschikbare trainers kiezen/wijzigen totdat het schema definitief is gemaakt. 

Neem de trainingen dus pas over in je eigen agenda als het schema definitief is!. 
''';

String _helpOld = '''
Verlopen betekend dat dit schema al lang definitief is.
Het heeft dan ook geen zin om aanpassingen te maken.
Dit schema zal op een gegeven moment van de website van Lonu verdwijnen.
''';

String _helpUnknown = '''
Onbekende status,
neem contact op met beheerder want dit zou niet mogelijk moeten zijn.
''';
