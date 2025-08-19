import 'package:flutter/material.dart';

class PanelServiciosScreen extends StatelessWidget {
  const PanelServiciosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = <_ServiceItem>[
      _ServiceItem(
        icon: Icons.speed,
        title: 'Escaneo en tiempo real',
        subtitle: 'Próximamente (OBDII)',
        enabled: false,
        onTap: () {
          _showSnack(context, 'Esta función estará disponible pronto.');
        },
      ),
      _ServiceItem(
        icon: Icons.fact_check,
        title: 'Diagnóstico rápido',
        subtitle: 'Chequeo guiado en minutos',
        onTap: () {
          _showSnack(context, 'Abrir “Diagnóstico rápido” (TODO).');
          // TODO: Navigator.push(... a tu pantalla de diagnóstico)
        },
      ),
      _ServiceItem(
        icon: Icons.event_note,
        title: 'Recordatorios',
        subtitle: 'Aceite, VTV y más',
        onTap: () {
          _showSnack(context, 'Abrir “Recordatorios” (TODO).');
          // TODO: Navigator.push(... a tu pantalla de recordatorios)
        },
      ),
      _ServiceItem(
        icon: Icons.history,
        title: 'Historial del vehículo',
        subtitle: 'Servicios y cambios',
        onTap: () {
          _showSnack(context, 'Abrir “Historial” (TODO).');
          // TODO: Navigator.push(... a tu pantalla de historial)
        },
      ),
      _ServiceItem(
        icon: Icons.warning_amber_rounded,
        title: 'Alertas preventivas',
        subtitle: 'Por tiempo o km',
        onTap: () {
          _showSnack(context, 'Abrir “Alertas preventivas” (TODO).');
          // TODO: Navigator.push(... a tu pantalla de alertas)
        },
      ),
      _ServiceItem(
        icon: Icons.lightbulb,
        title: 'Guía de testigos',
        subtitle: 'Explicación simple',
        onTap: () {
          _showSnack(context, 'Abrir “Guía de testigos” (TODO).');
          // TODO: Navigator.push(... a tu pantalla de guía)
        },
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cacho Bujía — Panel'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          itemCount: items.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,           // 2 columnas
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.05,
          ),
          itemBuilder: (_, i) => _ServiceCard(item: items[i]),
        ),
      ),
    );
  }

  static void _showSnack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}

class _ServiceItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool enabled;
  final VoidCallback onTap;

  _ServiceItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.enabled = true,
  });
}

class _ServiceCard extends StatelessWidget {
  final _ServiceItem item;
  const _ServiceCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final disabled = !item.enabled;

    return InkWell(
      onTap: disabled ? null : item.onTap,
      child: Card(
        elevation: 2,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(14),
          foregroundDecoration: disabled
              ? BoxDecoration(color: Colors.grey.withOpacity(0.08))
              : null,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(item.icon, size: 36),
              const SizedBox(height: 10),
              Text(
                item.title,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium,
                maxLines: 2,
              ),
              const SizedBox(height: 6),
              Text(
                item.subtitle,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.textTheme.bodySmall?.color?.withOpacity(0.75),
                ),
                maxLines: 2,
              ),
              if (disabled) ...[
                const SizedBox(height: 8),
                const Badge(label: Text('Pronto')),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
