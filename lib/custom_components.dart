import 'package:flutter/material.dart';
import 'package:winaday/view.dart';

import 'domain.dart';
import 'messages.dart';
import 'model.dart';

class WinEditor extends StatefulWidget {
  final WinEditorModel model;
  final void Function(Message) dispatch;

  const WinEditor({Key? key, required this.model, required this.dispatch})
      : super(key: key);

  @override
  State<WinEditor> createState() => _WinEditorState();
}

class _WinEditorState extends State<WinEditor> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.text = widget.model.win.text;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Edit win'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            tooltip: 'Save',
            onPressed: () {
              // TODO: consider passing updated values to the message and then constructing new win in the reducer
              var updatedWin = WinData(_controller.text,
                  widget.model.win.overallResult, widget.model.win.priorities);
              widget.dispatch(WinChangesConfirmed(widget.model.date,
                  widget.model.today, widget.model.priorityList, updatedWin));
            },
          )
        ],
      ),
      body: WillPopScope(
          onWillPop: () async {
            widget.dispatch(CancelEditingWinRequested(
                widget.model.date, widget.model.today));
            return false;
          },
          child: Column(children: [
            dayOverallResult(_controller, widget.model, widget.dispatch),
            const Divider(
              height: 12,
              thickness: 1,
              indent: 12,
              endIndent: 12,
            ),
            Expanded(
                child: Padding(
                    padding: const EdgeInsets.only(
                        top: TEXT_PADDING,
                        left: TEXT_PADDING * 2,
                        right: TEXT_PADDING * 2,
                        bottom: TEXT_PADDING),
                    child: TextField(
                      maxLength: 1000,
                      controller: _controller,
                      autofocus: true,
                      style: const TextStyle(fontSize: TEXT_FONT_SIZE),
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Write down you win here'),
                    )))
          ])),
    );
  }
}

class PriorityEditor extends StatefulWidget {
  final PriorityEditorModel model;
  final void Function(Message) dispatch;

  const PriorityEditor({Key? key, required this.model, required this.dispatch})
      : super(key: key);

  @override
  State<PriorityEditor> createState() => _PriorityEditorState();
}

class _PriorityEditorState extends State<PriorityEditor> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.text = widget.model.priority.text;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Edit priority'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            tooltip: 'Save',
            onPressed: () {
              PriorityData priority = PriorityData(
                  widget.model.priority.id,
                  _controller.text,
                  widget.model.priority.color,
                  widget.model.priority.deleted);
              widget.dispatch(PrioritySaveRequested(
                  widget.model.date, widget.model.priorityList, priority));
            },
          )
        ],
      ),
      body: WillPopScope(
          onWillPop: () async {
            widget.dispatch(CancelEditingPriorityRequested(
                widget.model.date, widget.model.today));
            return false;
          },
          child: Column(children: [
            priorityBoxColorPicker(_controller, widget.model, widget.dispatch),
            const Divider(
              // TODO: single-source
              height: 12,
              thickness: 1,
              indent: 12,
              endIndent: 12,
            ),
            Expanded(
                child: Padding(
                    padding: const EdgeInsets.only(
                        top: TEXT_PADDING,
                        left: TEXT_PADDING * 2,
                        right: TEXT_PADDING * 2,
                        bottom: TEXT_PADDING),
                    child: TextField(
                      maxLength: 100,
                      controller: _controller,
                      autofocus: true,
                      style: const TextStyle(fontSize: TEXT_FONT_SIZE),
                      maxLines: 1,
                      keyboardType: TextInputType.multiline,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Write down you priority here'),
                    )))
          ])),
    );
  }
}

class DraggablePriorityGrid extends StatefulWidget {
  final EditPrioritiesModel model;
  final void Function(Message) dispatch;

  const DraggablePriorityGrid(
      {Key? key, required this.model, required this.dispatch})
      : super(key: key);

  @override
  State<DraggablePriorityGrid> createState() => _DraggablePriorityGridState();
}

class _DraggablePriorityGridState extends State<DraggablePriorityGrid> {
  PriorityData? _exchangeWith;

  void onWillAccept(PriorityData? priority) {
    setState(() {
      _exchangeWith = priority;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GridView.count(
        crossAxisCount: 3,
        padding: const EdgeInsets.all(16.0),
        mainAxisSpacing: 12.0,
        crossAxisSpacing: 12.0,
        children: widget.model.priorityList.items
            .where((element) => !element.deleted)
            .map((e) => draggablePriorityBox(
                widget.model, e, _exchangeWith, widget.dispatch, onWillAccept))
            .toList());
  }
}
