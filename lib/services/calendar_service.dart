import 'package:device_calendar_plus/device_calendar_plus.dart';

class CalendarService {
  static final DeviceCalendar _calendar =
      DeviceCalendar.instance;

  static Future<bool> requestPermission() async {
    try {
      final status =
          await _calendar.requestPermissions();

      return status ==
          CalendarPermissionStatus.granted;
    } catch (_) {
      return false;
    }
  }

  static Future<List<Calendar>> getCalendars() async {
    final hasPermission =
        await requestPermission();

    if (!hasPermission) {
      return [];
    }

    try {
      return await _calendar.listCalendars();
    } catch (_) {
      return [];
    }
  }

  static Future<List<Event>> getUpcomingEvents() async {
    final hasPermission =
        await requestPermission();

    if (!hasPermission) {
      return [];
    }

    try {
      final now = DateTime.now();

      //
      // Pradedame nuo šiandienos pradžios,
      // kad gautume ir jau prasidėjusius,
      // bet dar nepasibaigusius įvykius.
      //
      final start = DateTime(
        now.year,
        now.month,
        now.day,
      );

      final end = now.add(
        const Duration(days: 7),
      );

      final events = await _calendar.listEvents(
        start,
        end,
      );

      final relevantEvents =
          events.where((event) {
        //
        // Visos dienos įvykiai, pvz.
        // gimtadieniai, neužblokuoja
        // visos dienos.
        //
        if (event.isAllDay) {
          return false;
        }

        //
        // Atšauktų įvykių nenaudojame.
        //
        if (event.status ==
            EventStatus.canceled) {
          return false;
        }

        final endDate = event.endDate;

        //
        // Paliekame įvykį, jeigu jis
        // dar nėra pasibaigęs.
        //
        return endDate.isAfter(now);
      }).toList();

      relevantEvents.sort(
        (a, b) => a.startDate.compareTo(
          b.startDate,
        ),
      );

      return relevantEvents;
    } catch (_) {
      return [];
    }
  }

  static Future<Event?> getNextEvent() async {
    final events =
        await getUpcomingEvents();

    if (events.isEmpty) {
      return null;
    }

    final now = DateTime.now();

    //
    // Pirmiausia tikriname,
    // ar kažkas vyksta DABAR.
    //
    for (final event in events) {
      final start = event.startDate;
      final end = event.endDate;

      final isHappeningNow =
          !now.isBefore(start) &&
              now.isBefore(end);

      if (isHappeningNow) {
        return event;
      }
    }

    //
    // Jei dabar nieko nevyksta,
    // grąžiname artimiausią
    // būsimą įvykį.
    //
    for (final event in events) {
      if (event.startDate.isAfter(now)) {
        return event;
      }
    }

    return null;
  }

  static Future<int?>
      getMinutesUntilNextEvent() async {
    final event =
        await getNextEvent();

    if (event == null) {
      return null;
    }

    final now = DateTime.now();

    //
    // Jei įvykis jau vyksta,
    // laisvo laiko iki jo nėra.
    //
    if (!now.isBefore(event.startDate) &&
        now.isBefore(event.endDate)) {
      return 0;
    }

    final minutes = event.startDate
        .difference(now)
        .inMinutes;

    if (minutes <= 0) {
      return 0;
    }

    return minutes;
  }
}