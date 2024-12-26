import 'package:demoparty_assistant/views/widgets/universal/errors/error_display_widget.dart';
import 'package:demoparty_assistant/utils/errors/error_helper.dart';
import 'package:demoparty_assistant/views/widgets/universal/loading/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:demoparty_assistant/data/manager/users/users_manager.dart';
import 'package:demoparty_assistant/views/widgets/drawer/drawer.dart';
import 'package:flag/flag.dart';

/// The UsersScreen displays a list of users and provides filtering and statistics features.
/// 
/// Features:
/// - Displays a searchable and filterable user list.
/// - Shows statistics about users by country.
/// - Handles errors and allows data refresh.
class UsersScreen extends StatefulWidget {
  const UsersScreen({Key? key}) : super(key: key);

  @override
  _UsersScreenState createState() => _UsersScreenState();
}

/// The state class for managing user data and UI updates for the UsersScreen.
class _UsersScreenState extends State<UsersScreen> {
  List<Map<String, String>> users = []; // Stores the full list of users.
  List<Map<String, String>> filteredUsers = []; // Stores the filtered list of users based on search and filters.
  Map<String, int> countryStats = {}; // Stores the count of users per country.
  String? errorMessage; // Stores an error message if data loading fails.
  bool isLoading = true; // Tracks whether data is currently being loaded.
  TextEditingController searchController = TextEditingController(); // Controller for the search bar.
  String? selectedCountry; // Tracks the currently selected country for filtering.

  @override
  void initState() {
    super.initState();
    _loadUsers(); // Load user data when the screen initializes.
    searchController.addListener(_filterUsers); // Add a listener to handle search input changes.
  }

  /// Loads user data with optional force refresh and updates the state.
  /// Handles errors and updates UI accordingly.
  Future<void> _loadUsers({bool forceRefresh = false}) async {
    setState(() => isLoading = true); // Show loading state.

    try {
      // Fetch users and statistics from the UsersManager.
      final result = await UsersManager().fetchUsersWithStats(forceRefresh: forceRefresh);
      setState(() {
        users = result['users']; // Full list of users.
        countryStats = result['countryStats']; // Country-based user statistics.
        filteredUsers = _applyFilters(users); // Apply current filters to the loaded data.
        errorMessage = null; // Clear any previous error message.
      });
    } catch (e) {
      // Handle errors using the ErrorHelper utility.
      ErrorHelper.handleError(e);
      setState(() {
        errorMessage = ErrorHelper.getErrorMessage(e); // Display a user-friendly error message.
      });
    } finally {
      setState(() => isLoading = false); // Hide loading state.
    }
  }

  /// Applies search and country filters to the list of users.
  ///
  /// Returns a filtered list based on the current search query and selected country.
  List<Map<String, String>> _applyFilters(List<Map<String, String>> userList) {
    final query = searchController.text.toLowerCase(); // Get the search query in lowercase.
    return userList.where((user) {
      // Check if the user matches the search query and the selected country filter.
      final matchesQuery = user['name']!.toLowerCase().contains(query) ||
          user['country']!.toLowerCase().contains(query);
      final matchesCountry = selectedCountry == null || user['country'] == selectedCountry;
      return matchesQuery && matchesCountry;
    }).toList();
  }

