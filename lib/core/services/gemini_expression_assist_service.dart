import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../../domain/expression/expression_alternatives.dart';
import '../../domain/expression/expression_assist.dart';

typedef ExpressionHttpPost =
    Future<({int statusCode, String body})> Function(
      Uri uri,
      Map<String, String> headers,
      String body,
    );

/// Servicio cliente para consultar sugerencias de Expresar a través del
/// proxy seguro en Supabase Edge Functions (sin almacenar claves de IA en la app).
class SupabaseGeminiExpressionAssistService implements ExpressionAssistService {
  SupabaseGeminiExpressionAssistService({
    String? endpointUrl,
    String? publishableKey,
    this.post,
    this.timeout = const Duration(seconds: 15),
  }) : endpointUrl =
           endpointUrl ??
           const String.fromEnvironment(
             'PUENTE_EXPRESSION_AI_URL',
             defaultValue:
                 'https://fuoelcgnzylyoldcxpul.supabase.co/functions/v1/expression-assist',
           ),
       publishableKey =
           publishableKey ??
           const String.fromEnvironment(
             'PUENTE_SUPABASE_PUBLISHABLE_KEY',
             defaultValue: 'sb_publishable_ma0oiLbY1p4NMjz3SO-_ig_fBKbZFso',
           );

  final String endpointUrl;
  final String publishableKey;
  final ExpressionHttpPost? post;
  final Duration timeout;

  @override
  Future<ExpressionAssistResult> assist({
    required String text,
    ExpressionIntent? intent,
    String? clarificationChoice,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      return ExpressionAssistResult.local(input: trimmed, intent: intent);
    }

    final uri = Uri.tryParse(endpointUrl);
    if (uri == null || !uri.hasScheme || publishableKey.trim().isEmpty) {
      throw const ExpressionAssistException(
        'El servicio de asistencia con IA no está configurado.',
        isNotConfigured: true,
      );
    }

    final payload = jsonEncode({
      'text': trimmed,
      if (intent != null) 'intent': intent.name,
      if (clarificationChoice != null && clarificationChoice.trim().isNotEmpty)
        'clarificationChoice': clarificationChoice.trim(),
    });

    final headers = <String, String>{
      'Content-Type': 'application/json; charset=utf-8',
      'apikey': publishableKey,
    };

    try {
      final response = await (post ?? _defaultPost)(
        uri,
        headers,
        payload,
      ).timeout(timeout);

      Map<String, dynamic>? decoded;
      try {
        final raw = jsonDecode(response.body);
        if (raw is Map<String, dynamic>) decoded = raw;
      } catch (_) {
        decoded = null;
      }

      if (response.statusCode == 503 &&
          decoded?['error'] == 'ai_not_configured') {
        throw const ExpressionAssistException(
          'La asistencia de IA no está disponible en este momento.',
          isNotConfigured: true,
        );
      }

      if (response.statusCode < 200 || response.statusCode >= 300) {
        final serverMessage = (decoded?['message'] as String?)?.trim();
        throw ExpressionAssistException(
          (serverMessage != null && serverMessage.isNotEmpty)
              ? serverMessage
              : 'No pudimos conectar con el asistente de IA ahora.',
        );
      }

      if (decoded == null) {
        throw const ExpressionAssistException(
          'La respuesta del asistente no tuvo el formato esperado.',
        );
      }

      return ExpressionAssistResult.fromAiJson(
        originalText: trimmed,
        json: decoded,
      );
    } on ExpressionAssistException {
      rethrow;
    } on TimeoutException {
      throw const ExpressionAssistException(
        'La asistencia de IA tardó demasiado. Podés usar las opciones locales.',
      );
    } on SocketException {
      throw const ExpressionAssistException(
        'Sin conexión. Podés usar las opciones locales o tu texto original.',
      );
    } on FormatException catch (error) {
      throw ExpressionAssistException(error.message);
    } catch (_) {
      throw const ExpressionAssistException(
        'No pudimos conectar con la asistencia de IA. Podés usar las opciones locales.',
      );
    }
  }

  Future<({int statusCode, String body})> _defaultPost(
    Uri uri,
    Map<String, String> headers,
    String payload,
  ) async {
    final client = HttpClient()..connectionTimeout = timeout;
    try {
      final request = await client.postUrl(uri);
      headers.forEach(request.headers.set);
      request.add(utf8.encode(payload));
      final response = await request.close();
      final body = await utf8.decodeStream(response);
      return (statusCode: response.statusCode, body: body);
    } finally {
      client.close(force: true);
    }
  }
}

/// Doble de prueba controlable para pruebas de widgets sin red real.
class MockExpressionAssistService implements ExpressionAssistService {
  MockExpressionAssistService({this.onAssist, this.errorToThrow});

  final ExpressionAssistResult Function(
    String text,
    ExpressionIntent? intent,
    String? clarificationChoice,
  )?
  onAssist;
  final Object? errorToThrow;

  int callCount = 0;
  String? lastText;
  String? lastClarificationChoice;

  @override
  Future<ExpressionAssistResult> assist({
    required String text,
    ExpressionIntent? intent,
    String? clarificationChoice,
  }) async {
    callCount++;
    lastText = text;
    lastClarificationChoice = clarificationChoice;

    if (errorToThrow != null) {
      throw errorToThrow!;
    }

    if (onAssist != null) {
      return onAssist!(text, intent, clarificationChoice);
    }

    return ExpressionAssistResult(
      originalText: text.trim(),
      source: ExpressionAssistSource.ai,
      uncertaintyNote: 'Revisá los artículos sugeridos antes de usar.',
      suggestions: [
        ExpressionSuggestion(
          label: 'Redacción clara',
          description: 'Ajusta artículos y concordancia manteniendo tu idea',
          text: text.trim(),
        ),
        ExpressionSuggestion(
          label: 'Cordial para mostrador',
          description: 'Versión amable para iniciar la atención',
          text: 'Hola, ${text.trim()}',
        ),
      ],
    );
  }
}
