import "dart:async";

import "package:flutter/material.dart";
import "package:flutter/services.dart" show PointerEnterEvent, PointerExitEvent;
import "package:provider/provider.dart";
import "package:go_router/go_router.dart";
import "dart:math";
import "../providers.dart";
import "./children/info.dart";
import "./children/confirm.dart";

class CardComponent extends StatefulWidget {
	const CardComponent({
		super.key,
		required this.id,
		required this.card,
		required this.enterComplete
	});
	final int id;
	final CardData card;
	final Completer<bool> enterComplete;
	
	@override
	State<CardComponent> createState() => CardComponentState();
}

class CardComponentState extends State<CardComponent> with TickerProviderStateMixin {
	late final movementNotifier = MovementNotifier();
	late final canNextBus = context.read<EnterAnimationBus>();
	late final choiceBus = context.read<ChoiceBus>();
	late final layout = context.read<LayoutBasicData>();
	late final card = widget.card;

	late AnimationController enterController;
	late AnimationController hoverController;
	late AnimationController tapController;
	
	@override
	void initState() {
	    super.initState();

		childController = PageController();

		// 入场动画
		enterController = AnimationController(
			vsync: this,
			duration: const Duration(milliseconds: 1400)
		);

		// Hover 动画
		hoverController = AnimationController(
			vsync: this,
			duration: const Duration(milliseconds: 180),
			reverseDuration: const Duration(milliseconds: 120)
		);

		// 点击的动画
		tapController = AnimationController(
			vsync: this,
			duration: const Duration(milliseconds: 350),
			reverseDuration: const Duration(milliseconds: 500)
		);

		initEnterAnimation(enterController);

		enterController.forward().whenComplete(() {
			widget.enterComplete.complete(true);
		});

		canNextBus.register(nextBusEvent);
	}

	@override
	void dispose() {
		childController.dispose();

		choiceBus.remove(chooseBusEvent);
		canNextBus.remove(nextBusEvent);

		enterController.dispose();
		hoverController.dispose();
		tapController.dispose();

		super.dispose();
	}

	void nextBusEvent() {
		initHoverAnimation(hoverController);

		choiceBus.register(chooseBusEvent);

		setState(() {
			controllerIndex = 1; // 切换到点击动画
		});
	}

