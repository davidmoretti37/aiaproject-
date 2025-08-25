import 'package:flutter/material.dart';

class OnboardingController extends ChangeNotifier {
  final PageController pageController = PageController();
  int currentPage = 0;

  void nextPage() {
    if (currentPage < onboardingStepsCount - 1) {
      currentPage++;
      pageController.animateToPage(
        currentPage,
        duration: const Duration(milliseconds: 400),
        curve: Curves.ease,
      );
      notifyListeners();
    }
  }

  void previousPage() {
    if (currentPage > 0) {
      currentPage--;
      pageController.animateToPage(
        currentPage,
        duration: const Duration(milliseconds: 400),
        curve: Curves.ease,
      );
      notifyListeners();
    }
  }

  void jumpToPage(int page) {
    currentPage = page;
    pageController.jumpToPage(page);
    notifyListeners();
  }

  static int get onboardingStepsCount => 12;
}
