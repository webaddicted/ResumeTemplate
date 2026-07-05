import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:template/global/utils/global_utility.dart';

/// Base Service class for GetX Services
/// 
/// Services are typically used for:
/// - API calls
/// - Database operations
/// - Device services (camera, location, etc.)
/// - Third-party integrations
/// 
/// Usage:
/// ```dart
/// class MyService extends BaseService {
///   @override
///   Future<void> onServiceInit() async {
///     // Async initialization - optional
///   }
///
///   @override
///   void onServiceClose() {
///     // Cleanup - optional
///   }
/// }
/// ```
/// 
/// Register in binding:
/// ```dart
/// Get.lazyPut<MyService>(() => MyService());
/// // OR for permanent service
/// Get.put(MyService(), permanent: true);
/// ```
abstract class BaseService extends GetxService {
  bool _isInitialized = false;
  bool _isInitializing = false;
  Exception? _initException;

  /// Check if service is initialized
  bool get isInitialized => _isInitialized;

  /// Check if service is currently initializing
  bool get isInitializing => _isInitializing;

  /// Get initialization exception if any
  Exception? get initException => _initException;

  /// Check if initialization failed
  bool get hasInitError => _initException != null;

  // ============ LIFECYCLE METHODS ============

  /// Override for async initialization - called after onInit (ON DEMAND)
  @protected
  Future<void> onServiceInit() async {}

  /// Override for cleanup - called before onClose (ON DEMAND)
  @protected
  void onServiceClose() {}

  /// Called when initialization fails - override if needed (ON DEMAND)
  @protected
  void onInitError(Exception e) {
    printLog(msg:'${runtimeType.toString()} initialization failed: $e');
  }

  @override
  void onInit() {
    super.onInit();
    _initialize();
  }

  @override
  void onClose() {
    onServiceClose();
    super.onClose();
  }

  Future<void> _initialize() async {
    if (_isInitialized || _isInitializing) return;

    _isInitializing = true;
    try {
      await onServiceInit();
      _isInitialized = true;
      _initException = null;
    } catch (e) {
      _initException = e is Exception ? e : Exception(e.toString());
      onInitError(_initException!);
    } finally {
      _isInitializing = false;
    }
  }

  // ============ UTILITY METHODS ============

  /// Wait until service is initialized
  /// Useful when you need to ensure service is ready before using
  Future<void> ensureInitialized() async {
    if (_isInitialized) return;
    
    // Wait for initialization to complete
    while (_isInitializing) {
      await Future.delayed(const Duration(milliseconds: 50));
    }

    if (!_isInitialized && _initException != null) {
      throw _initException!;
    }
  }

  /// Reinitialize service (useful after error or for refresh)
  Future<void> reinitialize() async {
    _isInitialized = false;
    _initException = null;
    await _initialize();
  }

  /// Execute an async operation with error handling
  Future<T?> execute<T>({
    required Future<T> Function() action,
    Function(Exception)? onError,
  }) async {
    try {
      return await action();
    } catch (e) {
      final exception = e is Exception ? e : Exception(e.toString());
      onError?.call(exception);
      return null;
    }
  }

  /// Log debug message (only in debug mode)
  void logDebug(String message) {
    if (kDebugMode) {
      printLog(msg:'[${runtimeType.toString()}] $message');
    }
  }

  /// Log error message
  void logError(String message, [Object? error]) {
    printLog(msg:'[${runtimeType.toString()}] ERROR: $message');
    if (error != null) {
      printLog(msg:'[${runtimeType.toString()}] $error');
    }
  }
}

/// Mixin for services that need periodic tasks
mixin PeriodicServiceMixin on BaseService {
  final List<_PeriodicTask> _periodicTasks = [];

  /// Start a periodic task
  void startPeriodicTask(
    String taskId,
    Duration interval,
    Future<void> Function() task,
  ) {
    // Cancel existing task with same ID
    cancelPeriodicTask(taskId);

    final periodicTask = _PeriodicTask(
      id: taskId,
      interval: interval,
      task: task,
    );
    _periodicTasks.add(periodicTask);
    periodicTask.start();
  }

  /// Cancel a periodic task
  void cancelPeriodicTask(String taskId) {
    final index = _periodicTasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      _periodicTasks[index].cancel();
      _periodicTasks.removeAt(index);
    }
  }

  /// Cancel all periodic tasks
  void cancelAllPeriodicTasks() {
    for (final task in _periodicTasks) {
      task.cancel();
    }
    _periodicTasks.clear();
  }

  @override
  void onServiceClose() {
    cancelAllPeriodicTasks();
    super.onServiceClose();
  }
}

class _PeriodicTask {
  final String id;
  final Duration interval;
  final Future<void> Function() task;
  bool _isRunning = false;
  bool _isCancelled = false;

  _PeriodicTask({
    required this.id,
    required this.interval,
    required this.task,
  });

  void start() {
    _runLoop();
  }

  void cancel() {
    _isCancelled = true;
  }

  Future<void> _runLoop() async {
    while (!_isCancelled) {
      if (!_isRunning) {
        _isRunning = true;
        try {
          await task();
        } catch (e) {
          printLog(msg:'Periodic task $id error: $e');
        } finally {
          _isRunning = false;
        }
      }
      await Future.delayed(interval);
    }
  }
}
