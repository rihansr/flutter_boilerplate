import 'package:flutter/material.dart';
import '../../controllers/dashboard_viewmodel.dart';
import '../../shared/colors.dart';
import '../../shared/dimens.dart';
import '../../widgets/base_widget.dart';
import '../widgets/appbar_widget.dart';
import '../widgets/curved_bottom_navigation_widget.dart';
import 'tab/home_view.dart';
import 'tab/profile_view.dart';
import 'tab/settings_view.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return BaseWidget<DashboardViewModel>(
      model: DashboardViewModel(context),
      onInit: (controller) => controller.init(),
      builder: (context, controller, child) => Scaffold(
        appBar: CustomizedAppBar(
          title: controller.navigation['label'],
          automaticallyImplyLeading: false,
          onTapLeading: () {},
        ),
        body: IndexedStack(
          index: controller.selectedTab,
          children: const [
            Align(
              alignment: Alignment.center,
              child: ProfileView(),
            ),
            Align(
              alignment: Alignment.center,
              child: HomeView(),
            ),
            Align(
              alignment: Alignment.center,
              child: SettingsView(),
            ),
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
