import "package:flutter/material.dart";

const cardDelay = Duration(milliseconds: 200);
const double cardRadio = 300 / 450;
const double minCardGap = 40;

class LayoutBasicData {
	late List<CardItem> cardList;
	late Size layoutSize;
	late Size cardSize;
	late double cardGap;

	LayoutBasicData({
		required this.cardList,
		required this.layoutSize,
		required this.cardSize,
		required this.cardGap
	});
}

class CardItem {

}

// 卡片信息
class CardData {
	final Offset fixed;
	final BoxBorder cardBorder;
	final Color cardBackground;
	final List<StarData> stars;

	CardData({
		required this.cardBorder,
		required this.cardBackground,
		required this.fixed,
		required this.stars
	});
}

class TBLR {
	final double? top;
	final double? bottom;
	final double? left;
	final double? right;

	TBLR({
		this.top,
		this.bottom,
		this.left,
		this.right
	});
}

class StarData {
	final TBLR position;
	final Size size;
	final Color borderColor;
	final Color backgdColor;
	final Color shadowColor;

	StarData({
		required this.position,
		required this.size,
		required this.borderColor,
		required this.backgdColor,
		required this.shadowColor
	});
}

typedef EnterAnimationCallback = void Function();
typedef ChoiceCallback = void Function(int, bool);

class EnterAnimationBus {
	EnterAnimationBus._internal();

	static final _singleton = EnterAnimationBus._internal();
	factory EnterAnimationBus()=> _singleton;

	final List<EnterAnimationCallback> _emap = [];
	void register(EnterAnimationCallback callback) => _emap.add(callback);
	void emit() => { for (final emap in _emap) emap() };
	void remove(EnterAnimationCallback callback) => _emap.remove(callback);
}

class ChoiceBus {
	ChoiceBus._internal();

	static final _singleton = ChoiceBus._internal();
	factory ChoiceBus()=> _singleton;

	final List<ChoiceCallback> _emap = [];
	void register(ChoiceCallback callback) => _emap.add(callback);
	void emit(int id, [bool cancelTap = false]) => { for (final emap in _emap) emap(id, cancelTap) };
	void remove(ChoiceCallback callback) => _emap.remove(callback);
}

class MovementNotifier with ChangeNotifier {
	Offset offset = Offset.zero;
	void move(Offset offset) {
		this.offset = offset;
		notifyListeners();
	}
}