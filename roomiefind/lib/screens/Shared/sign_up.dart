import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:roomiefind/viewmodels/auth_viewmodel.dart';
import 'role_selection.dart'; 

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool _acceptedTerms = false;
  final _formKey = GlobalKey<FormState>(); // Para validar todo el formulario a la vez

  // 1. Controladores para todos los campos
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _confirmEmailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _userController.dispose();
    _emailController.dispose();
    _confirmEmailController.dispose();
    _passController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final authViewModel = Provider.of<AuthViewModel>(context);

    return Scaffold(
      backgroundColor: colors.secondary,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: Form( // Envolvemos todo en un Form
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Registra tu cuenta', style: TextStyle(color: colors.primary, fontSize: 26, fontWeight: FontWeight.bold)),
              const SizedBox(height: 30),

              // Nombre y Apellidos
              _buildLabel('Nombre y Apellidos'),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(hintText: 'Ej: Juan Pérez'),
                validator: (value) => value!.isEmpty ? 'Introduce tu nombre' : null,
              ),
              const SizedBox(height: 15),

              // Nombre de Usuario
              _buildLabel('Nombre de Usuario'),
              TextFormField(
                controller: _userController,
                decoration: const InputDecoration(hintText: 'juanito123'),
                validator: (value) => value!.isEmpty ? 'Introduce un usuario' : null,
              ),
              const SizedBox(height: 15),

              // Correo
              _buildLabel('Correo electrónico'),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(hintText: 'correo@ejemplo.com'),
                validator: (value) => !value!.contains('@') ? 'Email inválido' : null,
              ),
              const SizedBox(height: 15),

              // Confirmar Correo
              _buildLabel('Confirmar correo'),
              TextFormField(
                controller: _confirmEmailController,
                decoration: const InputDecoration(hintText: 'Repite tu correo'),
                validator: (value) => value != _emailController.text ? 'Los correos no coinciden' : null,
              ),
              const SizedBox(height: 15),

              // Contraseña
              _buildLabel('Contraseña'),
              TextFormField(
                controller: _passController,
                obscureText: true,
                decoration: const InputDecoration(hintText: 'Min. 6 caracteres'),
                validator: (value) => value!.length < 6 ? 'Mínimo 6 caracteres' : null,
              ),
              const SizedBox(height: 15),

              // Confirmar Contraseña
              _buildLabel('Confirmar contraseña'),
              TextFormField(
                controller: _confirmPassController,
                obscureText: true,
                decoration: const InputDecoration(hintText: 'Repite tu contraseña'),
                validator: (value) => value != _passController.text ? 'Las contraseñas no coinciden' : null,
              ),
              const SizedBox(height: 25),

              // Checkbox Términos
              Row(
                children: [
                  Checkbox(
                    value: _acceptedTerms,
                    onChanged: (v) => setState(() => _acceptedTerms = v!),
                  ),
                  const Expanded(child: Text("Acepto términos y condiciones")),
                ],
              ),
              const SizedBox(height: 30),

              // Botón Registrarme
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (authViewModel.isLoading || !_acceptedTerms)
                      ? null
                      : () async {
                          // 2. Ejecutar validaciones locales antes de ir a Supabase
                          if (_formKey.currentState!.validate()) {
                            final success = await authViewModel.register(
                              email: _emailController.text.trim(),
                              password: _passController.text.trim(),
                              fullName: _nameController.text.trim(),
                              username: _userController.text.trim(),
                            );

                            if (success && mounted) {
                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const RoleSelectionScreen()));
                            } else if (!success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(authViewModel.errorMessage ?? 'Error'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                  child: authViewModel.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Registrarme'),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
    );
  }
}