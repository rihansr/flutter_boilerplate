import 'package:flutter/material.dart';
import '../components/custom_button.dart';
import '../../services/navigation_service.dart';
import '../../controllers/home_viewmodel.dart';
import '../../routes/routes.dart';
import '../../shared/strings.dart';
import '../../widgets/base_widget.dart';

class HomeView extends StatelessWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseWidget<HomeViewModel>(
        model: HomeViewModel(context),
        builder: (context, controller, child) => Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                CustomButton(
                  label: string(context).httpCall,
                  icon: Icons.http,
                  loading: controller.isLoading(key: 'Http', orElse: false),
                  onPressed: () => controller.httpCall(),
                ),
                CustomButton(
                  label: string(context).dioCall,
                  icon: Icons.network_cell,
                  loading: controller.isLoading(key: 'Dio', orElse: false),
                  onPressed: () => controller.dioCall(),
                ),
                CustomButton(
                  label:
                      '${controller.uploadProgress == null ? '' : '${controller.uploadProgress}% '}${string(context).upload}',
                  icon: Icons.upload,
                  onPressed: () => controller.uploadFile(),
                ),
                if (controller.url != null)
                  CustomButton(
                    label:
                        '${controller.downloadProgress == null ? '' : '${controller.downloadProgress}% '}${string(context).download}',
                    icon: Icons.download,
                    onPressed: () => controller.downloadFile(),
                  ),
                CustomButton(
                  label: string(context).socketBot,
                  icon: Icons.message,
                  onPressed: () => context.push(Routes.chat),
                ),
              ],
            ));
  }
}
