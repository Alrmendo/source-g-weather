import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/services/email_subscription_service.dart';
import '../../weather/providers/weather_providers.dart';

class SubscriptionForm extends ConsumerStatefulWidget {
  const SubscriptionForm({super.key});

  @override
  ConsumerState<SubscriptionForm> createState() => _SubscriptionFormState();
}

class _SubscriptionFormState extends ConsumerState<SubscriptionForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  bool _isLoading = false;
  bool _isDisposed = false;
  String? _lastCheckedEmail;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _emailController.dispose();
    super.dispose();
  }

  void _checkSubscriptionStatus(String email) {
    if (_isDisposed || !mounted) return;
    
    if (email.isNotEmpty && email != _lastCheckedEmail) {
      _lastCheckedEmail = email;
      ref.read(subscriptionStatusProvider.notifier).checkSubscriptionStatus(email);
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  Future<void> _handleSubscribe() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    setState(() => _isLoading = true);

    try {
      await ref.read(subscriptionStatusProvider.notifier).requestSubscription(email);
      
      if (mounted) {
        _showSuccessDialog(
          'Subscription Requested',
          'A confirmation email has been sent to $email. Please check your inbox and click the confirmation link to complete your subscription.',
          isSubscribe: true,
        );
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Subscription Failed', e.toString());
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleUnsubscribe() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    
    // Show confirmation dialog first
    final confirmed = await _showUnsubscribeConfirmationDialog(email);
    if (!confirmed) return;

    setState(() => _isLoading = true);

    try {
      await ref.read(subscriptionStatusProvider.notifier).requestUnsubscription(email);
      
      if (mounted) {
        _showSuccessDialog(
          'Unsubscription Requested',
          'A confirmation email has been sent to $email. Please check your inbox and click the confirmation link to complete your unsubscription.',
          isSubscribe: false,
        );
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Unsubscription Failed', e.toString());
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSuccessDialog(String title, String message, {required bool isSubscribe}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              isSubscribe ? Icons.email : Icons.unsubscribe,
              color: isSubscribe ? Colors.green : Colors.orange,
            ),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _emailController.clear();
              _lastCheckedEmail = null;
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.error, color: Colors.red),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<bool> _showUnsubscribeConfirmationDialog(String email) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Unsubscription'),
        content: Text(
          'Are you sure you want to unsubscribe $email from daily weather forecasts?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Unsubscribe'),
          ),
        ],
      ),
    );
    
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final subscriptionStatusAsync = ref.watch(subscriptionStatusProvider);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                'Daily Forecast Subscription',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Description
              Text(
                'Get daily weather forecasts delivered to your email. Double opt-in required for subscription.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Email input
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                enabled: !_isLoading,
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  hintText: 'Enter your email address',
                  prefixIcon: Icon(Icons.email),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your email address';
                  }
                  if (!_isValidEmail(value.trim())) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
                onChanged: _checkSubscriptionStatus,
              ),
              
              const SizedBox(height: 16),
              
              // Subscription status
              subscriptionStatusAsync.when(
                data: (status) => _SubscriptionStatusWidget(
                  status: status,
                  email: _emailController.text.trim(),
                ),
                loading: () => const _StatusLoading(),
                error: (_, __) => const SizedBox.shrink(),
              ),
              
              const SizedBox(height: 24),
              
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _handleSubscribe,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Icon(Icons.email),
                      label: Text(_isLoading ? 'Processing...' : 'Subscribe'),
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isLoading ? null : _handleUnsubscribe,
                      icon: const Icon(Icons.unsubscribe),
                      label: const Text('Unsubscribe'),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Terms notice
              Text(
                'By subscribing, you agree to receive daily weather forecast emails. You can unsubscribe at any time.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SubscriptionStatusWidget extends StatelessWidget {
  final SubscriptionStatus status;
  final String email;
  
  const _SubscriptionStatusWidget({
    required this.status,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    if (email.isEmpty) return const SizedBox.shrink();

    IconData icon;
    Color color;
    String message;

    switch (status) {
      case SubscriptionStatus.confirmed:
        icon = Icons.check_circle;
        color = Colors.green;
        message = 'You are subscribed to daily forecasts';
        break;
      case SubscriptionStatus.pending:
        icon = Icons.pending;
        color = Colors.orange;
        message = 'Subscription pending confirmation';
        break;
      case SubscriptionStatus.unsubscribed:
        icon = Icons.info;
        color = AppColors.textSecondary;
        message = 'Not subscribed to daily forecasts';
        break;
      case SubscriptionStatus.failed:
        icon = Icons.error;
        color = Colors.red;
        message = 'Subscription failed - please try again';
        break;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusLoading extends StatelessWidget {
  const _StatusLoading();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.textSecondary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 8),
          Text(
            'Checking subscription status...',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
