import 'jsr:@supabase/functions-js/edge-runtime.d.ts';

const corsHeaders: Record<string, string> = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers':
    'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
};

const GEMINI_INTERACTIONS_URL =
  'https://generativelanguage.googleapis.com/v1beta/interactions';
const GEMINI_MODEL = 'gemini-3.8-flash';
const MAX_INPUT_LENGTH = 500;
const MAX_CLARIFICATION_LENGTH = 160;

const SYSTEM_INSTRUCTION = `Sos un asistente opcional de redacción clara para Puente, una app de comunicación accesible pensada inicialmente para personas sordas o con dificultades auditivas en situaciones cotidianas (comercios, oficinas, turnos, trámites).

Reglas estrictas que siempre debés cumplir:
1. Respetá la forma de escribir de la persona usuaria. Nunca juzgues ni corrijas con tono paternalista.
2. Ayudá a mejorar la claridad en español (especialmente artículos, pronombres como el/la/los/las, lo/la/le, concordancia de género/número, preposiciones y orden de frase) conservando exactamente el sentido y la intención original.
3. Nunca inventes palabras, datos, precios, importes, fechas, horarios, direcciones, nombres propios ni afirmaciones que no estén en el texto original. Conservá todas las negaciones y cifras intactas.
4. Si un pronombre, artículo, género, número o intención (por ejemplo pregunta vs afirmación, o a qué objeto/persona se refiere) es genuinamente ambiguo y la persona aún no eligió una aclaración:
   - Poné has_ambiguity = true.
   - Explicá brevemente el motivo en ambiguity_reason (1 oración clara).
   - Proponé entre 2 y 3 interpretations concretas (con id corto, label claro y description breve) para que la persona elija la que coincide con lo que quiso decir.
5. Si ya recibiste clarificationChoice, aplicá esa interpretación fielmente y poné has_ambiguity = false (salvo que siga habiendo otra duda importante).
6. Si tuviste que inferir algún artículo, pronombre o conector, aclarálo con honestidad y en pocas palabras en uncertainty_note. Si no hubo inferencias dudosas, dejá uncertainty_note vacío ("").
7. Generá entre 2 y 3 suggestions breves, naturales para español rioplatense/cotidiano y listas para mostrar o enviar:
   - "Redacción clara": ajusta artículos, pronombres y concordancia manteniendo el estilo directo original.
   - "Cordial para mostrador": versión amable y clara para iniciar una atención.
   - Tercera opción útil (por ejemplo "Pregunta directa" o "Pedir confirmación" si incluye un dato o pedido).
8. Respondé únicamente con JSON válido siguiendo el esquema pedido.`;

const RESPONSE_FORMAT = {
  type: 'text',
  mime_type: 'application/json',
  schema: {
    type: 'object',
    properties: {
      has_ambiguity: { type: 'boolean' },
      ambiguity_reason: { type: 'string' },
      uncertainty_note: { type: 'string' },
      interpretations: {
        type: 'array',
        items: {
          type: 'object',
          properties: {
            id: { type: 'string' },
            label: { type: 'string' },
            description: { type: 'string' },
          },
          required: ['id', 'label', 'description'],
        },
      },
      suggestions: {
        type: 'array',
        items: {
          type: 'object',
          properties: {
            label: { type: 'string' },
            description: { type: 'string' },
            text: { type: 'string' },
          },
          required: ['label', 'description', 'text'],
        },
      },
    },
    required: [
      'has_ambiguity',
      'ambiguity_reason',
      'uncertainty_note',
      'interpretations',
      'suggestions',
    ],
  },
};

function jsonResponse(status: number, payload: unknown): Response {
  return new Response(JSON.stringify(payload), {
    status,
    headers: {
      ...corsHeaders,
      'Content-Type': 'application/json; charset=utf-8',
      'Cache-Control': 'no-store',
    },
  });
}

