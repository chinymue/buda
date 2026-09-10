import 'package:flutter/material.dart';

class ListTemplate extends StatelessWidget {
  final List<String> items;
  final String title;
  final double maxWidth;
  final double maxHeight;

  const ListTemplate({
    super.key,
    required this.items,
    required this.title,
    this.maxWidth = 200,
    this.maxHeight = 200,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.yellow,
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          width: maxWidth,
          height: maxHeight,
          child: ListView(
            scrollDirection: Axis.vertical,
            children: [for (String item in items) ListTileTemplate(item: item)],
          ),
        ),
      ),
    );
  }
}

class ListTileTemplate extends StatelessWidget {
  final String item;

  const ListTileTemplate({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return ListTile(title: Text(item));
  }
}

class ListActionTemplate extends StatelessWidget {
  final List<(String, VoidCallback)> actions;
  final double? maxWidth, maxHeight;
  const ListActionTemplate({
    super.key,
    required this.actions,
    this.maxWidth,
    this.maxHeight,
  });

  @override
  Widget build(BuildContext context) {
    double width = (150 * actions.length).toDouble();
    return SizedBox(
      width: maxWidth ?? width,
      height: maxHeight ?? 100,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: actions
            .map(
              (action) =>
                  ElevatedButton(onPressed: action.$2, child: Text(action.$1)),
            )
            .toList(),
      ),
    );
  }
}
