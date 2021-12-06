import 'package:co/ui/auth/signup/almost_done.dart';
import 'package:co/ui/main/cards/physical_card.dart';
import 'package:co/ui/main/cards/virtual_card.dart';
import 'package:co/ui/main/credit/credit.dart';
import 'package:co/ui/main/home/home.dart';
import 'package:co/ui/main/transactions/transaction_admin.dart';
import 'package:co/ui/main/transactions/transaction_user.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:co/constants/constants.dart';
import 'package:co/ui/splash/loading.dart';
import 'package:co/ui/splash/splash.dart';
import 'package:co/ui/auth/signin/signin.dart';
import 'package:co/ui/auth/signin/signin_auth.dart';
import 'package:co/ui/auth/signin/forgotpwd.dart';
import 'package:co/ui/auth/signup/index.dart';
import 'package:co/ui/auth/signup/mail_verify.dart';
import 'package:co/ui/auth/signup/company_detail.dart';
import 'package:co/ui/auth/signup/registered_address.dart';
import 'package:co/ui/auth/signup/main_contact_person.dart';
import 'package:co/ui/auth/signup/two_step_verification.dart';
import 'package:co/ui/auth/signup/two_step_final.dart';
import 'package:co/ui/auth/signup/two_step_failed.dart';

import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:co/utils/basedata.dart';
import 'dart:convert';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    final HttpLink httpLink = HttpLink("https://gql.staging.fxr.one/v1/graphiql/");
    AuthLink authLink = AuthLink(getToken: () async =>
      // final temptoken = token;
      // return '$temptoken';
      'Bearer eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IlJqQXhNekkwTjBWR1JqazRNalk0TWtZME1VTTBNVGd3TURsQlJVWTJOMFJCUXpVMU1UWXlSUSJ9.eyJodHRwOi8vYXBwLnN0YWdpbmcuZmluYXhhci5jb20vdXNlcl9tZXRhZGF0YSI6eyJmaXJzdF9uYW1lIjoiUm9uYWsiLCJsYXN0X25hbWUiOiJKYWluIiwicGhvbmUiOiIrOTE4ODc4MjQ0NTU0IiwiY29tcGFueV9uYW1lIjoiW1RFU1RdIGZsZXggbmV3IGNoYW5nZXMiLCJjb21wYW55X3R5cGUiOiJQYXJ0bmVyc2hpcHMiLCJsYW5ndWFnZSI6ImVuIiwic2lnbnVwX2NvdW50cnkiOiJzZyIsImdlb19kYXRhIjp7ImNvdW50cnlfY29kZSI6IklOIiwiY291bnRyeV9jb2RlMyI6IklORCIsImNvdW50cnlfbmFtZSI6IkluZGlhIiwiY2l0eV9uYW1lIjoiUHVuZSIsImxhdGl0dWRlIjoxOC42MTYxLCJsb25naXR1ZGUiOjczLjcyODYsInRpbWVfem9uZSI6IkFzaWEvS29sa2F0YSIsImNvbnRpbmVudF9jb2RlIjoiQVMifSwiaWQiOjE5OTMsInRva2VuIjoiWW53MFpBOVhLLUtwR3ZFZ2dSZE9wMng1THBZc3VHZzAifSwiaXNzIjoiaHR0cHM6Ly9maW5heGFyLXN0YWdpbmcuYXV0aDAuY29tLyIsInN1YiI6ImF1dGgwfDYwMTAxY2RkMTljOTI3MDA2YzUxNDdhYSIsImF1ZCI6WyJodHRwczovL2ZpbmF4YXItc3RhZ2luZy5hdXRoMC5jb20vYXBpL3YyLyIsImh0dHBzOi8vZmluYXhhci1zdGFnaW5nLmF1dGgwLmNvbS91c2VyaW5mbyJdLCJpYXQiOjE2Mzg3NzE4MjEsImV4cCI6MTYzODc3OTAyMSwiYXpwIjoibExUWnA5VTRSUkRONDlXdHA5YTE2c2lzamw0TXJFa0wiLCJzY29wZSI6Im9wZW5pZCBwcm9maWxlIn0.YMsQ8Az4jzsTxJLoHpy1pUx0iz1Ma_ArE35xGRvg_q8vjYgrAuSH82Y2JTGjCaOmxCrDu40CUcPIoR5bbliK-u9VeiZWJ79ofe9puvbrRohGlfdyKhM7B-fv8Ye_5_-iWTdh7nPpq9OsLLYHXVCaAdoplHzuVS165F9nUe9zdMZmBcWjQyLJSVhDZyiDJgxUMvP-xMOXrLQVkepKSSHjHlVyRDAAzCKUvEdzAhX6otszVoIVyWbHgaHcZnZsBzMN4beiq0MjgM4SDZWyXLWI1z17GhWDfo3wVfYJMAVZV0jyWGEFhKkDUfVaBQMrhsAIkbttBAWSk-33jxxz4fg0Ow'
    );
    final Link link = authLink.concat(httpLink);

    // final HttpLink rickAndMortyHttpLink =
    //     HttpLink('https://rickandmortyapi.com/graphql');

    ValueNotifier<GraphQLClient> client = ValueNotifier(
      GraphQLClient(
        link: link,
        cache: GraphQLCache(
          store: InMemoryStore(),
        ),
      ),
    );

    return GraphQLProvider(
      client: client,
      child: MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: <String, WidgetBuilder>{
        LOADING_SCREEN: (BuildContext context) => const LoadingScreen(),
        SPLASH_SCREEN: (BuildContext context) => const SplashScreen(),
        SIGN_IN: (BuildContext context) => const SignInScreen(),
        SIGN_IN_AUTH: (BuildContext context) => const SignInAuthScreen(),
        FORGOT_PWD: (BuildContext context) => const ForgotPwdScreen(),
        SIGN_UP: (BuildContext context) => const SignUpScreen(),
        MAIL_VERIFY: (BuildContext context) => const MailVerifyScreen(),
        COMPANY_DETAIL: (BuildContext context) => const CompanyDetailScreen(),
        REGISTERED_ADDRESS: (BuildContext context) =>
            const RegisteredAddressScreen(),
        MAIN_CONTACT_PERSON: (BuildContext context) =>
            const MainContactPersonScreen(),
        TWO_STEP_VERIFICATION: (BuildContext context) =>
            const TwoStepVerificationScreen(),
        TWO_STEP_FINAL: (BuildContext context) => const TwoStepFinalScreen(),
        TWO_STEP_FAILED: (BuildContext context) => const TwoStepFailedScreen(),
        ALMOST_DONE: (BuildContext context) => const AlmostDoneScreen(),
        // MAIN_SCREEN: (BuildContext context) =>  MainScreen(),
        HOME_SCREEN: (BuildContext context) => const HomeScreen(),
        PHYSICAL_CARD: (BuildContext context) => const PhysicalCards(),
        VIRTUAL_CARD: (BuildContext context) => const VirtualCards(),
        TRANSACTION_ADMIN: (BuildContext context) => const TransactionAdmin(),
        TRANSACTION_USER: (BuildContext context) => const TransactionUser(),
        CREDIT_SCREEN: (BuildContext context) => const CreditScreen(),
      },
      initialRoute: LOADING_SCREEN,
      
    ));
  }
}

// class AuthenticationState extends ChangeNotifier{

//   final _token = [];
//   dynamic get authenticationToken => _token;

//   void changeAuthState(value){
//     _token.add(value);
//     notifyListeners();
//   }
// }
