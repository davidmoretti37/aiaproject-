import 'package:flutter/material.dart';

class OnboardingController extends ChangeNotifier {
  int _currentPage = 0;
  int get currentPage => _currentPage;

  void nextPage() {
    if (_currentPage < onboardingStepsCount - 1) {
      _currentPage++;
      notifyListeners();
    }
  }

  void previousPage() {
    if (_currentPage > 0) {
      _currentPage--;
      notifyListeners();
    }
  }

  void jumpToPage(int page) {
    _currentPage = page;
    notifyListeners();
  }

  static int get onboardingStepsCount => 12;
}
