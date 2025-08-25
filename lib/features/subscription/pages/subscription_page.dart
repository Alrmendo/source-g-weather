import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../widgets/subscription_form.dart';

class SubscriptionPage extends StatelessWidget {
  const SubscriptionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Email Subscription'),
        centerTitle: true,
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _SubscriptionHeader(),
            
            SizedBox(height: 24),
            
            // Subscription form
            SubscriptionForm(),
            
            SizedBox(height: 24),
            
            // Information section
            _InformationSection(),
          ],
        ),
      ),
    );
  }
}

class _SubscriptionHeader extends StatelessWidget {
  const _SubscriptionHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Never Miss the Weather',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: 8),
        
        Text(
          'Get personalized daily weather forecasts delivered straight to your inbox. Stay prepared for whatever the day brings.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _InformationSection extends StatelessWidget {
  const _InformationSection();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How it works',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 16),
            
            ..._informationItems.map((item) => _InformationItem(
              icon: item.icon,
              title: item.title,
              description: item.description,
            )),
            
            const SizedBox(height: 24),
            
            // Security notice
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.primaryBlue.withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.security,
                        color: AppColors.primaryBlue,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Your Privacy Matters',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'We use double opt-in to ensure your email is secure. Your data is never shared with third parties, and you can unsubscribe at any time.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.primaryBlue.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InformationItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  
  const _InformationItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: AppColors.primaryBlue,
              size: 20,
            ),
          ),
          
          const SizedBox(width: 16),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InformationItemData {
  final IconData icon;
  final String title;
  final String description;
  
  const _InformationItemData({
    required this.icon,
    required this.title,
    required this.description,
  });
}

final List<_InformationItemData> _informationItems = [
  const _InformationItemData(
    icon: Icons.email_outlined,
    title: 'Subscribe',
    description: 'Enter your email and click Subscribe. A confirmation email will be sent to verify your address.',
  ),
  const _InformationItemData(
    icon: Icons.link,
    title: 'Confirm',
    description: 'Click the confirmation link in the email to activate your subscription. This ensures your email is valid.',
  ),
  const _InformationItemData(
    icon: Icons.schedule,
    title: 'Receive',
    description: 'Get daily weather forecasts delivered to your inbox every morning, featuring your most recent searched location.',
  ),
  const _InformationItemData(
    icon: Icons.unsubscribe,
    title: 'Unsubscribe',
    description: 'Change your mind? Unsubscribe anytime with a single click, or use the unsubscribe link in any email.',
  ),
];
