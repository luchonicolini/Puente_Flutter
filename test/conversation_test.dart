import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:puente/core/services/speech_service.dart';
import 'package:puente/core/services/tts_service.dart';
import 'package:puente/core/theme/app_theme.dart';
import 'package:puente/core/widgets/not_understood_sheet.dart';
import 'package:puente/features/conversation/conversation_screen.dart';

class FakeSpeechService implements SpeechService {
  FakeSpeechService({
    this.initialAvailable = true,
    this.initialHasPermission = true,
  });

  bool initialAvailable;
  bool initialHasPermission;

  SpeechState _state = SpeechState.uninitialized;
  bool _isListening = false;
  void Function(SpeechState state)? _onStateChanged;
  void Function(String errorMessage)? _onError;
  void Function(String words, bool isFinal)? _onResult;

  @override
  SpeechState get state => _state;

  @override
  bool get isListening => _isListening;

  @override
  bool get isAvailable => initialAvailable;

  @override
  Future<bool> get hasPermission async => initialHasPermission;

  @override
  Future<bool> initialize({
    void Function(SpeechState state)? onStateChanged,
    void Function(String errorMessage)? onError,
  }) async {
    _onStateChanged = onStateChanged;
    _onError = onError;
    if (!initialHasPermission) {
      _state = SpeechState.denied;
      _onStateChanged?.call(_state);
      return false;
    }
    if (!initialAvailable) {
      _state = SpeechState.notAvailable;
      _onStateChanged?.call(_state);
      return false;
    }
    _state = SpeechState.ready;
    _onStateChanged?.call(_state);
    return true;
  }

  @override
  Future<void> startListening({
    required void Function(String words, bool isFinal) onResult,
    String? localeId,
  }) async {
    _isListening = true;
    _state = SpeechState.listening;
    _onResult = onResult;
    _onStateChanged?.call(_state);
  }

  void emitResult(String words, {bool isFinal = false}) {
    _onResult?.call(words, isFinal);
    if (isFinal) {
      _isListening = false;
      _state = SpeechState.ready;
      _onStateChanged?.call(_state);
    }
  }

  @override
  Future<void> stopListening() async {
    _isListening = false;
    _state = SpeechState.ready;
    _onStateChanged?.call(_state);
  }

  @override
  Future<void> cancelListening() async {
    _isListening = false;
    _state = SpeechState.ready;
    _onStateChanged?.call(_state);
  }

  @override
  void dispose() {
    _isListening = false;
  }
}

class FakeTtsService implements TtsService {
  bool _isSpeaking = false;
  String? lastSpokenText;
  int speakCount = 0;
  int stopCount = 0;

  @override
  bool get isSpeaking => _isSpeaking;

  @override
  Future<void> initialize({String? languageCode, double? speechRate}) async {}

  @override
  Future<void> speak(String text) async {
    _isSpeaking = true;
    lastSpokenText = text;
    speakCount++;
  }

  @override
  Future<void> stop() async {
    _isSpeaking = false;
    stopCount++;
  }

  @override
  Future<void> setSpeechRate(double rate) async {}

  @override
  void dispose() {
    _isSpeaking = false;
  }
}

