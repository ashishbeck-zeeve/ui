import 'package:flutter/material.dart';

class MaterialTabBar extends StatefulWidget {
  final List<String> tabs;
  final Function(int) onTap;

  const MaterialTabBar({Key key, @required this.tabs, this.onTap})
      : super(key: key);

  @override
  _MaterialTabBarState createState() => _MaterialTabBarState();
}

class _MaterialTabBarState extends State<MaterialTabBar>
    with SingleTickerProviderStateMixin {
  TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: widget.tabs.length, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var tabs = widget.tabs;
    return TabBar(
      controller: tabController,
      unselectedLabelColor: Colors.grey,
      labelColor: Theme.of(context).primaryColor,
      tabs: tabs
          .map((e) => Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(e, style: TextStyle(fontSize: 16)),
              ))
          .toList(),
      onTap: (i) => widget.onTap(i),
    );
  }
}
