/**
 * Development/staging seed. Idempotent: safe to run repeatedly.
 *
 * Creates:
 *  - the `bebu` tenant (https://bebuapp.in/) with sane defaults
 *  - a SUPER_ADMIN account bound to SEED_SUPER_ADMIN_FIREBASE_UID
 *    (defaults to the dev-auth uid "dev-super-admin")
 *  - three sample coin packages
 *
 * Never run against production with default values.
 */
import { PrismaPg } from '@prisma/adapter-pg';

import { loadRootEnv } from '../src/config/load-env.js';
import { PrismaClient } from '../src/generated/prisma/client.js';

loadRootEnv();

const databaseUrl = process.env['DATABASE_URL'];
if (!databaseUrl) throw new Error('DATABASE_URL is required');

const prisma = new PrismaClient({ adapter: new PrismaPg({ connectionString: databaseUrl }) });

const SUPER_ADMIN_UID = process.env['SEED_SUPER_ADMIN_FIREBASE_UID'] ?? 'dev-super-admin';
const SUPER_ADMIN_EMAIL = process.env['SEED_SUPER_ADMIN_EMAIL'] ?? 'admin@bebuapp.in';

async function main(): Promise<void> {
  const tenant = await prisma.tenant.upsert({
    where: { key: 'bebu' },
    update: {},
    create: {
      key: 'bebu',
      name: 'bebu',
      androidPackageName: 'in.bebuapp.android',
      iosBundleId: 'in.bebuapp.ios',
      supportedCountries: ['IN'],
      branding: {
        displayName: 'bebu',
        logoUrl: null,
        primaryColor: '#7c3aed',
        secondaryColor: '#111827',
        accentColor: '#f59e0b',
      },
      legal: {
        privacyPolicyUrl: 'https://bebuapp.in/privacy',
        termsUrl: 'https://bebuapp.in/terms',
        supportUrl: 'https://bebuapp.in/support',
        refundPolicyUrl: 'https://bebuapp.in/refunds',
      },
      featureFlags: {
        voiceCalls: true,
        videoCalls: true,
        randomMatching: true,
        becomeCaller: true,
      },
      pricing: {
        currency: 'INR',
        platformCommissionBps: 3000,
        defaultAudioRatePerMinute: 10,
        defaultVideoRatePerMinute: 20,
        minimumBalanceToCall: 10,
        minimumPayoutCoins: 1000,
      },
    },
  });

  await prisma.adminAccount.upsert({
    where: { firebaseUid: SUPER_ADMIN_UID },
    update: { email: SUPER_ADMIN_EMAIL },
    create: {
      firebaseUid: SUPER_ADMIN_UID,
      email: SUPER_ADMIN_EMAIL,
      displayName: 'Platform Admin',
      role: 'SUPER_ADMIN',
      tenantId: null,
    },
  });

  const packages = [
    {
      name: 'Starter',
      coins: 100,
      bonusCoins: 0,
      priceMinorUnits: 9_900,
      sortOrder: 1,
      isPopular: false,
    },
    {
      name: 'Popular',
      coins: 550,
      bonusCoins: 50,
      priceMinorUnits: 49_900,
      sortOrder: 2,
      isPopular: true,
    },
    {
      name: 'Pro',
      coins: 1_200,
      bonusCoins: 200,
      priceMinorUnits: 99_900,
      sortOrder: 3,
      isPopular: false,
    },
  ];
  for (const pkg of packages) {
    const existing = await prisma.coinPackage.findFirst({
      where: { tenantId: tenant.id, name: pkg.name },
    });
    if (!existing) {
      await prisma.coinPackage.create({ data: { ...pkg, tenantId: tenant.id, currency: 'INR' } });
    }
  }

  console.warn(
    `seeded tenant "${tenant.key}" (${tenant.id}) and super admin uid "${SUPER_ADMIN_UID}"`,
  );
}

main()
  .catch((err: unknown) => {
    console.error(err);
    process.exitCode = 1;
  })
  .finally(() => prisma.$disconnect());
