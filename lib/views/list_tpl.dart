import 'package:flutter/material.dart';

enum ListItemAction { remove, edit, filter }

class TListTemplate<T> extends StatelessWidget {
  final List<T> items;
  final String Function(T item) toTitle;
  final String Function(T item)? toSubtitle, toTrailing;
  final String title;
  final String? subtitle;
  final double maxWidth;
  final double maxHeight;
  final Set<ListItemAction> actions;
  final void Function(T item, ListItemAction action) onAction;

  const TListTemplate({
    super.key,
    required this.items,
    required this.toTitle,
    this.toSubtitle,
    this.toTrailing,
    required this.title,
    this.subtitle,
    this.maxWidth = 200,
    this.maxHeight = 400,
    this.actions = const {},
    required this.onAction,
  });

  IconData _iconFor(ListItemAction action) => switch (action) {
    ListItemAction.remove => Icons.remove,
    ListItemAction.edit => Icons.edit,
    ListItemAction.filter => Icons.filter_alt,
  };

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.primaries[0].shade100,
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: SizedBox(
          width: maxWidth,
          height: maxHeight,
          child: Column(
            children: [
              Text(title),
              if (subtitle != null) Text(subtitle!),
              SizedBox(
                width: maxWidth,
                height: maxHeight - 100,
                child: ListView(
                  children: [
                    for (final item in items)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ListTileTemplate(
                            maxWidth: maxWidth - 50 * actions.length,
                            maxHeight: 50,
                            title: toTitle(item),
                            subtitle: toSubtitle?.call(item),
                            trailing: toTrailing?.call(item),
                          ),
                          for (final action in actions)
                            IconButton(
                              alignment: Alignment.centerRight,
                              onPressed: () => onAction(item, action),
                              icon: Icon(_iconFor(action)),
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
  final String title;
  final String? subtitle, trailing;
  final double maxWidth, maxHeight;

  const ListTileTemplate({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    required this.maxWidth,
    required this.maxHeight,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: maxWidth,
      height: maxHeight,
      child: (subtitle != null) & (trailing != null)
          ? ListTile(
              title: Text(title),
              subtitle: Text(subtitle!),
              trailing: Text(trailing!),
            )
          : ((subtitle != null)
                ? ListTile(title: Text(title), subtitle: Text(subtitle!))
                : ListTile(title: Text(title))),
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
