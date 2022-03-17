import 'dart:developer';
import 'package:winaday/journey/persistence.dart';
import 'package:logging/logging.dart';

import 'domain.dart';
import 'rest.dart';
import 'dateutil.dart';

Session? currentSession;

class Journey {
  /// Initializes new session.
  /// [accountId] is your account id
  /// [appId] is your application id
  /// [version] is the application version (e.g. 1.2.3)
  /// Use packageInfo.version to access version.
  /// [isRelease] is to separate debug sessions from release sessions.
  /// Use kReleaseMode to access mode.
  static Future<void> initialize(
      String accountId, String appId, String version, bool isRelease) async {
    try {
      // start new session synchronously
      currentSession = Session(accountId, appId, version, isRelease);
      log('Journey3: Started new session ${currentSession!.id}',
          level: Level.INFO.value);

      // report previous session
      log('Journey3: Report last saved session', level: Level.INFO.value);
      final session = await loadLastSession();
      if (session != null) {
        await postSession(session);
      }

      // configure current session based on previous session
      if (session == null) {
        currentSession!.firstLaunch = true;
      } else {
        var today = DateTime.now();
        var lastSessionStart = session.start;
        if (!lastSessionStart.isSameDay(today)) {
          currentSession!.firstLaunchToday = true;
        }
        if (!lastSessionStart.isSameMonth(today)) {
          currentSession!.firstLaunchThisMonth = true;
        }
        if (!lastSessionStart.isSameYear(today)) {
          currentSession!.firstLaunchThisYear = true;
        }
        if (session.version != version) {
          currentSession!.firstLaunchThisVersion = true;
        }
      }

      // save current session
      await saveSession(currentSession!);
    } catch (err) {
      log('Journey3: Failed to initialize Journey: ${err.toString()}');
    }
  }

  /// Registers the event in the current session.
  ///
  /// Events are distinguished by [eventName], for example 'click_play',
  /// 'add_to_library' or 'use_search'.
  /// Short and clear names are recommended.
  ///
  /// Do not include any personal data as an event name.
  ///
  /// Specify whether event [isCollapsible].
  /// Collapsible events will only appear in the sequence once.
  /// Make events collapsible when number of times it is repeated is not
  /// important. For example, if your application is music play app, where the
  /// users normally browse through the list of albums before clicking 'play',
  /// 'scroll_to_next_album' event would probably be a good candidate to be
  /// made collapsible, while 'click_play' event would probably not.
  ///
  /// Collapsible event names appear in brackets in the sequence,
  /// for example '(scroll_to_next_album)'.
  static Future<void> reportEvent(String eventName,
      {bool isCollapsible = false, bool isError = false}) async {
    if (currentSession == null) {
      log('Journey3: Cannot update session. Journey have not been initialized.');
      return;
    }

    // TODO: maybe queue the events until session is initialized?
    try {
      // count events
      currentSession!.eventCounts[eventName] =
          (currentSession!.eventCounts[eventName] ?? 0) + 1;

      // set error
      if (isError) {
        currentSession!.hasError = true;
      }

      // sequence events
      var seq = currentSession!.eventSequence;
      var seqEventName = isCollapsible ? '($eventName)' : eventName;
      if (!(seq.isNotEmpty && seq.last == seqEventName && isCollapsible)) {
        seq.add(seqEventName);
      } else {
        // ignore the event for the sequence
      }

      // update endtime
      currentSession!.end = DateTime.now().toUtc();

      // save session
      await saveSession(currentSession!);
    } catch (err) {
      log('Journey3: Cannot update session: ${err.toString()}');
    }
  }
}
