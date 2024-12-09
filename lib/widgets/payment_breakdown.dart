import 'package:enrollease/model/payment_model.dart';
import 'package:enrollease/utils/nav.dart';
import 'package:enrollease/widgets/custom_button.dart';
import 'package:flutter/material.dart';

class PaymentBreakdown extends StatelessWidget {
  final Payment payment;
  const PaymentBreakdown({required this.payment, super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Payment breakdown',
              style: TextStyle(fontSize: 18, color: Colors.black),
            ),
            ...payment.amount == null
                ? [const Text('Error reading individual breakdown')]
                : payment.amount!.toMap().entries.map((e) {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${e.key}: ',
                          style: const TextStyle(color: Colors.black),
                        ),
                        Text('P${e.value.toString().substring(0, e.value.toString().length - 2)}', style: const TextStyle(color: Colors.black))
                      ],
                    );
                  }).toList(),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomBtn(
                  vertical: 10,
                  horizontal: 20,
                  colorBg: Colors.red,
                  colorTxt: Colors.black,
                  txtSize: 18,
                  onTap: () {
                    Nav.pop(context);
                  },
                  btnTxt: 'Back',
                  textStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
