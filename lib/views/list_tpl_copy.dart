import 'package:flutter/material.dart';

enum ListItemAction { remove, edit, filter }

class TListTemplate<T> extends ListTemplate {
  TListTemplate({
    super.key,
    required List<T> items,
    required String Function(T item) item2String,
    required super.title,
    super.subtitle,
    super.maxWidth,
    super.maxHeight,
    required super.actions,
    required super.onChanged,
  }) : super(items: items.map(item2String).toList());
}

class ListTemplate extends StatelessWidget {
  final List<String> items;
  final String title;
  final String? subtitle;
  final double maxWidth, maxHeight;
  final List<ListItemAction> actions;
  final void Function(String, ListItemAction) onChanged;

  const ListTemplate({
    super.key,
    required this.items,
    required this.title,
    this.subtitle,
    this.maxWidth = 200,
    this.maxHeight = 400,
    this.actions = const [],
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: maxWidth,
      height: maxHeight,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.primaries[0].shade100,
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              if (subtitle != null && subtitle!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(subtitle!, maxLines: 2, overflow: TextOverflow.ellipsis),
              ],
              const SizedBox(height: 8),
              Expanded(
                child: items.isEmpty
                    ? const Center(child: Text('No items'))
                    : ListView.separated(
                        padding: EdgeInsets.zero,
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 8,
                            ),
                            title: Text(
                              item,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: actions.isEmpty
                                ? null
                                : Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      for (final action in actions)
                                        _buildActionButton(item, action),
                                    ],
                                  ),
                          );
                        },
                        separatorBuilder: (context, index) =>
                            const Divider(height: 1),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(String item, ListItemAction action) {
    final (label, icon) = switch (action) {
      ListItemAction.remove => ('Remove', Icons.remove),
      ListItemAction.edit => ('Edit', Icons.edit),
      ListItemAction.filter => ('Filter', Icons.filter_alt),
    };

    return IconButton(
      tooltip: label,
      visualDensity: VisualDensity.compact,
      constraints: const BoxConstraints.tightFor(width: 40, height: 40),
      padding: EdgeInsets.zero,
      onPressed: () => onChanged(item, action),
      icon: Icon(icon, size: 20),
    );
  }
}

class ListActionTemplate extends StatelessWidget {
  final List<(String, VoidCallback)> actions;
  final double? maxWidth;

  const ListActionTemplate({super.key, required this.actions, this.maxWidth});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: maxWidth ?? double.infinity,
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 12,
        runSpacing: 8,
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
