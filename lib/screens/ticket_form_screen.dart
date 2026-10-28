import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/tickets_controller.dart';
import '../models/ticket.dart';
import '../utils/validadores.dart';

class TicketFormScreen extends StatefulWidget {
  final Ticket? ticket;
  final String? equipoInicial;
  final String? categoriaInicial;

  const TicketFormScreen({
    super.key,
    this.ticket,
    this.equipoInicial,
    this.categoriaInicial,
  });

  @override
  State<TicketFormScreen> createState() => _TicketFormScreenState();
}

class _TicketFormScreenState extends State<TicketFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _tituloCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _equipoCtrl;
  late String _categoria;
  late String _prioridad;
  bool _guardando = false;

  bool get _esEdicion => widget.ticket != null;

  @override
  void initState() {
    super.initState();
    _tituloCtrl = TextEditingController(text: widget.ticket?.titulo ?? '');
    _descCtrl = TextEditingController(text: widget.ticket?.descripcion ?? '');
    _equipoCtrl = TextEditingController(
      text: widget.ticket?.equipoAfectado ?? widget.equipoInicial ?? 'General',
    );
    _categoria = widget.ticket?.categoria ?? widget.categoriaInicial ?? 'servidores';
    _prioridad = widget.ticket?.prioridad ?? 'media';
  }

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _descCtrl.dispose();
    _equipoCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _guardando = true);

    final ticketsCtrl = Get.find<TicketsController>();
    bool exito;

    if (_esEdicion) {
      final t = widget.ticket!;
      final cambios = <String, dynamic>{};
      if (_tituloCtrl.text.trim() != t.titulo) cambios['titulo'] = _tituloCtrl.text.trim();
      if (_descCtrl.text.trim() != t.descripcion) cambios['descripcion'] = _descCtrl.text.trim();
      if (_equipoCtrl.text.trim() != t.equipoAfectado) cambios['equipo_afectado'] = _equipoCtrl.text.trim();
      if (_categoria != t.categoria) cambios['categoria'] = _categoria;
      if (_prioridad != t.prioridad) cambios['prioridad'] = _prioridad;

      if (cambios.isEmpty) {
        Get.back();
        return;
      }
      exito = await ticketsCtrl.actualizarTicket(t.id, cambios);
    } else {
      exito = await ticketsCtrl.crearTicket(
        titulo: _tituloCtrl.text.trim(),
        descripcion: _descCtrl.text.trim(),
        categoria: _categoria,
        prioridad: _prioridad,
        equipoAfectado: _equipoCtrl.text.trim(),
      );
    }

    if (mounted) setState(() => _guardando = false);
    if (exito) Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_esEdicion ? 'Editar Ticket #${widget.ticket!.id}' : 'Registrar Nuevo Ticket'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _tituloCtrl,
                decoration: const InputDecoration(
                  labelText: 'Título o Asunto de la Incidencia',
                  hintText: 'Ej. Falla de conectividad en cluster DB',
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (v) => Validadores.requerido(v, 'El título'),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _categoria,
                      decoration: const InputDecoration(
                        labelText: 'Categoría',
                        prefixIcon: Icon(Icons.category_outlined),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'servidores', child: Text('Servidores')),
                        DropdownMenuItem(value: 'redes', child: Text('Redes')),
                        DropdownMenuItem(value: 'hardware', child: Text('Hardware')),
                        DropdownMenuItem(value: 'software', child: Text('Software')),
                        DropdownMenuItem(value: 'seguridad', child: Text('Seguridad')),
                      ],
                      onChanged: (v) {
                        if (v != null) setState(() => _categoria = v);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _prioridad,
                      decoration: const InputDecoration(
                        labelText: 'Prioridad',
                        prefixIcon: Icon(Icons.priority_high),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'baja', child: Text('Baja')),
                        DropdownMenuItem(value: 'media', child: Text('Media')),
                        DropdownMenuItem(value: 'alta', child: Text('Alta (Crítica)')),
                      ],
                      onChanged: (v) {
                        if (v != null) setState(() => _prioridad = v);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _equipoCtrl,
                decoration: const InputDecoration(
                  labelText: 'Equipo o Activo Afectado',
                  hintText: 'SRV-DB-PRIMARY, FW-CORE, etc.',
                  prefixIcon: Icon(Icons.dns_outlined),
                ),
                validator: (v) => Validadores.requerido(v, 'El equipo afectado'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descCtrl,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Descripción detallada del problema',
                  hintText: 'Describe el síntoma, impacto y logs relevantes...',
                  alignLabelWithHint: true,
                ),
                validator: (v) => Validadores.requerido(v, 'La descripción'),
              ),
              const SizedBox(height: 28),
              FilledButton.icon(
                onPressed: _guardando ? null : _guardar,
                icon: _guardando
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.save),
                label: Text(
                  _esEdicion ? 'Guardar Cambios' : 'Registrar Ticket',
                  style: const TextStyle(fontSize: 16),
                ),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
