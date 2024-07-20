import 'package:drawing_sketch/widgets/class.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BoardingController extends GetxController {
  final RxList board = <Boarding>[
    Boarding(title: 'BoardTitle1', img: 'assets/png/board1.png'),
    Boarding(title: 'BoardTitle2', img: 'assets/png/board2.png'),
    Boarding(title: 'BoardTitle3', img: 'assets/png/board3.png')
  ].obs;
  final RxInt currentIndex = 0.obs;
  final PageController pageController = PageController();

  void next() {
    pageController.nextPage(duration: const Duration(milliseconds: 500), curve: Easing.linear);
  }

  void previous() {
    pageController.previousPage(duration: const Duration(milliseconds: 500), curve: Easing.linear);
  }

  bool last() => currentIndex.value == board.length - 1;

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }
}
