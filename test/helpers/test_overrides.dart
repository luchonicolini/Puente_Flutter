import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:puente/core/services/gemini_expression_assist_service.dart';
import 'package:puente/core/services/haptic_service.dart';
import 'package:puente/core/services/permission_service.dart';
import 'package:puente/core/services/services_providers.dart';
import 'package:puente/core/services/stt_service.dart';
import 'package:puente/core/services/tts_service.dart';
import 'package:puente/core/storage/quick_phrases_store.dart';
import 'package:puente/domain/expression/expression_assist.dart';

/// Overrides estándar para Riverpod en el entorno de pruebas.
/// Reemplaza todos los servicios nativos con dobles de prueba controlables.
List<Override> createTestOverrides({
  TtsService? ttsService,
  SttService? sttService,
  HapticService? hapticService,
  PermissionService? permissionService,
  QuickPhrasesStore? quickPhrasesStore,
  ExpressionAssistService? expressionAssistService,
}) {
  return [
    ttsServiceProvider.overrideWithValue(ttsService ?? MockTtsService()),
    sttServiceProvider.overrideWithValue(sttService ?? MockSttService()),
    hapticServiceProvider.overrideWithValue(
      hapticService ?? MockHapticService(),
    ),
    permissionServiceProvider.overrideWithValue(
      permissionService ?? MockPermissionService(granted: true),
    ),
    quickPhrasesStoreProvider.overrideWithValue(
      quickPhrasesStore ?? MockQuickPhrasesStore(),
    ),
    expressionAssistServiceProvider.overrideWithValue(
      expressionAssistService ?? MockExpressionAssistService(),
    ),
  ];
}
