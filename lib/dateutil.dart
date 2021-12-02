const monthNames = <String>[
  "January",
  "February",
  "March",
  "April",
  "May",
  "June",
  "July",
  "August",
  "September",
  "October",
  "November",
  "December"
];

String getDayString(DateTime date) {
  return '${monthNames[date.month - 1]}, ${date.day}';
}
