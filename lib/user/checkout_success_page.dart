import 'package:flutter/material.dart';
import 'package:pizza_delivery_app/core/color_app.dart';

class CheckoutSuccesspage extends StatelessWidget {
  const CheckoutSuccesspage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Success icon
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.green.withAlpha(26),
                ),
                padding: const EdgeInsets.all(20),
                child: Image.asset("assets/Pizzalogo.png"),
              ),
              const SizedBox(height: 24),

              // Message
              const Text(
                "Thanh toán thành công!",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                "Cảm ơn bạn đã mua sắm cùng chúng tôi. Hóa đơn của bạn đã được xử lý thành công.",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // Button
              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorApp.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.popUntil(
                      context,
                      (route) => route.isFirst,
                    );
                  },
                  child: const Text(
                    "Tiếp tục mua sắm",
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
