import "dart:io";
import "package:flutter/foundation.dart";

class DeviceInfo {
	bool isWeb = kIsWeb;
	bool isWebMobile = kIsWeb &&
		(defaultTargetPlatform == TargetPlatform.android
		|| defaultTargetPlatform == TargetPlatform.iOS
		|| defaultTargetPlatform == TargetPlatform.fuchsia);
	bool get isWebDesktop=> isWebMobile;

	late bool _isMobile;
	bool get isMobile => _isMobile;
	bool get isDesktop => !isMobile;

	DeviceInfo() {
		if (isWeb) {
			// Web
			_isMobile = isWebMobile;
		} else {
			_isMobile =
				Platform.isAndroid
				|| Platform.isFuchsia
				|| Platform.isIOS;
		}
	}
}

