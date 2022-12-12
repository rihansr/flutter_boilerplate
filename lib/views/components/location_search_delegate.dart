import 'package:boilerplate/services/navigation_service.dart';
import 'package:boilerplate/shared/styles.dart';
import 'package:flutter/material.dart';
import '../../configs/theme_config.dart';
import '../../controllers/location_viewmodel.dart';
import '../../models/location_model.dart';
import '../../shared/icons.dart';
import '../../widgets/appbar_widget.dart';
import '../../widgets/listview_builder.dart';
import '../../widgets/separator_widget.dart';

class CustomSearchDelegate extends SearchDelegate {
  @override
  String? get searchFieldLabel => 'Search your location';

  @override
  TextStyle? get searchFieldStyle => themeConfig.textTheme.bodyText2?.copyWith(
        color: themeConfig.theme.hintColor,
      );

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      Padding(
        padding: const EdgeInsets.only(right: 8),
        child: AppBarIconButton(
          icon: AppIcons.close,
          onTap: () => query = '',
        ),
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return AppBarIconButton(
      icon: AppIcons.arrow_back,
      onTap: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return itemBuilder(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return itemBuilder(context);
  }

  Widget itemBuilder(BuildContext context) => FutureBuilder<List<Location>>(
        initialData: const [],
        future: locationProvider(context: context).searchLocations(query),
        builder: (context, snapshot) => Container(
          color: Theme.of(context).backgroundColor,
          margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          child: ListViewBuilder<Location>(
            children: snapshot.data,
            spacing: const EdgeInsets.symmetric(vertical: 13),
            divider: Separator.vertical(
              color: Theme.of(context).disabledColor,
            ),
            onChildSelected: (location) => close(context, location),
            builder: (location, index) {
              List<String> splittedAddress = location?.name?.split(', ') ?? [];
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                minLeadingWidth: 0,
                leading: Icon(
                  AppIcons.location_rounded,
                  size: 24,
                  color: Theme.of(context).primaryColor,
                ),
                title: Text(
                  splittedAddress.length > 2
                      ? splittedAddress
                          .sublist(2, splittedAddress.length)
                          .join(', ')
                      : location?.name ?? '',
                  style: Theme.of(context).textTheme.subtitle1,
                ),
                subtitle: splittedAddress.length > 2
                    ? Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          splittedAddress.sublist(0, 2).join(', '),
                          style: Theme.of(context).textTheme.bodyText2,
                        ),
                      )
                    : null,
              );
            },
          ),
        ),
      );
}
