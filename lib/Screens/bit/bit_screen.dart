import 'package:aparcamientoszaragoza/Models/user-register.dart';
import 'package:aparcamientoszaragoza/Screens/bit/providers/BitProviders.dart';
import 'package:aparcamientoszaragoza/Screens/register/providers/RegisterProviders.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aparcamientoszaragoza/l10n/app_localizations.dart';

import '../../Common_widgets/gradient_background.dart';
import '../../Components/app_text_form_field.dart';
import '../../Utils/helpers/snackbar_helper.dart';
import '../../Values/app_regex.dart';
import '../../Values/app_strings.dart';
import '../../Values/app_theme.dart';
import '../smsVerified/smsvalidate_screen.dart';

class BitPage extends ConsumerStatefulWidget {

  static const routeName = '/bit-page';

  const BitPage({super.key});

  @override
  ConsumerState<BitPage> createState() => _BitPageState();
}

class _BitPageState extends ConsumerState<BitPage> {
  final _formKey = GlobalKey<FormState>();

  String ethNumber = "";

  late final TextEditingController ethAccountController;
  late final TextEditingController bitAmountController;

  final ValueNotifier<bool> fieldValidNotifier = ValueNotifier(false);

  void initializeControllers() {
    ethAccountController = TextEditingController()..addListener(controllerListener);
    bitAmountController = TextEditingController()..addListener(controllerListener);
  }

  void disposeControllers() {
    ethAccountController.dispose();
    bitAmountController.dispose();
  }

  void controllerListener() {
    final name = ethAccountController.text;
    final amount = bitAmountController.text;

    if (name.isEmpty) return;
    if (amount.isEmpty) return;

    fieldValidNotifier.value = true;
  }

  @override
  void initState() {
    initializeControllers();
    super.initState();
  }

  @override
  void dispose() {
    disposeControllers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    AsyncValue<String> result = ref.watch(bitProvider);

    if (result.value != null) {
      ethNumber = result.value ?? "";
    }

    return Scaffold(
      body: ListView(
        children: [
          GradientBackground(
              children: [
                Text(AppLocalizations.of(context)!.bitTitle, style: AppTheme.titleLarge),
                const SizedBox(height: 6),
                Text(AppLocalizations.of(context)!.createBitSubtitle, style: AppTheme.bodySmall),
              ],
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text("${ethNumber} ETH", style: AppTheme.bodySmall),
                  AppTextFormField(
                    autofocus: true,
                    labelText: AppLocalizations.of(context)!.accountEthLabel,
                    keyboardType: TextInputType.name,
                    textInputAction: TextInputAction.next,
                    onChanged: (value) => _formKey.currentState?.validate(),
                    validator: (value) {
                      if (value == null || value.isEmpty) return AppLocalizations.of(context)!.pleaseEnterEthAccount;
                      return value.length < 4
                          ? AppLocalizations.of(context)!.invalidEthAccount
                          : null;
                    },
                    controller: ethAccountController,
                  ),
                  AppTextFormField(
                    autofocus: true,
                    labelText: AppLocalizations.of(context)!.bitAmountLabel,
                    keyboardType: TextInputType.name,
                    textInputAction: TextInputAction.next,
                    onChanged: (value) => _formKey.currentState?.validate(),
                    validator: (value) {
                      if (value == null || value.isEmpty) return AppLocalizations.of(context)!.pleaseEnterBitAmount;
                      return value.length < 4
                          ? AppLocalizations.of(context)!.invalidBitAmount
                          : null;
                    },
                    controller: bitAmountController,
                  ),
                  ValueListenableBuilder(
                    valueListenable: fieldValidNotifier,
                    builder: (_, isValid, __) {
                      return FilledButton(
                        onPressed: () => {
                          ref .read(bitProvider.notifier)
                              .createBit(ethAccountController.text, bitAmountController.text),
                        },
                        child: Text(AppLocalizations.of(context)!.bitTitle)
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
