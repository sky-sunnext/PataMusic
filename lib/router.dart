import "package:go_router/go_router.dart";

import "./screens/home/main.dart";

final List<GoRoute> routes = [
	GoRoute(path: "/", redirect: (ctx, _) => "/home"),
	GoRoute(path: "/home", builder: (ctx, _) => const HomeScreen()),
];

final router = GoRouter(
	routes: routes
);