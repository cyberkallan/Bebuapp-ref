import 'dart:async';
import 'dart:developer';

import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:talk_in/utils/api.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/utils.dart';

io.Socket? socket;

/// Owns the single Socket.IO connection.
///
/// - `socketConnect()` always builds a fresh socket (`forceNew`) for the
///   current account so a stale cached manager with the previous user's
///   `globalRoom` query can never be reused after logout / role switch.
/// - `emit()` queues while offline and flushes on connect, and nudges the
///   socket to reconnect, so a message typed right after the app resumes is
///   delivered instead of being logged as "Socket Not Connected".
/// - Callers can `onConnected` to (re)bind listeners; the callback runs on
///   every connect, including automatic reconnects.
class SocketService {
  io.Socket? getSocket() => socket;

  static final List<MapEntry<String, dynamic>> _pending = [];
  static final Set<void Function()> _onConnected = {};
  static Completer<void>? _connecting;

  static bool get isConnected => socket?.connected == true;

  static String get _room =>
      "globalRoom:${Database.fetchLoginUserProfileModel?.user?.isListener == true ? Database.fetchListenerProfileModel?.data?.id : Database.loginUserId}";

  static Future<void> socketDisConnect() async {
    final s = socket;
    socket = null;
    _connecting = null;
    if (s == null) return;
    try {
      s.clearListeners();
      s.disconnect();
      s.dispose();
      Utils.showLog("Socket Listen => Socket Disconnected Called : ${s.id}");
    } catch (e) {
      Utils.showLog("Socket Listen => dispose failed: $e");
    }
  }

  static Future<void> socketConnect() async {
    log("listener id :::::: ${Database.fetchListenerProfileModel?.data?.id}");
    log("user id :::::: ${Database.loginUserId}");

    try {
      await socketDisConnect();

      final s = io.io(
        Api.baseUrl,
        io.OptionBuilder()
            .setTransports(['websocket'])
            .setQuery({"globalRoom": _room})
            .enableForceNew()
            .enableReconnection()
            .setReconnectionDelay(800)
            .setReconnectionDelayMax(8000)
            .setTimeout(15000)
            .build(),
      );
      socket = s;

      s.onConnect((_) {
        Utils.showLog("Socket Listen => Socket Connected : ${s.id}");
        for (final cb in List.of(_onConnected)) {
          try {
            cb();
          } catch (e) {
            Utils.showLog("Socket onConnected callback failed: $e");
          }
        }
        _flush();
        final c = _connecting;
        _connecting = null;
        if (c != null && !c.isCompleted) c.complete();
      });
      s.on("error", (error) => Utils.showLog("Socket Listen => Socket Error : $error"));
      s.on("connect_error", (error) => Utils.showLog("Socket Listen => Socket Connection Error : $error"));
      s.on("connect_timeout", (timeout) => Utils.showLog("Socket Listen => Socket Connection Timeout : $timeout"));
      s.on("disconnect", (reason) => Utils.showLog("Socket Listen => Socket Disconnected : $reason"));
      s.onReconnectAttempt((n) => Utils.showLog("Socket Listen => reconnect attempt $n"));

      s.connect();
    } catch (e) {
      Utils.showLog("Socket Listen => Socket Connection Error: $e");
    }
  }

  /// Register a callback that runs on every (re)connect. Idempotent per
  /// function identity, so static handlers can be added freely.
  static void onConnected(void Function() cb) => _onConnected.add(cb);

  /// Make sure a socket exists and is trying to connect. Resolves when it
  /// is connected, or after [timeout] — callers should not block on it.
  static bool _starting = false;

  static Future<void> ensureConnected({Duration timeout = const Duration(seconds: 6)}) async {
    if (isConnected) return;
    if (socket == null && !_starting) {
      _starting = true;
      try {
        await socketConnect();
      } finally {
        _starting = false;
      }
    } else if (socket != null && socket!.disconnected) {
      socket!.connect();
    }
    if (isConnected) return;
    final c = _connecting ??= Completer<void>();
    try {
      await c.future.timeout(timeout);
    } on TimeoutException {
      Utils.showLog("Socket Listen => still connecting after ${timeout.inSeconds}s");
    }
  }

  /// Emit now if connected, otherwise queue and kick a reconnect. Returns
  /// whether it went out immediately.
  static bool emit(String event, dynamic data) {
    if (isConnected) {
      socket!.emit(event, data);
      return true;
    }
    _pending.add(MapEntry(event, data));
    if (_pending.length > 50) _pending.removeAt(0);
    Utils.showLog("Socket Not Connected — queued '$event' (${_pending.length} pending)");
    ensureConnected();
    return false;
  }

  static void _flush() {
    if (_pending.isEmpty || !isConnected) return;
    final items = List.of(_pending);
    _pending.clear();
    for (final e in items) {
      socket?.emit(e.key, e.value);
    }
    Utils.showLog("Socket flushed ${items.length} queued event(s)");
  }
}
