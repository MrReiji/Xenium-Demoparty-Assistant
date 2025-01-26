// AppDrawer.dart
import 'package:flutter/material.dart';
import 'package:demoparty_assistant/views/Theme.dart';
import 'package:demoparty_assistant/utils/navigation/drawer_items.dart';
import 'package:demoparty_assistant/utils/navigation/app_router_paths.dart';
import 'package:demoparty_assistant/views/widgets/drawer/drawer-subtile.dart';
import 'package:demoparty_assistant/views/widgets/drawer/drawer-tile.dart';
import 'package:go_router/go_router.dart';

class AppDrawer extends StatefulWidget {
  final String currentPage;

  const AppDrawer({required this.currentPage, Key? key}) : super(key: key);

  @override
  _AppDrawerState createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  String? _expandedSection;

  void _toggleExpansion(String section) {
    setState(() {
      _expandedSection = (_expandedSection == section) ? null : section;
    });
  }

  List<Widget> _buildDrawerTiles() {
    return drawerItems.map((item) {
      bool hasSubItems = item.containsKey('subItems');
      bool isExpanded = _expandedSection == item['title'];
      bool isSelected = widget.currentPage.toLowerCase() == item['page']?.toString().toLowerCase();

      if (!hasSubItems) {
        return Padding(
          padding: EdgeInsets.symmetric(
            vertical: AppDimensions.paddingSmall / 2,
            horizontal: AppDimensions.paddingMedium - AppDimensions.paddingSmall,
          ),
          child: DrawerTile(
            icon: item['icon'],
            title: item['title'],
            isSelected: isSelected,
            iconColor: item['iconColor'],
            onTap: () {
              if (item['route'] != null) {
                if (widget.currentPage != item['page']) {
                  context.push(item['route']);
                }
              } else if (item['url'] != null) {
                context.push('${AppRouterPaths.content}?url=${Uri.encodeComponent(item['url'])}&title=${Uri.encodeComponent(item['title'])}');
              }
            },
          ),
        );
      }

      bool isAnySubItemSelected = item['subItems'].any((subItem) {
        return widget.currentPage == subItem['page'];
      });

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              vertical: AppDimensions.paddingSmall / 2,
              horizontal: AppDimensions.paddingMedium - AppDimensions.paddingSmall,
            ),
            child: DrawerTile(
              icon: item['icon'],
              title: item['title'],
              isSelected: isAnySubItemSelected,
              iconColor: item['iconColor'],
              onTap: () {
                _toggleExpansion(item['title']);
              },
            ),
          ),
          if (isExpanded)
            ...item['subItems'].map<Widget>((subItem) {
              bool isSubItemSelected = widget.currentPage == subItem['page'];
              return Padding(
                padding: EdgeInsets.only(
                  left: AppDimensions.paddingMedium + AppDimensions.paddingSmall,
                  top: AppDimensions.paddingXXSmall,
                  bottom: AppDimensions.paddingXXSmall,
                  right: AppDimensions.paddingSmall,
                ),
                child: SubDrawerTile(
                  icon: subItem['icon'],
                  title: subItem['title'],
                  isSelected: isSubItemSelected,
                  iconColor: subItem['iconColor'],
                  onTap: () {
                    if (subItem['route'] != null) {
                      if (widget.currentPage != subItem['page']) {
                        context.push(subItem['route']);
                      }
                    } else if (subItem['url'] != null) {
                      context.push('${AppRouterPaths.content}?url=${Uri.encodeComponent(subItem['url'])}&title=${Uri.encodeComponent(subItem['title'])}');
                    }
                  },
                ),
              );
            }).toList(),
        ],
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.1,
              width: double.infinity,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingMedium,
                  vertical: AppDimensions.paddingSmall,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Image.asset(
                        "assets/imgs/xenium_logo.png",
                        fit: BoxFit.contain,
                      ),
                    ),
                    SizedBox(
                      width: AppDimensions.drawerIconButtonWidth,
                      child: IconButton(
                        icon: Icon(
                          Icons.menu,
                          color: theme.iconTheme.color?.withOpacity(AppOpacities.iconOpacityHigh),
                          size: AppDimensions.iconSizeMedium,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Divider(
              height: AppDimensions.dividerHeight,
              thickness: AppDimensions.dividerThickness,
              color: theme.dividerColor,
            ),
            SizedBox(height: AppDimensions.paddingSmall),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _buildDrawerTiles(),
                ),
              ),
            ),
            SizedBox(height: AppDimensions.paddingLarge),
          ],
        ),
      ),
    );
  }
}