  /// Updates the filtered user list whenever the search query changes.
  void _filterUsers() {
    setState(() {
      filteredUsers = _applyFilters(users); // Apply filters to the full user list.
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Access the app's theme for consistent styling.

    return Scaffold(
      appBar: AppBar(
        title: const Text('Users'), // Title of the screen.
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh), // Refresh icon in the AppBar.
            onPressed: () async => await _loadUsers(forceRefresh: true), // Refresh user data.
            tooltip: 'Refresh', // Tooltip for accessibility.
          ),
        ],
      ),
      drawer: const AppDrawer(currentPage: 'Users'), // Drawer for navigation.
      body: isLoading
          ? const LoadingWidget(
              title: 'Loading Users', // Title for the loading widget.
              message: 'Please wait while we load the user data.', // Loading message.
            )
          : errorMessage != null
              ? ErrorDisplayWidget(
                  title: 'Error Loading Users', // Title for the error display.
                  message: errorMessage!, // Display the error message.
                  onRetry: () => _loadUsers(forceRefresh: true), // Retry loading on error.
                )
              : RefreshIndicator(
                  onRefresh: () async => await _loadUsers(forceRefresh: true), // Pull-to-refresh functionality.
                  child: Column(
                    children: [
                      _buildSearchBar(theme), // Search bar for filtering users.
                      _buildStatistics(theme), // Statistics section showing total users and country stats.
                      Expanded(child: _buildUserList(theme)), // User list with filtered users.
                    ],
                  ),
                ),
    );
  }

  /// Builds the search bar widget for filtering users by name or country.
  Widget _buildSearchBar(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), // Add consistent padding.
      child: TextField(
        controller: searchController, // Connect the search controller.
        decoration: InputDecoration(
          hintText: 'Search users by name or country...', // Placeholder text for the search bar.
          prefixIcon: const Icon(Icons.search), // Search icon.
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.0), // Rounded corners for the input field.
          ),
          filled: true,
          fillColor: theme.colorScheme.surface, // Background color for the input field.
        ),
      ),
    );
  }

  /// Builds the statistics section displaying total users and country-based user counts.
  Widget _buildStatistics(ThemeData theme) {
    final totalUsers = users.length; // Total number of users.
    final countries = countryStats.keys.toList(); // List of all countries.
    countries.sort((a, b) => countryStats[b]!.compareTo(countryStats[a]!)); // Sort countries by user count.

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4), // Add consistent padding.
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Align content to the start.
        children: [
          Text(
            'Total Users: $totalUsers', // Display the total number of users.
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold, // Bold text for emphasis.
            ),
          ),
          const SizedBox(height: 10), // Add spacing below the total users text.
          Wrap(
            spacing: 8, // Horizontal spacing between chips.
            runSpacing: 4, // Vertical spacing for wrapped rows.
            children: countries.map((country) {
              final count = countryStats[country]!; // Get the count of users for the country.
              final isSelected = country == selectedCountry; // Check if the country is selected.
              return GestureDetector(
                onTap: () {
                  setState(() {
                    // Toggle country selection.
                    selectedCountry = isSelected ? null : country;
                    filteredUsers = _applyFilters(users); // Update the filtered user list.
                  });
                },
                child: Chip(
                  label: Text(
                    '$country ($count)', // Display country name and user count.
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isSelected
                          ? theme.colorScheme.onPrimary // Text color for selected state.
                          : theme.colorScheme.onSurface, // Text color for unselected state.
                    ),
                  ),
                  backgroundColor: isSelected
                      ? theme.colorScheme.primary // Background color for selected state.
                      : theme.colorScheme.surfaceVariant, // Background color for unselected state.
                ),
              );
            }).toList(),
          ),],
      ),
    );
  }



  /// Builds the list of filtered users.
  Widget _buildUserList(ThemeData theme) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), // Add consistent padding.
      itemCount: filteredUsers.length, // Number of filtered users.
      itemBuilder: (context, index) {
        final user = filteredUsers[index]; // Get the user at the current index.
        return _buildUserCard(theme, user); // Build a user card.
      },
    );
  }

  /// Builds a card widget displaying user details.
  Widget _buildUserCard(ThemeData theme, Map<String, String> user) {
    return Card(
      elevation: 5, // Add shadow to the card.
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16), // Rounded corners for the card.
      ),
      margin: const EdgeInsets.symmetric(vertical: 4.0), // Add vertical spacing between cards.
      child: ListTile(
        leading: ClipOval(
          child: Flag.fromString(
            user['countryCode']!.toUpperCase(), // Display the user's country flag.
            height: 40,
            width: 40,
            fit: BoxFit.cover,
          ),
        ),
        title: Text(
          user['name']!, // Display the user's name.
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold, // Bold text for the name.
            color: theme.colorScheme.onSurface, // Text color from the theme.
          ),
        ),
        subtitle: Text(
          user['country']!, // Display the user's country.
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6), // Dimmed text color for the subtitle.
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose(); // Dispose the search controller to avoid memory leaks.
    super.dispose();
  }
}