function isAuthorizedApiKey(apiKey: string | null): boolean {
  if (!apiKey) return false;
  const expectedKeys: string[] = [];

  const legacyAnon = Deno.env.get('SUPABASE_ANON_KEY');
  if (legacyAnon) expectedKeys.push(legacyAnon);

  const publishableJson = Deno.env.get('SUPABASE_PUBLISHABLE_KEYS');
  if (publishableJson) {
    try {
      const parsed = JSON.parse(publishableJson) as Record<string, unknown>;
      for (const value of Object.values(parsed)) {
        if (typeof value === 'string' && value.length > 0) {
          expectedKeys.push(value);
        }
      }
    } catch {
      // Ignore malformed env JSON
    }
  }

  if (expectedKeys.length === 0) return false;
  return expectedKeys.some((candidate) => candidate === apiKey);
}

interface InteractionStepContent {
  type?: string;
  text?: string;
}

interface InteractionStep {
  type?: string;
  content?: InteractionStepContent[];
}

interface InteractionResponse {
  status?: string;
  steps?: InteractionStep[];
  errors?: Array<{ message?: string }>;
}

function extractModelJsonText(data: InteractionResponse): string | null {
  if (!Array.isArray(data.steps)) return null;
  const textParts: string[] = [];
  for (const step of data.steps) {
    if (step.type !== 'model_output' || !Array.isArray(step.content)) continue;
    for (const part of step.content) {
      if (part.type === 'text' && typeof part.text === 'string') {
        textParts.push(part.text);
      }
    }
  }
  const combined = textParts.join('').trim();
  return combined.length > 0 ? combined : null;
}

