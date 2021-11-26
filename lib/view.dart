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
    if (model is DailyWinViewLoadingModel) {
      return DailyWinViewLoading(model: model, dispatch: dispatch);
    }
    if (model is WinEditorViewModel) {
      return WinEditorView(model: model);
    }
    if (model is DailyWinViewModel) {
      return DailyWinView(model: model, dispatch: dispatch);
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

class DailyWinViewLoading extends StatelessWidget {
  final void Function(Message) dispatch;
  final DailyWinViewLoadingModel model;

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
  final DailyWinViewModel model;

  const DailyWinView({Key? key, required this.model, required this.dispatch})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      GestureDetector(
        child: Text("DailyWin: " + model.win),
        onTap: () => dispatch(EditWinRequested(model.date, model.win)),
      )
    ]);
  }
}

class WinEditorView extends StatelessWidget {
  final WinEditorViewModel model;

  const WinEditorView({Key? key, required this.model}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text("Editor: " + model.win);
  }
}
