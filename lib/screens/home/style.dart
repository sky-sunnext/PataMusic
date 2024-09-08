import "package:flutter/material.dart" show Color;
import "./components/kinesis-circle/main.dart" show PositionOffset, KinesisCircle;

const double maxMenuWidth = 300;
const double minMenuWidth = 220;
const double menuHorizontalPadding = 10;

final List<KinesisCircle> kinesisCircles = [
	KinesisCircle(
		positionRadio: PositionOffset(top: "5%", right: "-16vw"),
		radiusRadio: 32,
		backgroundColor: const Color.fromRGBO(234, 241, 250, 1),
		oppositePath: true,
	),
	KinesisCircle(
		positionRadio: PositionOffset(top: "50%", left: "50%"),
		radiusRadio: 16,
		borderColor: const Color.fromRGBO(242, 234, 250, 1)
	),
	KinesisCircle(
		positionRadio: PositionOffset(top: "25%", left: "30%"),
		radiusRadio: 8,
		lazyRadio: 0.7,
		backgroundColor: const Color.fromRGBO(250, 249, 234, 1),
		oppositePath: true,
	),
	KinesisCircle(
		positionRadio: PositionOffset(top: "90%", right: "20%"),
		radiusRadio: 10,
		lazyRadio: 0.5,
		backgroundColor: const Color.fromRGBO(234, 250, 242, 1)
	),
	KinesisCircle(
		positionRadio: PositionOffset(top: "60%", left: "20%"),
		radiusRadio: 8,
		lazyRadio: 0.4,
		borderColor: const Color.fromRGBO(250, 243, 234, 1)
	),
	KinesisCircle(
		positionRadio: PositionOffset(top: "25%", left: "-4.8vw"),
		radiusRadio: 12,
		backgroundColor: const Color.fromRGBO(250, 234, 234, 1),
		oppositePath: true,
	),
];