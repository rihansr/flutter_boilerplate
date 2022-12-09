import 'package:flutter/material.dart';
import '../../controllers/dashboard_viewmodel.dart';
import '../../shared/colors.dart';
import '../../shared/dimens.dart';
import '../../widgets/base_widget.dart';
import '../configs/app_settings.dart';
import '../shared/strings.dart';
import '../widgets/button_widget.dart';
import '../widgets/splitter_widget.dart';
import '../widgets/center_curved_bottom_navigation.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return BaseWidget<DashboardViewModel>(
      model: DashboardViewModel(context),
      onInit: (controller) => controller.init(),
      builder: (context, controller, child) => Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            controller.navigation['label'],
            maxLines: 1,
            style: theme.textTheme.bodyText2,
          ),
        ),
        body: IndexedStack(
          index: controller.selectedTab,
          children: [
            const Center(child: Text('Cart')),
            Splitter.vertical(
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
            const Center(child: Text('Profile')),
          ],
        ),
        floatingActionButton: SizedBox.square(
          dimension: 48,
          child: FloatingActionButton.large(
            backgroundColor: controller.isCenterTab ? null : theme.cardColor,
            splashColor: Colors.transparent,
            child: Icon(
              controller.navigations[controller.centerTab]!['icon'] as IconData,
              color: controller.isCenterTab
                  ? ColorPalette.light().primaryLight
                  : theme.bottomNavigationBarTheme.unselectedItemColor,
              size: 24,
            ),
            onPressed: () => controller.selectedTab = controller.centerTab,
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: CenterCurvedBottomNavigation(
          backgroundColor: theme.cardColor,
          currentIndex: controller.selectedTab,
          height: dimen.navbarHeight,
          items: controller.navigations
              .map((value) => BottomNavigationBarItem(
                    icon: Icon(value['icon'] as IconData),
                    label: value['label'] as String,
                  ))
              .toList(),
          onTap: (i) => controller.selectedTab = i,
        ),
      ),
    );
  }
}
