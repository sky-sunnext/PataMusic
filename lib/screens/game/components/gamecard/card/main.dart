import "package:flutter/material.dart";
import "package:flutter/services.dart" show PointerEnterEvent, PointerExitEvent;
import "package:provider/provider.dart";
import "package:go_router/go_router.dart";
import "dart:math";
import "../providers.dart";
import "./children/info.dart";

class CardComponent extends StatefulWidget {
	const CardComponent({ super.key, required this.id, required this.card });
	final int id;
	final CardData card;
	
	@override
	State<CardComponent> createState() => CardComponentState();
}

class CardComponentState extends State<CardComponent> with TickerProviderStateMixin {
	late final layout = context.read<LayoutBasicData>();
	late final card = widget.card;

	late AnimationController enterController;
	late AnimationController hoverController;
	late AnimationController tapController;
	
	@override
	void initState() {
	    super.initState();

		// 创建子路由
		initChildren();

		// 入场动画
		enterController = AnimationController(
			vsync: this,
			duration: const Duration(milliseconds: 1600)
		);

		// Hover 动画
		hoverController = AnimationController(
			vsync: this,
			duration: const Duration(milliseconds: 200)
		);

		// 点击的动画
		tapController = AnimationController(
			vsync: this,
			duration: const Duration(milliseconds: 800),
			reverseDuration: const Duration(milliseconds: 300)
		);

		initEnterAnimation(enterController);

		enterController.forward().whenComplete(() {
			initHoverAnimation(hoverController);

			setState(() {
				controllerIndex = 1; // 切换到点击动画
			});
		});
	}

	late Animation<Offset> cardPosition;
	late Animation<Matrix4> cardMatrix;
	late Animation<double> cardOpacity;
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

	void initTapAnimation(AnimationController controller) {
		
	}

	@override
	Widget build(BuildContext context) {
		return AnimatedBuilder(
			animation: controller,
			builder: (context, child) => _CardFrame(
				parent: this,
				child: child!
			),
			child: MaterialApp.router(
				debugShowCheckedModeBanner: false,
				builder: (context, child) {
					return Scaffold(
						backgroundColor: Colors.transparent,
						body: MultiProvider(
							providers: [
								Provider<CardData>.value(value: card),
								Provider<CardComponentState>.value(value: this)
							],
							builder: (context, _) => child!,
						),
					);
				},
				routerConfig: GoRouter(
					routes: childrenRoutes
				)
			),
		);
	}

	final List<GoRoute> childrenRoutes = [
		GoRoute(path: "/", redirect: (ctx, _) => "/0"),
	];

	void initChildren() {
		// 默认页面
		childrenRoutes.add(
			GoRoute(path: "/0", builder: (c, s) => const CardInfoPage())
		);
	}

	// 自动切换 AnimationController
	int controllerIndex = 0;
	AnimationController get controller => [
		enterController,
		inTap ? tapController : hoverController
	].elementAt(controllerIndex);

	bool inHover = false;
	bool inTap = false;

	void onPointerDown(PointerDownEvent event) => setState(() {
		inTap = true;
	});

	void onPointerMove(PointerMoveEvent event) => setState(() {
	});

	void onPointerUp(PointerUpEvent event) => setState(() {
		inTap = false;
	});

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
				child: Container(
					constraints: const BoxConstraints.expand(),
					decoration: containerDecoration,
					alignment: Alignment.center,
					transformAlignment: Alignment.center,
					transform: parent.cardMatrix.value,
					child: child,
				),
			),
		);
	}
}