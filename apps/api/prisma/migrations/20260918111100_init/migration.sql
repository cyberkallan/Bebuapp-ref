-- CreateEnum
CREATE TYPE "TenantStatus" AS ENUM ('ACTIVE', 'SUSPENDED', 'ARCHIVED');

-- CreateEnum
CREATE TYPE "AdminRole" AS ENUM ('SUPER_ADMIN', 'TENANT_ADMIN', 'TENANT_STAFF');

-- CreateEnum
CREATE TYPE "AccountStatus" AS ENUM ('ACTIVE', 'BLOCKED', 'DELETED');

-- CreateEnum
CREATE TYPE "Gender" AS ENUM ('FEMALE', 'MALE', 'NON_BINARY', 'UNDISCLOSED');

-- CreateEnum
CREATE TYPE "ClientPlatform" AS ENUM ('ANDROID', 'IOS', 'WEB');

-- CreateEnum
CREATE TYPE "CallerStatus" AS ENUM ('PENDING_REVIEW', 'APPROVED', 'REJECTED', 'SUSPENDED');

-- CreateEnum
CREATE TYPE "WalletKind" AS ENUM ('USER', 'CALLER_EARNINGS', 'PLATFORM_REVENUE');

-- CreateEnum
CREATE TYPE "WalletTransactionType" AS ENUM ('PURCHASE', 'BONUS', 'CALL_CHARGE', 'CALL_EARNING', 'PLATFORM_COMMISSION', 'REFUND', 'HOLD', 'HOLD_RELEASE', 'PAYOUT', 'PAYOUT_REVERSAL', 'ADMIN_ADJUSTMENT', 'CHARGEBACK');

-- CreateEnum
CREATE TYPE "LedgerDirection" AS ENUM ('CREDIT', 'DEBIT');

-- CreateEnum
CREATE TYPE "WalletTransactionStatus" AS ENUM ('PENDING', 'POSTED', 'REVERSED', 'FAILED');

-- CreateEnum
CREATE TYPE "LedgerReferenceType" AS ENUM ('PAYMENT_ORDER', 'CALL', 'CALL_BILLING_INTERVAL', 'PAYOUT_REQUEST', 'ADMIN_ACTION', 'PROMOTION');

-- CreateEnum
CREATE TYPE "ActorType" AS ENUM ('USER', 'ADMIN', 'SYSTEM');

-- CreateEnum
CREATE TYPE "PaymentProviderKind" AS ENUM ('WEB', 'GOOGLE_PLAY', 'APPLE_IAP', 'MANUAL');

-- CreateEnum
CREATE TYPE "PaymentOrderStatus" AS ENUM ('CREATED', 'PENDING_VERIFICATION', 'COMPLETED', 'FAILED', 'CANCELLED', 'EXPIRED', 'REFUNDED', 'CHARGED_BACK');

-- CreateEnum
CREATE TYPE "PayoutStatus" AS ENUM ('REQUESTED', 'APPROVED', 'PAID', 'REJECTED', 'FAILED');

-- CreateEnum
CREATE TYPE "CallType" AS ENUM ('AUDIO', 'VIDEO');

-- CreateEnum
CREATE TYPE "CallMode" AS ENUM ('PRIVATE', 'RANDOM');

-- CreateEnum
CREATE TYPE "CallState" AS ENUM ('REQUESTED', 'RINGING', 'ACCEPTED', 'CONNECTING', 'CONNECTED', 'BILLING', 'ENDING', 'COMPLETED', 'REJECTED', 'MISSED', 'CANCELLED', 'FAILED', 'INSUFFICIENT_BALANCE', 'TIMEOUT');

-- CreateEnum
CREATE TYPE "CallEndReason" AS ENUM ('CALLER_HUNG_UP', 'CALLEE_HUNG_UP', 'INSUFFICIENT_BALANCE', 'NETWORK_LOST', 'RING_TIMEOUT', 'CONNECT_TIMEOUT', 'REJECTED', 'CANCELLED', 'MODERATION', 'SERVER_ERROR');

-- CreateEnum
CREATE TYPE "BillingIntervalStatus" AS ENUM ('CHARGED', 'FAILED_INSUFFICIENT', 'REFUNDED');

-- CreateEnum
CREATE TYPE "ReportReason" AS ENUM ('HARASSMENT', 'SEXUAL_CONTENT', 'SCAM_OR_FRAUD', 'UNDERAGE', 'HATE_SPEECH', 'SPAM', 'IMPERSONATION', 'OTHER');

