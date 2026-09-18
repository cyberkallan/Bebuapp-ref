import type { LucideIcon } from "lucide-react";
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
} from "lucide-react";

export interface NavItem {
  href: string;
  label: string;
  icon: LucideIcon;
  /** Present when the screen is not built yet; shown as a disabled entry. */
  stage?: string;
}

export const NAV_SECTIONS: { title: string; items: NavItem[] }[] = [
  {
    title: "Platform",
    items: [
      { href: "/", label: "Overview", icon: Activity },
      { href: "/tenants", label: "Applications", icon: Building2 },
    ],
  },
  {
    title: "Operations",
    items: [
      { href: "/users", label: "Users", icon: Users, stage: "Stage 2" },
      { href: "/callers", label: "Callers", icon: Headset, stage: "Stage 2" },
      { href: "/calls", label: "Calls", icon: PhoneCall, stage: "Stage 4" },
    ],
  },
  {
    title: "Finance",
    items: [
      { href: "/wallets", label: "Wallets & ledger", icon: Coins, stage: "Stage 3" },
      { href: "/payments", label: "Payments & payouts", icon: CreditCard, stage: "Stage 3" },
    ],
  },
  {
    title: "Trust",
    items: [
      { href: "/moderation", label: "Moderation", icon: ShieldAlert, stage: "Stage 5" },
      { href: "/analytics", label: "Analytics", icon: BarChart3, stage: "Stage 6" },
    ],
  },
];
