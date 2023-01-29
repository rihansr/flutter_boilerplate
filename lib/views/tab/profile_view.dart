import 'package:flutter/material.dart';
import '../components/custom_button.dart';
import '../../shared/enums.dart';
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
                icon: "assets/icons/ic_pm_stripe.svg",
                loading:
                    controller.isLoading(key: 'stripe_payment', orElse: false),
                onPressed: () => controller.payVia(PaymentMethod.stripe),
              ),
              CustomButton(
                label: string(context).paypal,
                icon: "assets/icons/ic_pm_paypal.svg",
                loading:
                    controller.isLoading(key: 'paypal_payment', orElse: false),
                onPressed: () => controller.payVia(PaymentMethod.paypal),
              ),
              CustomButton(
                label: string(context).ssl,
                icon: "assets/icons/ic_pm_ssl.svg",
                loading:
                    controller.isLoading(key: 'ssl_payment', orElse: false),
                onPressed: () => controller.payVia(PaymentMethod.ssl),
              ),
            ],
          );
        });
  }
}
