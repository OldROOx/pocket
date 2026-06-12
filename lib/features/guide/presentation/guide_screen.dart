import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/pocket_widgets.dart';

/// Guía de uso de Pocket: explica qué hace cada herramienta,
/// cómo se utiliza paso a paso, un ejemplo real de cuándo usarla
/// y su compatibilidad con iPhone (iOS).
class GuideScreen extends StatelessWidget {
  const GuideScreen({super.key});

  bool get _isIos => !kIsWeb && Platform.isIOS;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Guía de Pocket')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (_isIos)
            PocketCard(
              color: AppColors.red.withOpacity(0.10),
              borderColor: AppColors.red.withOpacity(0.5),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.phone_iphone_rounded,
                      color: AppColors.red, size: 28),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Estás usando un iPhone. Algunas funciones de Pocket '
                      'NO van a funcionar en iOS porque Apple no permite '
                      'el acceso (busca la etiqueta roja en cada tarjeta).',
                      style: TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          if (_isIos) const SizedBox(height: 16),
          const Text(
            'Toca cualquier tarjeta para ver qué hace la herramienta, '
            'cómo se usa y un ejemplo de cuándo te sirve.',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          const SizedBox(height: 16),
          ..._items.map((item) => _GuideCard(item: item, isIos: _isIos)),
        ],
      ),
    );
  }
}

enum _IosSupport { full, limited, none }

class _GuideItem {
  const _GuideItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.what,
    required this.steps,
    required this.example,
    required this.iosSupport,
    this.iosNote,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String what;
  final List<String> steps;
  final String example;
  final _IosSupport iosSupport;
  final String? iosNote;
}

