import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:futblha/application/config/design_system/app_colors.dart';
import 'package:futblha/application/core/basecomponents/base_view_model_view.dart';
import 'package:futblha/application/core/di/app_component/app_component.dart';
import 'package:futblha/application/core/utils/helpers/extension_functions/size_extension.dart';
import 'package:futblha/presentation/widgets/app_size_boxes.dart';
import 'package:futblha/presentation/widgets/custom_loading_widget.dart';
import 'package:futblha/presentation/widgets/snackbar_utill.dart';
import 'package:futblha/presentation/pages/payment_method/bloc/payment_method_bloc.dart';
import 'package:futblha/generated/locale_keys.g.dart';

import '../../../domain/entities/payment_method_entity.dart';

class PaymentMethodBottomSheet extends StatefulWidget {
  final String selectedMethod;
  final Function(PaymentMethodEntity) onMethodSelected;

  const PaymentMethodBottomSheet({
    super.key,
    required this.selectedMethod,
    required this.onMethodSelected,
  });

  @override
  State<PaymentMethodBottomSheet> createState() => _PaymentMethodBottomSheetState();
}

class _PaymentMethodBottomSheetState extends State<PaymentMethodBottomSheet> {
  PaymentMethodEntity? _selectedMethod;
  final paymentMethodBloc = locator<PaymentMethodBloc>();

  @override
  void initState() {
    super.initState();
    // Fetch payment methods if not already loaded
    if (paymentMethodBloc.state is! PaymentMethodLoaded) {
      paymentMethodBloc.add(GetPaymentMethodsEvent());
    }
  }

  void _initializeSelectedMethod(List<PaymentMethodEntity> paymentMethods) {
    if (_selectedMethod != null || paymentMethods.isEmpty) return;

    // Find matching method by key or name
    try {
      _selectedMethod = paymentMethods.firstWhere(
        (method) =>
            method.key?.toLowerCase() == widget.selectedMethod.toLowerCase() ||
            method.name?.toLowerCase() == widget.selectedMethod.toLowerCase() ||
            (widget.selectedMethod == 'Apple Pay' && method.key == 'apple_pay') ||
            (widget.selectedMethod == 'K-Net Fast' && method.key == 'kent') ||
            (widget.selectedMethod == 'Visa/Master' && method.key == 'visa_master'),
      );
    } catch (e) {
      // If no match found, use the first available method
      _selectedMethod = paymentMethods.first;
    }
  }

  IconData _getPaymentMethodIcon(String? key) {
    switch (key?.toLowerCase()) {
      case 'apple_pay':
        return Icons.apple;
      case 'kent':
        return Icons.payment;
      case 'visa_master':
        return Icons.credit_card;
      default:
        return Icons.payment;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomBlocConsumer<PaymentMethodBloc, PaymentMethodState>(
      bloc: paymentMethodBloc,
      listener: (context, state) {
        if (state is PaymentMethodError) {
          context.showMessage(isError: true, state.message);
        }
      },
      builder: (context, state) {
        return Container(
          margin: EdgeInsets.only(top: 32.h),
          decoration: BoxDecoration(
            color: AppColors.backgroundColor,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      LocaleKeys.payment_method.tr(), 
                      style: const TextStyle(
                        color: AppColors.primaryBlack,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: AppColors.primaryDark),
                    ),
                  ],
                ),
                20.heightBox(),
                if (state is PaymentMethodLoading)
                  const Center(
                    child: Padding(padding: EdgeInsets.all(20.0), child: LoadingWidget()),
                  )
                else if (state is PaymentMethodLoaded && state.paymentMethods.isNotEmpty) ...[
                  Builder(
                    builder: (context) {
                      _initializeSelectedMethod(state.paymentMethods);
                      return const SizedBox.shrink();
                    },
                  ),
                  ...state.paymentMethods.map((method) {
                    final isSelected = _selectedMethod?.key == method.key;
                    return Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: _buildPaymentOption(
                        method.name ?? method.key ?? '',
                        _getPaymentMethodIcon(method.key),
                        method: method,
                        isSelected: isSelected,
                      ),
                    );
                  }),
                ] else
                  const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Center(
                      child: Text(
                        'No payment methods available',
                        style: TextStyle(color: AppColors.lightTextColor, fontSize: 14),
                      ),
                    ),
                  ),
                24.heightBox(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _selectedMethod != null
                        ? () {
                            widget.onMethodSelected(_selectedMethod!);
                            Navigator.pop(context);
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      LocaleKeys.confirm.tr(),
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
      },
    );
  }

  Widget _buildPaymentOption(
    String methodName,
    IconData icon, {
    required PaymentMethodEntity method,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMethod = method;
        });
      },
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.primaryLiteGrey,
          borderRadius: BorderRadius.circular(12),
          border: isSelected ? Border.all(color: AppColors.primaryColor, width: 2) : null,
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primaryColor : AppColors.primaryGrey,
                  width: 2,
                ),
                color: isSelected ? AppColors.primaryColor : AppColors.primaryWhite,
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 16, color: AppColors.primaryWhite)
                  : null,
            ),
            16.widthBox(),
            Icon(icon, color: AppColors.primaryDark, size: 24),
            12.widthBox(),
            Text(
              methodName,
              style: TextStyle(
                color: AppColors.primaryDark,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
