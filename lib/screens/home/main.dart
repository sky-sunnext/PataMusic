import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:glassmorphism_ui/glassmorphism_ui.dart";
import "package:patamusic/providers.dart";

import "./providers/menu.dart";
import "./providers/pointer.dart";
import "./menu.dart";
import "./body.dart";
import "./style.dart";

class HomeScreen extends StatefulWidget {
	const HomeScreen({ super.key });

	@override
	State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
	late MenuStatus menuStatus;
	late PointerStatus pointerStatus = PointerStatus();

	@override
	void initState() {
		super.initState();

		menuStatus = MenuStatus();
	}

	@override
	Widget build(BuildContext context) {
		final screenSize = MediaQuery.of(context).size;
		double menuWidth = screenSize.width * 0.2;

		if (menuWidth >= maxMenuWidth) {
			menuWidth = maxMenuWidth;
		} else if (menuWidth <= minMenuWidth) {
			menuWidth = minMenuWidth;
		}

		Widget Function({ required Widget child }) louseListener;

		if(context.read<DeviceInfo>().isDesktop) {
			// 桌面
			louseListener = ({ required child }) =>
				MouseRegion(
					onHover: (event) {
						pointerStatus.position = event.position;
						pointerStatus.update();
					},
					child: child,
				);
		} else {
			// 移动
			louseListener = ({ required child }) =>
				Listener(
					onPointerMove: (event) {
						pointerStatus.position = event.position;
						pointerStatus.update();
					},
					child: child,
				);
		}

		return Theme(
			data: ThemeData.dark(),
			child: louseListener(
				child: Scaffold(
					body: MultiProvider(
						providers: [
							Provider<MenuStatus>.value(value: menuStatus),
							ChangeNotifierProvider<PointerStatus>.value(value: pointerStatus)
						],
						child: Stack(
							children: [
								// 菜单
								Positioned(
									left: 0,
									top: 0,
									height: screenSize.height,
									width: menuWidth,
									child: const MenuContext()
								),

								// 单独为主屏幕分配一个 Builder
								Theme(
									data: ThemeData.light(),
									child: MainContent(
										scaleRadio: 1 - menuWidth / screenSize.width
									)
								)
							],
						),
					),

					floatingActionButton: FloatingActionButton(
						onPressed: () {
							menuStatus.toggleMenu();
						},
						child: const Icon(Icons.menu_rounded),
					),
				),
			)
		);
	}
}