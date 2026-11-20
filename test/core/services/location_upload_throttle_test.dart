import 'package:flutter_test/flutter_test.dart';
import 'package:rsc_rider/core/services/location_upload_throttle.dart';

void main() {
  test(
    'rapid fixes and retries stay below 12 requests in every 60 seconds',
    () {
      final throttle = LocationUploadThrottle();
      final attempts = <DateTime>[];
      var now = DateTime.utc(2026, 11, 15);

      for (var index = 0; index < 240; index++) {
        if (throttle.waitBefore(now) == Duration.zero) {
          throttle.recordAttempt(now);
          attempts.add(now);
        }
        now = now.add(const Duration(milliseconds: 500));
      }

      for (final end in attempts) {
        final windowStart = end.subtract(const Duration(seconds: 60));
        final requestsInWindow = attempts
            .where(
              (attempt) =>
                  attempt.isAfter(windowStart) && !attempt.isAfter(end),
            )
            .length;
        expect(requestsInWindow, lessThanOrEqualTo(12));
      }
    },
  );

  test(
    'rate limits pause uploads and the interval recovers after successes',
    () {
      final throttle = LocationUploadThrottle();
      final startedAt = DateTime.utc(2026, 11, 15);

      throttle.recordAttempt(startedAt);
      throttle.recordRateLimit();
      expect(
        throttle.waitBefore(startedAt.add(const Duration(seconds: 1))),
        const Duration(seconds: 11),
      );

      final resumedAt = startedAt.add(const Duration(seconds: 12));
      throttle.recordAttempt(resumedAt);
      for (var count = 0; count < 5; count++) {
        throttle.recordSuccess();
      }
      expect(
        throttle.waitBefore(resumedAt.add(const Duration(seconds: 6))),
        Duration.zero,
      );
    },
  );
}
