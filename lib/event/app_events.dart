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

class TrainerReadyEvent {}

class TrainerDataReadyEvent {}

class SchemaUpdatedEvent {}

// event that is send from widget with radiobuttons, to tell parent page that some value is changed
class TrainerUpdatedEvent {
  User trainer;
  TrainerUpdatedEvent({
    required this.trainer,
  });
}

class SpreadsheetReadyEvent {}

class DatesReadyEvent {}

class ExtraDayUpdatedEvent {
  final int dag;
  final String text;

  ExtraDayUpdatedEvent(this.dag, this.text);
}

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

class TrainerPrefUpdatedEvent {
  final String paramName;
  final int newValue;

  TrainerPrefUpdatedEvent(
    this.paramName,
    this.newValue,
  );
}

class ErrorEvent {
  final String errMsg;
  ErrorEvent(
    this.errMsg,
  );
}

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

  static void fireTrainerReady() => _sEventBus.fire(TrainerReadyEvent());

  static void fireTrainerDataReady() =>
      _sEventBus.fire(TrainerDataReadyEvent());

  static void fireSchemaUpdated() => _sEventBus.fire(SchemaUpdatedEvent());
  static void fireTrainerUpdated(User trainer) =>
      _sEventBus.fire(TrainerUpdatedEvent(trainer: trainer));

  static void fireSpreadsheetReady() =>
      _sEventBus.fire(SpreadsheetReadyEvent());

  static void fireDatesReady() => _sEventBus.fire(DatesReadyEvent());

  static void fireExtraDayUpdatedEvent(int dag, String text) =>
      _sEventBus.fire(ExtraDayUpdatedEvent(dag, text));

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

  static void fireTrainerPrefUpdated(String paramName, int newValue) =>
      _sEventBus.fire(TrainerPrefUpdatedEvent(paramName, newValue));

  static void fireErrorEvent(String errMsg) =>
      _sEventBus.fire(ErrorEvent(errMsg));

  ///----- static onXxx methods --------
  static void onShowPage(OnShowPageFunc func) =>
      _sEventBus.on<ShowPageEvent>().listen((event) => func(event));

  static void onTrainerReadyEvent(OnTrainerReadyEventFunc func) =>
      _sEventBus.on<TrainerReadyEvent>().listen((event) => func(event));

  static void onTrainerDataReadyEvent(OnTrainerDataReadyEventFunc func) =>
      _sEventBus.on<TrainerDataReadyEvent>().listen((event) => func(event));

  static void onSchemaUpdatedEvent(OnSchemaUpdateEventFunc func) =>
      _sEventBus.on<SchemaUpdatedEvent>().listen((event) => func(event));

  static void onTrainerUpdatedEvent(OnTrainerUpdatedEventFunc func) =>
      _sEventBus.on<TrainerUpdatedEvent>().listen((event) => func(event));

  static void onSpreadsheetReadyEvent(OnSpreadsheetReadyEventFunc func) =>
      _sEventBus.on<SpreadsheetReadyEvent>().listen((event) => func(event));

  static void onDatesReadyEvent(OnDatesReadyEventFunc func) =>
      _sEventBus.on<DatesReadyEvent>().listen((event) => func(event));

  static void onExtraDayUpdatedEvent(OnExtraDayUpdatedEventFunc func) =>
      _sEventBus.on<ExtraDayUpdatedEvent>().listen((event) => func(event));

  static void onReservationEvent(OnReservationEventFunc func) =>
      _sEventBus.on<ReservationEvent>().listen((event) => func(event));

  static void onTrainerPrefUpdatedEvent(OnTrainerPrefUpdatedEventFunc func) =>
      _sEventBus.on<TrainerPrefUpdatedEvent>().listen((event) => func(event));

  static void onErrorEvent(OnErrorEventFunc func) =>
      _sEventBus.on<ErrorEvent>().listen((event) => func(event));
}

/// ----- typedef's -----------
typedef OnShowPageFunc = void Function(ShowPageEvent event);

typedef OnTrainerReadyEventFunc = void Function(TrainerReadyEvent event);

typedef OnTrainerDataReadyEventFunc = void Function(
    TrainerDataReadyEvent event);

typedef OnSchemaUpdateEventFunc = void Function(SchemaUpdatedEvent event);

typedef OnTrainerUpdatedEventFunc = void Function(TrainerUpdatedEvent event);

typedef OnSpreadsheetReadyEventFunc = void Function(
    SpreadsheetReadyEvent event);

typedef OnDatesReadyEventFunc = void Function(DatesReadyEvent event);

typedef OnExtraDayUpdatedEventFunc = void Function(ExtraDayUpdatedEvent event);
typedef OnReservationEventFunc = void Function(ReservationEvent event);

typedef OnTrainerPrefUpdatedEventFunc = void Function(
    TrainerPrefUpdatedEvent event);

typedef OnErrorEventFunc = void Function(ErrorEvent event);
