import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:task_manager/l10n/messages_all.dart';

class DemoLocalizations {
  static Future<DemoLocalizations> load(Locale locale) {
    final String name = locale?.countryCode?.isEmpty ?? true ? locale.languageCode : locale.toString();
    final String localeName = Intl.canonicalizedLocale(name);

    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      return DemoLocalizations();
    });
  }

  static DemoLocalizations of(BuildContext context) {
    return Localizations.of<DemoLocalizations>(context, DemoLocalizations);
  }

  String get title {
    return Intl.message(
      'Welcome',
      name: 'title',
      desc: 'message on home page',
    );
  }

  String get continueButton {
    return Intl.message(
      'Continue',
      name: 'continueButton',
      desc: 'Button text on home page',
    );
  }

  String get email {
    return Intl.message(
      'Email',
      name: 'email',
      desc: 'Label for getting email',
    );
  }

  String get password {
    return Intl.message(
      'Password',
      name: 'password',
      desc: 'Label for getting password',
    );
  }

  String get loginButton {
    return Intl.message(
      'Login',
      name: 'loginButton',
      desc: 'Button text for login',
    );
  }

  String get signUpButton {
    return Intl.message(
      'SignUp',
      name: 'signUpButton',
      desc: 'Button text for signup',
    );
  }

  String get login {
    return Intl.message(
      "Have an account? Login",
      name: 'login',
      desc: 'Flat button text for login',
    );
  }

  String get signUp {
    return Intl.message(
      "Don't have an account? Sign up",
      name: 'signUp',
      desc: 'Flat button text for signup',
    );
  }

  String get cTitle {
    return Intl.message(
      'Clients list',
      name: 'cTitle',
      desc: 'Title on clients page',
    );
  }

  String get addButton {
    return Intl.message(
      'Add Clients',
      name: 'addButton',
      desc: 'Button text for adding clients',
    );
  }

  String get signOutButton {
    return Intl.message(
      'SignOut',
      name: 'signOutButton',
      desc: 'Button text for sign out',
    );
  }

  String get name {
    return Intl.message(
      'Name',
      name: 'name',
      desc: 'Label for getting name',
    );
  }

  String get submitButton {
    return Intl.message(
      'Submit',
      name: 'submitButton',
      desc: 'Button text for submit',
    );
  }

  String get backButton {
    return Intl.message(
      'Back',
      name: 'backButton',
      desc: 'Button text for back',
    );
  }

  String get phoneNo {
    return Intl.message(
      'Phone no.',
      name: 'phoneNo',
      desc: 'Label for getting name',
    );
  }

  String get addUserButton {
    return Intl.message(
      'Add Users',
      name: 'addUserButton',
      desc: 'Button text for adding clients',
    );
  }
}

class DemoLocalizationsDelegate extends LocalizationsDelegate<DemoLocalizations> {
  const DemoLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'mr'].contains(locale.languageCode);

  @override
  Future<DemoLocalizations> load(Locale locale) {
    return DemoLocalizations.load(locale);
  }

  @override
  bool shouldReload(DemoLocalizationsDelegate old) => false;
}

/*
Commands for generating l10n files:
flutter pub run intl_translation:extract_to_arb --output-dir=lib/l10n lib/locales/locale.dart

 flutter pub run intl_translation:generate_from_arb --output-dir=lib/l10n --no-use-deferred-loading lib/l10n/intl_en.arb lib/l10n/intl_mr.arb lib/l10n/intl_messages.arb lib/locales/locale.dart*/
