import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dwpn_3dcnc_rooster/data/app_data.dart';
import 'package:dwpn_3dcnc_rooster/data/populate_data.dart' as p;
import 'package:dwpn_3dcnc_rooster/event/app_events.dart';
import 'package:dwpn_3dcnc_rooster/model/app_models.dart';
import 'package:dwpn_3dcnc_rooster/service/dbs.dart';
import 'package:dwpn_3dcnc_rooster/util/app_mixin.dart';
import 'package:stack_trace/stack_trace.dart';

enum FsCol {
  logs,
  users,
  schemas,
  spreadsheets,
  mail,
  metadata,
  error;
}

final User administrator = p.userBill;

class FirestoreHelper with AppMixin implements Dbs {
  FirestoreHelper._();
  static final FirestoreHelper instance = FirestoreHelper._();

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  /// find Trainer

  ///--------------------------------------------

  @override
  Future<List<User>> getAllUsers() async {
    List<User> result = [];

    CollectionReference colRef = collectionRef(FsCol.users);
    late QuerySnapshot querySnapshot;

    try {
      querySnapshot = await colRef.get();
      for (var doc in querySnapshot.docs) {
        var map = doc.data() as Map<String, dynamic>;
        map['id'] = doc.id;
        User trainer = User.fromMap(map);
        result.add(trainer);
      }
    } catch (e, stackTrace) {
      handleError(e, stackTrace);
    }

    return result;
  }

  ///--------------------------
  @override
  Future<User> createOrUpdateUser(trainer) async {
    User result = User.empty();

    CollectionReference colRef = collectionRef(FsCol.users);

    try {
      Map<String, dynamic> map = trainer.toMap();
      await colRef.doc(trainer.pk).set(map);
      result = trainer;
      _handleSucces(LogAction.modifySettings);
    } catch (e, stackTrace) {
      handleError(e, stackTrace);
    }

    return result;
  }

  ///--------------------------
  @override
  Future<void> saveSpreadsheet(SpreadSheet spreadSheet) async {
    CollectionReference colRef = collectionRef(FsCol.spreadsheets);

    String docId = '${spreadSheet.year}_${spreadSheet.month}';
    try {
      await colRef.doc(docId).set(spreadSheet.toMap());
    } catch (e, stackTrace) {
      handleError(e, stackTrace);
    }
  }

  //-----------------------------------------
  @override
  Future<List<SpreadSheet>> getActiveSpreadsheets(
      {required int year, required int month}) async {
    List<SpreadSheet> result = [];
    CollectionReference colRef = collectionRef(FsCol.spreadsheets);

    late QuerySnapshot querySnapshot;
    try {
      querySnapshot = await colRef
          .where("year", isEqualTo: year)
          .where("month", isGreaterThanOrEqualTo: month)
          .get();
      for (var docSnapshot in querySnapshot.docs) {
        result.add(
            SpreadSheet.fromMap(docSnapshot.data() as Map<String, dynamic>));
      }
    } catch (ex, stackTrace) {
      handleError(ex, stackTrace);
    }

    return result;
  }

  ///-------- sendEmail
  @override
  Future<bool> sendEmail(
      {required List<User> toList,
      required List<User> ccList,
      required String subject,
      required String html}) async {
    bool result = false;
    // CollectionReference colRef = collectionRef(FsCol.mail);

    Map<String, dynamic> map = {};
    map['to'] = _buildEmailAdresList(toList);
    map['cc'] = _buildEmailAdresList(ccList);
    map['message'] = _buildEmailMessageMap(subject, html);

    // await colRef
    //     .add(map)
    //     .then((DocumentReference doc) => result = true)
    //     .onError((e, _) {
    //   lp('Error in sendEmail $e');
    //   return false;
    // });

    return result;
  }

  ///--------------------------

  @override
  Future<void> saveDevices(List<Device> devices) async {
    CollectionReference colRef = collectionRef(FsCol.metadata);

    List<Map<String, dynamic>> groupsMap = [];
    for (Device device in devices) {
      groupsMap.add(device.toMap());
    }
    Map<String, dynamic> map = {'devices': groupsMap};

    await colRef.doc('devices').set(map).then((val) {}).catchError((e) {
      lp('Error in saveDevices $e');
      throw e;
    });
  }

  @override
  Future<List<Device>> getAllDevices() async {
    List<Device> result = [];
    CollectionReference colRef = collectionRef(FsCol.metadata);

    late DocumentSnapshot snapshot;
    try {
      snapshot = await colRef.doc('devices').get();
      if (snapshot.exists) {
        Map<String, dynamic> map = snapshot.data() as Map<String, dynamic>;
        List<dynamic> data = List<dynamic>.from(map['devices'] as List);
        result = data.map((e) => Device.fromMap(e)).toList();
      }
    } catch (ex, stackTrace) {
      handleError(ex, stackTrace);
    }

    return result;
  }

