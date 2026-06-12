/// Regla de automatización: cuando ocurre un disparador, se ejecuta
/// una acción. Las reglas se persisten en Hive como Map.
class AutomationRule {
  AutomationRule({
    required this.id,
    required this.name,
    required this.triggerType,
    required this.triggerValue,
    required this.actionType,
    required this.actionValue,
    this.enabled = true,
  });

  final String id;
  final String name;

  /// nfc (UID) | qr (contenido) | hora (HH:mm)
  final String triggerType;
  final String triggerValue;

  /// url (abrir enlace/app) | mensaje (mostrar notificación en app)
  final String actionType;
  final String actionValue;
  final bool enabled;

  AutomationRule copyWith({bool? enabled}) => AutomationRule(
        id: id,
        name: name,
        triggerType: triggerType,
        triggerValue: triggerValue,
        actionType: actionType,
        actionValue: actionValue,
        enabled: enabled ?? this.enabled,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'triggerType': triggerType,
        'triggerValue': triggerValue,
        'actionType': actionType,
        'actionValue': actionValue,
        'enabled': enabled,
      };

  factory AutomationRule.fromMap(Map map) => AutomationRule(
        id: map['id'] as String,
        name: map['name'] as String,
        triggerType: map['triggerType'] as String,
        triggerValue: map['triggerValue'] as String,
        actionType: map['actionType'] as String,
        actionValue: map['actionValue'] as String,
        enabled: map['enabled'] as bool? ?? true,
      );
}
