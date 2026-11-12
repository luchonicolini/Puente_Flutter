import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/smooth_entrance.dart';
import '../models/chat_message.dart';
import 'detected_info_card.dart';

/// Burbuja individual de conversación con identificación explícita del
/// participante, horario accesible y tarjeta opcional de información detectada.
class ConversationMessageBubble extends StatelessWidget {
  const ConversationMessageBubble({
    super.key,
    required this.message,
    required this.onTapDetectedInfo,
  });

  final ChatMessage message;
  final VoidCallback onTapDetectedInfo;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final textSecondary = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;
    final isUser = message.sender == MessageSender.user;

    final bubbleColor = isUser
        ? (isDark ? AppColors.bubbleUserDark : AppColors.bubbleUserLight)
        : (isDark ? AppColors.bubbleOtherDark : AppColors.bubbleOtherLight);

    final borderColor = isUser
        ? (isDark
              ? AppColors.primaryTealOnDark.withValues(alpha: 0.35)
              : AppColors.primaryTealMuted)
        : (isDark ? AppColors.borderDark : AppColors.borderLight);

    final senderLabelColor = isUser
        ? (isDark ? AppColors.primaryTealMuted : AppColors.primaryTealDark)
        : textSecondary;

    final maxBubbleWidth = MediaQuery.sizeOf(context).width * 0.82;

    return SmoothEntrance(
      key: ValueKey(message.id),
      child: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          constraints: BoxConstraints(maxWidth: maxBubbleWidth),
          child: Column(
            crossAxisAlignment: isUser
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              MergeSemantics(
                child: Semantics(
                  label:
                      '${isUser ? "Vos" : "Interlocutor"}, ${message.timeFormatted}: ${message.text}',
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(14, 10, 14, 11),
                    decoration: BoxDecoration(
                      color: bubbleColor,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(18),
                        topRight: const Radius.circular(18),
                        bottomLeft: Radius.circular(isUser ? 18 : 6),
                        bottomRight: Radius.circular(isUser ? 6 : 18),
                      ),
                      border: Border.all(color: borderColor, width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                isUser ? 'Vos' : 'Otra persona',
                                style: AppTypography.metadata(
                                  senderLabelColor,
                                ).copyWith(fontWeight: FontWeight.w700),
                              ),
                            ),
                            Text(
                              ' · ${message.timeFormatted}',
                              style: AppTypography.metadata(textSecondary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          message.text,
                          style: AppTypography.conversation(textPrimary),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (message.detectedInfo != null)
                DetectedInfoCard(
                  detectedInfo: message.detectedInfo!,
                  onTap: onTapDetectedInfo,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
