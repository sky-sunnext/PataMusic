import "package:flutter/material.dart";

class PointerStatus with ChangeNotifier {
	Offset position = const Offset(0, 0);

	update() {
		notifyListeners();
	}
}