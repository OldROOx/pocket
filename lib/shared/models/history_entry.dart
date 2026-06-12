/// Entrada genérica de historial. Se guarda como Map en Hive
/// para evitar generación de código con adapters.
class HistoryEntry {
  HistoryEntry({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.data,
    DateTime? date,
  }) : date = date ?? DateTime.now();

  /// nfc | bluetooth | wifi | qr | automation
  final String type;
  final String title;
  final String subtitle;
  final Map<String, dynamic> data;
  final DateTime date;

  Map<String, dynamic> toMap() => {
        'type': type,
        'title': title,
        'subtitle': subtitle,
        'data': data,
        'date': date.toIso8601String(),
      };

  factory HistoryEntry.fromMap(Map map) => HistoryEntry(
        type: map['type'] as String,
        title: map['title'] as String,
        subtitle: map['subtitle'] as String,
        data: Map<String, dynamic>.from(map['data'] as Map),
        date: DateTime.tryParse(map['date'] as String? ?? '') ?? DateTime.now(),
      );
}
