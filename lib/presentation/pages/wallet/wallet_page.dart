import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:futblha/application/config/design_system/app_colors.dart';
import 'package:futblha/application/config/design_system/app_theme_colors.dart';
import 'package:futblha/application/core/basecomponents/base_view_model_view.dart';
import 'package:futblha/application/core/di/app_component/app_component.dart';
import 'package:futblha/application/core/utils/helpers/extension_functions/size_extension.dart';
import 'package:futblha/presentation/widgets/app_size_boxes.dart';
import 'package:futblha/presentation/widgets/custom_loading_widget.dart';
import 'package:futblha/presentation/widgets/snackbar_utill.dart';
import 'package:futblha/application/core/utils/auto_router_setup/app_router.dart';
import 'package:futblha/presentation/pages/wallet/charge_wallet_bottom_sheet.dart';
import 'package:futblha/presentation/pages/wallet/bloc/wallet_bloc.dart';
import 'package:futblha/generated/locale_keys.g.dart';

import '../../../data/models/response_model/wallet/transaction_model.dart';

@RoutePage()
class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  final bloc = locator<WalletBloc>();

  @override
  void initState() {
    super.initState();
    bloc.add(GetTransactionsEvent());
  }

  void _showChargeWalletBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return ChargeWalletBottomSheet(
          onProceed: (amount) {
            Navigator.pop(context);
            context.router.push(ChargeWalletRoute(amount: amount));
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(LocaleKeys.wallet.tr())),
      body: CustomBlocConsumer<WalletBloc, WalletState>(
        bloc: bloc,
        listener: (context, state) {
          if (state is WalletError) {
            context.showMessage(isError: true, state.message);
          }
        },
        builder: (context, state) {
          return state is WalletLoading
              ? const LoadingWidget()
              : SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Wallet Balance Card
                      Container(
                        padding: EdgeInsets.all(20.w),
                        decoration: BoxDecoration(
                          color: context.chipBackground,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.account_balance_wallet,
                                  color: context.brandOnSurface,
                                  size: 32,
                                ),
                                16.widthBox(),
                                Text(
                                  LocaleKeys.wallet_balance.tr(),
                                  style: TextStyle(
                                    color: context.brandOnSurface,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            16.heightBox(),
                            Text(
                              '${bloc.balance ?? '0.000'} ${LocaleKeys.kwd.tr()}',
                              style: TextStyle(
                                color: context.brandOnSurface,
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            20.heightBox(),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () => _showChargeWalletBottomSheet(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryColor,
                                  padding: EdgeInsets.symmetric(vertical: 14.h),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  LocaleKeys.charge_wallet_button.tr(),
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
                      24.heightBox(),
                      // Transactions Section
                      Text(
                        LocaleKeys.transactions.tr(),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      16.heightBox(),
                      bloc.transactions.isEmpty
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(32.0),
                                child: Text(
                                  LocaleKeys.no_transactions_yet.tr(),
                                  style: TextStyle(color: AppColors.lightTextColor, fontSize: 16),
                                ),
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: bloc.transactions.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: EdgeInsets.only(bottom: 12.h),
                                  child: _buildTransactionCard(bloc.transactions[index]),
                                );
                              },
                            ),
                    ],
                  ),
                );
        },
      ),
    );
  }

  Widget _buildTransactionCard(TransactionModel transaction) {
    final isGained = transaction.type == 'gained';
    final amountColor = isGained ? context.brandOnSurface : AppColors.primaryRed;
    final typeText = isGained ? LocaleKeys.gained.tr() : LocaleKeys.deduct.tr();
    final amountPrefix = isGained ? '+' : '';
    final amount =
        double.tryParse(transaction.amount?.replaceAll(RegExp(r'[^\d.-]'), '') ?? '0') ?? 0.0;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: context.cardBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      typeText,
                      style: TextStyle(
                        color: amountColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '$amountPrefix${amount.toStringAsFixed(3)} ${LocaleKeys.kwd.tr()}',
                      style: TextStyle(
                        color: amountColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                4.heightBox(),
                Text(
                  transaction.notes ?? '',
                  style: TextStyle(
                    color: context.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                4.heightBox(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (transaction.id != null) ...[
                      Text(
                        '${LocaleKeys.transaction_no.tr()} : ${transaction.id}',
                        style: const TextStyle(
                          color: AppColors.lightTextColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                    Text(
                      transaction.createdAt ?? '',
                      style: const TextStyle(
                        color: AppColors.lightTextColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