Deno.serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  if (req.method !== 'POST') {
    return jsonResponse(405, {
      error: 'method_not_allowed',
      message: 'Usá POST para solicitar sugerencias de redacción.',
    });
  }

  const apiKeyHeader = req.headers.get('apikey');
  if (!isAuthorizedApiKey(apiKeyHeader)) {
    return jsonResponse(401, {
      error: 'unauthorized',
      message: 'Clave de cliente inválida o ausente.',
    });
  }

  const geminiApiKey = Deno.env.get('GEMINI_API_KEY')?.trim();
  if (!geminiApiKey) {
    return jsonResponse(503, {
      error: 'ai_not_configured',
      message:
        'La clave GEMINI_API_KEY todavía no está configurada en Supabase.',
    });
  }

  let rawBody: Record<string, unknown>;
  try {
    rawBody = (await req.json()) as Record<string, unknown>;
  } catch {
    return jsonResponse(400, {
      error: 'invalid_json',
      message: 'El cuerpo de la solicitud debe ser JSON válido.',
    });
  }

  const rawText = typeof rawBody.text === 'string' ? rawBody.text.trim() : '';
  if (rawText.length === 0 || rawText.length > MAX_INPUT_LENGTH) {
    return jsonResponse(400, {
      error: 'invalid_text',
      message: `El texto debe tener entre 1 y ${MAX_INPUT_LENGTH} caracteres.`,
    });
  }

  const intent =
    rawBody.intent === 'consultation' || rawBody.intent === 'clarification'
      ? rawBody.intent
      : null;

  const clarificationChoice =
    typeof rawBody.clarificationChoice === 'string'
      ? rawBody.clarificationChoice.trim().slice(0, MAX_CLARIFICATION_LENGTH)
      : '';

  const promptLines = [
    `Texto original de la persona: ${JSON.stringify(rawText)}`,
  ];
  if (intent === 'consultation') {
    promptLines.push(
      'Intención elegida por la persona: quiere formularlo como una consulta/pregunta.',
    );
  } else if (intent === 'clarification') {
    promptLines.push(
      'Intención elegida por la persona: quiere pedir una aclaración.',
    );
  }
  if (clarificationChoice.length > 0) {
    promptLines.push(
      `Aclaración elegida por la persona: ${JSON.stringify(clarificationChoice)}`,
    );
  }

  const abortController = new AbortController();
  const timeout = setTimeout(() => abortController.abort(), 14000);

  try {
    const geminiResponse = await fetch(GEMINI_INTERACTIONS_URL, {
      method: 'POST',
      headers: {
        'x-goog-api-key': geminiApiKey,
        'Content-Type': 'application/json',
        'Api-Revision': '2026-05-20',
      },
      body: JSON.stringify({
        model: GEMINI_MODEL,
        store: false,
        system_instruction: SYSTEM_INSTRUCTION,
        input: promptLines.join('\n'),
        generation_config: {
          thinking_level: 'low',
        },
        response_format: RESPONSE_FORMAT,
      }),
      signal: abortController.signal,
    });

    if (!geminiResponse.ok) {
      console.error(`Gemini upstream HTTP ${geminiResponse.status}`);
      return jsonResponse(502, {
        error: 'upstream_error',
        message: 'No pudimos obtener sugerencias de Gemini en este momento.',
      });
    }

    const interaction = (await geminiResponse.json()) as InteractionResponse;
    if (interaction.status === 'failed') {
      console.error('Gemini interaction failed');
      return jsonResponse(502, {
        error: 'generation_failed',
        message: 'Gemini no pudo completar la sugerencia.',
      });
    }

    const modelText = extractModelJsonText(interaction);
    if (!modelText) {
      console.error('Gemini returned empty output_text');
      return jsonResponse(502, {
        error: 'empty_output',
        message: 'Gemini devolvió una respuesta vacía.',
      });
    }

    let parsedOutput: Record<string, unknown>;
    try {
      parsedOutput = JSON.parse(modelText) as Record<string, unknown>;
    } catch {
      console.error('Gemini returned non-JSON structured output');
      return jsonResponse(502, {
        error: 'invalid_model_output',
        message: 'No pudimos interpretar la respuesta estructurada de Gemini.',
      });
    }

    const rawSuggestions = Array.isArray(parsedOutput.suggestions)
      ? parsedOutput.suggestions
      : [];
    const suggestions = rawSuggestions
      .filter(
        (item): item is Record<string, unknown> =>
          typeof item === 'object' && item !== null,
      )
      .map((item) => ({
        label:
          typeof item.label === 'string' && item.label.trim().length > 0
            ? item.label.trim()
            : 'Propuesta clara',
        description:
          typeof item.description === 'string' &&
          item.description.trim().length > 0
            ? item.description.trim()
            : 'Sugerencia generada con Gemini',
        text: typeof item.text === 'string' ? item.text.trim() : '',
      }))
      .filter((item) => item.text.length > 0)
      .slice(0, 3);

    if (suggestions.length === 0) {
      return jsonResponse(502, {
        error: 'no_suggestions',
        message: 'Gemini no generó propuestas utilizables.',
      });
    }

    const rawInterpretations = Array.isArray(parsedOutput.interpretations)
      ? parsedOutput.interpretations
      : [];
    const interpretations = rawInterpretations
      .filter(
        (item): item is Record<string, unknown> =>
          typeof item === 'object' && item !== null,
      )
      .map((item, idx) => ({
        id:
          typeof item.id === 'string' && item.id.trim().length > 0
            ? item.id.trim()
            : `opt_${idx + 1}`,
        label: typeof item.label === 'string' ? item.label.trim() : '',
        description:
          typeof item.description === 'string' ? item.description.trim() : '',
      }))
      .filter((item) => item.label.length > 0)
      .slice(0, 3);

    return jsonResponse(200, {
      model: GEMINI_MODEL,
      has_ambiguity:
        Boolean(parsedOutput.has_ambiguity) && interpretations.length > 0,
      ambiguity_reason:
        typeof parsedOutput.ambiguity_reason === 'string'
          ? parsedOutput.ambiguity_reason.trim()
          : '',
      uncertainty_note:
        typeof parsedOutput.uncertainty_note === 'string'
          ? parsedOutput.uncertainty_note.trim()
          : '',
      interpretations,
      suggestions,
    });
  } catch (err) {
    const isTimeout = err instanceof DOMException && err.name === 'AbortError';
    console.error(
      isTimeout ? 'Gemini request timed out' : 'Unexpected proxy error',
    );
    return jsonResponse(isTimeout ? 504 : 502, {
      error: isTimeout ? 'timeout' : 'proxy_error',
      message: isTimeout
        ? 'Gemini tardó demasiado en responder.'
        : 'Ocurrió un error al consultar Gemini.',
    });
  } finally {
    clearTimeout(timeout);
  }
});
