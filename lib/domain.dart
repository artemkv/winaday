class WinData {
  final String text;

  WinData(this.text);

  WinData.fromJson(Map<String, dynamic> json) : text = json['text'];

  Map<String, dynamic> toJson() => {
        'text': text,
      };
}
