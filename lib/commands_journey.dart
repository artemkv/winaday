import 'package:flutter/material.dart';
import 'package:journey3_connector/journey3_connector.dart';

import 'commands.dart';
import 'messages.dart';

const stageExploration = 2;
const stageExplorationName = 'explore';

const stageEngagement = 3;
const stageEngagementName = 'engage';

const stageLoyalty = 4;
const stageLoyaltyName = 'stick';

@immutable
class ReportSignIn implements Command {
  @override
  void execute(void Function(Message) dispatch) {
    Future<void>.delayed(Duration.zero, () async {
      await Journey.instance().reportEvent('sign_in');
    });
  }
}

@immutable
class ReportSignOut implements Command {
  @override
  void execute(void Function(Message) dispatch) {
    Future<void>.delayed(Duration.zero, () async {
      await Journey.instance().reportEvent('sign_out');
    });
  }
}

@immutable
class ReportMovedToDay implements Command {
  @override
  void execute(void Function(Message) dispatch) {
    Future<void>.delayed(Duration.zero, () async {
      await Journey.instance().reportEvent('move_day', isCollapsible: true);
    });
  }
}

@immutable
class ReportEditWin implements Command {
  @override
  void execute(void Function(Message) dispatch) {
    Future<void>.delayed(Duration.zero, () async {
      await Journey.instance().reportEvent('edit_win');
      await Journey.instance()
          .reportStageTransition(stageEngagement, stageEngagementName);
    });
  }
}

@immutable
class ReportEditWinPriorities implements Command {
  @override
  void execute(void Function(Message) dispatch) {
    Future<void>.delayed(Duration.zero, () async {
      await Journey.instance().reportEvent('edit_win_priorities');
      await Journey.instance()
          .reportStageTransition(stageEngagement, stageEngagementName);
    });
  }
}

@immutable
class ReportWinSaved implements Command {
  @override
  void execute(void Function(Message) dispatch) {
    Future<void>.delayed(Duration.zero, () async {
      await Journey.instance().reportEvent('win_saved');
    });
  }
}

@immutable
class ReportNavigateToPriorities implements Command {
  @override
  void execute(void Function(Message) dispatch) {
    Future<void>.delayed(Duration.zero, () async {
      await Journey.instance().reportEvent('navto_priorities');
      await Journey.instance()
          .reportStageTransition(stageExploration, stageExplorationName);
    });
  }
}

@immutable
class ReportEditPriorities implements Command {
  @override
  void execute(void Function(Message) dispatch) {
    Future<void>.delayed(Duration.zero, () async {
      await Journey.instance().reportEvent('edit_priorities');
      await Journey.instance()
          .reportStageTransition(stageEngagement, stageEngagementName);
    });
  }
}

@immutable
class ReportEditPriority implements Command {
  @override
  void execute(void Function(Message) dispatch) {
    Future<void>.delayed(Duration.zero, () async {
      await Journey.instance().reportEvent('edit_priority');
      await Journey.instance()
          .reportStageTransition(stageEngagement, stageEngagementName);
    });
  }
}

@immutable
class ReportPrioritiesSaved implements Command {
  @override
  void execute(void Function(Message) dispatch) {
    Future<void>.delayed(Duration.zero, () async {
      await Journey.instance().reportEvent('priorities_saved');
    });
  }
}

@immutable
class ReportNavigateToStats implements Command {
  @override
  void execute(void Function(Message) dispatch) {
    Future<void>.delayed(Duration.zero, () async {
      await Journey.instance().reportEvent('navto_stats');
      await Journey.instance()
          .reportStageTransition(stageExploration, stageExplorationName);
    });
  }
}

@immutable
class ReportToggleStatsPieToHistograms implements Command {
  @override
  void execute(void Function(Message) dispatch) {
    Future<void>.delayed(Duration.zero, () async {
      await Journey.instance()
          .reportEvent('toggle_pie_hist', isCollapsible: true);
    });
  }
}

@immutable
class ReportNavigateToInsights implements Command {
  @override
  void execute(void Function(Message) dispatch) {
    Future<void>.delayed(Duration.zero, () async {
      await Journey.instance().reportEvent('navto_insights');
      await Journey.instance()
          .reportStageTransition(stageExploration, stageExplorationName);
    });
  }
}

