import "package:flutter/material.dart";
import "package:provider/provider.dart";

import "../../../card/star.dart";
import "../../providers.dart";
import "../main.dart" show CardComponentState;

class CardInfoPage extends StatelessWidget {
	const CardInfoPage({ super.key });
	
	@override
	Widget build(BuildContext context) {
		final layout = context.read<LayoutBasicData>();
		final card = context.read<CardData>();
		
		return SizedBox(
			width: layout.layoutSize.width,
			height: layout.layoutSize.height,
			child: Stack(
				children: [
					...card.stars.map((star) => generateStar(context, star))
				],
			),
		);
	}

	Widget generateStar(BuildContext context, StarData star) {
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
				matrix: context.read<CardComponentState>().starMatrix,
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