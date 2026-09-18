/**
 * Redis key layout for live presence and availability (all ephemeral).
 * Keys are built with RedisService.key(...) which prepends the env prefix.
 *
 *  presence:user:<userId>                 -> "1"      EX heartbeat TTL
 *  presence:caller:<callerId>             -> availability JSON, EX heartbeat TTL
 *  avail:<tenantId>:<callType>            -> ZSET callerId -> score (ranking)
 *  activecall:user:<userId>               -> callId   (busy marker)
 *  activecall:caller:<callerId>           -> callId   (busy marker)
 *  call:<callId>                          -> live call snapshot JSON
 */
export const PresenceKey = {
  user: (userId: string) => ['presence', 'user', userId] as const,
  caller: (callerId: string) => ['presence', 'caller', callerId] as const,
  availableSet: (tenantId: string, callType: 'AUDIO' | 'VIDEO') =>
    ['avail', tenantId, callType] as const,
  activeCallForUser: (userId: string) => ['activecall', 'user', userId] as const,
  activeCallForCaller: (callerId: string) => ['activecall', 'caller', callerId] as const,
  callSnapshot: (callId: string) => ['call', callId] as const,
} as const;

/** Heartbeat interval clients use; presence expires after 2 missed beats. */
export const PRESENCE_HEARTBEAT_SECONDS = 20;
export const PRESENCE_TTL_SECONDS = PRESENCE_HEARTBEAT_SECONDS * 2 + 5;
