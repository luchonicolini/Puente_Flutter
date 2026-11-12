import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:puente/core/services/gemini_expression_assist_service.dart';
import 'package:puente/domain/expression/expression_alternatives.dart';
import 'package:puente/domain/expression/expression_assist.dart';

void main() {
  group('ExpressionAssistResult', () {
    test('parsea ambigüedad, incertidumbre y sugerencias válidas', () {
      final result = ExpressionAssistResult.fromAiJson(
        originalText: 'yo querer sacar turno dia 15 3500',
        json: {
          'has_ambiguity': true,
          'ambiguity_reason':
              'No queda claro si te referís a "el turno" o "la consulta".',
          'uncertainty_note': 'Revisá la fecha 15 y el importe \$3500.',
          'interpretations': [
            {
              'id': 'turno',
              'label': 'Pedir un turno el día 15',
              'description': 'Usa masculino ("un turno")',
            },
            {
              'id': 'consulta',
              'label': 'Consultar si sale \$3500',
              'description': 'Lo formula como pregunta',
            },
          ],
          'suggestions': [
            {
              'label': 'Redacción clara',
              'description': 'Ajusta artículo y verbo',
              'text': 'Quiero sacar un turno para el día 15 por \$3500.',
            },
          ],
        },
      );

      expect(result.source, ExpressionAssistSource.ai);
      expect(result.hasAmbiguity, isTrue);
      expect(result.interpretations.length, 2);
      expect(result.uncertaintyNote, contains('15'));
      expect(result.suggestions.single.text, contains('\$3500'));
    });

    test('lanza FormatException si la respuesta viene sin propuestas', () {
      expect(
        () => ExpressionAssistResult.fromAiJson(
          originalText: 'hola',
          json: {'has_ambiguity': false, 'suggestions': []},
        ),
        throwsFormatException,
      );
    });
  });

  group('SupabaseGeminiExpressionAssistService', () {
    test('envía apikey y parsea respuesta preservando negación y cifras', () async {
      Uri? capturedUri;
      Map<String, String>? capturedHeaders;
      Map<String, dynamic>? capturedBody;

      final service = SupabaseGeminiExpressionAssistService(
        endpointUrl: 'https://example.supabase.co/functions/v1/expression-assist',
        publishableKey: 'sb_publishable_test_key',
        post: (uri, headers, body) async {
          capturedUri = uri;
          capturedHeaders = headers;
          capturedBody = jsonDecode(body) as Map<String, dynamic>;
          return (
            statusCode: 200,
            body: jsonEncode({
              'has_ambiguity': false,
              'ambiguity_reason': '',
              'uncertainty_note': 'Se usó artículo femenino "la".',
              'interpretations': [],
              'suggestions': [
                {
                  'label': 'Redacción clara',
                  'description': 'Ajusta artículos conservando la negación',
                  'text': 'No quiero la bolsa, solo las 2 facturas por \$1500.',
                },
              ],
            }),
          );
        },
      );

      final result = await service.assist(
        text: 'no querer el bolsa solo 2 factura 1500',
        intent: ExpressionIntent.clarification,
        clarificationChoice: 'Bolsa en femenino',
      );

      expect(
        capturedUri.toString(),
        'https://example.supabase.co/functions/v1/expression-assist',
      );
      expect(capturedHeaders?['apikey'], 'sb_publishable_test_key');
      expect(capturedHeaders?.containsKey('Authorization'), isFalse);
      expect(capturedBody?['intent'], 'clarification');
      expect(capturedBody?['clarificationChoice'], 'Bolsa en femenino');
      expect(result.suggestions.single.text, contains('No quiero la bolsa'));
      expect(result.suggestions.single.text, contains('2'));
      expect(result.suggestions.single.text, contains('\$1500'));
    });

    test('traduce 503 ai_not_configured a ExpressionAssistException controlada', () async {
      final service = SupabaseGeminiExpressionAssistService(
        endpointUrl: 'https://example.supabase.co/functions/v1/expression-assist',
        publishableKey: 'sb_publishable_test_key',
        post: (_, _, _) async => (
          statusCode: 503,
          body: jsonEncode({'error': 'ai_not_configured'}),
        ),
      );

      expect(
        () => service.assist(text: 'necesito recibo'),
        throwsA(
          isA<ExpressionAssistException>().having(
            (e) => e.isNotConfigured,
            'isNotConfigured',
            isTrue,
          ),
        ),
      );
    });

    test('maneja SocketException sin exponer stack técnico', () async {
      final service = SupabaseGeminiExpressionAssistService(
        endpointUrl: 'https://example.supabase.co/functions/v1/expression-assist',
        publishableKey: 'sb_publishable_test_key',
        post: (_, _, _) async => throw const SocketException('offline'),
      );

      expect(
        () => service.assist(text: 'necesito recibo'),
        throwsA(
          isA<ExpressionAssistException>().having(
            (e) => e.message,
            'message',
            contains('Sin conexión'),
          ),
        ),
      );
    });
  });
}
