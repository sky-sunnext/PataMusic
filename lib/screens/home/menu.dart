import "package:flutter/material.dart";

import "./style.dart";

class MenuContext extends StatelessWidget {
	const MenuContext({
		super.key
	});

	@override
	Widget build(BuildContext context) {
		final screenSize = MediaQuery.of(context).size;

		return Container(
			constraints: const BoxConstraints.expand(),
			padding: EdgeInsets.symmetric(
				vertical: screenSize.height * 0.2 / 2 * 0.6,
				horizontal: menuHorizontalPadding
			),
			child: const Column(
				children: [
					AutoScale(child: QuickDescription())
				],
			),
		);
	}

	Widget menuButton({
		required void Function()? onPressed,
		required Widget child,
		Widget? icon,
	}) {
		return TextButton(
			onPressed: () {},
			child: Row(
				children: [
					...icon == null? [] : [icon],
					Expanded(
						child: Center(
							child: child
						)
					)
				],
			)
		);
	}
}

class AutoScale extends StatelessWidget {
    const AutoScale({ super.key, required this.child });
	final Widget child;

	@override
	Widget build(BuildContext context) {
		return FittedBox(
			fit: BoxFit.scaleDown,
			child: SizedBox(
				width: maxMenuWidth - menuHorizontalPadding,
				child: child,
			),
		);
	}
}

class QuickDescription extends StatelessWidget {
    const QuickDescription({ super.key });

    @override
    Widget build(BuildContext context) {
		const titleStyle = TextStyle(
			fontSize: 18,
			fontWeight: FontWeight.bold
		);

		const subtitleStyle = TextStyle(
			fontSize: 12,
			fontWeight: FontWeight.bold
		);

		const contentStyle = TextStyle(
			fontSize: 11,
			fontWeight: FontWeight.w400
		);

        return Card.filled(
			clipBehavior: Clip.antiAlias,
			child: InkWell(
				onTap: () {},
				child: Padding(
					padding: const EdgeInsets.symmetric(
						horizontal: 16,
						vertical: 8
					),
					child: Row(
						children: [
							Container(
								decoration: BoxDecoration(
									borderRadius: BorderRadius.circular(8),
									color: Colors.black12,
								),
								padding: const EdgeInsets.all(4),
								child: Image.asset(
									"assets/images/logo@small.png",
									width: 56
								),
							),
							const SizedBox(width: 8),
							const Column(
								children: [
									Row(
										children: [
											Text("PataMusic", style: titleStyle),
											Text(" @ ACGFun", style: subtitleStyle),
										],
									),
									Row(
										children: [
											Text("Developer By ", style: contentStyle),
											Badge(
												label: Text("HelloK", style: contentStyle)
											)
										],
									)
								],
							)
						],
					),
				),
			)
		);
    }
}

