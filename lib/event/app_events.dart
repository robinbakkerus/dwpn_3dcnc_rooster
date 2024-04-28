// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:dwpn_3dcnc_rooster/model/app_models.dart';
import 'package:event_bus/event_bus.dart';

/*
 * All Events are maintainded here.
 */
class ShowPageEvent {
  PageEnum page;
  ShowPageEvent(this.page);
}

class ActiveUserReadyEvent {}

class LogoutEvent {}

// event that is send from widget with radiobuttons, to tell parent page that some value is changed

class SpreadsheetReadyEvent {}

class ReservationEvent {
  final int day;
  final DaySlotEnum daySlotEnum;
  final String devicePk;
  final User user;
  final bool addReservation;
  ReservationEvent({
    required this.day,
    required this.daySlotEnum,
    required this.devicePk,
    required this.user,
    required this.addReservation,
  });
}

class ErrorEvent {
  final String errMsg;
  ErrorEvent(
    this.errMsg,
  );
}

class LogbookReadyEvent {}

/*
	Static class that contains all onXxx and fireXxx methods.
*/
class AppEvents {
  static final EventBus _sEventBus = EventBus();

  // Only needed if clients want all EventBus functionality.
  static EventBus ebus() => _sEventBus;

  /*
  * The methods below are just convenience shortcuts to make it easier for the client to use.
  */
  static void fireShowPage(PageEnum page) =>
      _sEventBus.fire(ShowPageEvent(page));

  static void fireActiveUserReady() => _sEventBus.fire(ActiveUserReadyEvent());

  static void fireLogOutEvent() => _sEventBus.fire(LogoutEvent());

  static void fireSpreadsheetReady() =>
      _sEventBus.fire(SpreadsheetReadyEvent());

  static void fireReservationEvent(
          {required int day,
          required DaySlotEnum daySlotEnum,
          required String devicePk,
          required User user,
          required bool addReservation}) =>
      _sEventBus.fire(ReservationEvent(
          day: day,
          daySlotEnum: daySlotEnum,
          devicePk: devicePk,
          user: user,
          addReservation: addReservation));

  static void fireErrorEvent(String errMsg) =>
      _sEventBus.fire(ErrorEvent(errMsg));

  static void fireLogbookReadyEvent() => _sEventBus.fire(LogbookReadyEvent());

  ///----- static onXxx methods --------
  static void onShowPage(OnShowPageFunc func) =>
      _sEventBus.on<ShowPageEvent>().listen((event) => func(event));

  static void onUserReadyEvent(OnTrainerReadyEventFunc func) =>
      _sEventBus.on<ActiveUserReadyEvent>().listen((event) => func(event));

  static void onLogoutEvent(OnLogoutEventFunc func) =>
      _sEventBus.on<LogoutEvent>().listen((event) => func(event));

  static void onSpreadsheetReadyEvent(OnSpreadsheetReadyEventFunc func) =>
      _sEventBus.on<SpreadsheetReadyEvent>().listen((event) => func(event));

  static void onReservationEvent(OnReservationEventFunc func) =>
      _sEventBus.on<ReservationEvent>().listen((event) => func(event));

  static void onErrorEvent(OnErrorEventFunc func) =>
      _sEventBus.on<ErrorEvent>().listen((event) => func(event));

  static void onLogbookReadyEvent(OnLogbookReadyEventFunc func) =>
      _sEventBus.on<LogbookReadyEvent>().listen((event) => func(event));
}

/// ----- typedef's -----------
typedef OnShowPageFunc = void Function(ShowPageEvent event);

typedef OnTrainerReadyEventFunc = void Function(ActiveUserReadyEvent event);

typedef OnLogoutEventFunc = void Function(LogoutEvent event);

typedef OnSpreadsheetReadyEventFunc = void Function(
    SpreadsheetReadyEvent event);

typedef OnReservationEventFunc = void Function(ReservationEvent event);

typedef OnErrorEventFunc = void Function(ErrorEvent event);

typedef OnLogbookReadyEventFunc = void Function(LogbookReadyEvent event);
