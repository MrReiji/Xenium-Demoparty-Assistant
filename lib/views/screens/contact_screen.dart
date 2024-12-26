import 'package:demoparty_assistant/utils/functions/copyToClipboard.dart';
import 'package:demoparty_assistant/utils/functions/loadJson.dart';
import 'package:demoparty_assistant/views/widgets/drawer/drawer.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';

/// Displays contact information and allows interaction such as emailing or launching URLs.
class ContactScreen extends StatelessWidget {
  const ContactScreen({Key? key}) : super(key: key);

  /// Fetches contact data from a JSON file.
  /// 
  /// The JSON is expected to contain three keys: `emails`, `socialMedia`, and `other`,
  /// each containing a list of contact items.
  Future<Map<String, List<dynamic>>> fetchContactData() async {
    final data = await loadJson('assets/data/contact_data.json');
    return {
      "emails": data['emails'] ?? [], // List of email contacts.
      "socialMedia": data['socialMedia'] ?? [], // List of social media links.
      "other": data['other'] ?? [], // List of other contact options.
    };
  }

  /// Maps string-based icon names from JSON to Flutter icons.
  /// 
  /// This ensures dynamic and consistent icon rendering based on the JSON configuration.
  IconData _getIcon(String iconName) {
    switch (iconName) {
      case 'email': return Icons.email_outlined;
      case 'facebook': return FontAwesomeIcons.facebook;
      case 'youtube': return FontAwesomeIcons.youtube;
      case 'discord': return FontAwesomeIcons.discord;
      case 'info': return FontAwesomeIcons.xmark; // Icon for informational items.
      case 'website': return FontAwesomeIcons.globe;
      default: return Icons.info_outline; // Default fallback icon.
    }
  }

  /// Assigns colors to icons based on their identity for visual branding.
  /// 
  /// Example: Blue for Facebook, red for YouTube, and so on.
  Color _getIconColor(String iconName) {
    switch (iconName) {
      case 'email': return Colors.orangeAccent;
      case 'facebook': return Colors.blueAccent;
      case 'youtube': return Colors.redAccent;
      case 'discord': return const Color(0xFF5865F2); // Discord's color.
      case 'share': return Colors.deepPurpleAccent; // Mastodon-like purple.
      case 'info': return Colors.teal;
      case 'website': return Colors.green;
      default: return Colors.grey; // Default neutral color.
    }
  }

  /// Handles contact actions such as launching a URL or copying email to clipboard.
  /// 
  /// - If it's an email, it copies the address to the clipboard.
  /// - Otherwise, it launches the provided URL in the browser.
  void _handleContactAction(BuildContext context, String action, {bool isEmail = false}) async {
    if (isEmail) {
      copyToClipboard(context, action); // Copy email to clipboard.
    } else {
      final url = Uri.parse(action);
      if (await canLaunchUrl(url)) {
        await launchUrl(url); // Launch the URL if possible.
      } else {
        throw 'Could not launch $action'; // Throw error for invalid URLs.
      }
    }
  }

  /// Builds a single contact tile with a consistent visual style.
  /// 
  /// This is used to render each contact item dynamically from the provided data.
  Widget _buildContactTile({required BuildContext context, required Map<String, dynamic> contact}) {
    final isEmail = contact['icon'] == 'email'; // Check if the item is an email.
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // Rounded corners.
      elevation: 3, // Shadow for depth.
      margin: const EdgeInsets.symmetric(vertical: 8), // Spacing between tiles.
      child: ListTile(
        leading: Container(
          height: 50,
          width: 50,
          alignment: Alignment.center,
          child: Icon(
            _getIcon(contact['icon']), // Dynamically fetched icon.
            color: _getIconColor(contact['icon']), // Dynamic color based on the icon type.
            size: 30, // Consistent icon size.
          ),
        ),
        title: Text(
          contact['type'], // Display type (e.g., "Email", "Facebook").
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(contact['details']), // Display the details (e.g., email address, URL).
        onTap: () => _handleContactAction(context, contact['action'], isEmail: isEmail), // Handle tap actions.
      ),
    );
  }

  /// Builds a section with a title and a list of contact tiles.
  /// 
  /// This is used to organize contact items into groups like "Social Media" or "Emails."
  Widget _buildSection({required BuildContext context, required String title, required List<dynamic> items}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0), // Spacing between sections.
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Align title to the left.
        children: [
          Text(
            title, // Section title.
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary, // Highlighted title color.
            ),
          ),
          const SizedBox(height: 8),
          ...items.map((item) => _buildContactTile(context: context, contact: item)).toList(), // Generate tiles for all items.
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Access the app's current theme.

    return Scaffold(
      appBar: AppBar(title: const Text("Contact Us")), // AppBar with screen title.
      drawer: AppDrawer(currentPage: "Contact"), // Navigation drawer for consistency.
      body: Container(
        decoration: BoxDecoration(color: theme.scaffoldBackgroundColor), // Matches the overall app theme.
        child: FutureBuilder<Map<String, List<dynamic>>>(
          future: fetchContactData(), // Load contact data asynchronously.
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator(color: theme.colorScheme.primary)); // Show loader.
            } else if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error: ${snapshot.error}', // Display error messages.
                  style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.error),
                ),
              );
            } else if (!snapshot.hasData) {
              return const Center(child: Text('No contact data available.')); // Handle empty data.
            }

            final contactData = snapshot.data!; // Retrieve contact data.
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), // Rounded card design.
                    elevation: 3, // Subtle shadow for elevation.
                    margin: const EdgeInsets.only(bottom: 16), // Space below the card.
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text(
                            "Get in Touch!", // Main heading.
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 35,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Feel free to contact us via the methods below!", // Subheading.
                            style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onBackground),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (contactData['emails']!.isNotEmpty)
                    _buildSection(context: context, title: "Customer Support", items: contactData['emails']!),
                  if (contactData['socialMedia']!.isNotEmpty)
                    _buildSection(context: context, title: "Social Media", items: contactData['socialMedia']!),
                  if (contactData['other']!.isNotEmpty)
                    _buildSection(context: context, title: "Additional Contacts", items: contactData['other']!),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
