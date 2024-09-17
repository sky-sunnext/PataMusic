import "package:flutter/material.dart";

import "./components/card/main.dart";
import "./components/card/star.dart";

class GameScreen extends StatefulWidget {
	const GameScreen({ super.key });

	@override
	State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
	List<Widget> list = [];

	@override
	void initState() {
		super.initState();

		(() async {
			for (int i = 0; i< 6; i++) {
				// print(2);
				setState(() {
					list.add(const SizedBox(
						width: 160,
						child: FittedBox(
							fit: BoxFit.scaleDown,
							child: ChoiceCard(cardHeight: 450, cardWidth: 300,),
						),
					));
					list.add(const SizedBox(width: 20,));
				});
				await Future.delayed(const Duration(milliseconds: 200));
			}
		})();
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			body: Row(
				children: List.generate(list.length, (i) => list[i]),
			),
			// body: CustomPaint(
			// 	size: const Size(300, 500),
			// 	painter: StarPainter(),
			// )
		);
	}
}