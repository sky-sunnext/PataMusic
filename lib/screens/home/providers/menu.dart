class MenuStatus {
	bool isOpen = false;
	String? secondTag;

	final List<void Function(bool)> _listeners = [];
	addListener(void Function(bool) listener) {
		_listeners.add(listener);
	}

	openMenu() {
		isOpen = true;
		_applyChange();
	}

	closeMenu() {
		isOpen = false;
		_applyChange();
	}

	_applyChange() {
		for (final listener in _listeners) {
			listener(isOpen);
		}
		secondTag = null;
	}

	toggleMenu() {
		if (isOpen) {
			closeMenu();
		} else {
			openMenu();
		}
	}
}