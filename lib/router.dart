import "package:go_router/go_router.dart";

import "./screens/home/main.dart";
import "./screens/game/main.dart";

final List<GoRoute> routes = [
	GoRoute(path: "/", redirect: (ctx, _) => "/game"),
	GoRoute(path: "/home", builder: (ctx, _) => const HomeScreen()),
	GoRoute(path: "/game", builder: (ctx, _) => const GameScreen()),
];

final router = GoRouter(
	routes: routes
);