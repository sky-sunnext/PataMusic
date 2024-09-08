import "package:flutter/material.dart";
import "./position.dart";

class KinesisCircle {
	late Color backgroundColor;
	late Color borderColor;
	late double radiusRadio;
	late PositionOffset positionRadio;

	late bool oppositePath;
	late double lazyRadio;

	KinesisCircle({
		this.backgroundColor = Colors.transparent,
		this.borderColor = Colors.transparent,
		this.oppositePath = false,
		this.lazyRadio = 1,
		required this.radiusRadio,
		required this.positionRadio
	});
}