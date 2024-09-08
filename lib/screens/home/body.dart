import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "./providers/menu.dart";
import "./providers/pointer.dart";

import "./style.dart";
import "./components/kinesis-circle/main.dart";

class MainContent extends StatefulWidget {
	const MainContent({ super.key, required this.scaleRadio });

	final double scaleRadio;

	@override
	State<MainContent> createState() => _MainContentState();
}

class _MainContentState extends State<MainContent> with TickerProviderStateMixin {
	late AnimationController controller;
	late Animation<double> boxScale;
	late Animation<BorderRadius?> boxRadius;

	@override
	void initState() {
	    super.initState();

		controller = AnimationController(
			duration: const Duration(milliseconds: 400),
			vsync: this
		);

		boxScale = Tween<double>(
			begin: 1,
			end: widget.scaleRadio,
		).animate(
			CurvedAnimation(parent: controller, curve: Curves.easeInOutCubicEmphasized)
		);

		boxRadius = BorderRadiusTween(
			begin: BorderRadius.zero,
			end: const BorderRadius.only(
				topLeft: Radius.circular(35),
				bottomLeft: Radius.circular(35)
			),
		).animate(
			CurvedAnimation(parent: controller, curve: Curves.easeOut)
		);
		
		context.read<MenuStatus>().addListener((bool isOpen) {
			controller.stop();

			if (isOpen) {
				controller.forward();
			} else {
				controller.reverse();
			}
		});
	}

	@override
	void dispose() {
		controller.dispose();
	    super.dispose();
	}

	@override
	Widget build(BuildContext context) {
		boxScale = Tween<double>(
			begin: 1,
			end: widget.scaleRadio,
		).animate(
			CurvedAnimation(parent: controller, curve: Curves.easeInOutCubicEmphasized)
		);

		return AnimatedBuilder(
			animation: controller,
			builder: (context, _) => Transform.scale(
				scale: boxScale.value,
				alignment: Alignment.centerRight,
				child: ClipRRect(
					clipBehavior: Clip.antiAlias,
					borderRadius: boxRadius.value!,
					child: const Scaffold(
						body: Stack(
							children: [
								_BgmLoading(),
								_Background(),
								Center(
									child: FittedBox(
										fit: BoxFit.fill,
										child: SizedBox(
											width: 1920,
											height: 1080,
											child: _Content(),
										),
									),
								),
							],
						),
					),
				),
			)
		);
	}
}

class _BgmLoading extends StatelessWidget {
	const _BgmLoading();

	@override
	Widget build(context) {
		return const Positioned(
			left: 35,
			top: 35,
			child: Tooltip(
				message: "加载背景音乐中...",
				child: CircularProgressIndicator(),
			)
		);
	}
}

class _Background extends StatefulWidget {
	const _Background();

	@override
	State<_Background> createState() => _BackgroundState();
}

class _BackgroundState extends State<_Background> {
	@override
	Widget build(BuildContext context) {
		final screenSize = MediaQuery.of(context).size;
		final pointerPositon = context.watch<PointerStatus>().position;
		final pointerX = pointerPositon.dx;
		final pointerY = pointerPositon.dy;

		return Container(
			constraints: const BoxConstraints.expand(),
			child: Stack(
				children: [
					...List.generate(
						kinesisCircles.length,
						(index) {
							KinesisCircle kinesisCircle = kinesisCircles[index];
							
							final endOffset = Offset(
								pointerX / screenSize.width * 200
									* kinesisCircle.lazyRadio,
								pointerY / screenSize.height * 200
									* kinesisCircle.lazyRadio
							);

							return TweenAnimationBuilder(
								tween: Tween<Offset>(
									begin: Offset.zero,
									end: kinesisCircle.oppositePath
										? -endOffset
										: endOffset
								),
								duration: const Duration(seconds: 2),
								curve: Curves.elasticOut,
								builder: (context, offset, _) {
									return KinesisCircleComponent(
										kinesisCircle: kinesisCircle,
										positionOffset: offset
									);
								}
							);
						}
					)
				],
			),
		);
	}
}

class _Content extends StatelessWidget {
	const _Content();

	@override
	Widget build(BuildContext context) {
		const titleStyle = TextStyle(
			fontFamily: "Lingling",
			fontWeight: FontWeight.bold,
			fontSize: 80,
		);
		
		const subtitleStyle = TextStyle(
			fontFamily: "Lingling",
			fontWeight: FontWeight.bold,
			fontSize: 60,
		);

    	return Container(
			constraints: const BoxConstraints.expand(),
			padding: const EdgeInsets.all(25),
			child: const Column(
				children: [
					SizedBox(height: 20),
					Text("ACGFun 听歌识曲", style: titleStyle),
					Row(
						mainAxisSize: MainAxisSize.min,
						children: [
							Icon(Icons.star_rate_rounded),
							SizedBox(width: 5),
							Text("Pata Music", style: subtitleStyle),
							SizedBox(width: 5),
							Icon(Icons.star_rate_rounded),
						]
					),
					SizedBox(height: 20),
				],
			)
		);
	}
}