@immutable
class ReportNavigateToSettings implements Command {
  @override
  void execute(void Function(Message) dispatch) {
    Future<void>.delayed(Duration.zero, () async {
      await Journey.instance().reportEvent('navto_settings');
      await Journey.instance()
          .reportStageTransition(stageExploration, stageExplorationName);
    });
  }
}

@immutable
class ReportAppSettingsSaved implements Command {
  @override
  void execute(void Function(Message) dispatch) {
    Future<void>.delayed(Duration.zero, () async {
      await Journey.instance().reportEvent('settings_saved');
    });
  }
}

@immutable
class ReportNavigateToWinList implements Command {
  @override
  void execute(void Function(Message) dispatch) {
    Future<void>.delayed(Duration.zero, () async {
      await Journey.instance().reportEvent('navto_winlist');
    });
  }
}

@immutable
class ReportNavigateToCalendar implements Command {
  @override
  void execute(void Function(Message) dispatch) {
    Future<void>.delayed(Duration.zero, () async {
      await Journey.instance().reportEvent('navto_calendar');
    });
  }
}

@immutable
class ReportDailyWinViewLoadingFailed implements Command {
  @override
  void execute(void Function(Message) dispatch) {
    Future<void>.delayed(Duration.zero, () async {
      await Journey.instance().reportEvent('err_load_dailywin', isError: true);
    });
  }
}

@immutable
class ReportSavingWinFailed implements Command {
  @override
  void execute(void Function(Message) dispatch) {
    Future<void>.delayed(Duration.zero, () async {
      await Journey.instance().reportEvent('err_save_win', isError: true);
    });
  }
}

@immutable
class ReportPrioritiesLoadingFailed implements Command {
  @override
  void execute(void Function(Message) dispatch) {
    Future<void>.delayed(Duration.zero, () async {
      await Journey.instance()
          .reportEvent('err_load_priorities', isError: true);
    });
  }
}

@immutable
class ReportSavingPrioritiesFailed implements Command {
  @override
  void execute(void Function(Message) dispatch) {
    Future<void>.delayed(Duration.zero, () async {
      await Journey.instance()
          .reportEvent('err_save_priorities', isError: true);
    });
  }
}

@immutable
class ReportWinListFirstPageLoadingFailed implements Command {
  @override
  void execute(void Function(Message) dispatch) {
    Future<void>.delayed(Duration.zero, () async {
      await Journey.instance()
          .reportEvent('err_load_winlist_fst', isError: true);
    });
  }
}

@immutable
class ReportWinListNextPageLoadingFailed implements Command {
  @override
  void execute(void Function(Message) dispatch) {
    Future<void>.delayed(Duration.zero, () async {
      await Journey.instance()
          .reportEvent('err_load_winlist_next', isError: true);
    });
  }
}

@immutable
class ReportStatsLoadingFailed implements Command {
  @override
  void execute(void Function(Message) dispatch) {
    Future<void>.delayed(Duration.zero, () async {
      await Journey.instance().reportEvent('err_load_stats', isError: true);
    });
  }
}

@immutable
class ReportInsightsLoadingFailed implements Command {
  @override
  void execute(void Function(Message) dispatch) {
    Future<void>.delayed(Duration.zero, () async {
      await Journey.instance().reportEvent('err_load_insights', isError: true);
    });
  }
}

@immutable
class ReportLoyalUser implements Command {
  @override
  void execute(void Function(Message) dispatch) {
    Future<void>.delayed(Duration.zero, () async {
      await Journey.instance()
          .reportStageTransition(stageLoyalty, stageLoyaltyName);
    });
  }
}

@immutable
class ReportUserDataDeletionFailed implements Command {
  @override
  void execute(void Function(Message) dispatch) {
    Future<void>.delayed(Duration.zero, () async {
      await Journey.instance().reportEvent('err_del_data', isError: true);
    });
  }
}

@immutable
class ReportUserConfirmedDataDeletion implements Command {
  @override
  void execute(void Function(Message) dispatch) {
    Future<void>.delayed(Duration.zero, () async {
      await Journey.instance().reportEvent('del_data');
    });
  }
}
