import 'package:boilerplate/utils/debug.dart';
import 'package:flutter/material.dart';
import '../../controllers/dashboard_viewmodel.dart';
import '../../shared/colors.dart';
import '../../shared/dimens.dart';
import '../../widgets/base_widget.dart';
import '../utils/extensions.dart';
import '../controllers/location_viewmodel.dart';
import '../models/location_model.dart';
import '../widgets/appbar_widget.dart';
import '../configs/app_settings.dart';
import '../shared/strings.dart';
import '../widgets/button_widget.dart';
import '../widgets/curved_bottom_navigation_widget.dart';
import 'components/location_search_delegate.dart';

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
          children: [
            Align(
              alignment: Alignment.center,
              child: Text(
                '${locationProvider(context, listen: true).defaultAddress.address}',
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _Button(
                    label: string(context).httpCall,
                    icon: Icons.http,
                    loading: controller.isLoading(key: 'Http', orElse: false),
                    onPressed: () => controller.httpCall(),
                  ),
                  _Button(
                    label: string(context).dioCall,
                    icon: Icons.network_cell,
                    loading: controller.isLoading(key: 'Dio', orElse: false),
                    onPressed: () => controller.dioCall(),
                  ),
                  _Button(
                    label:
                        '${controller.uploadProgress == null ? '' : '${controller.uploadProgress}% '}${string(context).upload}',
                    icon: Icons.upload,
                    onPressed: () => controller.uploadFile(),
                  ),
                  if (controller.url != null)
                    _Button(
                      label:
                          '${controller.downloadProgress == null ? '' : '${controller.downloadProgress}% '}${string(context).download}',
                      icon: Icons.download,
                      onPressed: () => controller.downloadFile(),
                    ),
                  _Button(
                    label: string(context).payment,
                    icon: Icons.payment,
                    loading:
                        controller.isLoading(key: 'Payment', orElse: false),
                    onPressed: () => controller.makePaymet(),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _Button(
                    label: appSettings.isDarkTheme()
                        ? string(context).dark
                        : string(context).light,
                    icon: appSettings.isDarkTheme()
                        ? Icons.dark_mode
                        : Icons.light_mode,
                    onPressed: () => appSettings.switchTheme,
                  ),
                  _Button(
                    label: string(context).language,
                    icon: Icons.language,
                    onPressed: () => appSettings.switchLanguage,
                  ),
                  _Button(
                    label: string(context).location,
                    icon: Icons.location_pin,
                    loading: controller.isLoading(
                        key: 'fetching_location', orElse: false),
                    onPressed: () => locationProvider(context)
                        .findLocation(setAsDefault: true),
                  ),
                  _Button(
                    label: string(context).searchLocation,
                    icon: Icons.location_city_sharp,
                    onPressed: () => showSearch(
                      context: context,
                      delegate: LocationSearchDelegate(),
                    ).then((location) async => {
                          if ((location as Location?) != null)
                            debug.print(location!.toJson())
                        }),
                  ),
                ],
              ),
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

class _Button extends StatelessWidget {
  const _Button(
      {Key? key,
      required this.label,
      this.icon,
      this.loading = false,
      this.onPressed})
      : super(key: key);

  final String label;
  final IconData? icon;
  final bool loading;
  final Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return Button(
      loading: loading,
      label: label,
      fontColor: context.theme.scaffoldBackgroundColor,
      leading: icon != null
          ? Icon(
              icon,
              color: context.theme.scaffoldBackgroundColor,
            )
          : null,
      onPressed: onPressed,
    );
  }
}
