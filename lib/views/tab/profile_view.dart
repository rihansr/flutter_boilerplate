import 'package:flutter/material.dart';
import '../components/custom_button.dart';
import '../../controllers/payment_viewmodel.dart';
import '../../shared/strings.dart';
import '../../widgets/base_widget.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseWidget<PaymentViewModel>(
        model: PaymentViewModel(context),
        builder: (context, controller, child) {
          return Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              CustomButton(
                label: string(context).stripe,
                icon: Icons.payment,
                loading:
                    controller.isLoading(key: 'stripe_payment', orElse: false),
                onPressed: () => controller.stripePaymet(),
              ),
              CustomButton(
                label: string(context).ssl,
                icon: Icons.payment,
                loading:
                    controller.isLoading(key: 'ssl_payment', orElse: false),
                onPressed: () => controller.sslPaymet(),
              ),
            ],
          );
        });
  }
}
