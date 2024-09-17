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

	static const int cardCounts = 6;
	static const double cardPadding = 60;
	static const double ltPadding = 120;
	static const double cardWidth = (1920 - ltPadding * 2 - cardPadding * (cardCounts - 1)) / cardCounts;

	@override
	void initState() {
		super.initState();

		(() async {
			for (int i = 1; i <= cardCounts; i++) {
				// print(2);
				setState(() {
					list.add(const SizedBox(
						width: cardWidth,
						child: FittedBox(
							fit: BoxFit.scaleDown,
							child: ChoiceCard(cardHeight: 450, cardWidth: 300,),
						),
					));

					if (i != cardCounts) {
						list.add(const SizedBox(width: cardPadding,));
					}
				});
				await Future.delayed(const Duration(milliseconds: 200));
			}
		})();
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				centerTitle: true,
				title: const Row(
					mainAxisSize: MainAxisSize.min,
					children: [
						Text("你好")
					],
				),
			),
			body: Align(
				child: FittedBox(
					fit: BoxFit.fill,
					child: SizedBox(
						width: 1920,
						height: 1080,
						child: Column(
							children: [
								const Expanded(child: Align(child: Text("234"),)),

								Padding(
									padding: const EdgeInsets.symmetric(
										horizontal: ltPadding
									),
									child: Row(
										children: List.generate(list.length, (i) => list[i]),
									),
								),
								
								const SizedBox(height: 50,)
							],
						),
					),
				),
			),
		);
	}
}