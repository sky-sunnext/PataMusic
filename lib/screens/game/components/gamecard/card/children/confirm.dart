import "package:flutter/material.dart";
import "package:provider/provider.dart";

import "../../providers.dart";

class CardConfirmPage extends StatelessWidget {
	const CardConfirmPage({ super.key });
	
	@override
	Widget build(BuildContext context) {
		final layout = context.read<LayoutBasicData>();
		final card = context.read<CardData>();

		const confirmTime = Duration(milliseconds: 500);
		final pointerX = context.watch<MovementNotifier>().offset.dx;
		final endDistance = layout.cardSize.width;
		final double progress = (pointerX / endDistance).clamp(0, 1);
		
		return Container(
			constraints: const BoxConstraints.expand(),
			child: Column(
				children: [
					SizedBox(
						height: 50,
						child: LinearProgressIndicator(
							value: progress
						)
					),
					...progress != 1 ? [] : [
						SizedBox(
							height: 50,
							child: TweenAnimationBuilder(
								tween: Tween<double>(begin: 0, end: 1),
								duration: confirmTime,
								builder: (context, progress, _) {
									return LinearProgressIndicator(
										value: progress,
										semanticsValue: progress.toString(),
									);
								}
							)
						)
					]
				],
			),
		);
	}
}