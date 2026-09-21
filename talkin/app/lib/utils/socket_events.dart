class SocketEvents {
  static const sendMessage = "messageDispatched";
  static const markMessageSeen = "markMessageSeen";

  /// call user
  static const callOutgoingRinging = "callOutgoingRinging";

  /// out going call
  static const outGoingCall = "callEstablished";

  /// incoming call
  static const incomingCall = "incomingCall";

  /// call response receive or decline
  static const callResponseProcessed = "callResponseProcessed";

  /// call response false
  static const callDeclined = "callDeclined";

  /// call response true
  static const callAnswered = "callAnswered";

  /// call time out
  static const callTimedOut = "callTimedOut";

  /// caller call cut
  static const callerCallCut = "callRejected";

  /// call receiver call cut
  static const callEnded = "callEnded";

  /// call cut
  static const callTerminated = "callTerminated";

  /// random call ringing
  static const randomCallRinging = "incomingRingingStarted";

  /// call cut summary data
  static const callCutData = "callSummary";

  /// coin cut call
  static const callCoinsDeducted = "callCoinsDeducted";
  static const notEnoughCoins = "notEnoughCoins";
}