void main() {
  Widget createConversationScreen({
    SpeechService? speechService,
    TtsService? ttsService,
  }) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: ConversationScreen(
        speechService: speechService,
        ttsService: ttsService,
      ),
    );
  }

  testWidgets('ConversationScreen renders all components matching the approved mockup',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);

    final fakeSpeech = FakeSpeechService();
    final fakeTts = FakeTtsService();

    await tester.pumpWidget(createConversationScreen(
      speechService: fakeSpeech,
      ttsService: fakeTts,
    ));
    await tester.pumpAndSettle();

    // 1. Cabecera
    expect(find.text('Conversación'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsOneWidget);
    expect(find.byIcon(Icons.delete_outline_rounded), findsOneWidget);

    // 2. Historial de mensajes y timestamps del mockup
    expect(
      find.textContaining('Hola, quiero saber cuánto cuesta la inscripción'),
      findsOneWidget,
    );
    expect(
      find.textContaining('La inscripción es de \$20.000 y la cuota mensual cuesta \$35.000.'),
      findsOneWidget,
    );
    expect(find.text('9:41'), findsOneWidget);
    expect(find.text('9:42'), findsWidgets);

    // 3. Tarjeta de información detectada con resumen
    expect(find.text('Información detectada'), findsOneWidget);
    expect(find.text('Inscripción'), findsOneWidget);
    expect(find.text('\$20.000'), findsOneWidget);
    expect(find.text('Cuota mensual'), findsOneWidget);
    expect(find.text('\$35.000'), findsOneWidget);

    // 4. Los tres accesos circulares rápidos
    expect(find.text('Presentarme'), findsOneWidget);
    expect(find.text('No entendí'), findsOneWidget);
    expect(find.text('Confirmar'), findsOneWidget);

    // 5. Compositor de texto y botón de envío
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Escribí tu mensaje…'), findsOneWidget);

    // 6. Fila inferior de audio y micrófono
    expect(find.text('Tocá para hablar'), findsOneWidget);
    expect(find.byIcon(Icons.mic_rounded), findsOneWidget);
    expect(find.byIcon(Icons.mic_off_outlined), findsOneWidget);
    expect(find.byIcon(Icons.volume_up_outlined), findsOneWidget);
  });

  testWidgets('Tapping No entendí opens NotUnderstoodSheet with 4 options',
      (WidgetTester tester) async {
    final fakeSpeech = FakeSpeechService();
    final fakeTts = FakeTtsService();

    await tester.pumpWidget(createConversationScreen(
      speechService: fakeSpeech,
      ttsService: fakeTts,
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('No entendí'));
    await tester.pumpAndSettle();

    expect(find.byType(NotUnderstoodSheet), findsOneWidget);
    expect(find.text('¿Podés repetirlo?'), findsOneWidget);
    expect(find.text('¿Podés escribirlo?'), findsOneWidget);
    expect(find.text('¿Podés hablar más despacio?'), findsOneWidget);
    expect(find.text('¿Podés explicarlo de otra manera?'), findsOneWidget);
  });

  testWidgets('Tapping mic starts listening and displays real-time banner',
      (WidgetTester tester) async {
    final fakeSpeech = FakeSpeechService();
    final fakeTts = FakeTtsService();

    await tester.pumpWidget(createConversationScreen(
      speechService: fakeSpeech,
      ttsService: fakeTts,
    ));
    await tester.pumpAndSettle();

    expect(fakeSpeech.isListening, isFalse);

    // Tocar micrófono
    await tester.tap(find.byIcon(Icons.mic_rounded));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(fakeSpeech.isListening, isTrue);
    expect(find.text('Escuchando a la otra persona…'), findsOneWidget);
    expect(find.text('Escuchando…'), findsOneWidget);
    expect(find.byIcon(Icons.stop_rounded), findsOneWidget);

    // Emitir palabras parciales
    fakeSpeech.emitResult('Buenas tardes,');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Escuchando: "Buenas tardes,"'), findsOneWidget);

    // Detener escucha con el botón de detener
    await tester.tap(find.text('Detener'));
    await tester.pumpAndSettle();

    expect(fakeSpeech.isListening, isFalse);
    expect(find.text('Tocá para hablar'), findsOneWidget);
  });

  testWidgets('Final transcription result commits a new message from interlocutor',
      (WidgetTester tester) async {
    final fakeSpeech = FakeSpeechService();
    final fakeTts = FakeTtsService();

    await tester.pumpWidget(createConversationScreen(
      speechService: fakeSpeech,
      ttsService: fakeTts,
    ));
    await tester.pumpAndSettle();

    // Iniciar escucha
    await tester.tap(find.byIcon(Icons.mic_rounded));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Enviar resultado final
    fakeSpeech.emitResult('Tenemos una promoción con 20% de descuento.', isFinal: true);
    await tester.pumpAndSettle();

    expect(
      find.text('Tenemos una promoción con 20% de descuento.'),
      findsOneWidget,
    );
    expect(fakeSpeech.isListening, isFalse);
  });

  testWidgets('Microphone permission denied shows notice dialog',
      (WidgetTester tester) async {
    final fakeSpeech = FakeSpeechService(initialHasPermission: false);
    final fakeTts = FakeTtsService();

    await tester.pumpWidget(createConversationScreen(
      speechService: fakeSpeech,
      ttsService: fakeTts,
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.mic_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Permiso de micrófono necesario'), findsOneWidget);
    expect(find.text('Entendido'), findsOneWidget);

    await tester.tap(find.text('Entendido'));
    await tester.pumpAndSettle();
  });

  testWidgets('Tapping mute icon mutes audio and blocks mic',
      (WidgetTester tester) async {
    final fakeSpeech = FakeSpeechService();
    final fakeTts = FakeTtsService();

    await tester.pumpWidget(createConversationScreen(
      speechService: fakeSpeech,
      ttsService: fakeTts,
    ));
    await tester.pumpAndSettle();

    // Silenciar
    await tester.tap(find.byIcon(Icons.mic_off_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Silenciado'), findsOneWidget);

    // Tocar micrófono mientras está silenciado
    await tester.tap(find.byIcon(Icons.mic_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Micrófono silenciado'), findsWidgets);
    expect(find.text('Entendido'), findsOneWidget);
  });

  testWidgets('Tapping TTS speaker invokes speech synthesis for last message',
      (WidgetTester tester) async {
    final fakeSpeech = FakeSpeechService();
    final fakeTts = FakeTtsService();

    await tester.pumpWidget(createConversationScreen(
      speechService: fakeSpeech,
      ttsService: fakeTts,
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.volume_up_outlined));
    await tester.pumpAndSettle();

    expect(fakeTts.speakCount, equals(1));
    expect(fakeTts.lastSpokenText, contains('cuota mensual cuesta \$35.000'));
  });

  testWidgets('Final transcription detects sensitive data and displays DetectedInfoCard',
      (WidgetTester tester) async {
    final fakeSpeech = FakeSpeechService();
    final fakeTts = FakeTtsService();

    await tester.pumpWidget(createConversationScreen(
      speechService: fakeSpeech,
      ttsService: fakeTts,
    ));
    await tester.pumpAndSettle();

    // Iniciar escucha
    await tester.tap(find.byIcon(Icons.mic_rounded));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Enviar resultado final con precio y horario
    fakeSpeech.emitResult(r'El turno sale $15.000 a las 18:30 hs.', isFinal: true);
    await tester.pumpAndSettle();

    expect(find.text(r'El turno sale $15.000 a las 18:30 hs.'), findsOneWidget);
    expect(find.text('Información detectada'), findsWidgets);
    expect(find.text(r'$15.000'), findsOneWidget);
    expect(find.text('18:30 hs'), findsOneWidget);
    expect(find.text('Confirmar por escrito'), findsWidgets);
  });
}
