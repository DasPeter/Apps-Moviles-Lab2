import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:lab2/pages/home_page.dart';
import 'package:lab2/utils/secrets.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SignInScreen(
      headerBuilder: (context, constraints, shrinkOffset) {
        return const Center(
            child: Text(
          "Welcome to FindTrackApp! 🎵\n\nPlease login to continue.",
          textAlign: TextAlign.center,
          style: TextStyle(),
        ));
      },
      providerConfigs: const [
        EmailProviderConfiguration(),
        GoogleProviderConfiguration(clientId: GOOGLE_CLIENT_ID),
      ],
      footerBuilder: (context, action) {
        return const Center(
          child: Text("By signing in, you agree to our terms and conditions."),
        );
      },
      actions: [
        AuthStateChangeAction<SignedIn>((context, state) {
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const HomePage()));
        })
      ],
    );
  }
}
