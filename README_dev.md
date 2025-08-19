@'
# Mecánico Virtual — Guía rápida para dev

## Requisitos
- Flutter instalado (`flutter --version`)
- Android Studio o VS Code con extensiones Flutter/Dart
- JDK (Temurin 21 recomendado)

## Estructura sugerida
lib/
  main.dart
  screens/
  services/
  models/
  widgets/

- **services**: TTS, Firebase, storage, etc.
- **models**: entidades (UserProfile, VehicleSelection…)
- **widgets**: UI reutilizable

## Comandos clave
flutter clean
flutter pub get
flutter run
dart format .
flutter analyze

## Build APK
flutter build apk                # debug universal
flutter build apk --release      # release optimizado
# Salida: build/app/outputs/flutter-apk/

## Variables de entorno
- No subas `.env` (ya está en .gitignore).
- Cargar en main() antes de runApp:
  // await dotenv.load(fileName: ".env");

## Flujo Git básico
git status
git add .
git commit -m "mensaje"
git push

### Aplicar cambios que te pasen
# Si recibes archivos completos: reemplazá y probá.
# Si recibes .patch (opcional en el futuro):
#   git apply --3way archivo.patch

## Tip
1) Hacé commit/push de tus cambios.
2) Decime el hash corto: git rev-parse --short HEAD
3) Yo preparo el siguiente ajuste sobre tu repo.
'@ | Set-Content -Encoding utf8 README_dev.md
