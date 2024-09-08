import "package:flutter/material.dart";
import "package:flutter/services.dart";

import "./router.dart";

void main() {
	WidgetsFlutterBinding.ensureInitialized();
	SystemChrome.setPreferredOrientations([
		DeviceOrientation.landscapeLeft,
		DeviceOrientation.landscapeRight
	]);
	runApp(const App());
}

class App extends StatelessWidget {
	const App({ super.key });

	@override
	Widget build(BuildContext context) {
		return MaterialApp.router(
			routerConfig: router
		);
	}
}