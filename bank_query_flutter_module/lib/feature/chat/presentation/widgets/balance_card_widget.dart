import 'package:flutter/material.dart';

import '../../../../core/utils/image_constant.dart';

class BalanceCardWidget extends StatefulWidget {
  const BalanceCardWidget({super.key});

  @override
  State<BalanceCardWidget> createState() => _BalanceCardWidgetState();
}

class _BalanceCardWidgetState extends State<BalanceCardWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(ImageConstant.card_bg),
            fit: BoxFit.fill,
          ),
          gradient: const LinearGradient(
            colors: [Color(0xFF2C2C2C), Color(0xFF3A3A3A)],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: const [
            _row("Current Balance", "\$365,432.78"),
            SizedBox(height: 8),
            _row("Account No.", "5282 345 678"),
          ],
        ),
      ),
    );
  }
}


class _row extends StatelessWidget {
  final String label;
  final String value;
  const _row(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white70,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w400,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}


