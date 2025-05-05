import 'package:flutter/material.dart';

extension NavigationExtensions on BuildContext {
  Future navigateToNextPage(String routeName) => Navigator.of(this).pushNamed(routeName);

  Future navigateToNextPageWithReplacement(String routeName) => Navigator.of(this).pushReplacementNamed(routeName);

  Future navigateToNextPageWithRemoveUntil(String routeName) => Navigator.of(this).pushNamedAndRemoveUntil(routeName, (route) => false);

  void navigateBack([Object? argument]) {
    if (Navigator.of(this).canPop()) {
      Navigator.of(this).pop(argument);
    }
  }
}
