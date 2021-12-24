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
              var updatedWin =
                  WinData(_controller.text, widget.model.win.overallResult);
              widget.dispatch(WinSaveRequested(widget.model.date, updatedWin));
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
