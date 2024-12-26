import 'package:demoparty_assistant/utils/functions/getColorForType.dart'; 
import 'package:demoparty_assistant/utils/functions/getIconForType.dart'; 
import 'package:demoparty_assistant/utils/navigation/app_router_paths.dart';
import 'package:flutter/material.dart'; 
import 'package:demoparty_assistant/views/Theme.dart'; 
import 'package:demoparty_assistant/views/widgets/drawer/drawer-subtile.dart'; 
import 'package:demoparty_assistant/views/widgets/drawer/drawer-tile.dart'; 
import 'package:go_router/go_router.dart'; 
import 'package:demoparty_assistant/utils/functions/loadJson.dart'; 

/// A stateful widget representing the application's navigation drawer.
/// It dynamically loads its content from a JSON configuration file and handles user interactions for navigation.
class AppDrawer extends StatefulWidget {
  final String currentPage; // The currently active page to highlight in the drawer.

  const AppDrawer({required this.currentPage, Key? key}) : super(key: key);

  @override
  _AppDrawerState createState() => _AppDrawerState();
}

/// The state class for [AppDrawer], responsible for managing dynamic drawer content
/// and tracking expanded sections for tiles with sub-items.
class _AppDrawerState extends State<AppDrawer> {
  String? _expandedSection; // Tracks the title of the currently expanded section (null if none are expanded).
  List<dynamic>? drawerItems; // Stores the list of items loaded from the JSON configuration.

  /// Initializes the state of the drawer and triggers loading of the drawer items.
  @override
  void initState() {
    super.initState();
    _loadDrawerData(); // Loads the content for the drawer on widget initialization.
  }

  /// Asynchronously loads the drawer items from a JSON file.
  /// Parses the content and updates the `drawerItems` state, which drives the UI.
  Future<void> _loadDrawerData() async {
    try {
      final data = await loadJson('assets/data/drawer_items.json'); // Loads the JSON configuration file.
      setState(() {
        drawerItems = data['drawerItems']; // Updates the state with parsed drawer items.
      });
    } catch (e) {
      print("Error loading JSON: $e"); // Logs any errors encountered during the loading process.
    }
  }

  /// Toggles the expansion state of a drawer section.
  /// If the section is already expanded, it collapses; otherwise, it expands.
  void _toggleExpansion(String section) {
    setState(() {
      _expandedSection = (_expandedSection == section) ? null : section; // Updates the expanded section state.
    });
  }

