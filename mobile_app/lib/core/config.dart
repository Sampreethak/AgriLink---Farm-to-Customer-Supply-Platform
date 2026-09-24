/// ==============================================================================
/// AgriLink Enterprise Configuration Module
/// ==============================================================================
/// Values are injected at compile/build time via:
/// 1. `--dart-define-from-file=.env` (Standard for Flutter 3.7+)
/// 2. Individual `--dart-define=KEY=VALUE` flags in CI/CD pipelines
/// 
/// This guarantees zero hardcoded secrets in version-controlled source files.
class AppConfig {
  // Supabase Cloud Project URL
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://nxwhnbejvwxiuekhtmpm.supabase.co',
  );

  // Supabase Anon / Publishable Public Key
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'sb_publishable__NSFd-NXvWsSDms7aE1tJQ_uziQLZO7',
  );

  // Supabase Project Reference
  static const String supabaseRef = String.fromEnvironment(
    'SUPABASE_REF',
    defaultValue: 'nxwhnbejvwxiuekhtmpm',
  );

  // FastAPI ML / Logistics Core API Gateway
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8000/api/v1',
  );

  // Environment Mode (development | staging | production)
  static const String appEnv = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'development',
  );

  static bool get isProduction => appEnv == 'production';
  static bool get isDevelopment => appEnv == 'development';
}