-- CreateEnum
CREATE TYPE "ReportStatus" AS ENUM ('OPEN', 'UNDER_REVIEW', 'ACTION_TAKEN', 'DISMISSED');

-- CreateEnum
CREATE TYPE "ModerationAction" AS ENUM ('WARN', 'TEMPORARY_BLOCK', 'PERMANENT_BLOCK', 'CALLER_SUSPEND', 'CONTENT_REMOVED', 'NO_ACTION');

-- CreateEnum
CREATE TYPE "NotificationCategory" AS ENUM ('CALL', 'WALLET', 'AVAILABILITY', 'PROMOTION', 'ACCOUNT');

-- CreateEnum
CREATE TYPE "NotificationOrigin" AS ENUM ('SYSTEM', 'CALLER_AUTHORED');

-- CreateEnum
CREATE TYPE "NotificationDeliveryStatus" AS ENUM ('QUEUED', 'SENT', 'SUPPRESSED', 'FAILED');

-- CreateTable
CREATE TABLE "tenants" (
    "id" UUID NOT NULL,
    "key" VARCHAR(64) NOT NULL,
    "name" VARCHAR(80) NOT NULL,
    "status" "TenantStatus" NOT NULL DEFAULT 'ACTIVE',
    "androidPackageName" VARCHAR(160),
    "iosBundleId" VARCHAR(160),
    "supportedCountries" TEXT[] DEFAULT ARRAY[]::TEXT[],
    "branding" JSONB NOT NULL DEFAULT '{}',
    "legal" JSONB NOT NULL DEFAULT '{}',
    "featureFlags" JSONB NOT NULL DEFAULT '{}',
    "pricing" JSONB NOT NULL DEFAULT '{}',
    "notificationConfig" JSONB NOT NULL DEFAULT '{}',
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMPTZ(3) NOT NULL,

    CONSTRAINT "tenants_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "admin_accounts" (
    "id" UUID NOT NULL,
    "firebaseUid" VARCHAR(128) NOT NULL,
    "email" VARCHAR(320) NOT NULL,
    "displayName" VARCHAR(120) NOT NULL,
    "role" "AdminRole" NOT NULL,
    "tenantId" UUID,
    "status" "AccountStatus" NOT NULL DEFAULT 'ACTIVE',
    "lastLoginAt" TIMESTAMPTZ(3),
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMPTZ(3) NOT NULL,

    CONSTRAINT "admin_accounts_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "users" (
    "id" UUID NOT NULL,
    "tenantId" UUID NOT NULL,
    "firebaseUid" VARCHAR(128) NOT NULL,
    "authProvider" VARCHAR(40),
    "email" VARCHAR(320),
    "phoneNumber" VARCHAR(32),
    "displayName" VARCHAR(80) NOT NULL DEFAULT '',
    "avatarUrl" VARCHAR(1024),
    "gender" "Gender" NOT NULL DEFAULT 'UNDISCLOSED',
    "birthDate" DATE,
    "country" VARCHAR(2),
    "language" VARCHAR(16),
    "status" "AccountStatus" NOT NULL DEFAULT 'ACTIVE',
    "blockedReason" VARCHAR(500),
    "notificationPreferences" JSONB NOT NULL DEFAULT '{}',
    "lastActiveAt" TIMESTAMPTZ(3),
    "deletedAt" TIMESTAMPTZ(3),
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMPTZ(3) NOT NULL,

    CONSTRAINT "users_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "devices" (
    "id" UUID NOT NULL,
    "tenantId" UUID NOT NULL,
    "userId" UUID NOT NULL,
    "platform" "ClientPlatform" NOT NULL,
    "fcmToken" VARCHAR(512) NOT NULL,
    "appVersion" VARCHAR(32),
    "locale" VARCHAR(16),
    "timezone" VARCHAR(64),
    "lastSeenAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "devices_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "caller_profiles" (
    "id" UUID NOT NULL,
    "tenantId" UUID NOT NULL,
    "userId" UUID NOT NULL,
    "status" "CallerStatus" NOT NULL DEFAULT 'PENDING_REVIEW',
    "displayName" VARCHAR(80) NOT NULL,
    "bio" VARCHAR(2000) NOT NULL DEFAULT '',
    "languages" TEXT[] DEFAULT ARRAY[]::TEXT[],
    "topics" TEXT[] DEFAULT ARRAY[]::TEXT[],
    "privateAudioPerMinute" INTEGER NOT NULL DEFAULT 0,
    "privateVideoPerMinute" INTEGER NOT NULL DEFAULT 0,
    "randomAudioPerMinute" INTEGER NOT NULL DEFAULT 0,
    "randomVideoPerMinute" INTEGER NOT NULL DEFAULT 0,
    "ratingSum" INTEGER NOT NULL DEFAULT 0,
    "ratingCount" INTEGER NOT NULL DEFAULT 0,
    "totalCalls" INTEGER NOT NULL DEFAULT 0,
    "totalBilledSeconds" BIGINT NOT NULL DEFAULT 0,
    "sharedAcrossTenants" BOOLEAN NOT NULL DEFAULT false,
    "verificationDocuments" JSONB NOT NULL DEFAULT '[]',
    "rejectionReason" VARCHAR(500),
    "reviewedAt" TIMESTAMPTZ(3),
    "reviewedByAdminId" UUID,
    "lastOnlineAt" TIMESTAMPTZ(3),
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMPTZ(3) NOT NULL,

    CONSTRAINT "caller_profiles_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "caller_tenant_visibility" (
    "callerProfileId" UUID NOT NULL,
    "tenantId" UUID NOT NULL,
    "enabled" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "caller_tenant_visibility_pkey" PRIMARY KEY ("callerProfileId","tenantId")
);

-- CreateTable
CREATE TABLE "wallets" (
    "id" UUID NOT NULL,
    "tenantId" UUID NOT NULL,
    "kind" "WalletKind" NOT NULL,
    "userId" UUID,
    "balance" BIGINT NOT NULL DEFAULT 0,
    "heldBalance" BIGINT NOT NULL DEFAULT 0,
    "version" INTEGER NOT NULL DEFAULT 0,
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMPTZ(3) NOT NULL,

    CONSTRAINT "wallets_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "wallet_transactions" (
    "id" UUID NOT NULL,
    "tenantId" UUID NOT NULL,
    "walletId" UUID NOT NULL,
    "type" "WalletTransactionType" NOT NULL,
    "direction" "LedgerDirection" NOT NULL,
    "amount" BIGINT NOT NULL,
    "balanceBefore" BIGINT NOT NULL,
    "balanceAfter" BIGINT NOT NULL,
    "referenceType" "LedgerReferenceType",
    "referenceId" UUID,
    "idempotencyKey" VARCHAR(160) NOT NULL,
    "status" "WalletTransactionStatus" NOT NULL DEFAULT 'POSTED',
    "actorType" "ActorType" NOT NULL,
    "actorId" UUID,
    "metadata" JSONB NOT NULL DEFAULT '{}',
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "wallet_transactions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "coin_packages" (
    "id" UUID NOT NULL,
    "tenantId" UUID NOT NULL,
    "name" VARCHAR(80) NOT NULL,
    "coins" INTEGER NOT NULL,
    "bonusCoins" INTEGER NOT NULL DEFAULT 0,
    "priceMinorUnits" INTEGER NOT NULL,
    "currency" VARCHAR(3) NOT NULL,
    "googlePlayProductId" VARCHAR(160),
    "appleProductId" VARCHAR(160),
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "isPopular" BOOLEAN NOT NULL DEFAULT false,
    "sortOrder" INTEGER NOT NULL DEFAULT 0,
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMPTZ(3) NOT NULL,

    CONSTRAINT "coin_packages_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "payment_orders" (
    "id" UUID NOT NULL,
    "tenantId" UUID NOT NULL,
    "userId" UUID NOT NULL,
    "coinPackageId" UUID NOT NULL,
    "provider" "PaymentProviderKind" NOT NULL,
    "platform" "ClientPlatform" NOT NULL,
    "status" "PaymentOrderStatus" NOT NULL DEFAULT 'CREATED',
    "coins" INTEGER NOT NULL,
    "amountMinorUnits" INTEGER NOT NULL,
    "currency" VARCHAR(3) NOT NULL,
    "providerOrderId" VARCHAR(255),
    "idempotencyKey" VARCHAR(160) NOT NULL,
    "walletTransactionId" UUID,
    "failureReason" VARCHAR(500),
    "expiresAt" TIMESTAMPTZ(3),
    "completedAt" TIMESTAMPTZ(3),
    "metadata" JSONB NOT NULL DEFAULT '{}',
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMPTZ(3) NOT NULL,

    CONSTRAINT "payment_orders_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "payment_events" (
    "id" UUID NOT NULL,
    "tenantId" UUID,
    "paymentOrderId" UUID,
    "provider" "PaymentProviderKind" NOT NULL,
    "providerEventId" VARCHAR(255) NOT NULL,
    "eventType" VARCHAR(120) NOT NULL,
    "payload" JSONB NOT NULL,
    "signatureValid" BOOLEAN NOT NULL,
    "processedAt" TIMESTAMPTZ(3),
    "processingError" VARCHAR(1000),
    "receivedAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "payment_events_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "payout_requests" (
    "id" UUID NOT NULL,
    "tenantId" UUID NOT NULL,
    "callerProfileId" UUID NOT NULL,
    "coins" BIGINT NOT NULL,
    "amountMinorUnits" INTEGER NOT NULL,
    "currency" VARCHAR(3) NOT NULL,
    "status" "PayoutStatus" NOT NULL DEFAULT 'REQUESTED',
    "payoutMethod" JSONB NOT NULL DEFAULT '{}',
    "walletTransactionId" UUID,
    "reviewedByAdminId" UUID,
    "reviewedAt" TIMESTAMPTZ(3),
    "reviewNote" VARCHAR(500),
    "paidAt" TIMESTAMPTZ(3),
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMPTZ(3) NOT NULL,

    CONSTRAINT "payout_requests_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "calls" (
    "id" UUID NOT NULL,
    "tenantId" UUID NOT NULL,
    "userId" UUID NOT NULL,
    "callerProfileId" UUID NOT NULL,
    "type" "CallType" NOT NULL,
    "mode" "CallMode" NOT NULL,
    "state" "CallState" NOT NULL DEFAULT 'REQUESTED',
    "endReason" "CallEndReason",
    "ratePerMinute" INTEGER NOT NULL,
    "commissionBps" INTEGER NOT NULL,
    "agoraChannelName" VARCHAR(64) NOT NULL,
    "userAgoraUid" INTEGER NOT NULL,
    "callerAgoraUid" INTEGER NOT NULL,
    "requestedAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "ringingAt" TIMESTAMPTZ(3),
    "acceptedAt" TIMESTAMPTZ(3),
    "connectedAt" TIMESTAMPTZ(3),
    "endedAt" TIMESTAMPTZ(3),
    "billedSeconds" INTEGER NOT NULL DEFAULT 0,
    "totalCharged" BIGINT NOT NULL DEFAULT 0,
    "callerEarnings" BIGINT NOT NULL DEFAULT 0,
    "platformCommission" BIGINT NOT NULL DEFAULT 0,
    "idempotencyKey" VARCHAR(160) NOT NULL,
    "stateVersion" INTEGER NOT NULL DEFAULT 0,
    "metadata" JSONB NOT NULL DEFAULT '{}',
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMPTZ(3) NOT NULL,

    CONSTRAINT "calls_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "call_billing_intervals" (
    "id" UUID NOT NULL,
    "callId" UUID NOT NULL,
    "intervalIndex" INTEGER NOT NULL,
    "startsAt" TIMESTAMPTZ(3) NOT NULL,
    "endsAt" TIMESTAMPTZ(3) NOT NULL,
    "amount" INTEGER NOT NULL,
    "callerAmount" INTEGER NOT NULL,
    "platformAmount" INTEGER NOT NULL,
    "status" "BillingIntervalStatus" NOT NULL,
    "chargeTransactionId" UUID,
    "earningTransactionId" UUID,
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "call_billing_intervals_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "call_state_transitions" (
    "id" UUID NOT NULL,
    "callId" UUID NOT NULL,
    "fromState" "CallState" NOT NULL,
    "toState" "CallState" NOT NULL,
    "actorType" "ActorType" NOT NULL,
    "actorId" UUID,
    "reason" VARCHAR(255),
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "call_state_transitions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ratings" (
    "id" UUID NOT NULL,
    "tenantId" UUID NOT NULL,
    "callId" UUID NOT NULL,
    "userId" UUID NOT NULL,
    "callerProfileId" UUID NOT NULL,
    "score" INTEGER NOT NULL,
    "comment" VARCHAR(1000),
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "ratings_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "reports" (
    "id" UUID NOT NULL,
    "tenantId" UUID NOT NULL,
    "reporterUserId" UUID NOT NULL,
    "reportedUserId" UUID NOT NULL,
    "callId" UUID,
    "reason" "ReportReason" NOT NULL,
    "description" VARCHAR(2000),
    "status" "ReportStatus" NOT NULL DEFAULT 'OPEN',
    "actionTaken" "ModerationAction",
    "resolutionNote" VARCHAR(1000),
    "resolvedByAdminId" UUID,
    "resolvedAt" TIMESTAMPTZ(3),
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMPTZ(3) NOT NULL,

    CONSTRAINT "reports_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "audit_logs" (
    "id" UUID NOT NULL,
    "tenantId" UUID,
    "actorType" "ActorType" NOT NULL,
    "actorId" UUID,
    "action" VARCHAR(80) NOT NULL,
    "targetType" VARCHAR(80) NOT NULL,
    "targetId" VARCHAR(160),
    "before" JSONB,
    "after" JSONB,
    "reason" VARCHAR(1000),
    "requestId" VARCHAR(64),
    "ipAddress" VARCHAR(64),
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "audit_logs_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "notification_logs" (
    "id" UUID NOT NULL,
    "tenantId" UUID NOT NULL,
    "userId" UUID NOT NULL,
    "category" "NotificationCategory" NOT NULL,
    "origin" "NotificationOrigin" NOT NULL,
    "triggerEvent" VARCHAR(64),
    "templateKey" VARCHAR(120) NOT NULL,
    "status" "NotificationDeliveryStatus" NOT NULL,
    "suppressionReason" VARCHAR(64),
    "deviceId" UUID,
    "providerMessageId" VARCHAR(255),
    "payload" JSONB NOT NULL DEFAULT '{}',
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "notification_logs_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "tenants_key_key" ON "tenants"("key");

-- CreateIndex
CREATE INDEX "tenants_status_idx" ON "tenants"("status");

-- CreateIndex
CREATE UNIQUE INDEX "admin_accounts_firebaseUid_key" ON "admin_accounts"("firebaseUid");

-- CreateIndex
CREATE INDEX "admin_accounts_tenantId_role_idx" ON "admin_accounts"("tenantId", "role");

-- CreateIndex
CREATE INDEX "users_tenantId_status_idx" ON "users"("tenantId", "status");

-- CreateIndex
CREATE INDEX "users_tenantId_createdAt_idx" ON "users"("tenantId", "createdAt" DESC);

-- CreateIndex
CREATE INDEX "users_tenantId_lastActiveAt_idx" ON "users"("tenantId", "lastActiveAt");

-- CreateIndex
CREATE UNIQUE INDEX "users_tenantId_firebaseUid_key" ON "users"("tenantId", "firebaseUid");

-- CreateIndex
CREATE UNIQUE INDEX "devices_fcmToken_key" ON "devices"("fcmToken");

-- CreateIndex
CREATE INDEX "devices_userId_idx" ON "devices"("userId");

-- CreateIndex
CREATE UNIQUE INDEX "caller_profiles_userId_key" ON "caller_profiles"("userId");

-- CreateIndex
CREATE INDEX "caller_profiles_tenantId_status_idx" ON "caller_profiles"("tenantId", "status");

-- CreateIndex
CREATE INDEX "caller_profiles_status_sharedAcrossTenants_idx" ON "caller_profiles"("status", "sharedAcrossTenants");

-- CreateIndex
CREATE INDEX "caller_tenant_visibility_tenantId_enabled_idx" ON "caller_tenant_visibility"("tenantId", "enabled");

-- CreateIndex
CREATE UNIQUE INDEX "wallets_tenantId_kind_userId_key" ON "wallets"("tenantId", "kind", "userId");

-- CreateIndex
CREATE INDEX "wallet_transactions_walletId_createdAt_idx" ON "wallet_transactions"("walletId", "createdAt" DESC);

-- CreateIndex
CREATE INDEX "wallet_transactions_tenantId_referenceType_referenceId_idx" ON "wallet_transactions"("tenantId", "referenceType", "referenceId");

-- CreateIndex
CREATE INDEX "wallet_transactions_tenantId_type_createdAt_idx" ON "wallet_transactions"("tenantId", "type", "createdAt" DESC);

-- CreateIndex
CREATE UNIQUE INDEX "wallet_transactions_tenantId_idempotencyKey_key" ON "wallet_transactions"("tenantId", "idempotencyKey");

-- CreateIndex
CREATE INDEX "coin_packages_tenantId_isActive_sortOrder_idx" ON "coin_packages"("tenantId", "isActive", "sortOrder");

-- CreateIndex
CREATE UNIQUE INDEX "payment_orders_walletTransactionId_key" ON "payment_orders"("walletTransactionId");

-- CreateIndex
CREATE INDEX "payment_orders_tenantId_userId_createdAt_idx" ON "payment_orders"("tenantId", "userId", "createdAt" DESC);

-- CreateIndex
CREATE INDEX "payment_orders_tenantId_status_idx" ON "payment_orders"("tenantId", "status");

-- CreateIndex
CREATE UNIQUE INDEX "payment_orders_tenantId_userId_idempotencyKey_key" ON "payment_orders"("tenantId", "userId", "idempotencyKey");

-- CreateIndex
CREATE UNIQUE INDEX "payment_orders_provider_providerOrderId_key" ON "payment_orders"("provider", "providerOrderId");

-- CreateIndex
CREATE INDEX "payment_events_paymentOrderId_idx" ON "payment_events"("paymentOrderId");

-- CreateIndex
CREATE UNIQUE INDEX "payment_events_provider_providerEventId_key" ON "payment_events"("provider", "providerEventId");

-- CreateIndex
CREATE UNIQUE INDEX "payout_requests_walletTransactionId_key" ON "payout_requests"("walletTransactionId");

-- CreateIndex
CREATE INDEX "payout_requests_tenantId_status_createdAt_idx" ON "payout_requests"("tenantId", "status", "createdAt" DESC);

-- CreateIndex
CREATE INDEX "payout_requests_callerProfileId_idx" ON "payout_requests"("callerProfileId");

-- CreateIndex
CREATE UNIQUE INDEX "calls_agoraChannelName_key" ON "calls"("agoraChannelName");

-- CreateIndex
CREATE INDEX "calls_tenantId_userId_createdAt_idx" ON "calls"("tenantId", "userId", "createdAt" DESC);

-- CreateIndex
CREATE INDEX "calls_tenantId_callerProfileId_createdAt_idx" ON "calls"("tenantId", "callerProfileId", "createdAt" DESC);

-- CreateIndex
CREATE INDEX "calls_tenantId_state_idx" ON "calls"("tenantId", "state");

-- CreateIndex
CREATE UNIQUE INDEX "calls_tenantId_userId_idempotencyKey_key" ON "calls"("tenantId", "userId", "idempotencyKey");

-- CreateIndex
CREATE UNIQUE INDEX "call_billing_intervals_callId_intervalIndex_key" ON "call_billing_intervals"("callId", "intervalIndex");

-- CreateIndex
CREATE INDEX "call_state_transitions_callId_createdAt_idx" ON "call_state_transitions"("callId", "createdAt");

-- CreateIndex
CREATE UNIQUE INDEX "ratings_callId_key" ON "ratings"("callId");

-- CreateIndex
CREATE INDEX "ratings_callerProfileId_createdAt_idx" ON "ratings"("callerProfileId", "createdAt" DESC);

-- CreateIndex
CREATE INDEX "reports_tenantId_status_createdAt_idx" ON "reports"("tenantId", "status", "createdAt" DESC);

-- CreateIndex
CREATE INDEX "reports_reportedUserId_idx" ON "reports"("reportedUserId");

-- CreateIndex
CREATE INDEX "audit_logs_tenantId_createdAt_idx" ON "audit_logs"("tenantId", "createdAt" DESC);

-- CreateIndex
CREATE INDEX "audit_logs_actorId_createdAt_idx" ON "audit_logs"("actorId", "createdAt" DESC);

-- CreateIndex
CREATE INDEX "audit_logs_targetType_targetId_idx" ON "audit_logs"("targetType", "targetId");

-- CreateIndex
CREATE INDEX "notification_logs_userId_createdAt_idx" ON "notification_logs"("userId", "createdAt" DESC);

-- CreateIndex
CREATE INDEX "notification_logs_tenantId_triggerEvent_createdAt_idx" ON "notification_logs"("tenantId", "triggerEvent", "createdAt" DESC);

-- AddForeignKey
ALTER TABLE "admin_accounts" ADD CONSTRAINT "admin_accounts_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES "tenants"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "users" ADD CONSTRAINT "users_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES "tenants"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "devices" ADD CONSTRAINT "devices_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES "tenants"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "devices" ADD CONSTRAINT "devices_userId_fkey" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "caller_profiles" ADD CONSTRAINT "caller_profiles_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES "tenants"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "caller_profiles" ADD CONSTRAINT "caller_profiles_userId_fkey" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "caller_tenant_visibility" ADD CONSTRAINT "caller_tenant_visibility_callerProfileId_fkey" FOREIGN KEY ("callerProfileId") REFERENCES "caller_profiles"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "caller_tenant_visibility" ADD CONSTRAINT "caller_tenant_visibility_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES "tenants"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "wallets" ADD CONSTRAINT "wallets_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES "tenants"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "wallets" ADD CONSTRAINT "wallets_userId_fkey" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "wallet_transactions" ADD CONSTRAINT "wallet_transactions_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES "tenants"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "wallet_transactions" ADD CONSTRAINT "wallet_transactions_walletId_fkey" FOREIGN KEY ("walletId") REFERENCES "wallets"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "coin_packages" ADD CONSTRAINT "coin_packages_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES "tenants"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "payment_orders" ADD CONSTRAINT "payment_orders_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES "tenants"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "payment_orders" ADD CONSTRAINT "payment_orders_userId_fkey" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "payment_orders" ADD CONSTRAINT "payment_orders_coinPackageId_fkey" FOREIGN KEY ("coinPackageId") REFERENCES "coin_packages"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "payment_orders" ADD CONSTRAINT "payment_orders_walletTransactionId_fkey" FOREIGN KEY ("walletTransactionId") REFERENCES "wallet_transactions"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "payment_events" ADD CONSTRAINT "payment_events_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES "tenants"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "payment_events" ADD CONSTRAINT "payment_events_paymentOrderId_fkey" FOREIGN KEY ("paymentOrderId") REFERENCES "payment_orders"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "payout_requests" ADD CONSTRAINT "payout_requests_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES "tenants"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "payout_requests" ADD CONSTRAINT "payout_requests_callerProfileId_fkey" FOREIGN KEY ("callerProfileId") REFERENCES "caller_profiles"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "payout_requests" ADD CONSTRAINT "payout_requests_walletTransactionId_fkey" FOREIGN KEY ("walletTransactionId") REFERENCES "wallet_transactions"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "calls" ADD CONSTRAINT "calls_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES "tenants"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "calls" ADD CONSTRAINT "calls_userId_fkey" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "calls" ADD CONSTRAINT "calls_callerProfileId_fkey" FOREIGN KEY ("callerProfileId") REFERENCES "caller_profiles"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "call_billing_intervals" ADD CONSTRAINT "call_billing_intervals_callId_fkey" FOREIGN KEY ("callId") REFERENCES "calls"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "call_billing_intervals" ADD CONSTRAINT "call_billing_intervals_chargeTransactionId_fkey" FOREIGN KEY ("chargeTransactionId") REFERENCES "wallet_transactions"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "call_billing_intervals" ADD CONSTRAINT "call_billing_intervals_earningTransactionId_fkey" FOREIGN KEY ("earningTransactionId") REFERENCES "wallet_transactions"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "call_state_transitions" ADD CONSTRAINT "call_state_transitions_callId_fkey" FOREIGN KEY ("callId") REFERENCES "calls"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ratings" ADD CONSTRAINT "ratings_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES "tenants"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ratings" ADD CONSTRAINT "ratings_callId_fkey" FOREIGN KEY ("callId") REFERENCES "calls"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ratings" ADD CONSTRAINT "ratings_userId_fkey" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ratings" ADD CONSTRAINT "ratings_callerProfileId_fkey" FOREIGN KEY ("callerProfileId") REFERENCES "caller_profiles"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "reports" ADD CONSTRAINT "reports_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES "tenants"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "reports" ADD CONSTRAINT "reports_reporterUserId_fkey" FOREIGN KEY ("reporterUserId") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "reports" ADD CONSTRAINT "reports_reportedUserId_fkey" FOREIGN KEY ("reportedUserId") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "reports" ADD CONSTRAINT "reports_callId_fkey" FOREIGN KEY ("callId") REFERENCES "calls"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "audit_logs" ADD CONSTRAINT "audit_logs_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES "tenants"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "notification_logs" ADD CONSTRAINT "notification_logs_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES "tenants"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "notification_logs" ADD CONSTRAINT "notification_logs_userId_fkey" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;
