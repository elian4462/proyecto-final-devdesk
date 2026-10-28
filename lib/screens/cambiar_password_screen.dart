import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../utils/validadores.dart';

class CambiarPasswordScreen extends StatefulWidget {
  const CambiarPasswordScreen({super.key});

  @override
  State<CambiarPasswordScreen> createState() => _CambiarPasswordScreenState();
}

class _CambiarPasswordScreenState extends State<CambiarPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _actualCtrl = TextEditingController();
  final _nuevaCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _ocultarPass = true;

  @override
  void dispose() {
    _actualCtrl.dispose();
    _nuevaCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_nuevaCtrl.text != _confirmCtrl.text) {
      Get.snackbar('Error', 'Las contraseñas nuevas no coinciden', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    final auth = Get.find<AuthController>();
    final ok = await auth.cambiarPassword(_actualCtrl.text, _nuevaCtrl.text);
    if (ok) {
      Get.back();
      Get.snackbar(
        'Contraseña Actualizada',
        'Tu contraseña fue cambiada con éxito.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cambiar Contraseña'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _actualCtrl,
                obscureText: _ocultarPass,
                decoration: const InputDecoration(
                  labelText: 'Contraseña actual',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                validator: (v) => Validadores.requerido(v, 'La contraseña actual'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nuevaCtrl,
                obscureText: _ocultarPass,
                decoration: InputDecoration(
                  labelText: 'Nueva contraseña',
                  prefixIcon: const Icon(Icons.lock_reset),
                  suffixIcon: IconButton(
                    icon: Icon(_ocultarPass ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _ocultarPass = !_ocultarPass),
                  ),
                ),
                validator: Validadores.password,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmCtrl,
                obscureText: _ocultarPass,
                decoration: const InputDecoration(
                  labelText: 'Confirmar nueva contraseña',
                  prefixIcon: Icon(Icons.check_circle_outline),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Confirma la nueva contraseña';
                  if (v != _nuevaCtrl.text) return 'Las contraseñas no coinciden';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Obx(() => FilledButton(
                    onPressed: auth.cargando.value ? null : _submit,
                    child: auth.cargando.value
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Actualizar Contraseña'),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
