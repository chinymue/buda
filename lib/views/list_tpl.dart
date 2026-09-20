import 'package:flutter/material.dart';

class TListTemplate<T> extends ListTemplate {
  TListTemplate({
    super.key,
    required List<T> items,
    required String Function(T item) item2String,
    required super.title,
    super.subtitle,
    super.maxWidth,
    super.maxHeight,
    required super.onChanged,
  }) : super(items: items.map(item2String).toList());
}

class ListTemplate extends StatelessWidget {
  final List<String> items;
  final String title;
  final String? subtitle;
  final double maxWidth, maxHeight;
  final void Function(String, String) onChanged;

  const ListTemplate({
    super.key,
    required this.items,
    required this.title,
    this.subtitle,
    this.maxWidth = 200,
    this.maxHeight = 400,
    required this.onChanged,
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
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          width: maxWidth,
          height: maxHeight,
          child: Column(
            children: [
              Text(title),
              if (subtitle?.isNotEmpty == true) Text(subtitle!),
              SizedBox(
                width: maxWidth,
                height: maxHeight - 100,
                child: ListView(
                  scrollDirection: Axis.vertical,
                  children: [
                    for (String item in items)
                      Row(
                        children: [
                          ListTileTemplate(
                            maxWidth: maxWidth - 50 * 3,
                            maxHeight: (maxHeight - 100) / 5,
                            item: item,
                          ),
                          IconButton(
                            onPressed: () => onChanged(item, 'remove'),
                            icon: const Icon(Icons.remove),
                          ),
                          IconButton(
                            onPressed: () => onChanged(item, 'edit'),
                            icon: const Icon(Icons.edit),
                          ),
                          IconButton(
                            onPressed: () => onChanged(item, 'filter'),
                            icon: const Icon(Icons.filter_alt),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ListTileTemplate extends StatelessWidget {
  final String item;
  final double maxWidth, maxHeight;

  const ListTileTemplate({
    super.key,
    required this.item,
    required this.maxWidth,
    required this.maxHeight,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: maxWidth,
      height: maxHeight,
      child: ListTile(title: Text(item)),
    );
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
