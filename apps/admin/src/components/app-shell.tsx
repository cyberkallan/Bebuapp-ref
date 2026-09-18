"use client";

import { LogOut, Menu, X } from "lucide-react";
import { useState } from "react";

import { BrandMark } from "@/components/brand-mark";
import { SidebarNav } from "@/components/sidebar-nav";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Separator } from "@/components/ui/separator";
import type { AdminSession } from "@/lib/session";

interface AppShellProps {
  session: AdminSession;
  environment: string;
  authMode: string;
  signOutAction: () => Promise<void>;
  children: React.ReactNode;
}

export function AppShell({ session, environment, authMode, signOutAction, children }: AppShellProps) {
  const [open, setOpen] = useState(false);
  const roleLabel = session.roles.map(humanizeRole).join(", ");

  const sidebar = (
    <div className="flex h-full flex-col gap-6 p-4">
      <div className="flex items-center justify-between">
        <BrandMark />
        <Button
          variant="ghost"
          size="icon-sm"
          className="lg:hidden"
          aria-label="Close navigation"
          onClick={() => setOpen(false)}
        >
          <X />
        </Button>
      </div>
      <SidebarNav onNavigate={() => setOpen(false)} />
      <div className="mt-auto space-y-3">
        <Separator />
        <div className="space-y-1 px-1 text-xs">
          <p className="truncate font-medium">{session.email ?? session.adminId}</p>
          <p className="text-muted-foreground">{roleLabel}</p>
          <p className="text-muted-foreground">
            Scope: {session.tenantId ? <span className="font-mono">{session.tenantId.slice(0, 8)}…</span> : "all applications"}
          </p>
        </div>
        <form action={signOutAction}>
          <Button type="submit" variant="outline" size="sm" className="w-full">
            <LogOut data-icon="inline-start" /> Sign out
          </Button>
        </form>
      </div>
    </div>
  );

  return (
    <div className="flex min-h-screen w-full">
      <aside className="hidden w-64 shrink-0 border-r bg-sidebar text-sidebar-foreground lg:block">
        <div className="sticky top-0 h-screen">{sidebar}</div>
      </aside>

      {open ? (
        <div className="fixed inset-0 z-40 lg:hidden">
          <button
            type="button"
            aria-label="Close navigation"
            className="absolute inset-0 bg-black/40"
            onClick={() => setOpen(false)}
          />
          <aside className="absolute inset-y-0 left-0 w-72 border-r bg-sidebar text-sidebar-foreground shadow-xl">
            {sidebar}
          </aside>
        </div>
      ) : null}

      <div className="flex min-w-0 flex-1 flex-col">
        <header className="sticky top-0 z-30 flex h-14 items-center gap-3 border-b bg-background/80 px-4 backdrop-blur sm:px-6">
          <Button
            variant="ghost"
            size="icon-sm"
            className="lg:hidden"
            aria-label="Open navigation"
            onClick={() => setOpen(true)}
          >
            <Menu />
          </Button>
          <div className="lg:hidden">
            <BrandMark />
          </div>
          <div className="ml-auto flex items-center gap-2">
            <Badge variant="outline" className="font-mono">
              {environment}
            </Badge>
            <Badge variant={authMode === "dev" ? "destructive" : "secondary"}>
              auth: {authMode}
            </Badge>
          </div>
        </header>
        <main className="flex-1 px-4 py-6 sm:px-6 lg:px-8">{children}</main>
      </div>
    </div>
  );
}

function humanizeRole(role: string): string {
  return role.toLowerCase().replaceAll("_", " ");
}
