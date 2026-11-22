class LocationUploadThrottle {
  LocationUploadThrottle({
    this.minimumInterval = const Duration(seconds: 6),
    this.rateLimitedInterval = const Duration(seconds: 12),
  }) : _interval = minimumInterval;

  final Duration minimumInterval;
  final Duration rateLimitedInterval;

  Duration _interval;
  DateTime? _lastAttemptAt;
  int _consecutiveSuccesses = 0;

  Duration waitBefore(DateTime now) {
    final lastAttemptAt = _lastAttemptAt;
    if (lastAttemptAt == null) return Duration.zero;
    final remaining = _interval - now.difference(lastAttemptAt);
    return remaining.isNegative ? Duration.zero : remaining;
  }

  void recordAttempt(DateTime at) {
    _lastAttemptAt = at;
  }

  void recordRateLimit() {
    _interval = rateLimitedInterval;
    _consecutiveSuccesses = 0;
  }

  void recordSuccess() {
    _consecutiveSuccesses++;
    if (_consecutiveSuccesses >= 5) {
      _interval = minimumInterval;
    }
  }

  void recordFailure() {
    _consecutiveSuccesses = 0;
  }

  void reset() {
    _interval = minimumInterval;
    _lastAttemptAt = null;
    _consecutiveSuccesses = 0;
  }
}
