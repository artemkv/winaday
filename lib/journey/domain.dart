import 'package:uuid/uuid.dart';

const uuid = Uuid();

// TODO: maybe ts should be received encoded from server
class Session {
  final String id;
  final DateTime start;
  final String accountId;
  final String appId;
  final String version;
  final bool isRelease;

  DateTime end;

  bool firstLaunch = false;
  bool firstLaunchThisHour = false;
  bool firstLaunchToday = false;
  bool firstLaunchThisMonth = false;
  bool firstLaunchThisYear = false;
  bool firstLaunchThisVersion = false;

  bool hasError = false;
  Map<String, int> eventCounts =
      {}; // TODO: limit on number of different events?
  List<String> eventSequence = []; // TODO: limit on number of events?

  Session(this.accountId, this.appId, this.version, this.isRelease)
      : id = uuid.v4(),
        start = DateTime.now().toUtc(),
        end = DateTime.now().toUtc();

  Session.fromJson(Map<String, dynamic> json)
      : id = json['id'] ?? uuid.v4(),
        start = DateTime.tryParse(json['start']) ?? DateTime.now().toUtc(),
        end = DateTime.tryParse(json['end']) ?? DateTime.now().toUtc(),
        accountId = json['acc'] ?? '',
        appId = json['aid'] ?? '',
        version = json['version'] ?? '',
        isRelease = json['is_release'] ?? false,
        firstLaunch = json['fst_launch'] ?? false,
        firstLaunchThisHour = json['fst_launch_hour'] ?? false,
        firstLaunchToday = json['fst_launch_day'] ?? false,
        firstLaunchThisMonth = json['fst_launch_month'] ?? false,
        firstLaunchThisYear = json['fst_launch_year'] ?? false,
        firstLaunchThisVersion = json['fst_launch_version'] ?? false,
        hasError = json['has_error'] ?? false,
        eventCounts =
            json['evts'] != null ? json['evts'].cast<String, int>() : {},
        eventSequence =
            json['evt_seq'] != null ? json['evt_seq'].cast<String>() : [];

  Map<String, dynamic> toJson() => {
        'id': id,
        'start': start.toIso8601String(),
        'end': end.toIso8601String(),
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
        'has_error': hasError,
        'evts': eventCounts,
        'evt_seq': eventSequence
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