	void chooseBusEvent(int newId, bool cancelTap) {
		if (!cancelTap) {
			inTap = true;
		}

		final cardsCounts = layout.cardList.length;
		final myId = widget.id;
		final isAfter = myId > newId;

		Tween<Size> size;
		Tween<Offset> position;
		Tween<double> rotate;
		if (newId == myId) {
			setState(() {
				const duration = Duration(milliseconds: 200);
				if (cancelTap) {
					childController.animateToPage(
						0,
						duration: duration,
						curve: Curves.easeOutQuad
					);
				} else {
					childController.animateToPage(
						1,
						duration: duration,
						curve: Curves.easeInQuad
					);
				}
			});

			rotate = Tween(begin: 0, end: 0);

			final newSize = layout.cardSize * 1.5;
			size = Tween(
				begin: layout.cardSize,
				end: newSize
			);

			final double changeX = -(newSize.width - layout.cardSize.width) / 2;
			final double changeY = -(newSize.height -  layout.cardSize.height);
			position = Tween(
				begin: card.fixed,
				end: card.fixed + Offset(changeX, changeY)
			);
		} else {
			// 点击的不是自己
			size = Tween(
				begin: layout.cardSize,
				end: layout.cardSize
			);

			double changeX;
			double changeAngle;
			final leftWeight = newId * (minCardGap + layout.cardSize.width)
				+ layout.cardSize.width;
			if (isAfter) {
				// 在点击的元素右边
				final propWeight = (myId - newId) / (cardsCounts - newId - 1);
				final fixpropWeight = propWeight * 0.2;
				final unpropWeight = 1 - fixpropWeight;

				// 剩余空间
				final expendWeight = layout.layoutSize.width - leftWeight;
				// 均摊空间
				final averageWeight = expendWeight / (cardsCounts - newId);
				final linearWeight = pow(unpropWeight, 1.5);

				// debugPrint("[R:$myId] Prop($linearWeight)");
				changeX = averageWeight * linearWeight;

				changeAngle = pi / 4 * linearWeight;
			} else {
				final propWeight = (myId + 1) / newId;
				final fixpropWeight = propWeight * 0.5;
				final unpropWeight = fixpropWeight;

				final expendWeight = leftWeight;
				final averageWeight = expendWeight / newId;
				final linearWeight = pow(unpropWeight, 1.5);

				// debugPrint("[L:$myId] Prop($linearWeight)");
				changeX = - averageWeight * linearWeight;

				changeAngle = -pi / 4 * linearWeight;
			}

			position = Tween(
				begin: card.fixed,
				end: card.fixed + Offset(changeX, 0)
			);

			rotate = Tween(begin: 0, end: changeAngle);
		}

		// 大小
		cardSize = size.animate(
			CurvedAnimation(
				parent: tapController,
				curve: Curves.easeInQuad
			)
		);
		// 位置
		cardPosition = position.animate(
			CurvedAnimation(
				parent: tapController,
				curve: Curves.easeInOutBack
			)
		);
		// 旋转
		cardRotate = rotate.animate(
			CurvedAnimation(
				parent: tapController,
				curve: Curves.easeInOutBack
			)
		);

		cardScale = Tween<double>(
			begin: cardScale.value,
			end: 1
		).animate(
			CurvedAnimation(
				parent: tapController,
				curve: const Interval(0, 0.2)
			)
		);

		setState(() {
			if (cancelTap) {
				tapController..stop()..reverse().whenComplete(() {
					initHoverAnimation(hoverController);
					inTap = false;
				});
			} else {
				tapController..stop()..forward();
			}
		});
	}

	late Animation<Offset> cardPosition;
	late Animation<Matrix4> cardMatrix;
	late Animation<double> cardOpacity;
	late Animation<double> cardRotate;
	late Animation<double> cardScale;
	late Animation<Size> cardSize;

	late Animation<Matrix4> starMatrix;

	void initEnterAnimation(AnimationController controller) {
		// 默认翻转
		final defaultMatrix = Tween<Matrix4>(
			begin: Matrix4.rotationY(pi / 2),
			end: Matrix4.rotationY(0)
		);

		// 卡片的位置
		final centerOffset = Offset(
			(layout.layoutSize.width - layout.cardSize.width) / 2,
			layout.layoutSize.height + minCardGap * 2
		);

		// 有动画的部分
		// 透明度动画
		cardOpacity = Tween<double>(
			begin: 0,
			end: 1
		).animate(CurvedAnimation(
			parent: controller,
			curve: const Interval(0, 0.3, curve: Curves.easeOut)
		));

		// 缩放动画
		cardScale = Tween<double>(
			begin: 0.8,
			end: 1
		).animate(CurvedAnimation(
			parent: controller,
			curve: const Interval(0, 0.2, curve: Curves.bounceOut)
		));

		// 位置动画
		cardPosition = Tween<Offset>(
			begin: centerOffset,
			end: card.fixed
		).animate(CurvedAnimation(
			parent: controller,
			curve: const Interval(0, 0.5, curve: Curves.easeOutBack)
		));

		// 卡片翻转动画
		cardMatrix = defaultMatrix.animate(CurvedAnimation(
			parent: controller,
			curve: const Interval(0, 0.5, curve: Curves.easeOutBack)
		));

		// 星星翻转动画
		starMatrix = defaultMatrix.animate(CurvedAnimation(
			parent: controller,
			curve: Curves.elasticInOut
		));

		// （目前）没有动画的部分
		// 卡片大小
		cardSize = Tween<Size>(
			begin: layout.cardSize,
			end: layout.cardSize
		).animate(controller);

		cardRotate = Tween<double>(
			begin: 0,
			end: 0
		).animate(controller);
	}