  @override
  Future<List<WeekdaySlot>> getAllWeekdaySlots() async {
    List<WeekdaySlot> result = [];
    CollectionReference colRef = collectionRef(FsCol.metadata);

    late DocumentSnapshot snapshot;
    try {
      snapshot = await colRef.doc('weekday_slots').get();
      if (snapshot.exists) {
        Map<String, dynamic> map = snapshot.data() as Map<String, dynamic>;
        List<dynamic> data = List<dynamic>.from(map['slots'] as List);
        result = data.map((e) => WeekdaySlot.fromMap(e)).toList();
      }
    } catch (ex, stackTrace) {
      handleError(ex, stackTrace);
    }

    return result;
  }

  @override
  Future<void> saveReservation(Reservation reservation, bool add) async {
    CollectionReference colRef = collectionRef(FsCol.spreadsheets);

    DateTime date = AppData.instance.getActiveDate();
    String docId = '${date.year}_${date.month}';
    var reservationsRef = colRef.doc(docId);

    String reservationId = reservation.toDbsId();
    try {
      if (add) {
        reservationsRef.update({
          "reservations": FieldValue.arrayUnion([reservationId])
        });
      } else {
        reservationsRef.update({
          "reservations": FieldValue.arrayRemove([reservationId])
        });
      }
    } catch (e, stackTrace) {
      handleError(e, stackTrace);
    }
  }

  @override
  Future<void> saveWeekdaySlots(List<WeekdaySlot> weekdaySlots) async {
    CollectionReference colRef = collectionRef(FsCol.metadata);

    List<Map<String, dynamic>> slotsMap = [];
    for (WeekdaySlot device in weekdaySlots) {
      slotsMap.add(device.toMap());
    }
    Map<String, dynamic> map = {'slots': slotsMap};

    await colRef.doc('weekday_slots').set(map).then((val) {}).catchError((e) {
      lp('Error in saveWeekdaySlots $e');
      throw e;
    });
  }

  ///============ private methods --------

  Map<String, dynamic> _buildEmailMessageMap(String subject, String html) {
    Map<String, dynamic> msgMap = {};
    msgMap['subject'] = subject;
    msgMap['html'] = html;
    return msgMap;
  }

  List<String> _buildEmailAdresList(List<User> trainerList) {
    List<String> toList = [];
    for (User trainer in trainerList) {
      if (trainer.email.isNotEmpty) {
        toList.add(trainer.email);
      }
    }

    if (AppData.instance.runMode != RunMode.prod) {
      toList = [administrator.email];
    }

    return toList;
  }

  void _saveError(String errMsg, String trace) {
    CollectionReference colRef = collectionRef(FsCol.error);

    Map<String, dynamic> map = {
      'at': DateTime.now(),
      'err': errMsg,
      'trace': trace,
    };

    String id = _uniqueDocId();
    colRef.doc(id).set(map);
  }

  ///--------------------------------------------
  void handleError(Object? ex, StackTrace stackTrace) {
    String traceMsg = _buildTraceMsg(stackTrace);
    _saveError(ex.toString(), traceMsg);

    String by = AppData.instance.getUser().isEmpty()
        ? ''
        : ' by ${AppData.instance.getUser().pk}';

    String html = '<div>Error detected $by : $ex <br> $traceMsg</div>';
    sendEmail(
        toList: [administrator], ccList: [], subject: 'Error', html: html);

    AppEvents.fireErrorEvent(ex.toString());
  }

  String _buildTraceMsg(StackTrace stackTrace) {
    String traceMsg = '';
    Trace trace = Trace.from(stackTrace).terse;
    List<Frame> frames = trace.frames;
    for (Frame frame in frames) {
      String s = frame.toString();
      if (s.contains('rooster')) {
        traceMsg += '$s;';
      }
    }
    return traceMsg;
  }

  ///----------------
  void _handleSucces(LogAction logAction) {
    Map<String, dynamic> map = {
      'at': DateTime.now(),
      'action': logAction.index
    };

    CollectionReference colRef = collectionRef(FsCol.logs);
    String id = _uniqueDocId();
    colRef.doc(id).set(map);
  }

  ///----------------
  String _uniqueDocId() {
    String id =
        '${AppData.instance.getUser().pk}-${DateTime.now().microsecondsSinceEpoch}';
    return id;
  }

  ///--------------------------------------------
  CollectionReference collectionRef(FsCol fsCol) {
    String collectionName = AppData.instance.runMode == RunMode.prod
        ? fsCol.name
        : '${fsCol.name}_acc';

    if (collectionName.startsWith('mail')) {
      collectionName = 'mail';
    }

    return firestore.collection(collectionName);
  }
}