const _items = <_GuideItem>[
  _GuideItem(
    icon: Icons.nfc_rounded,
    color: AppColors.blue,
    title: 'NFC Center',
    what: 'Lee etiquetas y tarjetas NFC: muestra su UID (identificador '
        'único), las tecnologías que soporta y el contenido NDEF grabado '
        '(textos, enlaces, etc.).',
    steps: [
      'Activa NFC en los ajustes de tu teléfono.',
      'Entra a NFC Center y presiona ESCANEAR ETIQUETA.',
      'Acerca la etiqueta a la parte trasera del teléfono.',
      'Revisa los datos leídos; puedes exportarlos o verlos después en el Historial.',
    ],
    example: 'Compraste tags NFC para tu setup y quieres verificar qué URL '
        'tiene grabada cada una antes de pegarlas, o quieres ver el UID de '
        'tu tarjeta del transporte para identificarla.',
    iosSupport: _IosSupport.limited,
    iosNote: 'Si tienes iPhone: solo funciona en iPhone 7 o más reciente, '
        'la app debe compilarse con la capability de NFC activada en Xcode '
        '(requiere cuenta de desarrollador de pago) y la lectura es más '
        'limitada que en Android. Si no se cumple esto, NO va a funcionar.',
  ),
  _GuideItem(
    icon: Icons.bluetooth_rounded,
    color: AppColors.purple,
    title: 'Bluetooth Scanner',
    what: 'Escanea los dispositivos Bluetooth Low Energy (BLE) cercanos y '
        'muestra su nombre, dirección MAC, intensidad de señal (RSSI) y '
        'servicios anunciados.',
    steps: [
      'Activa Bluetooth y concede el permiso cuando la app lo pida.',
      'Presiona INICIAR ESCANEO y espera unos segundos.',
      'Toca cualquier dispositivo de la lista para ver sus detalles.',
      'El color del RSSI te dice qué tan cerca está: verde = cerca, rojo = lejos.',
    ],
    example: 'No encuentras tus audífonos en el cuarto: escanea y camina; '
        'si el RSSI sube (se acerca a 0), vas en la dirección correcta. '
        'También sirve para ver qué dispositivos desconocidos hay cerca.',
    iosSupport: _IosSupport.full,
    iosNote: 'En iPhone funciona, pero iOS oculta la dirección MAC real de '
        'los dispositivos por privacidad: verás un identificador distinto.',
  ),
  _GuideItem(
    icon: Icons.wifi_rounded,
    color: AppColors.green,
    title: 'WiFi Analyzer',
    what: 'Muestra tu red WiFi actual y escanea las redes cercanas con su '
        'intensidad de señal, canal, banda (2.4 / 5 / 6 GHz) y tipo de '
        'seguridad.',
    steps: [
      'Concede el permiso de ubicación (Android lo exige para escanear WiFi).',
      'Presiona ESCANEAR REDES.',
      'Compara la intensidad y el canal de cada red.',
    ],
    example: 'Tu internet va lento en tu cuarto: escanea y descubre que tu '
        'router está en el canal 6 igual que cinco redes de tus vecinos; '
        'lo cambias al canal 11 y mejora la conexión.',
    iosSupport: _IosSupport.none,
    iosNote: 'Si tienes iPhone esta herramienta NO va a funcionar: Apple '
        'no permite a ninguna app escanear redes WiFi cercanas. En iOS '
        'solo podrás ver el nombre de la red a la que ya estás conectado.',
  ),
  _GuideItem(
    icon: Icons.qr_code_rounded,
    color: AppColors.orange,
    title: 'Códigos QR',
    what: 'Escanea códigos QR y de barras con la cámara, y genera tus '
        'propios QR de texto, enlaces, contactos (vCard), redes WiFi o '
        'eventos.',
    steps: [
      'Pestaña Escanear: apunta la cámara al código y copia o comparte el resultado.',
      'Pestaña Generar: elige el tipo (texto, URL, vCard, WiFi, evento).',
      'Escribe el contenido y el QR se dibuja al instante.',
      'Compártelo como imagen o deja que alguien lo escanee de tu pantalla.',
    ],
    example: 'Llega una visita a tu casa y te pide la contraseña del WiFi: '
        'generas un QR tipo WiFi y la persona solo lo escanea para '
        'conectarse, sin dictarle nada. O pones el QR de tu canal en la '
        'descripción de tus videos.',
    iosSupport: _IosSupport.full,
  ),
  _GuideItem(
    icon: Icons.phone_android_rounded,
    color: AppColors.red,
    title: 'Mi Dispositivo',
    what: 'Muestra la información de tu teléfono (modelo, sistema, '
        'hardware), el estado de la batería y los sensores en vivo: '
        'acelerómetro, giroscopio y magnetómetro.',
    steps: [
      'Abre la herramienta: los datos se cargan solos.',
      'Observa los sensores actualizarse en tiempo real.',
      'Mueve o gira el teléfono para ver cómo cambian los valores.',
    ],
    example: 'Estás programando un juego que usa el giroscopio y quieres '
        'entender qué valores entrega cada eje al inclinar el teléfono, o '
        'quieres usar el magnetómetro como brújula improvisada.',
    iosSupport: _IosSupport.full,
  ),
  _GuideItem(
    icon: Icons.auto_awesome_rounded,
    color: AppColors.yellow,
    title: 'Automatizaciones',
    what: 'Crea reglas del tipo "cuando pase X, haz Y": al leer cierta '
        'etiqueta NFC, al escanear cierto QR o a una hora, abre una URL o '
        'muestra un mensaje.',
    steps: [
      'Presiona NUEVA REGLA.',
      'Elige el disparador (NFC, QR u hora) y su valor.',
      'Elige la acción (abrir URL o mostrar mensaje).',
      'Activa la regla con el switch; usa Probar para verificarla.',
    ],
    example: 'Pegas un tag NFC en tu escritorio y creas la regla "al leer '
        'este tag, abrir YouTube Studio": cada vez que llegas a grabar, '
        'tocas el tag y listo.',
    iosSupport: _IosSupport.limited,
    iosNote: 'Si tienes iPhone: las reglas con disparador NFC dependen de '
        'que el NFC funcione en tu equipo (mira las limitaciones de NFC '
        'Center). Las reglas por QR y por hora sí funcionan.',
  ),
  _GuideItem(
    icon: Icons.swap_horiz_rounded,
    color: AppColors.blue,
    title: 'Conversor de datos',
    what: 'Convierte texto y números entre formatos: HEX, ASCII, Base64, '
        'binario y decimal.',
    steps: [
      'Elige el formato de entrada y el de salida.',
      'Escribe o pega el dato.',
      'Copia el resultado convertido.',
    ],
    example: 'Leíste una etiqueta NFC y su payload viene en HEX: lo pegas '
        'en el conversor y descubres que en ASCII dice una URL. También '
        'sirve para decodificar cadenas Base64 que encuentras depurando '
        'una API.',
    iosSupport: _IosSupport.full,
  ),
  _GuideItem(
    icon: Icons.key_rounded,
    color: AppColors.purple,
    title: 'Generadores',
    what: 'Genera UUIDs v4 y contraseñas seguras aleatorias con opciones '
        'de longitud, símbolos, números y mayúsculas.',
    steps: [
      'Elige UUID o contraseña.',
      'Ajusta las opciones (longitud, símbolos...).',
      'Presiona generar y copia el resultado.',
    ],
    example: 'Necesitas IDs únicos para los registros de tu API de '
        'FastAPI, o vas a crear una cuenta nueva y quieres una contraseña '
        'fuerte de 24 caracteres en vez de reciclar la de siempre.',
    iosSupport: _IosSupport.full,
  ),
  _GuideItem(
    icon: Icons.text_fields_rounded,
    color: AppColors.green,
    title: 'Herramientas de texto',
    what: 'Cuenta caracteres, palabras y líneas de cualquier texto, y '
        'formatea/valida JSON con sangría legible.',
    steps: [
      'Pega tu texto o JSON.',
      'Mira las estadísticas al instante o presiona formatear.',
      'Si el JSON es inválido, te dice dónde está el error.',
    ],
    example: 'Una API te regresa un JSON minificado en una sola línea: lo '
        'pegas, lo formateas y ya puedes leerlo. O cuentas los caracteres '
        'del título de tu próximo video para que no se corte.',
    iosSupport: _IosSupport.full,
  ),
  _GuideItem(
    icon: Icons.history_rounded,
    color: AppColors.orange,
    title: 'Historial',
    what: 'Guarda automáticamente todo lo que escaneas (NFC, QR, WiFi, '
        'Bluetooth) para consultarlo después, con búsqueda, filtros por '
        'tipo y exportación.',
    steps: [
      'Abre la pestaña Historial en la barra inferior.',
      'Busca por texto o filtra con los chips de tipo.',
      'Toca una entrada para ver el detalle completo.',
      'Desliza una entrada para borrarla, o usa el ícono de compartir para exportar todo.',
    ],
    example: 'La semana pasada escaneaste un QR con un enlace que ahora '
        'necesitas: filtras por QR, lo encuentras y lo copias sin tener '
        'que escanear nada de nuevo.',
    iosSupport: _IosSupport.full,
  ),
];

