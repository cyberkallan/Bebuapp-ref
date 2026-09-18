import type { LucideIcon } from 'lucide-react';
import {
  Activity,
  BarChart3,
  Building2,
  Coins,
  CreditCard,
  Headset,
  PhoneCall,
  ShieldAlert,
  Users,
} from 'lucide-react';
import type { Route } from 'next';

interface BuiltNavItem {
  kind: 'route';
  href: Route;
  label: string;
  icon: LucideIcon;
}

/** Screens that exist in the roadmap but have no route yet; rendered disabled. */
interface PlannedNavItem {
  kind: 'planned';
  label: string;
  icon: LucideIcon;
  stage: string;
}

export type NavItem = BuiltNavItem | PlannedNavItem;

export const NAV_SECTIONS: { title: string; items: NavItem[] }[] = [
  {
    title: 'Platform',
    items: [
      { kind: 'route', href: '/', label: 'Overview', icon: Activity },
      { kind: 'route', href: '/tenants', label: 'Applications', icon: Building2 },
    ],
  },
  {
    title: 'Operations',
    items: [
      { kind: 'planned', label: 'Users', icon: Users, stage: 'Stage 2' },
      { kind: 'planned', label: 'Callers', icon: Headset, stage: 'Stage 2' },
      { kind: 'planned', label: 'Calls', icon: PhoneCall, stage: 'Stage 4' },
    ],
  },
  {
    title: 'Finance',
    items: [
      { kind: 'planned', label: 'Wallets & ledger', icon: Coins, stage: 'Stage 3' },
      { kind: 'planned', label: 'Payments & payouts', icon: CreditCard, stage: 'Stage 3' },
    ],
  },
  {
    title: 'Trust',
    items: [
      { kind: 'planned', label: 'Moderation', icon: ShieldAlert, stage: 'Stage 5' },
      { kind: 'planned', label: 'Analytics', icon: BarChart3, stage: 'Stage 6' },
    ],
  },
];
