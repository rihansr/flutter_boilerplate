import 'package:flutter/material.dart';
import '../../configs/app_settings.dart';
import '../../controllers/location_viewmodel.dart';
import '../../models/location_model.dart';
import '../../shared/strings.dart';
import '../../utils/debug.dart';
import '../components/custom_button.dart';
import '../components/location_search_delegate.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Builder(
        builder: (context) => Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                CustomButton(
                  label: appSettings.isDarkTheme()
                      ? string(context).dark
                      : string(context).light,
                  icon: appSettings.isDarkTheme()
                      ? Icons.dark_mode
                      : Icons.light_mode,
                  onPressed: () => appSettings.switchTheme,
                ),
                CustomButton(
                  label: string(context).language,
                  icon: Icons.language,
                  onPressed: () => appSettings.switchLanguage,
                ),
                CustomButton(
                  label: string(context).location,
                  icon: Icons.location_pin,
                  loading: locationProvider(context, listen: true).isLoading(
                      key: 'fetching_location', orElse: false),
                  onPressed: () => locationProvider(context)
                      .findLocation(setAsDefault: true),
                ),
                CustomButton(
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
            ));
  }
}
