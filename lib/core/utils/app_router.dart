import 'package:go_router/go_router.dart';

import '../../features/splash/splash_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/authentication/login_screen.dart';
import '../../features/authentication/register_screen.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/emergency_contacts/emergency_contacts_screen.dart';
import '../../features/device_monitoring/device_monitoring_screen.dart';
import '../../features/profile/personal_information_screen.dart';
import '../../features/notifications/notifications_screen.dart';
import '../../features/support/help_support_screen.dart';
import '../../features/support/faq_screen.dart';
import '../../features/support/device_setup_screen.dart';
import '../../features/support/troubleshooting_screen.dart';
import '../../features/support/report_problem_screen.dart';
import '../../features/settings/account_security_screen.dart';
import '../../features/settings/privacy_policy_screen.dart';
import '../../features/settings/terms_conditions_screen.dart';

import '../../features/settings/app_permissions_screen.dart';

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      // Splash
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),

      // Onboarding
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),

      // Authentication
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),

      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),

      // Main application
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),

      // Emergency Contacts
      GoRoute(
        path: '/emergency-contacts',
        builder: (context, state) => const EmergencyContactsScreen(),
      ),

      GoRoute(
        path: '/terms-conditions',
        builder: (context, state) => const TermsConditionsScreen(),
      ),

      GoRoute(
        path: '/troubleshooting',
        builder: (context, state) => const TroubleshootingScreen(),
      ),

      GoRoute(
        path: '/app-permissions',
        builder: (context, state) => const AppPermissionsScreen(),
      ),

      GoRoute(
        path: '/privacy-policy',
        builder: (context, state) => const PrivacyPolicyScreen(),
      ),

      GoRoute(
        path: '/device-monitoring',
        builder: (context, state) => const DeviceMonitoringScreen(),
      ),

      GoRoute(
        path: '/account-security',
        builder: (context, state) => const AccountSecurityScreen(),
      ),

      GoRoute(
        path: '/personal-information',
        builder: (context, state) => const PersonalInformationScreen(),
      ),

      GoRoute(
        path: '/report-problem',
        builder: (context, state) => const ReportProblemScreen(),
      ),

      GoRoute(
        path: '/device-setup',
        builder: (context, state) => const DeviceSetupScreen(),
      ),

      GoRoute(
        path: '/help-support',
        builder: (context, state) => const HelpSupportScreen(),
      ),

      GoRoute(path: '/faq', builder: (context, state) => const FaqScreen()),

      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
    ],
  );
}
