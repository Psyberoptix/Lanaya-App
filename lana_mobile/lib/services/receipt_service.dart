import 'package:flutter/material.dart';

class ReceiptService {
  /// Generates the 'Golden Receipt' representation.
  /// In a real app this would paint to a Canvas and save a high-res JPG.
  /// Here we return a widget representation that can be displayed or simulated.
  Widget buildGoldenReceipt(String amountCop, String brebRef, DateTime date) {
    return Container(
      width: 400,
      height: 600,
      color: const Color(0xFF111827), // Matte Black
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 48),
          const Icon(
            Icons.generating_tokens, // Placeholder for app icon
            color: Color(0xFFFBBF24), // Sunlight Gold
            size: 80,
          ),
          const SizedBox(height: 24),
          const Text(
            'LanaYa Receipt',
            style: TextStyle(color: Color(0xFFFBBF24), fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 48),
          const Text(
            'Amount Transferred',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            '$amountCop COP',
            style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 48),
          const Divider(color: Colors.white24),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Date', style: TextStyle(color: Colors.grey, fontSize: 16)),
              Text(
                '${date.day}/${date.month}/${date.year}', 
                style: const TextStyle(color: Colors.white, fontSize: 16)
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Bre-B Ref', style: TextStyle(color: Colors.grey, fontSize: 16)),
              Text(
                brebRef, 
                style: const TextStyle(color: Color(0xFFFBBF24), fontSize: 16, fontWeight: FontWeight.bold)
              ),
            ],
          ),
        ],
      ),
    );
  }
}
