import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:roomiefind/viewmodels/auth_viewmodel.dart';
// Importamos las rutas en lugar del archivo directo
import 'package:roomiefind/routes/routes.dart'; 

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool _acceptedTerms = false;
  final _formKey = GlobalKey<FormState>(); 

  // Controladores
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
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, iconTheme: IconThemeData(color: colors.primary)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Registra tu cuenta', 
                style: TextStyle(color: colors.primary, fontSize: 26, fontWeight: FontWeight.bold)),
              const SizedBox(height: 30),

              _buildLabel('Nombre y Apellidos'),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(hintText: 'Ej: Juan Pérez'),
                validator: (value) => value!.isEmpty ? 'Introduce tu nombre' : null,
              ),
              const SizedBox(height: 15),

              _buildLabel('Nombre de Usuario'),
              TextFormField(
                controller: _userController,
                decoration: const InputDecoration(hintText: 'juanito123'),
                validator: (value) => value!.isEmpty ? 'Introduce un usuario' : null,
              ),
              const SizedBox(height: 15),

              _buildLabel('Correo electrónico'),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(hintText: 'correo@ejemplo.com'),
                validator: (value) => !value!.contains('@') ? 'Email inválido' : null,
              ),
              const SizedBox(height: 15),

              _buildLabel('Confirmar correo'),
              TextFormField(
                controller: _confirmEmailController,
                decoration: const InputDecoration(hintText: 'Repite tu correo'),
                validator: (value) => value != _emailController.text ? 'Los correos no coinciden' : null,
              ),
              const SizedBox(height: 15),

              _buildLabel('Contraseña'),
              TextFormField(
                controller: _passController,
                obscureText: true,
                decoration: const InputDecoration(hintText: 'Min. 6 caracteres'),
                validator: (value) => value!.length < 6 ? 'Mínimo 6 caracteres' : null,
              ),
              const SizedBox(height: 15),

              _buildLabel('Confirmar contraseña'),
              TextFormField(
                controller: _confirmPassController,
                obscureText: true,
                decoration: const InputDecoration(hintText: 'Repite tu contraseña'),
                validator: (value) => value != _passController.text ? 'Las contraseñas no coinciden' : null,
              ),
              const SizedBox(height: 25),

              Row(
                children: [
                  Checkbox(
                    activeColor: colors.primary,
                    value: _acceptedTerms,
                    onChanged: (v) => setState(() => _acceptedTerms = v!),
                  ),
                  const Expanded(child: Text("Al hacer clic en continuar, aceptas nuestros Términos de Servicio y nuestra Política de Privacidad", style: TextStyle(fontSize: 12))),
                ],
              ),
              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (authViewModel.isLoading || !_acceptedTerms)
                      ? null
                      : () async {
                          if (_formKey.currentState!.validate()) {
                            final success = await authViewModel.register(
                              email: _emailController.text.trim(),
                              password: _passController.text.trim(),
                              fullName: _nameController.text.trim(),
                              username: _userController.text.trim(),
                            );

                            if (success && mounted) {
                              // NAVEGACIÓN POR RUTA NOMBRADA
                              Navigator.pushReplacementNamed(context, AppRoutes.roleSelection);
                            } else if (!success && mounted) {
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
                      ? const SizedBox(
                          height: 20, 
                          width: 20, 
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                        )
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