import 'package:flutter/material.dart';
import 'model.dart';
import 'messages.dart';

// These should be all stateless! No side effects allowed!

class View {
  static Widget getHomeView(Model model, void Function(Message) dispatch) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Win a day'),
        ),
        body: View.getBody(model, dispatch));
  }

  static Widget getBody(Model model, void Function(Message) dispatch) {
    if (model is UserNotSignedInModel) {
      return UserNotSignedInView(model: model, dispatch: dispatch);
    }
    if (model is DailyWinLoadingModel) {
      return DailyWinViewLoading(model: model, dispatch: dispatch);
    }
    if (model is DailyWinModel) {
      return DailyWinView(model: model, dispatch: dispatch);
    }
    if (model is WinEditorModel) {
      return WinEditorView(model: model, dispatch: dispatch);
    }
    if (model is WinEditorSavingModel) {
      return WinEditorSavingView(model: model, dispatch: dispatch);
    }
    return UnknownModelWidget(model: model);
  }
}

class UnknownModelWidget extends StatelessWidget {
  final Model model;

  const UnknownModelWidget({Key? key, required this.model}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text("Unknown model: " + model.runtimeType.toString());
  }
}

class UserNotSignedInView extends StatelessWidget {
  final void Function(Message) dispatch;
  final UserNotSignedInModel model;

  const UserNotSignedInView(
      {Key? key, required this.model, required this.dispatch})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text("Welcome");
  }
}

class DailyWinViewLoading extends StatelessWidget {
  final void Function(Message) dispatch;
  final DailyWinLoadingModel model;

  const DailyWinViewLoading(
      {Key? key, required this.model, required this.dispatch})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
        children: [Text("Loading data for " + model.date.toString())]);
  }
}

class DailyWinView extends StatelessWidget {
  final void Function(Message) dispatch;
  final DailyWinModel model;

  const DailyWinView({Key? key, required this.model, required this.dispatch})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      GestureDetector(
        child: Text("DailyWin: " + model.win),
        onTap: () {
          dispatch(EditWinRequested(model.date, model.win));
        },
      )
    ]);
  }
}

class WinEditorView extends StatelessWidget {
  final void Function(Message) dispatch;
  final WinEditorModel model;

  const WinEditorView({Key? key, required this.model, required this.dispatch})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text("Editor: " + model.win),
      ElevatedButton(
        onPressed: () {
          dispatch(WinSaveRequested(model.date, model.win));
        },
        child: const Text('Save'),
      )
    ]);
  }
}

class WinEditorSavingView extends StatelessWidget {
  final void Function(Message) dispatch;
  final WinEditorSavingModel model;

  const WinEditorSavingView(
      {Key? key, required this.model, required this.dispatch})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(children: [Text("Saving... " + model.date.toString())]);
  }
}
