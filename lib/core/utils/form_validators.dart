/// Validadores de formularios reutilizables.
///
/// Cada validador devuelve `null` cuando el valor es válido, o un mensaje
/// de error cuando no lo es (convención de `FormField.validator`).
class FormValidators {
  FormValidators._();

  static String? required(String? value, {String label = 'Este campo'}) {
    final v = value?.trim();
    if (v == null || v.isEmpty) return '$label es obligatorio';
    return null;
  }

  static String? email(String? value) {
    final v = value?.trim();
    if (v == null || v.isEmpty) return 'El correo es obligatorio';
    final regex = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$');
    if (!regex.hasMatch(v)) return 'Ingresa un correo válido';
    return null;
  }

  static String? password(String? value, {int minLength = 6}) {
    final v = value ?? '';
    if (v.isEmpty) return 'La contraseña es obligatoria';
    if (v.length < minLength) return 'Mínimo $minLength caracteres';
    return null;
  }

  static String? volts(String? value) {
    final v = int.tryParse(value ?? '');
    if (v == null) return 'Ingresa un número';
    if (v < 0) return 'No puede ser negativo';
    if (v > 200) return 'Máximo 200 V';
    return null;
  }
}
