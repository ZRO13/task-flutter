
**Gestión de tareas y productividad basada en Voltios.**
Proyecto final — *Aplicaciones Móviles* (Grupo 9-2) — Ingeniería de Software.

VOLT reinventa la gestión de tareas asignando **Voltios** (energía) a cada tarea en lugar de solo prioridades. El usuario tiene un presupuesto diario de Voltios para evitar la sobrecarga y el *burnout*.

---

## 🎯 Diferenciador principal — Sistema de Voltaje

| Nivel de energía | Voltios (V) | Ejemplo |
|---|---|---|
| Baja | 10 V | Responder un correo |
| Media | 30 V | Escribir un informe |
| Alta | 50 V | Estudiar para un examen |

Cada usuario tiene un **límite diario configurable** (por defecto **100 V**). La app bloquea la creación de tareas cuando el día excede el presupuesto, promoviendo una carga de trabajo saludable.

---

## 🏗️ Arquitectura — Clean Architecture + Riverpod

El proyecto separa estrictamente tres capas por *feature*:

```
lib/
├── main.dart                      # Punto de entrada + inyección de dependencias
├── core/                          # Transversal a todas las features
│   ├── config/
│   │   ├── app_config.dart        # Lectura de variables de entorno (.env)
│   │   └── supabase_client.dart   # Singleton del cliente Supabase
│   ├── theme/
│   │   ├── app_colors.dart        # Sistema de colores (rampas + acentos neón)
│   │   └── app_theme.dart         # ThemeData (Material 3, dark por defecto)
│   ├── router/
│   │   └── app_router.dart        # GoRouter + redirect por estado de sesión
│   ├── utils/
│   │   ├── volt_utils.dart        # Cálculos de voltaje (consumo, límites)
│   │   └── form_validators.dart   # Validadores de formularios
│   └── widgets/                   # Widgets reutilizables
│       ├── volt_meter.dart        # Medidor circular de Voltios del día
│       ├── volt_chip.dart         # Chip de nivel de energía
│       └── async_value_widget.dart# Wrapper para AsyncValue (loading/error/data)
└── features/
    ├── auth/                      # Autenticación
    │   ├── domain/
    │   │   ├── entities/app_user.dart
    │   │   ├── repositories/auth_repository.dart   # abstract
    │   │   └── usecases/                           # (casos de uso finos)
    │   ├── data/
    │   │   └── auth_repository_impl.dart           # implementación Supabase
    │   ├── presentation/
    │   │   ├── providers/auth_providers.dart       # Riverpod providers
    │   │   ├── controllers/auth_controller.dart    # StateNotifier<AuthState>
    │   │   └── screens/
    │   │       ├── splash_screen.dart
    │   │       ├── login_screen.dart
    │   │       └── register_screen.dart
    └── tasks/                     # Gestión de tareas (CRUD)
        ├── domain/
        │   ├── entities/task_entity.dart
        │   ├── enums/task_status.dart
        │   └── repositories/task_repository.dart  # abstract
        ├── data/
        │   └── task_repository_impl.dart           # implementación Supabase
        └── presentation/
            ├── providers/task_providers.dart       # Riverpod providers
            ├── controllers/task_controller.dart    # StateNotifier<TaskListState>
            └── screens/
                ├── home_screen.dart                # Dashboard + medidor de Voltios
                ├── task_form_screen.dart           # Crear / editar tarea
                └── widgets/
                    └── task_card.dart
```

**Principios aplicados:**

- **Domain** no depende de Flutter ni de Supabase — solo Dart puro (entidades, interfaces de repositorio).
- **Data** implementa las interfaces del dominio usando el cliente Supabase.
- **Presentation** usa Riverpod (`StateNotifier`) y consume los repositorios vía inyección.
- La **inversión de dependencias** se logra con Riverpod providers: la UI nunca instancia un repositorio concreto.

---

## 🛠️ Stack tecnológico

| Capa | Tecnología |
|---|---|
| Frontend | Flutter (Dart) ≥ 3.19 |
| Backend / DB / Auth | Supabase (PostgreSQL + RLS) |
| Gestión de estado | Riverpod 2.x (`flutter_riverpod`) |
| Routing | GoRouter |
| Auth social | Google Sign-In vía Supabase |

---

## 🔐 Backend — Supabase

### Tablas

- **`profiles`** — perfil de usuario con `daily_volt_limit` (default 100).
- **`tasks`** — tareas con `volts`, `status` (`todo`/`in_progress`/`done`), `due_date`.

### Seguridad (RLS)

- RLS habilitado en ambas tablas.
- Políticas *owner-scoped*: cada usuario solo accede a **sus** filas (`auth.uid() = user_id` / `auth.uid() = id`).
- Trigger `on_auth_user_created` crea automáticamente el `profile` al registrarse.
- Trigger `tasks_set_updated_at` mantiene `updated_at` al día.

> El DDL completo está en `supabase/migrations/create_profiles_and_tasks.sql`.

---

## 🚀 Ejecución

```bash
flutter pub get
flutter run
```

> Las credenciales de Supabase se leen desde `.env` (`VITE_SUPABASE_URL`, `VITE_SUPABASE_ANON_KEY`).

---

## 📚 Módulos

1. **Autenticación** — Login/Registro con correo, Google Sign-In, *splash screen* inteligente, persistencia de sesión.
2. **Dashboard (Home)** — Medidor de Voltios consumidos vs. disponibles, lista de tareas del día por estado.
3. **CRUD de tareas** — Crear, leer, actualizar y eliminar, con asignación de Voltios y validación del límite diario.

---

## 👥 Grupo 9-2 — Aplicaciones Móviles

Proyecto académico para la sustentación final de la materia.