class _GuideCard extends StatefulWidget {
  const _GuideCard({required this.item, required this.isIos});

  final _GuideItem item;
  final bool isIos;

  @override
  State<_GuideCard> createState() => _GuideCardState();
}

class _GuideCardState extends State<_GuideCard> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: PocketCard(
        onTap: () => setState(() => _open = !_open),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ToolIcon(icon: item.icon, color: item.color),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.title,
                          style: const TextStyle(
                              fontWeight: FontWeight.w900, fontSize: 16)),
                      const SizedBox(height: 4),
                      _IosBadge(support: item.iosSupport),
                    ],
                  ),
                ),
                Icon(
                  _open
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: Theme.of(context).hintColor,
                ),
              ],
            ),
            if (_open) ...[
              const SizedBox(height: 14),
              _Section(title: '¿Qué hace?', child: Text(item.what,
                  style: const TextStyle(fontWeight: FontWeight.w600))),
              const SizedBox(height: 12),
              _Section(
                title: '¿Cómo se usa?',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var i = 0; i < item.steps.length; i++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 22,
                              height: 22,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: item.color.withOpacity(0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Text('${i + 1}',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 12,
                                      color: item.color)),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(item.steps[i],
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600)),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _Section(
                title: 'Ejemplo de cuándo usarla',
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: item.color.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(item.example,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontStyle: FontStyle.italic)),
                ),
              ),
              if (item.iosNote != null) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (item.iosSupport == _IosSupport.none
                            ? AppColors.red
                            : AppColors.yellow)
                        .withOpacity(0.10),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: (item.iosSupport == _IosSupport.none
                              ? AppColors.red
                              : AppColors.yellow)
                          .withOpacity(0.5),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.phone_iphone_rounded,
                        size: 20,
                        color: item.iosSupport == _IosSupport.none
                            ? AppColors.red
                            : AppColors.yellow,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(item.iosNote!,
                            style: const TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 13)),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _IosBadge extends StatelessWidget {
  const _IosBadge({required this.support});

  final _IosSupport support;

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (support) {
      _IosSupport.full => (AppColors.green, 'Android e iPhone'),
      _IosSupport.limited => (AppColors.yellow, 'Limitado en iPhone'),
      _IosSupport.none => (AppColors.red, 'NO funciona en iPhone'),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(label,
          style: TextStyle(
              fontWeight: FontWeight.w800, fontSize: 11, color: color)),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 13,
                color: Theme.of(context).hintColor,
                letterSpacing: 0.5)),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}
