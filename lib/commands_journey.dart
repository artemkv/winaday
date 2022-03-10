import 'package:flutter/material.dart';

import 'commands.dart';
import 'journey/journey.dart';
import 'messages.dart';

@immutable
class ReportSignIn implements Command {
  @override
  void execute(void Function(Message) dispatch) {
    Future<void>.delayed(Duration.zero, () async {
      await Journey.reportEvent('sign_in');
    });
  }
}

@immutable
class ReportSignOut implements Command {
  @override
  void execute(void Function(Message) dispatch) {
    Future<void>.delayed(Duration.zero, () async {
      await Journey.reportEvent('sign_out');
    });
  }
}

@immutable
class ReportMovedToDay implements Command {
  @override
  void execute(void Function(Message) dispatch) {
    Future<void>.delayed(Duration.zero, () async {
      await Journey.reportEvent('move_day', isCollapsible: true);
    });
  }
}

@immutable
class ReportEditWin implements Command {
  @override
  void execute(void Function(Message) dispatch) {
    Future<void>.delayed(Duration.zero, () async {
      await Journey.reportEvent('edit_win');
    });
  }
}

@immutable
class ReportEditWinPriorities implements Command {
  @override
  void execute(void Function(Message) dispatch) {
    Future<void>.delayed(Duration.zero, () async {
      await Journey.reportEvent('edit_win_priorities');
    });
  }
}

@immutable
class ReportWinSaved implements Command {
  @override
  void execute(void Function(Message) dispatch) {
    Future<void>.delayed(Duration.zero, () async {
      await Journey.reportEvent('win_saved');
    });
  }
}

@immutable
class ReportNavigateToPriorities implements Command {
  @override
  void execute(void Function(Message) dispatch) {
    Future<void>.delayed(Duration.zero, () async {
      await Journey.reportEvent('navto_priorities');
    });
  }
}

@immutable
class ReportEditPriorities implements Command {
  @override
  void execute(void Function(Message) dispatch) {
    Future<void>.delayed(Duration.zero, () async {
      await Journey.reportEvent('edit_priorities');
    });
  }
}

@immutable
class ReportEditPriority implements Command {
  @override
  void execute(void Function(Message) dispatch) {
    Future<void>.delayed(Duration.zero, () async {
      await Journey.reportEvent('edit_priority');
    });
  }
}

@immutable
class ReportPrioritiesSaved implements Command {
  @override
  void execute(void Function(Message) dispatch) {
    Future<void>.delayed(Duration.zero, () async {
      await Journey.reportEvent('priorities_saved');
    });
  }
}

@immutable
class ReportNavigateToStats implements Command {
  @override
  void execute(void Function(Message) dispatch) {
    Future<void>.delayed(Duration.zero, () async {
      await Journey.reportEvent('navto_stats');
    });
  }
}

@immutable
class ReportNavigateToInsights implements Command {
  @override
  void execute(void Function(Message) dispatch) {
    Future<void>.delayed(Duration.zero, () async {
      await Journey.reportEvent('navto_insights');
    });
  }
}

@immutable
class ReportNavigateToWinList implements Command {
  @override
  void execute(void Function(Message) dispatch) {
    Future<void>.delayed(Duration.zero, () async {
      await Journey.reportEvent('navto_winlist');
    });
  }
}

@immutable
class ReportNavigateToCalendar implements Command {
  @override
  void execute(void Function(Message) dispatch) {
    Future<void>.delayed(Duration.zero, () async {
      await Journey.reportEvent('navto_calendar');
    });
  }
}

@immutable
class ReportDailyWinViewLoadingFailed implements Command {
  @override
  void execute(void Function(Message) dispatch) {
    Future<void>.delayed(Duration.zero, () async {
      await Journey.reportEvent('err_load_dailywin', isError: true);
    });
  }
}

@immutable
class ReportSavingWinFailed implements Command {
  @override
  void execute(void Function(Message) dispatch) {
    Future<void>.delayed(Duration.zero, () async {
      await Journey.reportEvent('err_save_win', isError: true);
    });
  }
}

@immutable
class ReportPrioritiesLoadingFailed implements Command {
  @override
  void execute(void Function(Message) dispatch) {
    Future<void>.delayed(Duration.zero, () async {
      await Journey.reportEvent('err_load_priorities', isError: true);
    });
  }
}

@immutable
class ReportSavingPrioritiesFailed implements Command {
  @override
  void execute(void Function(Message) dispatch) {
    Future<void>.delayed(Duration.zero, () async {
      await Journey.reportEvent('err_save_priorities', isError: true);
    });
  }
}

@immutable
class ReportWinListFirstPageLoadingFailed implements Command {
  @override
  void execute(void Function(Message) dispatch) {
    Future<void>.delayed(Duration.zero, () async {
      await Journey.reportEvent('err_load_winlist_fst', isError: true);
    });
  }
}

@immutable
class ReportWinListNextPageLoadingFailed implements Command {
  @override
  void execute(void Function(Message) dispatch) {
    Future<void>.delayed(Duration.zero, () async {
      await Journey.reportEvent('err_load_winlist_next', isError: true);
    });
  }
}

@immutable
class ReportStatsLoadingFailed implements Command {
  @override
  void execute(void Function(Message) dispatch) {
    Future<void>.delayed(Duration.zero, () async {
      await Journey.reportEvent('err_load_stats', isError: true);
    });
  }
}

@immutable
class ReportInsightsLoadingFailed implements Command {
  @override
  void execute(void Function(Message) dispatch) {
    Future<void>.delayed(Duration.zero, () async {
      await Journey.reportEvent('err_load_insights', isError: true);
    });
  }
}
