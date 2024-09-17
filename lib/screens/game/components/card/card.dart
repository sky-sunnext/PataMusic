import "package:flutter/material.dart";
import "package:patamusic/provider.dart";
import "package:provider/provider.dart";
import "dart:math" as math;
import "./star.dart";

class ChoiceCard extends StatefulWidget {
	const ChoiceCard({
		super.key,

		required this.cardWidth,
		required this.cardHeight
	});

	final double cardWidth;
	final double cardHeight;

	@override
	State<ChoiceCard> createState() => _ChoiceCardState();
}

class _ChoiceCardState extends State<ChoiceCard> with TickerProviderStateMixin {
	late AnimationController controller;
	late Animation<double> hoverScale;
	late Animation<double> clickScale;

	@override
	void initState() {
	    super.initState();

		controller = AnimationController(
			duration: const Duration(milliseconds: 150),
			vsync: this
		);

		// boxScale = Tween<double>(begin: 1, end: 1).animate(controller);
		
		hoverScale = Tween<double>(
			begin: 1,
			end: 0.95,
		).animate(
			CurvedAnimation(parent: controller, curve: Curves.easeInOutCirc)
		);
		// controller.forward();
	}

	@override
	void dispose() {
		controller.dispose();
	    super.dispose();
	}

	bool isMouseEnter = false;

	@override
	Widget build(context) {
		bool isDesktop = context.read<DeviceInfo>().isDesktop;
		return MouseRegion(
			onEnter: !isDesktop ? null : (event) {
				if (!isMouseEnter) {
					isMouseEnter = true;
					controller.stop();
				}

				controller.forward();
			},
			onExit: !isDesktop ? null : (event) {
				if (!isMouseEnter) {
					isMouseEnter = true;
					controller.stop();
				}

				controller.reverse();
			},
			child: GestureDetector(
				onTap: () {
					// isMouseEnter = !isMouseEnter;
				},

				child: AnimatedBuilder(
					animation: controller,
					builder: (context, _) => Transform.scale(
						scale: hoverScale.value,
						child: _CardBody(widget: widget),
					)
				),
			),
		);
	}
}

class _CardBody extends StatelessWidget {
	const _CardBody({ required this.widget });

	final ChoiceCard widget;


	@override
	Widget build(BuildContext context) {
		return TweenAnimationBuilder(
			tween: Tween<Matrix4>(
				begin: Matrix4.rotationY(math.pi / 2),
				end: Matrix4.rotationY(0)
			),
			duration: const Duration(milliseconds: 800),
			curve: Curves.easeOutBack,
			builder: (context, matrix, _) => Transform(
				transform: matrix,
				alignment: Alignment.center,
				child: Container(
					width: widget.cardWidth,
					height: widget.cardHeight,
					decoration: BoxDecoration(
						color: Colors.black38,
						border: Border.all(color: Colors.black87, width: 12),
						borderRadius: BorderRadius.circular(24),
					),
					constraints: const BoxConstraints(),
					child: const Stack(
						children: [
							Positioned(
								top: 40,
								left: 20,
								child: StarComponent(width: 50, height: 120, borderColor: Colors.black, backgdColor: Colors.black, shadowColor: Colors.black)
							),
							Positioned(
								bottom: 5,
								right: 20,
								child: StarComponent(width: 80, height: 150, borderColor: Colors.black, backgdColor: Colors.black, shadowColor: Colors.black)
							)
						],
					),
				)
			)
		);
	}
}