  /// Dynamically builds the list of tiles for the navigation drawer.
  /// Supports both main tiles and expandable tiles with sub-items.
  List<Widget> _buildDrawerTiles() {
    if (drawerItems == null) return []; // Returns an empty list if the drawer items have not yet been loaded.

    return drawerItems!.map((item) {
      bool hasSubItems = item.containsKey('subItems'); // Checks whether the item has sub-items.
      bool isExpanded = _expandedSection == item['title']; // Determines if this item is the currently expanded section.
      bool isSelected = widget.currentPage.toLowerCase() == item['page']?.toString().toLowerCase(); // Checks if this item corresponds to the active page.

      if (!hasSubItems) {
        // Builds a single-level drawer tile (no sub-items).
        return Padding(
          padding: EdgeInsets.symmetric(
            vertical: AppDimensions.paddingSmall / 2,
            horizontal: AppDimensions.paddingMedium - AppDimensions.paddingSmall,
          ),
          child: DrawerTile(
            icon: getIconForType(item['icon']), // Retrieves the appropriate icon based on the item type.
            title: item['title'], // Displays the item's title.
            isSelected: isSelected, // Highlights the tile if it corresponds to the current page.
            iconColor: getColorForType(item['iconColor']), // Retrieves the color for the tile's icon dynamically.
            onTap: () {
              if (item['route'] != null) {
                // Handles navigation for the defined, not generic routes
                if (widget.currentPage != item['page']) {
                  context.push(item['route']); // Navigates to the specified route.
                }
              } else if (item['url'] != null) {
                // Navigates to a generic content screen.
                context.push('${AppRouterPaths.generic_content}?url=${Uri.encodeComponent(item['url'])}&title=${Uri.encodeComponent(item['title'])}');
              }
            },
          ),
        );

      }

      // Determines whether any sub-item within this section is selected.
      bool isAnySubItemSelected = item['subItems'].any((subItem) {
        return widget.currentPage == subItem['page'];
      });

      // Builds a tile with expandable sub-items.
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              vertical: AppDimensions.paddingSmall / 2,
              horizontal: AppDimensions.paddingMedium - AppDimensions.paddingSmall,
            ),
            child: DrawerTile(
              icon: getIconForType(item['icon']), // Retrieves the appropriate icon for the main tile.
              title: item['title'], // Displays the section's title.
              isSelected: isAnySubItemSelected, // Highlights the main tile if any sub-item is selected.
              iconColor: getColorForType(item['iconColor']), // Retrieves the icon color dynamically.
              onTap: () {
                _toggleExpansion(item['title']); // Toggles the expansion state of the section.
              },
            ),
          ),
          if (isExpanded)
            // Maps the sub-items to individual sub-tiles when the section is expanded.
            ...item['subItems'].map<Widget>((subItem) {
              bool isSubItemSelected = widget.currentPage == subItem['page']; // Checks if this sub-item is selected.
              return Padding(
                padding: EdgeInsets.only(
                  left: AppDimensions.paddingMedium + AppDimensions.paddingSmall,
                  top: AppDimensions.paddingXXSmall,
                  bottom: AppDimensions.paddingXXSmall,
                  right: AppDimensions.paddingSmall,
                ),
                child: SubDrawerTile(
                  icon: getIconForType(subItem['icon']), // Retrieves the appropriate icon for the sub-item.
                  title: subItem['title'], // Displays the sub-item's title.
                  isSelected: isSubItemSelected, // Highlights the sub-tile if it corresponds to the current page.
                  iconColor: getColorForType(subItem['iconColor']), // Retrieves the icon color dynamically.
                  onTap: () {
                    // Handles navigation or external link opening for the sub-item.
                    if (subItem['route'] != null) {
                      if (widget.currentPage != subItem['page']) {
                        context.push(subItem['route']); // Navigates to the sub-item's specified route.
                      }
                    } else if (subItem['url'] != null) {
                      // Opens an external URL in a web content screen.
                      context.push('${AppRouterPaths.generic_content}?url=${Uri.encodeComponent(subItem['url'])}&title=${Uri.encodeComponent(subItem['title'])}');
                    }
                  },
                ),
              );
            }).toList(),
        ],
      );
    }).toList(); // Converts the mapped list of widgets into a ListView-compatible structure.
  }

  /// Builds the complete navigation drawer, including the logo, main tiles, and sub-items.
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Retrieves the current theme for consistent styling.
    return 
    
    Drawer(
      child: SafeArea(
        child: Column(
          children: [
            // Top section: Displays the app's logo and a close menu button.
            Container(
              height: MediaQuery.of(context).size.height * 0.1, // Dynamically scales with the screen size.
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
                        "assets/imgs/xenium_logo.png", // Displays the app logo.
                        fit: BoxFit.contain, // Ensures the logo fits within its container.
                      ),
                    ),
                    SizedBox(
                      width: AppDimensions.drawerIconButtonWidth,
                      child: IconButton(
                        icon: Icon(
                          Icons.menu, // Menu icon to close the drawer.
                          color: theme.iconTheme.color?.withOpacity(AppOpacities.iconOpacityHigh),
                          size: AppDimensions.iconSizeMedium,
                        ),
                        onPressed: () {
                          Navigator.pop(context); // Closes the drawer.
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Divider(
              height: AppDimensions.dividerHeight, // Custom height for the divider.
              thickness: AppDimensions.dividerThickness, // Custom thickness for the divider.
              color: theme.dividerColor, // Divider color from the theme.
            ),
            SizedBox(height: AppDimensions.paddingSmall), // Adds spacing after the divider.
            // Main content section: Displays the drawer items.
            Expanded(
              child: SingleChildScrollView(
                child: drawerItems == null
                    ? Center(child: CircularProgressIndicator()) // Shows a loading indicator while data is being loaded.
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _buildDrawerTiles(), // Dynamically renders the drawer tiles.
                      ),
              ),
            ),
            SizedBox(height: AppDimensions.paddingLarge), // Adds spacing at the bottom of the drawer.
          ],
        ),
      ),
    );


  }
}
