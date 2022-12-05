import 'package:bottom_bar/bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:boilerplate/configs/app_settings.dart';
import 'package:boilerplate/controllers/dashboard_viewmodel.dart';
import 'package:boilerplate/shared/colors.dart';
import 'package:boilerplate/shared/strings.dart';
import 'package:boilerplate/widgets/base_widget.dart';
import 'package:boilerplate/widgets/button_widget.dart';
import 'package:boilerplate/widgets/splitter_widget.dart';
import '../widgets/settings_listenable_builder.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseWidget(
      model: Provider.of<DashboardViewModel>(context),
      builder: (context, controller, child) => Scaffold(
        floatingActionButton: SizedBox.square(
            dimension: 48,
            child: Transform.scale(
              scale: 1.1,
              child: FloatingActionButton.large(
                  child: const Icon(
                    Icons.add_outlined,
                    color: Colors.white,
                    size: 24,
                  ),
                  onPressed: () => {}),
            )),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: CustomPaint(
          size: const Size(double.infinity, 94.5),
          painter: BottomNavPainter(color: Colors.amber),
          child: BottomBar(
            height: 94.5,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            selectedIndex: controller.selectedIndex,
            padding: const EdgeInsets.all(0),
            itemPadding:
                const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
            onTap: (int index) => controller.updateSelectedIndex = index,
            items: const <BottomBarItem>[
              BottomBarItem(
                icon: Icon(Icons.home_outlined),
                title: Text('Home'),
                activeColor: Colors.blue,
              ),
              BottomBarItem(
                icon: Icon(Icons.shopify_outlined),
                title: Text('Order'),
                activeColor: Colors.red,
              ),
            ],
          ),
        ),
        appBar: AppBar(
          backgroundColor: Colors.amber,
          title: SettingsListenableBuilder(
            builder: (settings) => Text(
              string(context).appName,
              style: TextStyle(color: ColorPalette.current(settings).primary),
            ),
          ),
        ),
        body: Splitter.vertical(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                ButtonWidget(
                  label: 'Http',
                  onPressed: () => controller.httpCall(),
                  loading: controller.isLoading(key: 'Http', orElse: false),
                ),
                ButtonWidget(
                  label: 'Dio',
                  onPressed: () => controller.dioCall(),
                  loading: controller.isLoading(key: 'Dio', orElse: false),
                ),
                ButtonWidget(
                  label:
                      '${controller.uploadProgress == null ? '' : '${controller.uploadProgress}% '}Upload',
                  onPressed: () => controller.uploadFile(),
                ),
                if (controller.url != null)
                  ButtonWidget(
                    label:
                        '${controller.downloadProgress == null ? '' : '${controller.downloadProgress}% '}Download',
                    onPressed: () => controller.downloadFile(),
                  ),
              ],
            ),
            Splitter.horizontal(
              spacing: 12,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ButtonWidget(
                  label: string(context).change,
                  leading: const Icon(Icons.dark_mode),
                  contentSpacing: 4,
                  onPressed: () => appSettings.switchTheme,
                ),
                ButtonWidget(
                  label: string(context).change,
                  leading: const Icon(Icons.language),
                  contentSpacing: 4,
                  onPressed: () => appSettings.switchLanguage,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class BottomNavPainter extends CustomPainter {
  final Color color;

  BottomNavPainter({
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    Path path = Path()..moveTo(0, size.height * .2);
    path.quadraticBezierTo(size.width * 0.25, 0, size.width * 0.375, 0);
    path.quadraticBezierTo(
        size.width * 0.40, 0, size.width * 0.40, size.height * .04);
    path.arcToPoint(
      Offset(size.width * 0.60, size.height * .04),
      radius: Radius.circular(size.height * .4025),
      clockwise: false,
    );
    path.quadraticBezierTo(size.width * 0.60, 0, size.width * 0.625, 0);
    path.quadraticBezierTo(size.width * 0.75, 0, size.width, size.height * .2);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
