import 'package:aparcamientoszaragoza/Screens/smsVerified/providers/SmsValidateProviders.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sms_autodetect/sms_autodetect.dart';

import '../../Components/app_text_form_field.dart';
import '../../Values/app_regex.dart';
import '../../Values/app_strings.dart';

class SmsValidatePage extends ConsumerStatefulWidget {

  static const routeName = '/smsvalidate-page';

  const SmsValidatePage({super.key});

  @override
  ConsumerState<SmsValidatePage> createState() => _SmsValidateState();
}

class _SmsValidateState extends ConsumerState<SmsValidatePage> {

  late final TextEditingController phoneNumberController;
  final ValueNotifier<bool> phoneNumberNotifier = ValueNotifier(false);

  void initializeControllers() {
    phoneNumberController = TextEditingController()
      ..addListener(controllerPhoneListener);
  }

  void controllerPhoneListener() {
    return;
  }

  @override
  void initState() {
    initializeControllers();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Introduce el código SMS'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppTextFormField(
              labelText: AppStrings.phoneNumber,
              controller: phoneNumberController,
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.number,
              onChanged: (text) => {
                setState(() {
                  phoneNumberNotifier.value = text.isNotEmpty && AppRegex.phoneNumberRegex.hasMatch(text);
                }),
              },
              validator: (value) {
                return value!.isEmpty
                    ? AppStrings.pleasePhoneNumber
                    : AppRegex.phoneNumberRegex.hasMatch(value)
                    ? null
                    : AppStrings.phoneNumberInvalid;
              },
            ),
            PinCodeTextField(
              autoDisposeControllers: false,
              appContext: context,
              pastedTextStyle: TextStyle(
                color: Colors.green.shade600,
                fontWeight: FontWeight.bold,
              ),
              length: 6,
              obscureText: true,
              obscuringCharacter: '*',
              obscuringWidget: Icon(Icons.vpn_key_rounded),
              blinkWhenObscuring: true,
              animationType: AnimationType.fade,
              validator: (v) {
                if (v!.length < 6) {
                  return "Please enter valid OTP";
                } else {
                  return null;
                }
              },
              pinTheme: PinTheme(
                fieldOuterPadding: EdgeInsets.only(left: 8, right: 8),
                shape: PinCodeFieldShape.box,
                borderRadius: BorderRadius.circular(5),
                fieldHeight: 50,
                fieldWidth: 45,
                activeFillColor: Colors.white,
                inactiveFillColor: Colors.white,
                selectedColor: Colors.black54,
                selectedFillColor: Colors.white,
                inactiveColor: Colors.black54,
                activeColor: Colors.black54,
              ),
              cursorColor: Colors.black,
              animationDuration: Duration(milliseconds: 300),
              enableActiveFill: true,
              autoDismissKeyboard: false,
              keyboardType: TextInputType.number,
              mainAxisAlignment: MainAxisAlignment.center,
              boxShadows: [
                BoxShadow(
                  offset: Offset(0, 1),
                  color: Colors.black12,
                  blurRadius: 5,
                )
              ],
              onCompleted: (v) {
                print("Completed");
              },
              onTap: () {
                print("Pressed");
              },
              onChanged: (value) {
                print(value);
              },
              beforeTextPaste: (text) {
                print("Allowing to paste $text");
                //if you return true then it will show the paste confirmation dialog. Otherwise if false, then nothing will happen.
                //but you can show anything you want here, like your pop up saying wrong paste format or etc
                return true;
              },
            ),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                ref .read(smsValidateProvider.notifier).verifiedSMS(phoneNumberController.text);
              },
              child: const Text('Verificar'),
            ),
          ],
        ),
      ),
    );
  }
}
