class PositionOffset {
	bool topInWidth = false;
	double? top;
	bool bottomInWidth = false;
	double? bottom;
	bool leftInWidth = false;
	double? left;
	bool rightInWidth = false;
	double? right;

	PositionOffset({
		String? top,
		String? bottom,
		String? left,
		String? right
	}) {
		<String?>[
			top,
			bottom,
			left,
			right
		].asMap().entries.forEach((pair) {
			bool inWidth = false;
			double? value;

			if (pair.value != null) {
				String tempValue;

				if (pair.value!.endsWith("vw")) {
					tempValue = pair.value!.replaceAll(RegExp(r"vw$"), "");
					inWidth = true;
				} else if (pair.value!.endsWith("%")) {
					tempValue = pair.value!.replaceAll(RegExp(r"%$"), "");
				} else {
					tempValue = pair.value!;
				}

				value = double.parse(tempValue) / 100;
			}

			<Function()>[
				() => (this.top = value, leftInWidth = inWidth),
				() => (this.bottom = value, bottomInWidth = inWidth),
				() => (this.left = value, leftInWidth = inWidth),
				() => (this.right = value, rightInWidth = inWidth)
			][pair.key]();
		});
	}
}