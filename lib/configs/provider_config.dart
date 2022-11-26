import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import '../viewmodels/theming_viewmodel.dart';
import '../services/api.dart';

List<SingleChildWidget> providers = [
  ...independentService,
  ...universalService,
];

List<SingleChildWidget> independentService = [
  Provider.value(value: api),
];

List<SingleChildWidget> universalService = [
  ChangeNotifierProvider<ThemeViewModel>(
    create: (context) => ThemeViewModel(),
  ),
];
