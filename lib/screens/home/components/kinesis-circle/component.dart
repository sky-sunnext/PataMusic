import "package:flutter/material.dart";

import "./objects/kinesis.dart";

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