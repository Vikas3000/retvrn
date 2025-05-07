import 'package:flutter/material.dart';

class ProcessingStatus extends StatelessWidget {
  final bool isVisible;
  final String message;
  final Color color;

  const ProcessingStatus({
    Key? key,
    required this.isVisible,
    required this.message,
    this.color = Colors.amber,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: Duration(milliseconds: 300),
      opacity: isVisible ? 1.0 : 0.0,
      child: Visibility(
        visible: isVisible,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
              SizedBox(width: 8),
              Text(
                message,
                style: TextStyle(
                  color: color,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
