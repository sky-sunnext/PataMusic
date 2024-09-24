import "dart:math";
import "package:flutter/material.dart";
import "package:provider/provider.dart";

import "./card/main.dart";
import "./providers.dart";

class CardsComponent extends StatelessWidget {
	const CardsComponent({ super.key, required this.cardList });
	final List<CardItem> cardList;

	@override
	Widget build(context) {
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
				cardGap = minCardGap;	// 默认为最小间隔
				cardHeight = height;
				cardWidth = cardHeight * cardRadio;

				// 计算卡片大小
				final gapCounts = cardCounts - 1;
				final allGap = cardGap * gapCounts;
				if ( cardWidth * cardCounts + allGap > width ) {
					// 如果比总宽度大
					debugPrint("Larger than layout width");

					cardWidth = (width - allGap) / cardCounts;
					cardHeight = cardWidth / cardRadio;
				} else {
					// 间隔不是最小的
					debugPrint("Gap is to small");
					cardGap = (width - cardWidth * cardCounts) / gapCounts;
				}

				final cardSize = Size(cardWidth, cardHeight);
				debugPrint("Card size: $cardSize");

				return Provider<LayoutBasicData>.value(
					value: LayoutBasicData(
						cardGap: cardGap,
						cardSize: cardSize,
						layoutSize: layoutSize,
						cardList: cardList
					),
					builder: (context, _) => const _CardsComponent(),
				);
			}
		);
	}
}

class _CardsComponent extends StatelessWidget {
	const _CardsComponent();

	@override
	Widget build(context) {
		final layout = context.read<LayoutBasicData>();
		final cardSize  = layout.cardSize;
		final layoutSize = layout.layoutSize;
		final cardGap = layout.cardGap;

		final int cardCounts = layout.cardList.length;

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
			child: const _Cards()
		);
	}
}

class _Cards extends StatelessWidget {
	const _Cards();

	@override
	Widget build(BuildContext context) {
		final layout = context.read<LayoutBasicData>();
		final cardList = layout.cardList;

		return Stack(
			clipBehavior: Clip.none,
			children: List.generate(cardList.length, (index) {
				return FutureBuilder(
					future: Future.delayed(cardDelay * index),
					builder: (context, snapshot) {
						final card = generateCardData(context, index);

						if (snapshot.connectionState == ConnectionState.done) {
							return CardComponent(
								id: index,
								card: card
							);
						}

						return const Positioned(child: SizedBox());
					}
				);
			}),
		);
	}

	CardData generateCardData(BuildContext context, int index) {
		final layout = context.read<LayoutBasicData>();

		// 相对于左上角定位
		double offsetX = 0, offsetY = 0;
		offsetX = (layout.cardSize.width + layout.cardGap) * index;

		final card = CardData(
			cardBackground: Colors.black38,
			cardBorder: Border.all(color: Colors.black87, width: 12),
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

		return card;
	}
}