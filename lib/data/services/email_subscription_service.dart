import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/storage_constants.dart';
import '../../core/env/env_config.dart';

/// Exception thrown when email subscription operations fail
class EmailSubscriptionException implements Exception {
  final String message;
  final String? code;

  const EmailSubscriptionException(this.message, [this.code]);

  @override
  String toString() => 'EmailSubscriptionException: $message';
}

/// Status of email subscription confirmation
enum SubscriptionStatus {
  pending,
  confirmed,
  unsubscribed,
  failed,
}

/// Email subscription data model
class EmailSubscription {
  final String email;
  final SubscriptionStatus status;
  final DateTime createdAt;
  final DateTime? confirmedAt;
  final String? lastCity;

  const EmailSubscription({
    required this.email,
    required this.status,
    required this.createdAt,
    this.confirmedAt,
    this.lastCity,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'status': status.name,
        'createdAt': createdAt.toIso8601String(),
        'confirmedAt': confirmedAt?.toIso8601String(),
        'lastCity': lastCity,
      };

  factory EmailSubscription.fromJson(Map<String, dynamic> json) =>
      EmailSubscription(
        email: json['email'] as String,
        status: SubscriptionStatus.values.firstWhere(
          (s) => s.name == json['status'],
          orElse: () => SubscriptionStatus.pending,
        ),
        createdAt: DateTime.parse(json['createdAt'] as String),
        confirmedAt: json['confirmedAt'] != null
            ? DateTime.parse(json['confirmedAt'] as String)
            : null,
        lastCity: json['lastCity'] as String?,
      );

  EmailSubscription copyWith({
    String? email,
    SubscriptionStatus? status,
    DateTime? createdAt,
    DateTime? confirmedAt,
    String? lastCity,
  }) =>
      EmailSubscription(
        email: email ?? this.email,
        status: status ?? this.status,
        createdAt: createdAt ?? this.createdAt,
        confirmedAt: confirmedAt ?? this.confirmedAt,
        lastCity: lastCity ?? this.lastCity,
      );
}

/// Abstract interface for email subscription service
abstract class IEmailSubscriptionService {
  /// Request email confirmation for subscription
  Future<void> requestSubscriptionConfirmation(String email);

  /// Request email confirmation for unsubscription
  Future<void> requestUnsubscriptionConfirmation(String email);

  /// Request subscription (alias for requestSubscriptionConfirmation)
  Future<void> requestSubscription(String email);

  /// Request unsubscription (alias for requestUnsubscriptionConfirmation)
  Future<void> requestUnsubscription(String email);

  /// Confirm subscription with OOB code from email link
  Future<void> confirmSubscription(String oobCode);

  /// Confirm unsubscription with OOB code from email link
  Future<void> confirmUnsubscription(String oobCode);

  /// Check subscription status for an email
  Future<SubscriptionStatus> getSubscriptionStatus(String email);

  /// Get all confirmed subscribers (for sending daily forecasts)
  Future<List<EmailSubscription>> getConfirmedSubscribers();

  /// Update last searched city for a subscriber
  Future<void> updateLastCity(String email, String city);
}

/// Simple email subscription service using HTTP backend with Nodemailer
class SimpleEmailSubscriptionService implements IEmailSubscriptionService {
  final SharedPreferences _prefs;
  final String _backendUrl;

  SimpleEmailSubscriptionService({
    required SharedPreferences prefs,
    String? backendUrl,
  })  : _prefs = prefs,
        _backendUrl = backendUrl ?? EnvConfig.emailBackendUrl;

  @override
  Future<void> requestSubscription(String email) async {
    await requestSubscriptionConfirmation(email);
  }

  @override
  Future<void> requestUnsubscription(String email) async {
    await requestUnsubscriptionConfirmation(email);
  }

