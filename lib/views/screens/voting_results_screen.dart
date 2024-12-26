import 'package:demoparty_assistant/models/category_model.dart';
import 'package:demoparty_assistant/models/voting_entry_model.dart';
import 'package:demoparty_assistant/views/widgets/universal/errors/error_display_widget.dart';
import 'package:demoparty_assistant/utils/errors/error_helper.dart';
import 'package:demoparty_assistant/views/widgets/universal/loading/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:demoparty_assistant/data/manager/voting/voting_results_manager.dart';
import 'package:demoparty_assistant/views/widgets/drawer/drawer.dart';
import 'package:demoparty_assistant/views/widgets/cards/voting_result_card.dart';
import 'package:get_it/get_it.dart';

/// Screen that displays voting results categorized by competition entries.
///
/// The screen allows the user to:
/// - View categories of competitions.
/// - Select a category to view its voting results.
/// - Handle errors and loading states effectively.
class VotingResultsScreen extends StatefulWidget {
  const VotingResultsScreen({Key? key}) : super(key: key);

  @override
  _VotingResultsScreenState createState() => _VotingResultsScreenState();
}

class _VotingResultsScreenState extends State<VotingResultsScreen> {
  final VotingResultsManager _manager = GetIt.instance<VotingResultsManager>();
  final ValueNotifier<List<VotingEntry>> _entriesNotifier = ValueNotifier([]);
  List<Category> categories = [];
  String? errorMessage;
  String currentCategory = "";
  bool isLoading = true;
  bool isListLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  @override
  void dispose() {
    _entriesNotifier.dispose();
    super.dispose();
  }

  /// Fetches available categories and handles pre-loading the first category's entries.
  Future<void> _fetchCategories({bool forceRefresh = false}) async {
    setState(() => isLoading = true);

    try {
      final fetchedCategories = await _manager.retrieveVotingCategories(forceRefresh: forceRefresh);

      if (fetchedCategories.isEmpty) {
        throw Exception("No categories available.");
      }

      setState(() {
        categories = fetchedCategories;
        currentCategory = fetchedCategories.first.name;
      });

      await _fetchVotingEntries(
        fetchedCategories.first.url.toString(),
        forceRefresh: forceRefresh,
      );
    } catch (e) {
      ErrorHelper.handleError(e);
      setState(() => errorMessage = ErrorHelper.getErrorMessage(e));
    } finally {
      setState(() => isLoading = false);
    }
  }

  /// Fetches voting entries for the specified category.
  Future<void> _fetchVotingEntries(String url, {bool forceRefresh = false}) async {
    setState(() => isListLoading = true);

    try {
      final fetchedEntries = await _manager.retrieveCategoryVotingResults(url, forceRefresh: forceRefresh);
      _entriesNotifier.value = fetchedEntries;
      setState(() => errorMessage = null);
    } catch (e) {
      ErrorHelper.handleError(e);
      setState(() {
        errorMessage = ErrorHelper.getErrorMessage(e);
        _entriesNotifier.value = [];
      });
    } finally {
      setState(() => isListLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Voting Results"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              if (!isLoading && !isListLoading) {
                await _fetchCategories(forceRefresh: true);
              }
            },
            tooltip: "Refresh",
          ),
        ],
      ),
      drawer: const AppDrawer(currentPage: "Voting Results"),
      body: isLoading
          ? const LoadingWidget(
              title: "Fetching Data",
              message: "Please wait while we retrieve the latest voting results.",
            )
          : errorMessage != null
              ? ErrorDisplayWidget(
                  title: "Error Loading Data",
                  message: errorMessage!,
                  onRetry: () => _fetchCategories(forceRefresh: true),
                )
              : _buildContent(theme),
    );
  }

  /// Builds the main content of the screen.
  Widget _buildContent(ThemeData theme) {
    return Column(
      children: [
        _buildCategoryDropdown(theme),
        Expanded(
          child: ValueListenableBuilder<List<VotingEntry>>(
            valueListenable: _entriesNotifier,
            builder: (context, entries, child) {
              if (entries.isEmpty) {
                return ErrorDisplayWidget(
                  title: "No Entries Found",
                  message: "No entries are available for this category. Try refreshing the data.",
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                itemCount: entries.length,
                itemBuilder: (context, index) {
                  return VotingResultCard(
                    entry: entries[index],
                    onImageTap: () => _showImageDialog(
                      context,
                      entries[index].imageUrl.toString(),
                      entries[index].title,
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  /// Builds the dropdown for selecting competition categories.
  Widget _buildCategoryDropdown(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Selected category:",
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8.0),
          DecoratedBox(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.primary.withOpacity(0.5),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: DropdownButton<String>(
                value: currentCategory,
                isExpanded: true,
                underline: Container(),
                menuMaxHeight: 200,
                icon: Icon(Icons.arrow_drop_down, color: theme.colorScheme.primary),
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
                dropdownColor: theme.colorScheme.surface,
                items: categories.map((category) {
                  return DropdownMenuItem<String>(
                    value: category.name,
                    child: Text(category.name),
                  );
                }).toList(),
                onChanged: (value) {
                  final selectedCategory = categories.firstWhere((c) => c.name == value);
                  setState(() => currentCategory = selectedCategory.name);
                  _fetchVotingEntries(selectedCategory.url.toString());
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Displays an image in a dialog for interactive viewing.
  void _showImageDialog(BuildContext context, String imageUrl, String altText) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black87,
        insetPadding: const EdgeInsets.all(10.0),
        child: InteractiveViewer(
          maxScale: 5.0,
          minScale: 1.0,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.0),
            child: Image.network(
              imageUrl,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => Center(
                child: Text(
                  altText,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
