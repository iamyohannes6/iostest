import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomBottomNavBar extends StatelessWidget {
  const CustomBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: CustomPaint(
            painter: NavBarPainter(),
            child: SizedBox(
              height: 67,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  const SizedBox(width: 8),
                  _buildNavItem('wallet.svg', 'Wallet', 0, true),
                  Container(
                    padding: EdgeInsets.only(left: 25.0 , right: 18),
                    child: _buildNavItem('earn.svg', 'Earn', 1, false),
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 75.0 , right: 0),
                    child: _buildNavItem('discover.svg', 'Discover', 3, false),
                  ),
                  _buildNavItem('ledger.svg', 'My Ledger', 4, false),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 30,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              width: 66,
              height: 66,
              decoration: BoxDecoration(
                color: const Color(0xFFBBB0FF),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: SvgPicture.asset(
                  'icons/swap.svg',
                  width: 27,
                  height: 27,
                  colorFilter: const ColorFilter.mode(Colors.black87, BlendMode.srcIn),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNavItem(String iconPath, String label, int index, bool isSelected) {
    return Container(
      margin: EdgeInsets.only(right: 20.0, left: 10.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            'icons/nav_bar/$iconPath',
            colorFilter: ColorFilter.mode(
              isSelected ? const Color(0xFFBBB0FF) : Colors.white.withOpacity(0.7),
              BlendMode.srcIn,
            ),
            width: 24,
            height: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? const Color(0xFFBBB0FF) : Colors.white.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class NavBarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Draw shadow first
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8)
      ..style = PaintingStyle.fill;

    final buttonRadius = 40.0;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo((size.width / 2) - 70, 0)
      ..quadraticBezierTo(
        size.width / 2 - 45,
        -1,
        size.width / 2 - 39,
        15,
      )
      ..arcToPoint(
        Offset(size.width / 2 + 39, 15),
        radius: Radius.circular(buttonRadius),
        clockwise: false,
      )
      ..quadraticBezierTo(
        size.width / 2 + 45,
        -1,
        (size.width / 2) + 70,
        0,
      )
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    // Draw shadow with slight offset
    canvas.save();
    canvas.translate(0, -1);
    canvas.drawPath(path, shadowPaint);
    canvas.restore();

    // Draw the actual navigation bar
    final paint = Paint()
      ..color = const Color(0xFF191919)
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}