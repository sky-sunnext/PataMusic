import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:flutter/services.dart";
import "./router.dart";
import "./provider.dart";

void main() {
	WidgetsFlutterBinding.ensureInitialized();
	SystemChrome.setPreferredOrientations([
		DeviceOrientation.landscapeLeft,
		DeviceOrientation.landscapeRight
	]);
	SystemChrome.setEnabledSystemUIMode(
		SystemUiMode.manual,
		overlays: []
	);

	runApp(MultiProvider(
		providers: [
			Provider<DeviceInfo>.value(value: DeviceInfo())
		],
		child: const App(),
	));
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