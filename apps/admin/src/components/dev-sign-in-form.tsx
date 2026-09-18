"use client";

import { useActionState } from "react";

import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { signInWithDevIdentity, type SignInState } from "@/lib/actions/auth";

const initialState: SignInState = { error: null };

export function DevSignInForm({ disabled }: { disabled: boolean }) {
  const [state, action, pending] = useActionState(signInWithDevIdentity, initialState);

  return (
    <form action={action} className="space-y-4">
      <div className="space-y-1.5">
        <Label htmlFor="uid">Admin uid</Label>
        <Input id="uid" name="uid" defaultValue="dev-super-admin" autoComplete="off" required disabled={disabled} />
        <p className="text-xs text-muted-foreground">
          The seed script creates <code className="font-mono">dev-super-admin</code> as the platform super admin.
        </p>
      </div>
      <div className="space-y-1.5">
        <Label htmlFor="email">Email</Label>
        <Input
          id="email"
          name="email"
          type="email"
          defaultValue="admin@bebuapp.in"
          autoComplete="off"
          required
          disabled={disabled}
        />
      </div>

      {state.error ? (
        <p role="alert" className="rounded-lg border border-destructive/30 bg-destructive/10 px-3 py-2 text-sm text-destructive">
          {state.error}
        </p>
      ) : null}
      {disabled ? (
        <p className="text-sm text-muted-foreground">
          Sign-in is unavailable while the API is unreachable. Start it with{" "}
          <code className="font-mono">pnpm dev:api</code>.
        </p>
      ) : null}

      <Button type="submit" className="w-full" size="lg" disabled={disabled || pending}>
        {pending ? "Signing in…" : "Sign in"}
      </Button>
    </form>
  );
}
