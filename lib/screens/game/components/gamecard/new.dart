import "dart:async";
import "dart:math";

import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:patamusic/providers.dart";
import "../card/star.dart";
import "./providers.dart";

export "./providers.dart" show CardItem;

const _cardDelay = Duration(milliseconds: 200);
const double _cardRadio = 300 / 450;
const double _minCardGap = 40;

class CardListComponent extends StatelessWidget {
	const CardListComponent({ super.key, required this.cardList });
	final List<CardItem> cardList;

	@override
	Widget build(context) {
		return Provider<List<CardItem>>.value(
			value: cardList,
			child: const CardsComponent()
		);
	}
}

class CardsComponent extends StatelessWidget {
	const CardsComponent({ super.key });

	@override
	Widget build(context) {
		final cardList = context.read<List<CardItem>>();
		final int cardCounts = cardList.length;

		if (cardCounts < 4) {
			throw "Fuck you! Why not set list lenght to 4???";
		} else if (cardCounts > 6) {
			throw "Fuck you! Why not set list lenght larger than 6???";
		}

		return LayoutBuilder(
			builder: (context, box) {
				// 获得总大小
				final double width = max(box.minWidth, box.maxWidth);
				final double height = max(box.minHeight, box.maxHeight);
				final layoutSize = Size(width, height);
				debugPrint("Card list size: ($width, $height)");

				// 卡片大小
				double cardWidth, cardHeight, cardGap;
				cardGap = _minCardGap;	// 默认为最小间隔
				cardHeight = height;
				cardWidth = cardHeight * _cardRadio;

				// 计算卡片大小
				final gapCounts = cardCounts - 1;
				final allGap = cardGap * gapCounts;
				if ( cardWidth * cardCounts + allGap > width ) {
					// 如果比总宽度大
					debugPrint("Larger than layout width");

					cardWidth = (width - allGap) / cardCounts;
					cardHeight = cardWidth / _cardRadio;
				} else {
					// 间隔不是最小的
					debugPrint("Gap is to small");
					cardGap = (width - cardWidth * cardCounts) / gapCounts;
				}

				final cardSize = Size(cardWidth, cardHeight);
				debugPrint("Card size: $cardSize");

				return _CardsComponent(
					cardList: cardList,
					layoutSize: layoutSize,
					cardSize: cardSize,
					cardGap: cardGap
				);
			}
		);
	}
}

class _CardsComponent extends StatelessWidget {
	const _CardsComponent({
		required this.cardList,
		required this.layoutSize,
		required this.cardSize,
		required this.cardGap
	});
	final List<CardItem> cardList;
	final Size layoutSize;
	final Size cardSize;
	final double cardGap;

	@override
	Widget build(context) {
		final int cardCounts = cardList.length;

		// 计算居中 padding
		final cardsWidth = cardSize.width * cardCounts;
		final gapsWidth = cardGap * (cardCounts - 1);
		final layoutWidth = cardsWidth + gapsWidth;
		final layoutHeight = cardSize.height;
		final boxPadding = EdgeInsets.symmetric(
			horizontal: layoutSize.width - layoutWidth,
			vertical: layoutSize.height - layoutHeight
		) / 2;

		return Container(
			width: layoutSize.width,
			height: layoutSize.height,
			padding: boxPadding,
			child: MultiProvider(
				providers: [
					ChangeNotifierProvider<CardProvider>.value(
						value: CardProvider()
					)
				],
				child: Stack(
					clipBehavior: Clip.none,
					children: List.generate(cardCounts, generateCard),
				),
			),
		);
	}

