import 'package:boilerplate/widgets/appbar_widget.dart';
import 'package:flutter/material.dart';
import '../../controllers/dashboard_viewmodel.dart';
import '../../shared/colors.dart';
import '../../shared/dimens.dart';
import '../../widgets/base_widget.dart';
import '../configs/app_settings.dart';
import '../shared/strings.dart';
import '../widgets/button_widget.dart';
import '../widgets/splitter_widget.dart';
import '../widgets/curved_bottom_navigation_widget.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return BaseWidget<DashboardViewModel>(
      model: DashboardViewModel(context),
      onInit: (controller) => controller.init(),
      builder: (context, controller, child) => Scaffold(
        appBar: AppBarWidget(
          title: controller.navigation['label'],
          automaticallyImplyLeading: false,
          onTapLeading: () {},
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
                    Button(
                      label: string(context).httpCall,
                      fontColor: theme.scaffoldBackgroundColor,
                      onPressed: () => controller.httpCall(),
                      leading: Icon(
                        Icons.http_outlined,
                        color: theme.scaffoldBackgroundColor,
                      ),
                      loading: controller.isLoading(key: 'Http', orElse: false),
                    ),
                    Button(
                      label: string(context).dioCall,
                      fontColor: theme.scaffoldBackgroundColor,
                      onPressed: () => controller.dioCall(),
                      leading: Icon(
                        Icons.network_cell_outlined,
                        color: theme.scaffoldBackgroundColor,
                      ),
                      loading: controller.isLoading(key: 'Dio', orElse: false),
                    ),
                    Button(
                      label:
                          '${controller.uploadProgress == null ? '' : '${controller.uploadProgress}% '}${string(context).upload}',
                      fontColor: theme.scaffoldBackgroundColor,
                      leading: Icon(
                        Icons.upload_outlined,
                        color: theme.scaffoldBackgroundColor,
                      ),
                      onPressed: () => controller.uploadFile(),
                    ),
                    if (controller.url != null)
                      Button(
                        label:
                            '${controller.downloadProgress == null ? '' : '${controller.downloadProgress}% '}${string(context).download}',
                        fontColor: theme.scaffoldBackgroundColor,
                        leading: Icon(
                          Icons.download_outlined,
                          color: theme.scaffoldBackgroundColor,
                        ),
                        onPressed: () => controller.downloadFile(),
                      ),
                  ],
                ),
                Splitter.horizontal(
                  spacing: 12,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Button(
                      label: appSettings.isDarkTheme()
                          ? string(context).dark
                          : string(context).light,
                      fontColor: theme.scaffoldBackgroundColor,
                      leading: Icon(
                        appSettings.isDarkTheme()
                            ? Icons.dark_mode
                            : Icons.light_mode,
                        color: theme.scaffoldBackgroundColor,
                      ),
                      onPressed: () => appSettings.switchTheme,
                    ),
                    Button(
                      label: string(context).language,
                      fontColor: theme.scaffoldBackgroundColor,
                      leading: Icon(
                        Icons.language,
                        color: theme.scaffoldBackgroundColor,
                      ),
                      onPressed: () => appSettings.switchLanguage,
                    ),
                  ],
                ),
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
        bottomNavigationBar: CurvedBottomNavigation(
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
