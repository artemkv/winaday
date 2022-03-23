import 'package:uuid/uuid.dart';

const uuid = Uuid();

class SessionHeader {
  final String v = "1.0.0";

  final String id;
  final String accountId;
  final String appId;
  final String version;
  final bool isRelease;

  final DateTime start;
  DateTime since;

  bool firstLaunch = false;
  bool firstLaunchThisHour = false;
  bool firstLaunchToday = false;
  bool firstLaunchThisMonth = false;
  bool firstLaunchThisYear = false;
  bool firstLaunchThisVersion = false;

  SessionHeader(this.accountId, this.appId, this.version, this.isRelease)
      : id = uuid.v4(),
        start = DateTime.now().toUtc(),
        since = DateTime.now().toUtc();

  Map<String, dynamic> toJson() => {
        'v': v,
        'id': id,
        'since': since.toIso8601String(),
        'start': start.toIso8601String(),
        'acc': accountId,
        'aid': appId,
        'version': version,
        'is_release': isRelease,
        'fst_launch': firstLaunch,
        'fst_launch_hour': firstLaunchThisHour,
        'fst_launch_day': firstLaunchToday,
        'fst_launch_month': firstLaunchThisMonth,
        'fst_launch_year': firstLaunchThisYear,
        'fst_launch_version': firstLaunchThisVersion,
      };
}

// TODO: maybe ts should be received encoded from server
class Session {
  final String v = "1.0.0";

  final String id;
  final String accountId;
  final String appId;
  final String version;
  final bool isRelease;

  final DateTime start;
  DateTime end;
  DateTime since;

  Stage prevStage = Stage.empty();
  Stage newStage = Stage.empty();

  bool hasError = false;
  Map<String, int> eventCounts =
      {}; // TODO: limit on number of different events?
  List<String> eventSequence = []; // TODO: limit on number of events?

  Session(this.id, this.accountId, this.appId, this.version, this.isRelease,
      this.start)
      : end = start,
        since = start;

  Session.fromJson(Map<String, dynamic> json)
      : id = json['id'] ?? uuid.v4(),
        since =
            (json['since'] == null || DateTime.tryParse(json['since']) == null)
                ? DateTime.now().toUtc()
                : DateTime.tryParse(json['since'])!,
        start =
            (json['start'] == null || DateTime.tryParse(json['start']) == null)
                ? DateTime.now().toUtc()
                : DateTime.tryParse(json['start'])!,
        end = (json['end'] == null || DateTime.tryParse(json['end']) == null)
            ? DateTime.now().toUtc()
            : DateTime.tryParse(json['end'])!,
        accountId = json['acc'] ?? '',
        appId = json['aid'] ?? '',
        version = json['version'] ?? '',
        isRelease = json['is_release'] ?? false,
        hasError = json['has_error'] ?? false,
        eventCounts =
            json['evts'] != null ? json['evts'].cast<String, int>() : {},
        eventSequence =
            json['evt_seq'] != null ? json['evt_seq'].cast<String>() : [],
        prevStage = json['prev_stage'] != null
            ? Stage.fromJson(json['prev_stage'])
            : Stage.empty(),
        newStage = json['new_stage'] != null
            ? Stage.fromJson(json['new_stage'])
            : Stage.empty();

  Map<String, dynamic> toJson() => {
        'v': v,
        'id': id,
        'since': since.toIso8601String(),
        'start': start.toIso8601String(),
        'end': end.toIso8601String(),
        'acc': accountId,
        'aid': appId,
        'version': version,
        'is_release': isRelease,
        'has_error': hasError,
        'evts': eventCounts,
        'evt_seq': eventSequence,
        'prev_stage': prevStage,
        'new_stage': newStage,
      };
}

class Stage {
  final DateTime ts;
  final int stage;
  final String name;

  Stage(this.stage, this.name) : ts = DateTime.now().toUtc();

  Stage.empty()
      : stage = 1,
        name = "new_user",
        ts = DateTime.now().toUtc();

  Stage.fromJson(Map<String, dynamic> json)
      : ts = DateTime.tryParse(json['ts']) ?? DateTime.now().toUtc(),
        stage = json['stage'] ?? 1,
        name = json['name'] ?? 'new_user';

  Map<String, dynamic> toJson() => {
        'ts': ts.toIso8601String(),
        'stage': stage,
        'name': name,
      };
}

class ApiResponseError {
  final String error;

  ApiResponseError(this.error);

  ApiResponseError.fromJson(Map<String, dynamic> json) : error = json['err'];

  @override
  String toString() {
    return 'Error: $error';
  }
}
