import 'package:flutter/material.dart';

class CenterCurvedBottomNavigation extends StatelessWidget {
  const CenterCurvedBottomNavigation({
    Key? key,
    this.backgroundColor = Colors.white,
    this.currentIndex = 0,
    this.height = 68,
    this.onTap,
    this.items = const [],
  }) : super(key: key);

  final Color backgroundColor;
  final int currentIndex;
  final double height;
  final List<BottomNavigationBarItem> items;
  final void Function(int)? onTap;

  @override
  Widget build(BuildContext context) {
    int centerIndex = (items.length / 2).floor();
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Container(
          width: double.infinity,
          height: MediaQuery.of(context).padding.bottom,
          color: backgroundColor,
        ),
        SafeArea(
          top: false,
          child: CustomPaint(
            painter:
                _BottomNavPainter(context: context, color: backgroundColor),
            child: Container(
              height: height,
              alignment: Alignment.bottomCenter,
              child: Theme(
                data: Theme.of(context).copyWith(
                  highlightColor: Colors.transparent,
                  splashColor: Colors.transparent,
                ),
                child: BottomNavigationBar(
                  type: BottomNavigationBarType.fixed,
                  onTap: (i) => {
                    if (currentIndex != i && i != centerIndex) onTap?.call(i)
                  },
                  currentIndex: currentIndex,
                  items: items
                    ..[centerIndex] = const BottomNavigationBarItem(
                      icon: SizedBox.shrink(),
                      label: '',
                    ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _BottomNavPainter extends CustomPainter {
  final BuildContext context;
  final Color color;

  _BottomNavPainter({
    required this.context,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    Path path = Path()..moveTo(0, size.height * .2);
    path.quadraticBezierTo(size.width * 0.25, 0, size.width * 0.375, 0);
    path.quadraticBezierTo(
        size.width * 0.40, 0, size.width * 0.4175, size.height * .125);
    path.arcToPoint(
      Offset(size.width * 0.5815, size.height * .125),
      radius: Radius.circular(size.height * .475),
      clockwise: false,
    );
    path.quadraticBezierTo(size.width * 0.60, 0, size.width * 0.625, 0);
    path.quadraticBezierTo(size.width * 0.75, 0, size.width, size.height * .2);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    canvas.drawShadow(path.shift(const Offset(0, -4)),
        Theme.of(context).shadowColor, 2, false);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
