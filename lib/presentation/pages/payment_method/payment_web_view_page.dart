import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:futblha/presentation/widgets/custom_text.dart';
import 'package:futblha/presentation/widgets/snackbar_utill.dart';

import '../../../application/config/app_assets.dart';
import '../../../application/core/di/app_component/app_component.dart';
import '../../../application/core/utils/auto_router_setup/app_router.dart';
import '../../../generated/locale_keys.g.dart';
import '../auth/bloc/authentication_bloc.dart';

/// Message key for the `reason` the server puts on `/payment/failed`.
String paymentFailureMessageKey(String? reason) => switch (reason) {
  'declined' => LocaleKeys.payment_failed_declined,
  'expired' => LocaleKeys.payment_failed_expired,
  'cancelled' => LocaleKeys.payment_failed_cancelled,
  _ => LocaleKeys.payment_failed_unknown,
};

@RoutePage()
class PaymentWebViewPage extends StatefulWidget {
  final String paymentUrl;
  const PaymentWebViewPage({super.key, required this.paymentUrl});

  @override
  State<PaymentWebViewPage> createState() => _PaymentWebViewPageState();
}

class _PaymentWebViewPageState extends State<PaymentWebViewPage> {
 // InAppWebViewController? _controller;
  bool isLoading = true;
  bool handledPayment = false;
  double progress = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: const CustomText(LocaleKeys.payment)),
      body: Stack(
        children: [
          InAppWebView(
            initialUrlRequest: URLRequest(url: WebUri(widget.paymentUrl)),
            initialSettings: InAppWebViewSettings(javaScriptEnabled: true, clearCache: false, useShouldOverrideUrlLoading: true),
           // onWebViewCreated: (controller) => _controller = controller,
            onProgressChanged: (controller, progressValue) {
              setState(() {
                progress = progressValue / 100;
                isLoading = progressValue < 100;
              });
            },
            onLoadStop: (controller, url) async {
              if (kDebugMode) debugPrint("✅ PageFinished: $url");
              if (url != null && url.path.contains("/success")) {
                _handlePaymentSuccess(url);
              } else if (url != null && url.path.contains("/payment/failed")) {
                _handlePaymentFailed(url);
              }
            },
            shouldOverrideUrlLoading: (controller, navigationAction) async {
              final uri = navigationAction.request.url;
              if (kDebugMode) debugPrint("➡️ NavigationRequest: $uri");
              // if (uri != null && uri.path.contains("/callback/success")) {
              //   _handlePaymentSuccess(uri);
              //   return NavigationActionPolicy.CANCEL;
              // }
              return NavigationActionPolicy.ALLOW;
            },
            onReceivedError: (_, _, _) {
              setState(() => isLoading = false);
            },
          ),
          if (isLoading) LinearProgressIndicator(value: progress > 0 ? progress : null),
        ],
      ),
    );
  }

  /// The server redirects declined / expired / cancelled payments to
  /// `/payment/failed?paymentId=..&reason=..` and marks the payment failed
  /// itself. Close the web view with `false` so the caller can let the user
  /// try again, and refresh the profile (wallet balance).
  void _handlePaymentFailed(Uri uri) {
    if (handledPayment) return;
    handledPayment = true;

    locator<AuthenticationBloc>().add(GetProfileEvent());
    context.showMessage(
      isError: true,
      paymentFailureMessageKey(uri.queryParameters['reason']).tr(),
    );
    context.router.maybePop(false);
  }

  void _handlePaymentSuccess(Uri uri) {
    if (handledPayment) return;
    handledPayment = true;

    final paymentId = uri.queryParameters['paymentId'];
    locator<AuthenticationBloc>().add(GetProfileEvent());

    context.router.pushAndPopUntil(
      CustomSuccessRoute(
        iconPath: AppAssets.ic_success,
        title: LocaleKeys.order_placed.tr(),
        message: '${LocaleKeys.order_placed_success_message.tr()}\n${paymentId ?? ''}',
        onButtonPress: () {},
      ),
      predicate: (_) => false,
    );
  }
}
