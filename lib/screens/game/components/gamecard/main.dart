import "dart:math";

import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:patamusic/provider.dart";
import "../card/main.dart";

class _CardNotifier with ChangeNotifier {
	int _id = -1;
	int get id => _id;
	choose(int id) {
		_id = id;
		notifyListeners();
	}
}

const double _cardRadio = 300 / 450;
const double _minCardGap = 20;
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

				double cardWidth, cardHeight, cardGap;
				cardGap = _minCardGap;	// 默认为最小间隔
				cardHeight = height;
				cardWidth = cardHeight * _cardRadio;
				if ( (height * _cardRadio * cardCounts) /* 卡片总宽度 */
					+ cardGap * (cardCounts - 1) /* 最小间隔 */
					> width /* 如果比总宽度大 */) {
					// 去掉最小间隔算最终长宽
					cardWidth = (width - cardGap * (cardCounts - 1))
						/ cardCounts;
					cardHeight = cardWidth * _cardRadio;
				} else {
					// 间隔不是最小的
					cardGap = (width - cardWidth * cardCounts) /
						(cardCounts - 1);
				}
				final cardSize = Size(cardWidth, cardHeight);

				return Container(
					constraints: box,
					child: Provider<_CardNotifier>.value(
						value: _CardNotifier(),
						child: Stack(
							clipBehavior: Clip.none,
							children: List.generate(cardCounts, (index) {
								// 相对于左上角定位
								double offsetX = 0, offsetY = 0;
								offsetX = (cardWidth + cardGap) * index;

								return CardComponent(
									fixed: Offset(offsetX, offsetY),
									cardSize: cardSize,
									cardId: index,
								);
							}),
						),
					),
				);
			}
		);
	}
}

class _CardState with ChangeNotifier {
    bool _isHover = false;
	bool get isHover => _isHover;
	void enterHover () {
		_isHover = true;
		notifyListeners();
	}
	void leaveHover () {
		_isHover = false;
		notifyListeners();
	}

	final List<void Function()> _tapListener = [];
	List<void Function()> get tapListener => _tapListener;
	void addTapListener (void Function() listener) {
		_tapListener.add(listener);
	}
	void emitTapListener () {
		for (final listener in _tapListener) {
			listener();
		}
	}
}

// 最外层监视
class CardComponent extends StatelessWidget {
    const CardComponent({
		super.key,

		required this.cardId,
		required this.cardSize,
		required this.fixed
	});

	final int cardId;
	final Size cardSize;
	final Offset fixed;

	@override
	Widget build(BuildContext context) {
		final state = _CardState();
		final bool isDesktop = context.read<DeviceInfo>().isDesktop;

		return GestureDetector(
			// 点击卡片
			onTap: () {
				state.emitTapListener();
			},
			child: MouseRegion(
				onEnter: !isDesktop ? null : (event) {
					state.enterHover();
				},
				onExit: !isDesktop ? null : (event) {
					state.leaveHover();
				},
				child: MultiProvider(
					providers: [
						Provider<_CardState>.value(value: state)
					],
					child: CardFrame(
						parent: this,
					),
				),
			),
		);
	}
}

// 卡片形状
class CardFrame extends StatefulWidget {
	const CardFrame({
		super.key,

		required this.parent
	});

	final CardComponent parent;

	@override
	State<CardFrame> createState() => _CardFrameState();
}

class _CardFrameState extends State<CardFrame> with TickerProviderStateMixin {
	late final parent = widget.parent;
	late AnimationController controller;
	late Animation<Offset> cardPosition;
	
	@override
	void initState() {
	    super.initState();

		// 点击事件
		context.watch<_CardState>().addTapListener(() {
			
		});

		controller = AnimationController(
			duration: const Duration(milliseconds: 150),
			vsync: this
		);
	}

	@override
	void dispose() {
		controller.dispose();
	    super.dispose();
	}

	@override
	Widget build(BuildContext context) {
		final bool isHover = context.watch<_CardState>().isHover;

		return AnimatedBuilder(
			animation: controller,
			builder: (context, _) => Positioned(
				// 卡片内容
				child: Container(
					width: parent.cardSize.width,
					height: parent.cardSize.height,
					decoration: BoxDecoration(
						color: Colors.black38,
						border: Border.all(color: Colors.black87, width: 12),
						borderRadius: BorderRadius.circular(24),
					),
					child: const Stack(
						children: [

						],
					),
				),
			)
		);
	}
}