import "dart:io";
import "package:flutter/foundation.dart";

class DeviceInfo {
	bool isWeb = kIsWeb;
	bool isWebMobile = kIsWeb &&
		(defaultTargetPlatform == TargetPlatform.android
		|| defaultTargetPlatform == TargetPlatform.iOS
		|| defaultTargetPlatform == TargetPlatform.fuchsia);
	bool get isWebDesktop => !isWebMobile;

	final bool _isMobile =
		Platform.isAndroid
		|| Platform.isFuchsia
		|| Platform.isIOS;
	bool get isMobile => isWebMobile || _isMobile;
	bool get isDesktop => !isMobile;

	DeviceInfo();
}

