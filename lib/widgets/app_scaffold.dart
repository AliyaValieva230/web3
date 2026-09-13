import 'package:flutter/material.dart';

class AppScaffold extends StatelessWidget {
  final Widget child;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  const AppScaffold({
    super.key,
    required this.child,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  static const _labels = ['Книги', 'Авторы', 'Жанры', 'Издательства', 'Читатели'];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    
    if (width < 600) {
      return Scaffold(
        body: child,
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: selectedIndex,
          onTap: onDestinationSelected,
          type: BottomNavigationBarType.fixed,
          items: _labels
              .map((label) => BottomNavigationBarItem(
                    icon: const SizedBox.shrink(),
                    label: label,
                  ))
              .toList(),
        ),
      );
    }

 
    return Scaffold(
      body: Row(
        children: [
          Container(
            width: 160,
            color: Theme.of(context).colorScheme.surface,
            child: ListView.builder(
              itemCount: _labels.length,
              itemBuilder: (context, index) {
                final isSelected = index == selectedIndex;
                return ListTile(
                  title: Text(_labels[index]),
                  selected: isSelected,
                  selectedTileColor: Theme.of(context).colorScheme.primaryContainer,
                  onTap: () => onDestinationSelected(index),
                );
              },
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(child: child),
        ],
      ),
    );
  }
}