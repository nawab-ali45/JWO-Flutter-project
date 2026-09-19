import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class EmailJSService {
  // ✅ Your EmailJS Configuration
  static const String serviceId = 'service_66gq9j2';
  static const String userId = 'R6TSMdVd1NKx8FlkN';

  // ✅ Template IDs
  static const String donationVerificationTemplateId = 'template_rjkxdum';
  static const String donationRejectionTemplateId = 'template_e4vrhqf';
  static const String volunteerCardTemplateId = 'template_ghtpsiv';

  // ✅ Donation Verification Email
  Future<bool> sendDonationVerification({
    required String toEmail,
    required String name,
    required String donationId,
    required double amount,
    required String donationDate,
  }) async {
    if (toEmail.isEmpty) {
      debugPrint('❌ Verification email: recipient email is empty');
      return false;
    }

    try {
      // ✅ IMPORTANT: Use 'email' parameter (not 'to_email') as per your template
      final Map<String, dynamic> templateParams = {
        'email': toEmail,  // ✅ Changed from 'to_email' to 'email'
        'name': name,
        'donation_id': donationId,
        'amount': amount.toStringAsFixed(2),
        'donation_date': donationDate,
        'status': 'Verified ✅',
        'organization': 'Jalal Welfare Organization',
        'website': 'www.jalalwelfare.org',
        'phone': '+92 341 5566663',
      };

      debugPrint('📧 Sending verification email to: $toEmail');
      debugPrint('📝 Template params: $templateParams');

      final response = await http.post(
        Uri.parse('https://api.emailjs.com/api/v1.0/email/send'),
        headers: {
          'Content-Type': 'application/json',
          'Origin': 'http://localhost',
        },
        body: jsonEncode({
          'service_id': serviceId,
          'template_id': donationVerificationTemplateId,
          'user_id': userId,
          'template_params': templateParams,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('✅ EmailJS verification email sent to $toEmail');
        debugPrint('Response: ${response.body}');
        return true;
      } else {
        debugPrint('❌ EmailJS verification error: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('❌ EmailJS verification exception: $e');
      return false;
    }
  }

  // ✅ Donation Rejection Email
  Future<bool> sendDonationRejection({
    required String toEmail,
    required String name,
    required String donationId,
  }) async {
    if (toEmail.isEmpty) {
      debugPrint('❌ Rejection email: recipient email is empty');
      return false;
    }

    try {
      // ✅ IMPORTANT: Use 'email' parameter (not 'to_email') as per your template
      final Map<String, dynamic> templateParams = {
        'email': toEmail,  // ✅ Changed from 'to_email' to 'email'
        'name': name,
        'donation_id': donationId,
        'status': 'Rejected ❌',
        'organization': 'Jalal Welfare Organization',
        'website': 'www.jalalwelfare.org',
        'phone': '+92 341 5566663',
      };

      debugPrint('📧 Sending rejection email to: $toEmail');
      debugPrint('📝 Template params: $templateParams');

      final response = await http.post(
        Uri.parse('https://api.emailjs.com/api/v1.0/email/send'),
        headers: {
          'Content-Type': 'application/json',
          'Origin': 'http://localhost',
        },
        body: jsonEncode({
          'service_id': serviceId,
          'template_id': donationRejectionTemplateId,
          'user_id': userId,
          'template_params': templateParams,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('✅ EmailJS rejection email sent to $toEmail');
        debugPrint('Response: ${response.body}');
        return true;
      } else {
        debugPrint('❌ EmailJS rejection error: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('❌ EmailJS rejection exception: $e');
      return false;
    }
  }

  // ✅ Volunteer Card Email
  Future<bool> sendVolunteerCard({
    required String toEmail,
    required String name,
    required String volunteerId,
    required String fatherName,
    required String bloodGroup,
    required String position,
    required String issueDate,
    required String expiryDate,
    String? profileImageUrl,
  }) async {
    if (toEmail.isEmpty) {
      debugPrint('❌ Volunteer email: recipient email is empty');
      return false;
    }

    try {
      // ✅ IMPORTANT: Use 'email' parameter (not 'to_email') as per your template
      final Map<String, dynamic> templateParams = {
        'email': toEmail,  // ✅ Changed from 'to_email' to 'email'
        'name': name,
        'volunteer_id': volunteerId,
        'father_name': fatherName,
        'blood_group': bloodGroup,
        'position': position,
        'issue_date': issueDate,
        'expiry_date': expiryDate,
        'photo': profileImageUrl ?? 'https://cdn-icons-png.flaticon.com/512/833/833472.png',
        'organization': 'Jalal Welfare Organization',
        'website': 'www.jalalwelfare.org',
        'phone': '+92 341 5566663',
      };

      debugPrint('📧 Sending volunteer card email to: $toEmail');
      debugPrint('📝 Template params: $templateParams');

      final response = await http.post(
        Uri.parse('https://api.emailjs.com/api/v1.0/email/send'),
        headers: {
          'Content-Type': 'application/json',
          'Origin': 'http://localhost',
        },
        body: jsonEncode({
          'service_id': serviceId,
          'template_id': volunteerCardTemplateId,
          'user_id': userId,
          'template_params': templateParams,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('✅ EmailJS volunteer email sent to $toEmail');
        debugPrint('Response: ${response.body}');
        return true;
      } else {
        debugPrint('❌ EmailJS volunteer error: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('❌ EmailJS volunteer exception: $e');
      return false;
    }
  }
}