	Widget generateCard(int index) {
		// 相对于左上角定位
		double offsetX = 0, offsetY = 0;
		offsetX = (cardSize.width + cardGap) * index;

		final card = CardData(
			cardId: index,
			cardSize: cardSize,
			layoutSize: layoutSize,
			fixed: Offset(offsetX, offsetY),
			stars: [
				StarData(
					position: TBLR(left: 20, top: 30),
					size: const Size(30, 60),
					borderColor: Colors.black,
					backgdColor: Colors.black,
					shadowColor: Colors.black
				),
				StarData(
					position: TBLR(bottom: 15, right: 20),
					size: const Size(40, 80),
					borderColor: Colors.black,
					backgdColor: Colors.black,
					shadowColor: Colors.black
				)
			]
		);

		return FutureBuilder(
			future: Future.delayed(_cardDelay * index),
			builder: (context, snapshot) {
				if (snapshot.connectionState == ConnectionState.done) {
					return delayComponent(card);
				}

				return const Positioned(child: SizedBox());
			}
		);
	}

	Widget delayComponent(CardData card) {
		return CardComponent(card: card);
	}
}

class CardComponent extends StatefulWidget {
	const CardComponent({ super.key, required this.card });
	final CardData card;

	@override
	State<CardComponent> createState() => _CardComponentState();
}

class _CardComponentState extends State<CardComponent> with TickerProviderStateMixin {
	late final card = widget.card;
	late AnimationController controller;

	Tween<T> initTween<T>(T defaultValue) {
		return Tween(
			begin: defaultValue,
			end: defaultValue
		);
	}

	Animation<T> initAnime<T>(T defaultTween, {
		AnimationController? controller
	}) {
		controller ??= this.controller;
		return initTween<T>(defaultTween).animate(
			CurvedAnimation(
				parent: controller,
				curve: const Interval(0, 0)
			)
		);
	}

	void resetAllTween([bool init = false]) {
		cardPosition = initAnime(init ? card.fixed  : cardPosition.value);
		cardMatrix = initAnime(init ? Matrix4.zero() : cardMatrix.value);
		starMatrix = initAnime(init ? Matrix4.zero() : starMatrix.value);
		cardSize = initAnime(init? card.cardSize : cardSize.value);
	}

	@override
	void initState() {
	    super.initState();
		controller = AnimationController(vsync: this);

		resetAllTween(true);

		// 入场动画
		initEnterAnimation();
	}

	@override
	void dispose() {
		controller.dispose();
	    super.dispose();
	}

	void initEnterAnimation() {
		controller.duration = const Duration(milliseconds: 1600);
		
		final defaultMatrix = Tween<Matrix4>(
			begin: Matrix4.rotationY(pi / 2),
			end: Matrix4.rotationY(0)
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
			(card.layoutSize.width - card.cardSize.width) / 2,
			card.layoutSize.height + _minCardGap * 2
		);
		
		// 卡片入场动画
		cardPosition = Tween<Offset>(
			begin: centerOffset,
			end: card.fixed
		).animate(CurvedAnimation(
			parent: controller,
			curve: const Interval(0, 0.5, curve: Curves.easeOutBack)
		));

		controller.forward().whenComplete(() {
			resetAllTween();
			enterAnimationFinished = true;

			for (var runner in afterEnterAnimation.values) {
				runner();
			}
			afterEnterAnimation.clear();
		});
	}

	bool enterAnimationFinished = false;
	Map<String, void Function()> afterEnterAnimation = {};
	void runAfterEnterAnimation(void Function() runner, [ String? tag ]) {
		if (enterAnimationFinished) {
			return runner();
		}

		tag ??= Random.secure().toString();
		afterEnterAnimation[tag] = runner;
	}

	late Animation<Offset> cardPosition;
	late Animation<Matrix4> cardMatrix;
	late Animation<Size> cardSize;

	bool inTap = false;
	bool inHover = false;

