/// Extremely small service locator for app-wide singletons.
///
/// This is intentionally minimal and does not attempt to be a full DI framework.
final Map<Type, Object> _services = <Type, Object>{};

/// Register a singleton instance for type [T].
void registerSingleton<T extends Object>(T instance) {
  _services[T] = instance;
}

/// Retrieve a previously registered singleton of type [T].
T getIt<T extends Object>() {
  final Object? service = _services[T];
  if (service == null) {
    throw StateError('Service of type $T has not been registered.');
  }
  return service as T;
}

/// Clear all registered services.
void resetServiceLocator() {
  _services.clear();
}

