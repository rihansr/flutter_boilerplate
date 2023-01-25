import 'package:flutter/material.dart';
import '../shared/icons.dart';
import '../shared/strings.dart';
import 'base_viewmodel.dart';

class DashboardViewModel extends BaseViewModel {
  DashboardViewModel(this.context) : super();

  final BuildContext context;

  init() {
    _selectedTab = centerTab;
  }

  List get navigations => [
        {
          'icon': AppIcons.profile_outlined,
          'label': string(context).profile,
        },
        {
          'icon': AppIcons.home_rounded,
          'label': string(context).home,
        },
        {
          'icon': AppIcons.filter_outlined,
          'label': string(context).settings,
        },
      ];

  get navigation => navigations[_selectedTab];

  int get centerTab => (navigations.length / 2).floor();
  bool get isCenterTab => _selectedTab == centerTab;

  int _selectedTab = 0;
  int get selectedTab => _selectedTab;
  set selectedTab(int i) => {
        if (_selectedTab != i) {_selectedTab = i, notifyListeners()}
      };
}
