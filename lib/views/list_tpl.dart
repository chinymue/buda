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
    // TODO: Fix onchanged detection for actions. Currently can't check by toSring(): Onchanged: Closure: (String, String) => void.
    debugPrint('ListTemplate build: $title, items: ${items.length}');
    debugPrint('Onchanged: ${onChanged.toString()}');
    final bool hasRemove = onChanged.toString().contains('remove');
    final bool hasEdit = onChanged.toString().contains('edit');
    final bool hasFilter = onChanged.toString().contains('filter');
    final int actionCount =
        (hasRemove ? 1 : 0) + (hasEdit ? 1 : 0) + (hasFilter ? 1 : 0);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.primaries[0].shade100,
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
              if (subtitle != null) Text(subtitle!),
              SizedBox(
                width: maxWidth,
                height:
                    maxHeight -
                    100, // Adjust height to account for title and subtitle
                child: ListView(
                  scrollDirection: Axis.vertical,
                  children: [
                    for (String item in items)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ListTileTemplate(
                            maxWidth: maxWidth - 50 * actionCount,
                            maxHeight: 50,
                            item: item,
                          ),
                          if (hasRemove)
                            IconButton(
                              alignment: Alignment.centerRight,
                              onPressed: () => onChanged(item, 'remove'),
                              icon: const Icon(Icons.remove),
                            ),
                          if (hasEdit)
                            IconButton(
                              alignment: Alignment.centerRight,
                              onPressed: () => onChanged(item, 'edit'),
                              icon: const Icon(Icons.edit),
                            ),
                          if (hasFilter)
                            IconButton(
                              alignment: Alignment.centerRight,
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
