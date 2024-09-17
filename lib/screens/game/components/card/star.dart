import "package:flutter/material.dart";
import "dart:math" as math;

class StarPainter extends CustomPainter {
	const StarPainter({
		required this.borderColor,
		required this.backgdColor,
		required this.shadowColor
	});

	final Color borderColor;
	final Color backgdColor;
	final Color shadowColor;

	@override
	void paint(Canvas canvas, Size size) {
		const double radio = 1.5;
		var width = size.width;
		var height = size.height;
		if (width > height) {
			width = height / radio;
		} else {
			height = width * radio;
		}

		final borderPaint = Paint()
			..isAntiAlias = true
			..style = PaintingStyle.stroke
			..color = borderColor
			..strokeWidth = width / 2 * 0.25;
		
		final bgPaint = Paint()
			..isAntiAlias = true
			..style = PaintingStyle.fill
			..color = backgdColor;

		Path path = Path();

		final centerOffset = Offset(width / 2, height / 2);
		const offsetRadio = 0.4;
		Offset prevOffset = Offset(0, height / 2);
		path.moveTo(prevOffset.dx, prevOffset.dy);
		
		for (final aimOffset in [
			Offset(width / 2, 0),
			Offset(width, height / 2),
			Offset(width / 2, height),
			prevOffset
		]) {
			Offset chooseMask = (prevOffset + aimOffset) / 2;
			
			final offset = chooseMask - centerOffset;
			// 建立两点之间的直线方程 y = kx + b
			// 求斜率 k
			final k = offset.dy / offset.dx;
			// 求截距 b
			final b = chooseMask.dy - k * chooseMask.dx;
			// 建立方程
			double f(double x) => k * x + b;

			// 获得标记坐标
			final x = chooseMask.dx - offset.dx * offsetRadio;
			final y = f(x);

			// debugPrint("Move -> ($x, $y)");

			path.conicTo(
				x, y,
				aimOffset.dx, aimOffset.dy,
				1
			);

			prevOffset = aimOffset;
		}
		
		path.close();
		
		canvas.drawShadow(path, shadowColor, 5, false);
		canvas.drawPath(path, bgPaint);
		canvas.drawPath(path, borderPaint);
	}

	@override
	bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class StarComponent extends StatelessWidget {
	const StarComponent({
		super.key,

		required this.width,
		required this.height,

		required this.borderColor,
		required this.backgdColor,
		required this.shadowColor
	});

	final double width;
	final double height;

	final Color borderColor;
	final Color backgdColor;
	final Color shadowColor;

	@override
	Widget build(BuildContext context) => TweenAnimationBuilder(
		tween: Tween<Matrix4>(
			begin: Matrix4.rotationY(math.pi / 2),
			end: Matrix4.rotationY(0)
		),
		duration: const Duration(milliseconds: 1600),
		curve: Curves.elasticInOut,
		builder: (context, matrix, _) => Transform(
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
		)
	);
}