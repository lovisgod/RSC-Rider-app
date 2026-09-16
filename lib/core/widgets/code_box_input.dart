import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rsc_rider/core/constants/app_colors.dart';
import 'package:rsc_rider/core/constants/app_spacing.dart';
import 'package:rsc_rider/core/constants/app_text_styles.dart';

// 6-digit OTP-style box input shared by CompleteDeliveryScreen and
// DeliveryCodeSheet.
class CodeBoxInput extends StatefulWidget {
  const CodeBoxInput({super.key, required this.onChanged, this.hasError = false});

  final ValueChanged<String> onChanged;
  final bool hasError;

  @override
  State<CodeBoxInput> createState() => _CodeBoxInputState();
}

class _CodeBoxInputState extends State<CodeBoxInput> {
  final _controllers = List.generate(6, (_) => TextEditingController());
  final _focusNodes = List.generate(6, (_) => FocusNode());

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onChanged(int index, String value) {
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
    widget.onChanged(_controllers.map((c) => c.text).join());
  }

  KeyEventResult _onKeyEvent(int index, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _controllers[index].text.isEmpty &&
        index > 0) {
      _focusNodes[index - 1].requestFocus();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(
          6,
          (index) => SizedBox(
            width: 44,
            height: 52,
            child: Focus(
              onKeyEvent: (node, event) => _onKeyEvent(index, event),
              child: TextField(
                controller: _controllers[index],
                focusNode: _focusNodes[index],
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                maxLength: 1,
                style: AppTextStyles.headlineSmall,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  counterText: '',
                  contentPadding: EdgeInsets.zero,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    borderSide: BorderSide(
                      color: widget.hasError
                          ? AppColors.error
                          : AppColors.inputBorder,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    borderSide: BorderSide(
                      color: widget.hasError
                          ? AppColors.error
                          : AppColors.inputBorderFocused,
                    ),
                  ),
                ),
                onChanged: (value) => _onChanged(index, value),
              ),
            ),
          ),
        ),
      );
}
