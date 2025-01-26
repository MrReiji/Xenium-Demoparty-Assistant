import 'package:demoparty_assistant/views/widgets/universal/errors/error_display_widget.dart';
import 'package:demoparty_assistant/utils/errors/error_helper.dart';
import 'package:demoparty_assistant/views/widgets/universal/loading/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:demoparty_assistant/data/manager/users/users_manager.dart';
import 'package:demoparty_assistant/views/widgets/drawer/drawer.dart';
import 'package:flag/flag.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({Key? key}) : super(key: key);

  @override
  _UsersScreenState createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  List<Map<String, String>> users = [];
  List<Map<String, String>> filteredUsers = [];
  Map<String, int> countryStats = {};
  String? errorMessage;
  bool isLoading = true;
  TextEditingController searchController = TextEditingController();
  String? selectedCountry;

  @override
  void initState() {
    super.initState();
    _loadUsers();
    searchController.addListener(_filterUsers);
  }

  /// Loads user data with error handling and caching.
  Future<void> _loadUsers({bool forceRefresh = false}) async {
    setState(() => isLoading = true);

    try {
      final result = await UsersManager().fetchUsersWithStats(forceRefresh: forceRefresh);
      setState(() {
        users = result['users'];
        countryStats = result['countryStats'];
        filteredUsers = _applyFilters(users);
        errorMessage = null;
      });
    } catch (e) {
      ErrorHelper.handleError(e);
      setState(() => errorMessage = ErrorHelper.getErrorMessage(e));
    } finally {
      setState(() => isLoading = false);
    }
  }

  /// Applies search and country filters to the users list.
  List<Map<String, String>> _applyFilters(List<Map<String, String>> userList) {
    final query = searchController.text.toLowerCase();
    return userList.where((user) {
      final matchesQuery = user['name']!.toLowerCase().contains(query) ||
          user['country']!.toLowerCase().contains(query);
      final matchesCountry = selectedCountry == null || user['country'] == selectedCountry;
      return matchesQuery && matchesCountry;
    }).toList();
  }

  /// Filters users when the search query changes.
  void _filterUsers() {
    setState(() {
      filteredUsers = _applyFilters(users);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Users'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async => await _loadUsers(forceRefresh: true),
            tooltip: 'Refresh',
          ),
        ],
      ),
      drawer: const AppDrawer(currentPage: 'Users'),
      body: isLoading
          ? const LoadingWidget(
              title: 'Loading Users',
              message: 'Please wait while we load the user data.',
            )
          : errorMessage != null
              ? ErrorDisplayWidget(
                  title: 'Error Loading Users',
                  message: errorMessage!,
                  onRetry: () => _loadUsers(forceRefresh: true),
                )
              : RefreshIndicator(
                  onRefresh: () async => await _loadUsers(forceRefresh: true),
                  child: Column(
                    children: [
                      _buildSearchBar(theme),
                      _buildStatistics(theme),
                      Expanded(child: _buildUserList(theme)),
                    ],
                  ),
                ),
    );
  }

  /// Builds the search bar for filtering users.
  Widget _buildSearchBar(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: searchController,
        decoration: InputDecoration(
          hintText: 'Search users by name or country...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          filled: true,
          fillColor: theme.colorScheme.surface,
        ),
      ),
    );
  }

  /// Builds the statistics section showing total users and country stats.
  Widget _buildStatistics(ThemeData theme) {
    final totalUsers = users.length;
    final countries = countryStats.keys.toList();
    countries.sort((a, b) => countryStats[b]!.compareTo(countryStats[a]!));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Users: $totalUsers',
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: countries.map((country) {
              final count = countryStats[country]!;
              final isSelected = country == selectedCountry;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedCountry = isSelected ? null : country;
                    filteredUsers = _applyFilters(users);
                  });
                },
                child: Chip(
                  label: Text(
                    '$country ($count)',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isSelected
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                  backgroundColor: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.surfaceVariant,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  /// Builds the list of filtered users.
  Widget _buildUserList(ThemeData theme) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: filteredUsers.length,
      itemBuilder: (context, index) {
        final user = filteredUsers[index];
        return _buildUserCard(theme, user);
      },
    );
  }

  /// Builds a user card displaying user details.
  Widget _buildUserCard(ThemeData theme, Map<String, String> user) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: ListTile(
        leading: ClipOval(
          child: Flag.fromString(
            user['countryCode']!.toUpperCase(),
            height: 40,
            width: 40,
            fit: BoxFit.cover,
          ),
        ),
        title: Text(
          user['name']!,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          user['country']!,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
