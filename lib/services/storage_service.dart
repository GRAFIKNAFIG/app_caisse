import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

import '../models/ticket.dart';

class StorageService {
  StorageService._();
  static final StorageService instance = StorageService._();

  Future<String> _getFilePath() async {
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/tickets.json';
    }

  Future<List<Ticket>> loadTickets() async {
    try {
      final file = File(await _getFilePath());
      if (!file.existsSync()) return [];
      final content = await file.readAsString();
      final List<dynamic> jsonList = jsonDecode(content);
      return jsonList
          .map((e) => Ticket.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveTicket(Ticket ticket) async {
    final file = File(await _getFilePath());
    List<Ticket> tickets = [];
    if (file.existsSync()) {
      try {
        final content = await file.readAsString();
        final List<dynamic> jsonList = jsonDecode(content);
        tickets = jsonList
            .map((e) => Ticket.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (_) {}
    }
    tickets.add(ticket);
    final jsonList = tickets.map((t) => t.toJson()).toList();
    await file.writeAsString(jsonEncode(jsonList));
  }
}
