import 'package:flutter/material.dart';

class ServiceItemsPage extends StatelessWidget {
  const ServiceItemsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => Navigator.pop(context)),
        title: const Text('Service Items'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Text(
            '''
This is the Service Items page.

1. Introduction
Lorem ipsum dolor sit amet, consectetur adipiscing elit. Pellentesque at mi ac risus gravida dictum. 

2. Use of Service
Vivamus fringilla nisi vitae tortor congue, sit amet maximus elit dapibus. Nullam at lorem vel turpis convallis rutrum.

3. User Responsibility
Suspendisse potenti. Curabitur in mi non arcu egestas tincidunt eget vitae lacus. 
Maecenas at purus quis libero bibendum euismod.

4. Termination
Sed eu velit ac sapien commodo dignissim. Integer fermentum odio at lectus gravida blandit.

5. Changes to Terms
Donec ullamcorper, elit sed fermentum porttitor, ex mi suscipit tortor, non gravida arcu neque et sapien.
            ''',
            style: TextStyle(fontSize: 15, height: 1.6),
          ),
        ),
      ),
    );
  }
}
