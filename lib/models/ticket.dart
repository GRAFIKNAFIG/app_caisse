import 'ticket_line.dart';

class Ticket {
  final String id;
  final DateTime dateTime;
  final List<TicketLine> lines;
  final String paymentMethod;

  Ticket({
    required this.id,
    required this.dateTime,
    required this.lines,
    required this.paymentMethod,
  });

  double get total =>
      lines.fold(0.0, (sum, line) => sum + line.total);

  String get dateString =>
      '${dateTime.year.toString().padLeft(4, '0')}-'
      '${dateTime.month.toString().padLeft(2, '0')}-'
      '${dateTime.day.toString().padLeft(2, '0')}';

  String get timeString =>
      '${dateTime.hour.toString().padLeft(2, '0')}:'
      '${dateTime.minute.toString().padLeft(2, '0')}';

  Map<String, dynamic> toJson() => {
        'id': id,
        'dateTime': dateTime.toIso8601String(),
        'lines': lines.map((l) => l.toJson()).toList(),
        'paymentMethod': paymentMethod,
      };

  factory Ticket.fromJson(Map<String, dynamic> json) => Ticket(
        id: json['id'] as String,
        dateTime: DateTime.parse(json['dateTime'] as String),
        lines: (json['lines'] as List<dynamic>)
            .map((e) => TicketLine.fromJson(e as Map<String, dynamic>))
            .toList(),
        paymentMethod: json['paymentMethod'] as String,
      );
}
