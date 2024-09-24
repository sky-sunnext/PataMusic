import "package:flutter/material.dart";

import "./components/gamecard/main.dart";
// import "./components/card/star.dart";

class GameScreen extends StatefulWidget {
	const GameScreen({ super.key });

	@override
	State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {

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
										horizontal: 120
									),
									child: SizedBox(
										height: 600,
										child: CardsComponent(
											cardList: List.generate(6, (_) => CardItem()),
										),
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