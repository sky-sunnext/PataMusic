import "dart:math";

import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:patamusic/provider.dart";
import "../card/star.dart";

class _CardNotifier with ChangeNotifier {
	int _id = -1;
	int get id => _id;
	choose(int id) {
		_id = id;
		notifyListeners();
	}
}

const double _cardRadio = 300 / 450;
const double _minCardGap = 40;
class CardListComponent extends StatelessWidget {
	const CardListComponent({
		super.key,

		required this.cardList
	});

	final List<Map> cardList;

	@override
	Widget build(BuildContext context) {
		final int cardCounts = cardList.length;

		if (cardCounts < 4) {
			throw "Fuck you! Why not set list lenght to 4???";
		} else if (cardCounts > 6) {
			throw "Fuck you! Why not set list lenght larger than 6???";
		}

		return LayoutBuilder(
			builder: (context, box) {
				final double width = max(box.minWidth, box.maxWidth);
				final double height = max(box.minHeight, box.maxHeight);
				final backgroundSize = Size(width, height);
				debugPrint("Card list size: ($width, $height)");

				double cardWidth, cardHeight, cardGap;
				cardGap = _minCardGap;	// 默认为最小间隔
				cardHeight = height;
				cardWidth = cardHeight * _cardRadio;
				if ( (height * _cardRadio * cardCounts) /* 卡片总宽度 */
					+ cardGap * (cardCounts - 1) /* 最小间隔 */
					> width /* 如果比总宽度大 */) {
					debugPrint("Larger than layout width");
					// 去掉最小间隔算最终长宽
					cardWidth = (width - cardGap * (cardCounts - 1))
						/ cardCounts;
					cardHeight = cardWidth / _cardRadio;
				} else {
					debugPrint("Gap is to small");
					// 间隔不是最小的
					cardGap = (width - cardWidth * cardCounts) /
						(cardCounts - 1);
				}
				final cardSize = Size(cardWidth, cardHeight);

				return Container(
					constraints: box,
					width: width,
					height: height,
					child: ChangeNotifierProvider<_CardNotifier>.value(
						value: _CardNotifier(),
						child: Stack(
							clipBehavior: Clip.none,
							children: List.generate(cardCounts, (index) {
								// 相对于左上角定位
								double offsetX = 0, offsetY = 0;
								offsetX = (cardWidth + cardGap) * index;

								final card = CardData(
									cardId: index,
									cardSize: cardSize,
									bgSize: backgroundSize,
									fixed: Offset(offsetX, offsetY)
								);

								return FutureBuilder(
									future: Future.delayed(Duration(milliseconds: 200 * index)),
									builder: (context, snapshot) {
										if (snapshot.connectionState == ConnectionState.done) {
											return CardComponent(card: card);
										}

										return const Positioned(child: SizedBox());
									}
								);
							}),
						),
					),
				);
			}
		);
	}
}

class CardData {
	final int cardId;
	final Size cardSize;
	final Size bgSize;
	final Offset fixed;

	CardData({
		required this.cardId,
		required this.cardSize,
		required this.bgSize,
		required this.fixed
	});
}

// 最外层监视
class CardEvents extends StatelessWidget {
    const CardEvents({
		super.key,

		required this.child,
		required this.onTap,
		required this.onEnter,
		required this.onExit,
	});

	final Widget child;
	final void Function() onTap;
	final void Function() onEnter;
	final void Function() onExit;

	@override
	Widget build(BuildContext context) {
		final bool isDesktop = context.read<DeviceInfo>().isDesktop;

		return GestureDetector(
			// 点击卡片
			onTap: onTap,
			child: MouseRegion(
				onEnter: !isDesktop ? null : (event) => onEnter(),
				onExit: !isDesktop ? null : (event) => onExit(),
				child: child
			),
		);
	}
}

// 卡片形状
class CardComponent extends StatefulWidget {
	const CardComponent({
		super.key,

		required this.card
	});

	final CardData card;

	@override
	State<CardComponent> createState() => _CardComponentState();
}

class _CardComponentState extends State<CardComponent> with TickerProviderStateMixin {
	// 入场动画
	late AnimationController controller;

	Animation<Size>? cardSize;
	late Animation<Offset> cardPosition;
	// late Animation<double> cardOpacity;
	late Animation<Matrix4> cardMatrix;

	late Animation<Matrix4> starMatrix;

	final defaultMatrix = Tween<Matrix4>(
		begin: Matrix4.rotationY(pi / 2),
		end: Matrix4.rotationY(0)
	);