	@override
	Widget build(BuildContext context) {
		return AnimatedBuilder(
			animation: controller,
			builder: (context, child) {
				return _CardBox(
					boxMatrix: cardMatrix.value,
					boxPosition: cardPosition.value,
					boxSize: cardSize.value,
					boxBackground: Colors.black38,
					boxBorder: Border.all(color: Colors.black87, width: 12),
					child: child!,
				);
			},
			child: _CardEvents(
				onHoverEnter: () => runAfterEnterAnimation(() {
					if (!inTap && !inHover) {
						hoverEvent(true);
					}
					
					inHover = true;
				}, "onHoverEnter"),
				onHoverExit: () => runAfterEnterAnimation(() {
					if (!inTap && inHover) {
						hoverEvent(false);
					}

					inHover = false;
				}, "onHoverExit"),
				onTap: () {
					
				},
				child: Stack(
					children: [
						...card.stars.map(starGenerator)
					],
				),
			),
		);
	}

	void hoverEvent(bool isEnter) {
		controller.duration = const Duration(milliseconds: 100);
		cardMatrix = _hoverRadioTween.animate(CurvedAnimation(
			parent: controller,
			curve: Curves.ease
		));

		setState(() {
			if (isEnter) {
				controller..reset()..forward();
			} else {
				controller.reverse();
			}
		});
	}

	late Animation<Matrix4> starMatrix;
	Widget starGenerator(StarData star) {
		return Positioned(
			top: star.position.top,
			bottom: star.position.bottom,
			left: star.position.left,
			right: star.position.right,
			child: _CardStar(
				width: star.size.width,
				height: star.size.height,
				borderColor: star.borderColor,
				backgdColor: star.backgdColor,
				shadowColor: star.shadowColor,
				matrix: starMatrix,
			),
		);
	}

	static const double _hoverRadio = 0.98;
	static final _hoverRadioTween = Tween(
		begin: Matrix4.diagonal3Values(1, 1, 1),
		end: Matrix4.diagonal3Values(_hoverRadio, _hoverRadio, 1)
	);
}

class _CardBox extends StatelessWidget {
	const _CardBox({
		required this.child,
		required this.boxPosition,
		required this.boxSize,
		required this.boxBorder,
		required this.boxBackground,
		required this.boxMatrix,
	});
	final Widget child;

	final Offset boxPosition;
	final Size boxSize;
	final BoxBorder boxBorder;
	final Color boxBackground;
	
	final Matrix4 boxMatrix;

	@override
	Widget build(BuildContext context) {
		return Positioned(
			left: boxPosition.dx,
			top: boxPosition.dy,
			width: boxSize.width,
			height: boxSize.height,
			child: Container(
				constraints: BoxConstraints.tight(boxSize),
				decoration: BoxDecoration(
					color: boxBackground,
					border: boxBorder,
					borderRadius: BorderRadius.circular(24),
				),
				transformAlignment: Alignment.center,
				transform: boxMatrix,
				child: child,
			),
		);
	}
}

// 卡片事件
class _CardEvents extends StatelessWidget {
    const _CardEvents({
		required this.child,
		required this.onTap,
		required this.onHoverEnter,
		required this.onHoverExit,
	});
	final Widget child;

	final void Function() onTap;
	final void Function() onHoverEnter;
	final void Function() onHoverExit;

	@override
	Widget build(BuildContext context) {
		final bool isDesktop = context.read<DeviceInfo>().isDesktop;

		return GestureDetector(
			onTap: onTap,
			child: MouseRegion(
				onEnter: !isDesktop ? null : (event) => onHoverEnter(),
				onExit: !isDesktop ? null : (event) => onHoverExit(),
				child: child,
			),
		);
	}
}

class _CardStar extends AnimatedWidget {
    const _CardStar({
		required Animation<Matrix4> matrix,

		required this.width,
		required this.height,

		required this.borderColor,
		required this.backgdColor,
		required this.shadowColor
	}) : super(listenable: matrix);

	final double width;
	final double height;

	final Color borderColor;
	final Color backgdColor;
	final Color shadowColor;

	@override
	Widget build(BuildContext context) {
		final matrix = listenable as Animation<Matrix4>;

		return Transform(
			transform: matrix.value,
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