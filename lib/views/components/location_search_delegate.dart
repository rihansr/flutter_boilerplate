import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:lottie/lottie.dart';
import '../../services/api.dart';
import '../../shared/shared_prefs.dart';
import '../../shared/strings.dart';
import '../../utils/validator.dart';
import '../../configs/theme_config.dart';
import '../../models/location_model.dart';
import '../../shared/drawables.dart';
import '../../shared/icons.dart';
import '../../widgets/appbar_widget.dart';
import '../../widgets/listview_builder.dart';
import '../../widgets/separator_widget.dart';

class LocationSearchDelegate extends SearchDelegate {
  @override
  String? get searchFieldLabel => string().searchYourLocation;

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
        future: query.search,
        builder: (context, snapshot) => snapshot.connectionState ==
                ConnectionState.done
            ? validator.isEmpty(snapshot.data)
                ? Center(
                    child: Lottie.asset(
                      Drawable.empty,
                      height: 144,
                    ),
                  )
                : Container(
                    color: Theme.of(context).backgroundColor,
                    margin: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 20),
                    child: ListViewBuilder<Location>(
                      items: snapshot.data,
                      spacing: const EdgeInsets.symmetric(vertical: 13),
                      divider: Separator.vertical(
                        color: Theme.of(context).disabledColor,
                      ),
                      onItemSelected: (location) => close(context, location),
                      builder: (location, index) {
                        List<String> splittedAddress =
                            location?.name?.split(', ') ?? [];
                        return ListTile(
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 16),
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
                                    style:
                                        Theme.of(context).textTheme.bodyText2,
                                  ),
                                )
                              : null,
                        );
                      },
                    ),
                  )
            : Center(
                child: SpinKitThreeBounce(
                  color: Theme.of(context).highlightColor,
                  size: 32,
                ),
              ),
      );
}

extension _SearchLocations on String {
  Future<List<Location>> get search async {
    if (isEmpty) return [];

    Map<String, dynamic> queryParams = {
      'q': this,
      'accept-language': sharedPrefs.settings.locale.languageCode,
      'countrycodes': sharedPrefs.address?.countryCode,
      'format': 'jsonv2',
    }..removeWhere((key, value) => value == null);

    Response response = await api.invoke(
      via: InvokeType.dio,
      method: Method.get,
      baseUrl: 'https://nominatim.openstreetmap.org',
      endpoint: 'search.php',
      queryParams: queryParams,
      showMessage: true,
      cacheSubKey: queryParams.toString(),
      cacheDuration: const Duration(seconds: 30),
    );

    return validator.isEmpty(response.data)
        ? []
        : List<Location>.from(
            response.data.map((json) => Location.fromJson(json)),
          );
  }
}
