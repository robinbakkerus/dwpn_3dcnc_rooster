import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dwpn_3dcnc_rooster/data/populate_data.dart' as p;
import 'package:dwpn_3dcnc_rooster/model/app_models.dart';
import 'package:dwpn_3dcnc_rooster/repo/firestore_helper.dart';
import 'package:dwpn_3dcnc_rooster/service/dbs.dart';
import 'package:dwpn_3dcnc_rooster/util/app_mixin.dart';
import 'package:flutter/material.dart';
import 'package:universal_html/html.dart' as html;

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> with AppMixin {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          OutlinedButton(onPressed: _addUsers, child: const Text('Add users')),
          OutlinedButton(
              onPressed: _removeCookie, child: const Text('Remove cookie')),
          OutlinedButton(
              onPressed: _addMetaData, child: const Text('Add MetaData')),
          OutlinedButton(
              onPressed: _addReservations,
              child: const Text('Add Reservations')),
          OutlinedButton(
              onPressed: _deleteOldLogs, child: const Text('Delete old logs')),
          OutlinedButton(
              onPressed: _deleteOldErrors,
              child: const Text('Delete old errors')),

          OutlinedButton(
              onPressed: _sendEmail, child: const Text('Send email')),
          // OutlinedButton(
          //     onPressed: _sendAccessCodes,
          //     child: const Text('Email accesscodes')),
          OutlinedButton(
              onPressed: _signUpOrSignIn, child: const Text('SignUp')),
        ],
      ),
    );
  }

  void _addUsers() {
    List<User> users = _allUsers();

    for (User trainer in users) {
      Dbs.instance.createOrUpdateUser(trainer);
    }
  }

  List<User> _allUsers() {
    List<User> users = [p.userBill, p.userElon, p.userMarc, p.userJeff];
    return users;
  }

  void _removeCookie() {
    html.document.cookie = "ac=";
  }

  void _deleteOldLogs() async {
    CollectionReference logRef =
        FirestoreHelper.instance.collectionRef(FsCol.logs);
    bool firstOne =
        true; // dont remove all logs becauce then de whole table is gone
    await logRef.get().then((querySnapshot) {
      for (var doc in querySnapshot.docs) {
        if (!firstOne) {
          doc.reference.delete();
        }
        firstOne = false;
      }
    });
  }

  void _deleteOldErrors() async {
    CollectionReference logRef =
        FirestoreHelper.instance.collectionRef(FsCol.error);
    bool firstOne =
        true; // dont remove all logs becauce then de whole table is gone
    await logRef.get().then((querySnapshot) {
      for (var doc in querySnapshot.docs) {
        if (!firstOne) {
          doc.reference.delete();
        }
        firstOne = false;
      }
    });
  }

  void _sendEmail() async {
    List<User> toUsers = [p.userBill];
    String html = '<p>Test</p>';
    Dbs.instance
        .sendEmail(toList: toUsers, ccList: [], subject: 'subject', html: html);
  }

  // void _sendAccessCodes() async {
  //   // for (Trainer trainer in _allUsers()) {
  //   for (Trainer trainer in p.allUsers) {
  //     String html = _accessCodeHtml(trainer);
  //     Dbs.instance.sendEmail(
  //         toList: [trainer], ccList: [], subject: 'Toegangscode', html: html);
  //   }
  // }

  void _signUpOrSignIn() async {
    //   for (Trainer trainer in _allUsers()) {
    //     AuthHelper.instance.signUp(
    //         email: trainer.email,
    //         password: AppHelper.instance.getAuthPassword(trainer));
    //   }
  }

  void _addMetaData() async {
    List<Device> groups = p.allDevices();
    Dbs.instance.saveDevices(groups);

    List<WeekdaySlot> slots = p.allWeekDaySlots();
    Dbs.instance.saveWeekdaySlots(slots);
  }

  void _addReservations() async {
    List<Reservation> reservations = p.allReservationsMaart();
    for (Reservation reservation in reservations) {
      Dbs.instance.saveReservation(reservation, true);
    }
  }

  //------------------ private -------------------------

  String accessCodeHtml(User trainer) {
    String html = '<div>';
    html += 'Hallo ${trainer.firstName()}<br><br>';
    html +=
        'Je kunt vanaf nu verhindering doorgeven via deze url: <b>https://lonutrainingschema.web.app</b> <br>';
    html += 'Je toegangscode is: <b>${trainer.accessCode}</b> <br><br>';
    html += 'Een korte uitleg vind je hier: <br>';
    html +=
        '<b>https://drive.google.com/file/d/1P1VRW5GXnh7jFimqcddL_0VJlvLq3Qrs/view?usp=sharing</b> <br><br>';

    html += 'Gr Robin <br>';
    return '$html</div>';
  }
}
