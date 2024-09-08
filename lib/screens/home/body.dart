import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "./providers/menu.dart";
import "./providers/pointer.dart";

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
								_Content(),
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

class PositionOffset {
	bool topInWidth = false;
	double? top;
	bool bottomInWidth = false;
	double? bottom;
	bool leftInWidth = false;
	double? left;
	bool rightInWidth = false;
	double? right;

	PositionOffset({
		String? top,
		String? bottom,
		String? left,
		String? right
	}) {
		<String?>[
			top,
			bottom,
			left,
			right
		].asMap().entries.forEach((pair) {
			bool inWidth = false;
			double? value;

			if (pair.value != null) {
				String tempValue;

				if (pair.value!.endsWith("vw")) {
					tempValue = pair.value!.replaceAll(RegExp(r"vw$"), "");
					inWidth = true;
				} else if (pair.value!.endsWith("%")) {
					tempValue = pair.value!.replaceAll(RegExp(r"%$"), "");
				} else {
					tempValue = pair.value!;
				}

				value = double.parse(tempValue) / 100;
			}

			<Function()>[
				() => (this.top = value, leftInWidth = inWidth),
				() => (this.bottom = value, bottomInWidth = inWidth),
				() => (this.left = value, leftInWidth = inWidth),
				() => (this.right = value, rightInWidth = inWidth)
			][pair.key]();
		});
	}
}

class KinesisCircle {
	late Color backgroundColor;
	late Color borderColor;
	late double radiusRadio;
	late PositionOffset positionRadio;

	late bool oppositePath;
	late double lazyRadio;

	KinesisCircle({
		this.backgroundColor = Colors.transparent,
		this.borderColor = Colors.transparent,
		this.oppositePath = false,
		this.lazyRadio = 1,
		required this.radiusRadio,
		required this.positionRadio
	});
}

class _Background extends StatefulWidget {
	const _Background();

	@override
	State<_Background> createState() => _BackgroundState();
}


final List<KinesisCircle> kinesisCircles = [
	KinesisCircle(
		positionRadio: PositionOffset(top: "5%", right: "-16vw"),
		radiusRadio: 32,
		backgroundColor: const Color.fromRGBO(234, 241, 250, 1),
		oppositePath: true,
	),
	KinesisCircle(
		positionRadio: PositionOffset(top: "50%", left: "50%"),
		radiusRadio: 16,
		borderColor: const Color.fromRGBO(242, 234, 250, 1)
	),
	KinesisCircle(
		positionRadio: PositionOffset(top: "25%", left: "30%"),
		radiusRadio: 8,
		lazyRadio: 0.7,
		backgroundColor: const Color.fromRGBO(250, 249, 234, 1),
		oppositePath: true,
	),
	KinesisCircle(
		positionRadio: PositionOffset(top: "90%", right: "20%"),
		radiusRadio: 10,
		lazyRadio: 0.5,
		backgroundColor: const Color.fromRGBO(234, 250, 242, 1)
	),
	KinesisCircle(
		positionRadio: PositionOffset(top: "60%", left: "20%"),
		radiusRadio: 8,
		lazyRadio: 0.4,
		borderColor: const Color.fromRGBO(250, 243, 234, 1)
	),
	KinesisCircle(
		positionRadio: PositionOffset(top: "25%", left: "-4.8vw"),
		radiusRadio: 12,
		backgroundColor: const Color.fromRGBO(250, 234, 234, 1),
		oppositePath: true,
	),
];

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

class KinesisCircleComponent extends StatelessWidget {
	const KinesisCircleComponent({
		super.key,
		required this.kinesisCircle,
		required this.positionOffset
	});

	final KinesisCircle kinesisCircle;
	final Offset positionOffset;

	@override
	Widget build(context) {
		final screenSize = MediaQuery.of(context).size;
		final relativeSize = Size(screenSize.width, screenSize.height * 0.9);

		double radius = screenSize.width * kinesisCircle.radiusRadio / 100;
		BoxBorder? border;

		if (kinesisCircle.borderColor != Colors.transparent) {
			border = Border.all(
				color: kinesisCircle.borderColor,
				width: 25
			);
		}

		List<double?> tblr = List.filled(4, null);
		final pr = kinesisCircle.positionRadio;
		<MapEntry<double?, bool>>[
			MapEntry(pr.top, pr.topInWidth),
			MapEntry(pr.bottom, pr.bottomInWidth),
			MapEntry(pr.left, pr.leftInWidth),
			MapEntry(pr.right, pr.rightInWidth)
		].asMap().entries.forEach((pair) {
			final prPair = pair.value;

			if (prPair.key != null) {
				if (prPair.value) {
					// 全局绝对定位
					tblr[pair.key] = screenSize.width * prPair.key!;
				} else {
					// 局部定位
					double tblrObj;
					if (pair.key <= 1) {
						tblrObj = relativeSize.height * prPair.key!;
					} else {
						tblrObj = relativeSize.width * prPair.key!;
					}

					tblr[pair.key] = tblrObj;
				}
			}
		});

		return Positioned(
			top: tblr[0],
			bottom: tblr[1],
			left: tblr[2],
			right: tblr[3],
			child:	Transform.translate(
				offset: positionOffset,
				child:  Container(
					width: radius,
					height: radius,
					decoration: BoxDecoration(
						color: kinesisCircle.backgroundColor,
						border: border,
						shape: BoxShape.circle
					)
				),
			)
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
			fontSize: 60,
		);
		
		const subtitleStyle = TextStyle(
			fontFamily: "Lingling",
			fontWeight: FontWeight.bold,
			fontSize: 40,
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