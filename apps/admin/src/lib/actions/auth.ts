"use server";

import { redirect } from "next/navigation";

import { adminConfig } from "@/lib/config";
import { clearSessionToken, encodeDevBearer, fetchSession, writeSessionToken } from "@/lib/session";

export interface SignInState {
  error: string | null;
}

/**
 * Dev-mode sign-in: exchanges an admin uid/email for a dev bearer token, then
 * verifies it against the API before storing it. Firebase sign-in replaces
 * this form when ADMIN_AUTH_MODE=firebase (later stage).
 */
export async function signInWithDevIdentity(_prev: SignInState, formData: FormData): Promise<SignInState> {
  if (adminConfig.authMode !== "dev") {
    return { error: "Dev sign-in is disabled. Configure Firebase sign-in for this environment." };
  }

  const uid = String(formData.get("uid") ?? "").trim();
  const email = String(formData.get("email") ?? "").trim();
  if (!uid) return { error: "Admin uid is required." };
  if (!email || !email.includes("@")) return { error: "A valid email is required." };

  const token = encodeDevBearer(uid, email);
  const session = await fetchSession(token);
  if (!session.ok) {
    if (session.unreachable) return { error: session.error.message };
    if (session.status === 403) {
      return { error: "No active admin account matches that identity. Run `pnpm db:seed` to create the default super admin." };
    }
    return { error: session.error.message };
  }

  await writeSessionToken(token);
  redirect("/");
}

export async function signOut(): Promise<void> {
  await clearSessionToken();
  redirect("/sign-in");
}