	void initEnterAnimation () {
		controller = AnimationController(
			duration: const Duration(milliseconds: 1600),
			vsync: this
		);

		// 星星翻转
		starMatrix = defaultMatrix.animate(CurvedAnimation(
			parent: controller,
			curve: Curves.elasticInOut
		));

		// 卡片翻转
		cardMatrix = defaultMatrix.animate(CurvedAnimation(
			parent: controller,
			// 只需要持续一半时间
			curve: const Interval(0, 0.5, curve: Curves.easeOutBack)
		));

		// 卡片位置
		final centerOffset = Offset(
			(card.bgSize.width - card.cardSize.width) / 2,
			card.bgSize.height + _minCardGap * 2
		);

		cardPosition = Tween<Offset>(
			begin: centerOffset,
			end: card.fixed
		).animate(CurvedAnimation(
			parent: controller,
			curve: const Interval(0, 0.5, curve: Curves.easeOutBack)
		));

		controller.forward();
	}

	void initToggleAnimation () {
		controller = AnimationController(
			duration: const Duration(milliseconds: 400),
			vsync: this
		);
	}

	late final card = widget.card;

	bool enterControllerFinished = false;
	
	@override
	void initState() {
	    super.initState();

		debugPrint("[${card.cardId}] Size: ${card.cardSize}");

		initEnterAnimation();

		// 第一次动画结束后
		controller.forward().orCancel.whenComplete(() {
			enterControllerFinished = true;

			initToggleAnimation();
		});
	}

	bool isHover = false;

	@override
	void dispose() {
		controller.dispose();
	    super.dispose();
	}

	@override
	Widget build(BuildContext context) {
		return AnimatedBuilder(
			animation: controller,
			builder: (context, _) => Positioned(
				left: cardPosition.value.dx,
				top: cardPosition.value.dy,
				width: (cardSize?.value ?? card.cardSize).width,
				height: (cardSize?.value ?? card.cardSize).height,
				// 卡片内容
				child: CardEvents(
					onEnter: enterHoverCard,
					onExit: leaveHoverCard,
					onTap: () {
						if (enterControllerFinished) {
							tapCard();
						}
					},
					child: TweenAnimationBuilder(
						tween: Tween<double>(
							begin: 1,
							end: scaleRadio
						),
						builder: (context, radio, child) => Transform.scale(
							scale: radio,
							child: child
						),
						duration: const Duration(milliseconds: 200),
						child: CardFrame(
							cardMatrix: cardMatrix.value,
							starMatrix: starMatrix.value
						),
					),
				)
			)
		);
	}

	double scaleRadio = 1;

	void enterHoverCard() {
		if (context.read<_CardNotifier>().id != -1) {
			return;
		}

		isHover = true;

		setState(() {
			scaleRadio = 0.95;
		});
	}

	void leaveHoverCard() {
		if (context.read<_CardNotifier>().id != -1) {
			return;
		}

		isHover = false;

		setState(() {
			scaleRadio = 1;
		});
	}

	void tapCard() {
		// context.read<_CardNotifier>().choose(card.cardId);
	}
}

class CardFrame extends StatelessWidget {
    const CardFrame({
		super.key,
		
		required this.cardMatrix,
		required this.starMatrix
	});

	final Matrix4 cardMatrix;
	final Matrix4 starMatrix;

	@override
	Widget build(BuildContext context) {
		return Container(
			constraints: const BoxConstraints.expand(),
			transform: cardMatrix,
			transformAlignment: Alignment.center,
			decoration: BoxDecoration(
				color: Colors.black38,
				border: Border.all(color: Colors.black87, width: 12),
				borderRadius: BorderRadius.circular(24),
			),
			child: Stack(
				children: [
					Positioned(
						top: 40,
						left: 20,
						child: CardStar(
							width: 30,
							height: 100,
							borderColor: Colors.black,
							backgdColor: Colors.black,
							shadowColor: Colors.black,
							matrix: starMatrix,
						)
					),
					Positioned(
						bottom: 5,
						right: 20,
						child: CardStar(
							width: 50,
							height: 120,
							borderColor: Colors.black,
							backgdColor: Colors.black,
							shadowColor: Colors.black,
							matrix: starMatrix,
						)
					)
				],
			),
		);
	}
}

class CardStar extends StatelessWidget {
    const CardStar({
		super.key,

		required this.matrix,

		required this.width,
		required this.height,

		required this.borderColor,
		required this.backgdColor,
		required this.shadowColor
	});

	final Matrix4 matrix;

	final double width;
	final double height;

	final Color borderColor;
	final Color backgdColor;
	final Color shadowColor;

	@override
	Widget build(BuildContext context) {
		return Transform(
			transform: matrix,
			alignment: Alignment.center,
			child: CustomPaint(
				size: Size(width, height),
				painter: StarPainter(
					borderColor: borderColor,
					backgdColor: backgdColor,
					shadowColor: shadowColor
				),
			),
		);
	}
}