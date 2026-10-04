import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:futblha/application/config/design_system/app_colors.dart';
import 'package:futblha/application/core/basecomponents/base_view_model_view.dart';
import 'package:futblha/application/core/di/app_component/app_component.dart';
import 'package:futblha/application/core/utils/helpers/extension_functions/size_extension.dart';
import 'package:futblha/presentation/widgets/app_size_boxes.dart';
import 'package:futblha/domain/entities/payment_method_entity.dart';
import 'package:futblha/presentation/pages/playgrounds/payment_method_bottom_sheet.dart';
import 'package:futblha/presentation/pages/wallet/bloc/wallet_bloc.dart';
import 'package:futblha/presentation/widgets/snackbar_utill.dart';
import 'package:futblha/data/models/request_model/wallet/add_balance_request_model.dart';
import 'package:futblha/application/core/utils/auto_router_setup/app_router.dart';
import 'package:futblha/generated/locale_keys.g.dart';

@RoutePage()
class ChargeWalletPage extends StatefulWidget {
  final double amount;

  const ChargeWalletPage({super.key, required this.amount});

  @override
  State<ChargeWalletPage> createState() => _ChargeWalletPageState();
}

class _ChargeWalletPageState extends State<ChargeWalletPage> {
  final bloc = locator<WalletBloc>();
  PaymentMethodEntity? _selectedPaymentMethod;

  void _showPaymentMethodBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return PaymentMethodBottomSheet(
          selectedMethod: _selectedPaymentMethod?.key ?? _selectedPaymentMethod?.name ?? '',
          onMethodSelected: (method) {
            setState(() {
              _selectedPaymentMethod = method;
            });
          },
        );
      },
    );
  }

  void _confirmCharge() {
    if (_selectedPaymentMethod == null) {
      context.showMessage(isError: true, LocaleKeys.please_select_payment_method.tr());
      return;
    }

    final request = AddBalanceRequestModel(
      amount: widget.amount,
      paymentMethod: _selectedPaymentMethod!.key ?? 'kent',
    );
    bloc.add(AddBalanceEvent(request: request));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(LocaleKeys.charge_wallet.tr())),
      body: CustomBlocConsumer<WalletBloc, WalletState>(
        bloc: bloc,
        listener: (context, state) {
          if (state is WalletError) {
            context.showMessage(isError: true, state.message);
          } else if (state is WalletSuccess) {
            // Handle success - show payment URL or success dialog
            if (bloc.addBalanceResponse?.paymentUrl != null &&
                bloc.addBalanceResponse!.paymentUrl!.isNotEmpty) {
              // Navigate to payment webview
              context.router.push(
                PaymentWebViewRoute(paymentUrl: bloc.addBalanceResponse!.paymentUrl!),
              );
            } else {
              showDialog(
                context: context,
                barrierColor: Colors.black.withValues(alpha: 0.7),
                builder: (context) => _PaymentSuccessDialog(),
              );
            }
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Charge Wallet Amount Card
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: AppColors.primaryWhite,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.account_balance_wallet,
                        color: AppColors.primaryColor,
                        size: 32,
                      ),
                      16.widthBox(),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              LocaleKeys.charge_wallet.tr(),
                              style: const TextStyle(
                                color: AppColors.primaryColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            4.heightBox(),
                            Text(
                              '${widget.amount.toStringAsFixed(3)} ${LocaleKeys.kwd.tr()}',
                              style: const TextStyle(
                                color: AppColors.primaryColor,
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                24.heightBox(),
                // Payment Method Section
                Text(
                  LocaleKeys.payment_method.tr(),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                12.heightBox(),
                GestureDetector(
                  onTap: _showPaymentMethodBottomSheet,
                  child: Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: AppColors.primaryWhite,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _selectedPaymentMethod?.name ?? _selectedPaymentMethod?.key ?? '',
                          style: const TextStyle(
                            color: AppColors.primaryColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_selectedPaymentMethod?.key == 'apple_pay' ||
                                _selectedPaymentMethod?.name?.toLowerCase() == 'apple pay')
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.apple, color: AppColors.primaryBlack, size: 20),
                                  4.widthBox(),
                                  Text(
                                    LocaleKeys.pay.tr(),
                                    style: const TextStyle(
                                      color: AppColors.primaryBlack,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            const Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: AppColors.primaryDark,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                24.heightBox(),
                // Price Summary Section
                Text(
                  LocaleKeys.price_summary.tr(),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                12.heightBox(),
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: AppColors.primaryWhite,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        LocaleKeys.charge_fees.tr(),
                        style: const TextStyle(
                          color: AppColors.primaryDark,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Text(
                        '${widget.amount.toStringAsFixed(3)} ${LocaleKeys.kwd.tr()}',
                        style: const TextStyle(
                          color: AppColors.primaryDark,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                32.heightBox(),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: CustomBlocConsumer<WalletBloc, WalletState>(
        bloc: bloc,
        listener: (context, state) {},
        builder: (context, state) {
          return Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: AppColors.primaryWhite,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryBlack.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (state is WalletLoading || _selectedPaymentMethod == null)
                    ? null
                    : _confirmCharge,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  disabledBackgroundColor: AppColors.primaryLiteGrey,
                ),
                child: state is WalletLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryWhite),
                        ),
                      )
                    : Text(
                        LocaleKeys.confirm.tr(),
                        style: const TextStyle(
                          color: AppColors.primaryWhite,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PaymentSuccessDialog extends StatelessWidget {
  const _PaymentSuccessDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.all(32.w),
        decoration: BoxDecoration(
          color: AppColors.primaryWhite,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80.w,
              height: 80.w,
              decoration: BoxDecoration(color: AppColors.primaryColor, shape: BoxShape.circle),
              child: const Icon(Icons.check, color: AppColors.primaryWhite, size: 50),
            ),
            24.heightBox(),
            Text(
              LocaleKeys.payment_done_successfully.tr(),
              style: const TextStyle(
                color: AppColors.primaryDark,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            24.heightBox(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  // Navigate back to wallet page
                  context.router.popUntil(
                    (route) =>
                        route.settings.name == WalletRoute.name || route.settings.name == '/',
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  LocaleKeys.ok_button.tr(),
                  style: const TextStyle(
                    color: AppColors.primaryWhite,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