  @override
  Future<void> requestSubscriptionConfirmation(String email) async {
    try {
      // Store pending subscription locally
      await _storePendingSubscription(email, isSubscribe: true);

      // Send email via backend
      final response = await http.post(
        Uri.parse('$_backendUrl/api/send-subscription-email'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'type': 'subscription',
        }),
      );

      if (response.statusCode != 200) {
        throw EmailSubscriptionException(
          'Failed to send subscription email: ${response.body}',
        );
      }
    } catch (e) {
      if (e is EmailSubscriptionException) rethrow;
      throw EmailSubscriptionException(
        'Failed to send subscription confirmation email: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> requestUnsubscriptionConfirmation(String email) async {
    try {
      // Store pending unsubscription locally
      await _storePendingSubscription(email, isSubscribe: false);

      // Send email via backend
      final response = await http.post(
        Uri.parse('$_backendUrl/api/send-subscription-email'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'type': 'unsubscription',
        }),
      );

      if (response.statusCode != 200) {
        throw EmailSubscriptionException(
          'Failed to send unsubscription email: ${response.body}',
        );
      }
    } catch (e) {
      if (e is EmailSubscriptionException) rethrow;
      throw EmailSubscriptionException(
        'Failed to send unsubscription confirmation email: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> confirmSubscription(String oobCode) async {
    try {
      // Verify confirmation code via backend
      final response = await http.post(
        Uri.parse('$_backendUrl/api/confirm-subscription'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'code': oobCode,
          'type': 'subscription',
        }),
      );

      if (response.statusCode != 200) {
        throw EmailSubscriptionException(
          'Failed to confirm subscription: ${response.body}',
        );
      }

      // Update local storage
      final responseData = json.decode(response.body);
      final email = responseData['email'] as String?;
      if (email != null) {
        await _updateSubscriptionStatus(email, SubscriptionStatus.confirmed);
      }
    } catch (e) {
      if (e is EmailSubscriptionException) rethrow;
      throw EmailSubscriptionException(
        'Failed to confirm subscription: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> confirmUnsubscription(String oobCode) async {
    try {
      // Verify confirmation code via backend
      final response = await http.post(
        Uri.parse('$_backendUrl/api/confirm-subscription'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'code': oobCode,
          'type': 'unsubscription',
        }),
      );

      if (response.statusCode != 200) {
        throw EmailSubscriptionException(
          'Failed to confirm unsubscription: ${response.body}',
        );
      }

      // Update local storage
      final responseData = json.decode(response.body);
      final email = responseData['email'] as String?;
      if (email != null) {
        await _updateSubscriptionStatus(email, SubscriptionStatus.unsubscribed);
      }
    } catch (e) {
      if (e is EmailSubscriptionException) rethrow;
      throw EmailSubscriptionException(
        'Failed to confirm unsubscription: ${e.toString()}',
      );
    }
  }

  @override
  Future<SubscriptionStatus> getSubscriptionStatus(String email) async {
    try {
      // Check local storage first
      final confirmedSubscriptions =
          _prefs.getStringList('confirmed_subscriptions') ?? [];
      final pendingSubscriptions =
          _prefs.getStringList('pending_subscriptions') ?? [];
      final pendingUnsubscriptions =
          _prefs.getStringList('pending_unsubscriptions') ?? [];

      if (confirmedSubscriptions.contains(email)) {
        return SubscriptionStatus.confirmed;
      }
      if (pendingUnsubscriptions.contains(email)) {
        return SubscriptionStatus.unsubscribed;
      }
      if (pendingSubscriptions.contains(email)) {
        return SubscriptionStatus.pending;
      }

      return SubscriptionStatus.unsubscribed;
    } catch (e) {
      throw EmailSubscriptionException(
        'Failed to get subscription status: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<EmailSubscription>> getConfirmedSubscribers() async {
    try {
      // Get confirmed subscribers from local storage
      final confirmedSubscriptions =
          _prefs.getStringList('confirmed_subscriptions') ?? [];
      
      return confirmedSubscriptions.map((email) => EmailSubscription(
        email: email,
        status: SubscriptionStatus.confirmed,
        createdAt: DateTime.now(), // Simplified - in real app would store actual dates
        confirmedAt: DateTime.now(),
      )).toList();
    } catch (e) {
      throw EmailSubscriptionException(
        'Failed to get confirmed subscribers: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> updateLastCity(String email, String city) async {
    try {
      // Store locally
      await _prefs.setString('last_city_$email', city);
    } catch (e) {
      throw EmailSubscriptionException(
        'Failed to update last city: ${e.toString()}',
      );
    }
  }

  /// Update subscription status in local storage
  Future<void> _updateSubscriptionStatus(String email, SubscriptionStatus status) async {
    final confirmedList = _prefs.getStringList('confirmed_subscriptions') ?? [];
    final pendingList = _prefs.getStringList('pending_subscriptions') ?? [];
    final unsubscribedList = _prefs.getStringList('pending_unsubscriptions') ?? [];

    // Remove from all lists first
    confirmedList.remove(email);
    pendingList.remove(email);
    unsubscribedList.remove(email);

    // Add to appropriate list
    switch (status) {
      case SubscriptionStatus.confirmed:
        confirmedList.add(email);
        break;
      case SubscriptionStatus.pending:
        pendingList.add(email);
        break;
      case SubscriptionStatus.unsubscribed:
        unsubscribedList.add(email);
        break;
      case SubscriptionStatus.failed:
        // Don't store failed status
        break;
    }

    // Save back to preferences
    await _prefs.setStringList('confirmed_subscriptions', confirmedList);
    await _prefs.setStringList('pending_subscriptions', pendingList);
    await _prefs.setStringList('pending_unsubscriptions', unsubscribedList);
  }

  Future<void> _storePendingSubscription(String email,
      {required bool isSubscribe}) async {
    final key =
        isSubscribe ? 'pending_subscriptions' : 'pending_unsubscriptions';
    final otherKey =
        isSubscribe ? 'pending_unsubscriptions' : 'pending_subscriptions';

    // Remove from opposite list
    final otherList = _prefs.getStringList(otherKey) ?? [];
    otherList.remove(email);
    await _prefs.setStringList(otherKey, otherList);

    // Add to current list
    final currentList = _prefs.getStringList(key) ?? [];
    if (!currentList.contains(email)) {
      currentList.add(email);
      await _prefs.setStringList(key, currentList);
    }
  }
}

/// Mock implementation for testing and demo
class MockEmailSubscriptionService implements IEmailSubscriptionService {
  final Map<String, EmailSubscription> _subscriptions = {};

  @override
  Future<void> requestSubscription(String email) async {
    await requestSubscriptionConfirmation(email);
  }

  @override
  Future<void> requestUnsubscription(String email) async {
    await requestUnsubscriptionConfirmation(email);
  }

  @override
  Future<void> requestSubscriptionConfirmation(String email) async {
    await Future.delayed(const Duration(milliseconds: 500));

    _subscriptions[email] = EmailSubscription(
      email: email,
      status: SubscriptionStatus.pending,
      createdAt: DateTime.now(),
    );

    // Simulate email sent
    print('Mock: Subscription confirmation email sent to $email');
  }

  @override
  Future<void> requestUnsubscriptionConfirmation(String email) async {
    await Future.delayed(const Duration(milliseconds: 500));

    if (_subscriptions.containsKey(email)) {
      _subscriptions[email] = _subscriptions[email]!.copyWith(
        status: SubscriptionStatus.pending,
      );
    }

    // Simulate email sent
    print('Mock: Unsubscription confirmation email sent to $email');
  }

  @override
  Future<void> confirmSubscription(String oobCode) async {
    await Future.delayed(const Duration(milliseconds: 500));

    // For demo, just confirm the first pending subscription
    final pendingEmail = _subscriptions.entries
        .where((e) => e.value.status == SubscriptionStatus.pending)
        .firstOrNull
        ?.key;

    if (pendingEmail != null) {
      _subscriptions[pendingEmail] = _subscriptions[pendingEmail]!.copyWith(
        status: SubscriptionStatus.confirmed,
        confirmedAt: DateTime.now(),
      );
    }
  }

  @override
  Future<void> confirmUnsubscription(String oobCode) async {
    await Future.delayed(const Duration(milliseconds: 500));

    // For demo, remove the subscription
    final pendingEmail = _subscriptions.entries
        .where((e) => e.value.status == SubscriptionStatus.pending)
        .firstOrNull
        ?.key;

    if (pendingEmail != null) {
      _subscriptions.remove(pendingEmail);
    }
  }

  @override
  Future<SubscriptionStatus> getSubscriptionStatus(String email) async {
    await Future.delayed(const Duration(milliseconds: 200));

    return _subscriptions[email]?.status ?? SubscriptionStatus.unsubscribed;
  }

  @override
  Future<List<EmailSubscription>> getConfirmedSubscribers() async {
    await Future.delayed(const Duration(milliseconds: 300));

    return _subscriptions.values
        .where((s) => s.status == SubscriptionStatus.confirmed)
        .toList();
  }

  @override
  Future<void> updateLastCity(String email, String city) async {
    await Future.delayed(const Duration(milliseconds: 200));

    if (_subscriptions.containsKey(email)) {
      _subscriptions[email] = _subscriptions[email]!.copyWith(
        lastCity: city,
      );
    }
  }
}
