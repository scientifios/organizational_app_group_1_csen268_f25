import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => Navigator.pop(context)),
        title: const Text('Privacy Policy'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Text(
            '''
This is the Privacy Policy page.

1. Data Collection
Lorem ipsum dolor sit amet, consectetur adipiscing elit. Cras id faucibus nunc, vel interdum nulla.

2. Data Usage
Sed dictum nulla id mi gravida, ut fermentum odio tincidunt. Vivamus non ante et lorem maximus suscipit.

3. Data Sharing
Aenean vel luctus lorem. Etiam vitae arcu euismod, sodales sapien at, aliquet metus.

4. Cookies
Praesent sagittis magna vel justo egestas, eget cursus ex blandit. Nunc pretium, tortor sed dignissim placerat.

5. User Rights
Curabitur quis urna sed mauris tincidunt consectetur. Donec a leo a est malesuada tincidunt.
            ''',
            style: TextStyle(fontSize: 15, height: 1.6),
          ),
        ),
      ),
    );
  }
}
