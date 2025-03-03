import 'package:flutter/material.dart';
import 'package:flutter_application_1/Screen/signin_screen.dart';
import 'package:flutter_application_1/Screen/signup_screen.dart';

import '../theme/theme.dart';
import '../widgets/custom_scaffold.dart';
import '../widgets/welcome_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: Column(
        children: [
          Flexible(
            flex: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(
                vertical: 0,
                horizontal: 40.0,
              ),
              child: Center(
                child: RichText(
                  textAlign: TextAlign.center,
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: 'Content de te revoir!\n',
                        style: TextStyle(
                          fontSize: 45.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Flexible(
            flex: 1,
            child: Align(
              alignment: Alignment.bottomRight,
              child: Row(
                children: [
                  const Expanded(
                    child: WelcomeButton(
                      buttonText: 'Se connecter',
                      onTap: SignInScreen(),
                      color: Colors.transparent,
                      textColor: Colors.white,
                    ),
                  ),
                  Expanded(
                    child: WelcomeButton(
                      buttonText: 'S\'inscrire',
                      onTap: const SignUpScreen(),
                      color: Colors.white,
                      textColor: Color(0xff0c355f),
                    ),
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
