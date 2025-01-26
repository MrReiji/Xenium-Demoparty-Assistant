import 'package:demoparty_assistant/utils/functions/copyToClipboard.dart';
import 'package:demoparty_assistant/utils/functions/loadJson.dart';
import 'package:demoparty_assistant/views/widgets/drawer/drawer.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({Key? key}) : super(key: key);

  /// Fetches contact data using the `loadJson` utility function.
  Future<Map<String, List<dynamic>>> fetchContactData() async {
    final data = await loadJson('assets/data/contact_data.json');
    return {
      "emails": data['emails'] ?? [],
      "socialMedia": data['socialMedia'] ?? [],
      "other": data['other'] ?? [],
    };
  }

  /// Maps icon names from the JSON file to actual Flutter icons.
  IconData _getIcon(String iconName) {
    switch (iconName) {
      case 'email':
        return Icons.email_outlined;
      case 'facebook':
        return FontAwesomeIcons.facebook;
      case 'youtube':
        return FontAwesomeIcons.youtube;
      case 'discord':
        return FontAwesomeIcons.discord;
      case 'info':
        return FontAwesomeIcons.xmark; // Replaced with X icon
      case 'website':
        return FontAwesomeIcons.globe;
      default:
        return Icons.info_outline;
    }
  }

  /// Maps icon names to specific colors for brand identity.
  Color _getIconColor(String iconName) {
    switch (iconName) {
      case 'email':
        return Colors.orangeAccent;
      case 'facebook':
        return Colors.blueAccent;
      case 'youtube':
        return Colors.redAccent;
      case 'discord':
        return const Color(0xFF5865F2); // Discord's bluish-purple
      case 'share':
        return Colors.deepPurpleAccent; // Mastodon
      case 'info':
        return Colors.teal;
      case 'website':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  /// Launches a given URL using the `url_launcher` package or copies text to the clipboard for email addresses.
  void _handleContactAction(BuildContext context, String action, {bool isEmail = false}) async {
    if (isEmail) {
      copyToClipboard(context, action);
    } else {
      final url = Uri.parse(action);
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        throw 'Could not launch $action';
      }
    }
  }

  /// Builds a contact tile with consistent styling.
  Widget _buildContactTile({
    required BuildContext context,
    required Map<String, dynamic> contact,
  }) {
    final isEmail = contact['icon'] == 'email';
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Container(
          height: 50,
          width: 50,
          alignment: Alignment.center,
          child: Icon(
            _getIcon(contact['icon']),
            color: _getIconColor(contact['icon']),
            size: 30, // Consistent icon size
          ),
        ),
        title: Text(
          contact['type'],
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        subtitle: Text(contact['details']),
        onTap: () => _handleContactAction(
          context,
          contact['action'],
          isEmail: isEmail,
        ),
      ),
    );
  }

  /// Builds a section with contact tiles and a section title.
  Widget _buildSection({
    required BuildContext context,
    required String title,
    required List<dynamic> items,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
          const SizedBox(height: 8),
          ...items.map((item) => _buildContactTile(context: context, contact: item)).toList(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Contact Us"),
      ),
      drawer: AppDrawer(currentPage: "Contact"),
      body: Container(
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor, // Matches the TimeTable screen
        ),
        child: FutureBuilder<Map<String, List<dynamic>>>(
          future: fetchContactData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  color: theme.colorScheme.primary,
                ),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error: ${snapshot.error}',
                  style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.error),
                ),
              );
            } else if (!snapshot.hasData) {
              return const Center(
                child: Text('No contact data available.'),
              );
            }

            final contactData = snapshot.data!;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 3,
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text(
                            "Get in Touch!",
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 35,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Feel free to contact us via the methods below!",
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onBackground,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (contactData['emails']!.isNotEmpty)
                    _buildSection(
                      context: context,
                      title: "Customer Support",
                      items: contactData['emails']!,
                    ),
                  if (contactData['socialMedia']!.isNotEmpty)
                    _buildSection(
                      context: context,
                      title: "Social Media",
                      items: contactData['socialMedia']!,
                    ),
                  if (contactData['other']!.isNotEmpty)
                    _buildSection(
                      context: context,
                      title: "Additional Contacts",
                      items: contactData['other']!,
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