	void initHoverAnimation(AnimationController controller) {
		// 缩放动画
		cardScale = Tween<double>(
			begin: 1,
			end: 0.95
		).animate(CurvedAnimation(
			parent: controller,
			curve: Curves.linearToEaseOut
		));
	}

	late PageController childController;

	@override
	Widget build(BuildContext context) {
		return AnimatedBuilder(
			animation: controller,
			builder: (context, child) => _CardFrame(
				parent: this,
				child: child!
			),
			child: MultiProvider(
				providers: [
					Provider.value(value: card),
					Provider.value(value: this),
					ChangeNotifierProvider.value(value: movementNotifier)
				],
				builder: (context, child) => child!,
				child: PageView.builder(
					controller: childController,
					itemCount: tabPages.length,
					itemBuilder: (context, index) {
						return tabPages.elementAt(index);
					}
				),
			),
		);
	}

	final List<Widget> tabPages = const [
		CardInfoPage(),
		CardConfirmPage()
	];

	// 自动切换 AnimationController
	int controllerIndex = 0;
	AnimationController get controller => [
		enterController,
		inTap ? tapController : hoverController
	].elementAt(controllerIndex);

	bool inHover = false;
	bool inTap = false;

	late Offset originPostion;
	void onPointerDown(PointerDownEvent event) => setState(() {
		choiceBus.emit(widget.id);
		// debugPrint("Tap ${widget.id}!");
		originPostion = event.localPosition;
		handlePointerMove(originPostion);
	});

	void onPointerMove(PointerMoveEvent event) => setState(() {
		handlePointerMove(event.localPosition);
	});

	void onPointerUp(PointerUpEvent event) => setState(() {
		choiceBus.emit(widget.id, true);
		// debugPrint("Cancel tap ${widget.id}!");
	});

	void handlePointerMove(Offset position) {
		movementNotifier.move(position - originPostion);
	}

	void onHoverEnter(PointerEnterEvent event) => setState(() {
		inHover = true;

		hoverController.forward();
	});

	void onHoverExit(PointerExitEvent event) => setState(() {
		inHover = false;

		hoverController.reverse();
	});
}

class _CardFrame extends StatelessWidget {
	const _CardFrame({ required this.parent, required this.child });
	final CardComponentState parent;
	final Widget child;

    @override
	Widget build(BuildContext context) {
		return Positioned(
			left: parent.cardPosition.value.dx,
			top: parent.cardPosition.value.dy,
			child: Listener(
				onPointerDown: parent.onPointerDown,
				onPointerMove: parent.onPointerMove,
				onPointerUp: parent.onPointerUp,
				child: MouseRegion(
					onEnter: parent.onHoverEnter,
					onExit: parent.onHoverExit,
					// 最外层固定大小（事件触发层）
					child: SizedBox(
						width: parent.cardSize.value.width,
						height: parent.cardSize.value.height,
						child: _CardFrameContent(
							parent: parent,
							child: child,
						),
					),
				),
			)
		);
	}
}

class _CardFrameContent extends StatelessWidget {
	const _CardFrameContent({ required this.parent, required this.child });
	final CardComponentState parent;
	final Widget child;

    @override
	Widget build(BuildContext context) {
		// final layout = context.read<LayoutBasicData>();
		final card = parent.card;

		final containerDecoration = BoxDecoration(
			color: card.cardBackground,
			border: card.cardBorder,
			borderRadius: BorderRadius.circular(24),
		);
		
		return Opacity(
			opacity: parent.cardOpacity.value,
			child: Transform.scale(
				scale: parent.cardScale.value,
				child: Transform.rotate(
					angle: parent.cardRotate.value,
					child: Container(
						constraints: const BoxConstraints.expand(),
						decoration: containerDecoration,
						alignment: Alignment.center,
						transformAlignment: Alignment.center,
						transform: parent.cardMatrix.value,
						clipBehavior: Clip.none,
						child: child,
					),
				)
			),
		);
	}
}