import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CryptoListItem extends StatelessWidget {
  final Widget icon;
  final String name;
  final String symbol;
  final String amount;
  final String cryptoAmount;
  final double changePercentage;
  final bool isPositive;

  const CryptoListItem({
    super.key,
    required this.icon,
    required this.name,
    required this.symbol,
    required this.amount,
    required this.cryptoAmount,
    required this.changePercentage,
    required this.isPositive,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          SizedBox(
            width: 42,
            height: 42,
            child: icon,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '$cryptoAmount $symbol',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Row(
                children: [
                  SvgPicture.asset(
                    isPositive 
                      ? 'assets/icons/indicator_arrow_up.svg'
                      : 'assets/icons/indicator_arrow_down.svg',
                    width: 11,
                    height: 11,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    '${changePercentage.abs().toStringAsFixed(0)}%',
                    style: TextStyle(
                      color: isPositive ? const Color(0xFF4E7B44) : const Color(0xFFBE5A69),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}