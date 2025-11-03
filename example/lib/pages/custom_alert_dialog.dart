import 'package:flutter/material.dart';

class CustomDialog extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final String? cancelText;
  final String? confirmText;
  final VoidCallback? onCancel;
  final VoidCallback? onConfirm;

  const CustomDialog({
    super.key,
    this.title,
    this.subtitle,
    this.cancelText,
    this.confirmText,
    this.onCancel,
    this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      contentPadding: EdgeInsets.zero,
      backgroundColor: Colors.white,
      content: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (title != null)
              Text(
                title!,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F1F1F)
                ),
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 12),
            if (subtitle != null)
              Text(
                subtitle!,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xff292929),
                ),
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 20),
            Row(
              children: [
                if (cancelText != null)
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: Color(0xffF5F5F5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        onPressed: () {
                          if (onCancel != null) {
                            onCancel!();
                          }
                        },
                        child: Text(
                          cancelText!,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xff292929)
                          ),
                        ),
                      ),
                    ),

                  ),
                if (cancelText != null && confirmText != null) const SizedBox(width: 15),
                if (confirmText != null)
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        onPressed: () {
                          if (onConfirm != null) {
                            onConfirm!();
                          }
                        },
                        child: Text(
                          confirmText!,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xffFAFAFA),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}