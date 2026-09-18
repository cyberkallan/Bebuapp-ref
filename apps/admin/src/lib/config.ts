import "server-only";

/**
 * Server-side configuration for the admin panel. Nothing here is exposed to
 * the browser: all API calls are made from Server Components / Actions so the
 * admin session token never leaves the server.
 */
export type AdminAuthMode = "dev" | "firebase";

function readAuthMode(): AdminAuthMode {
  const raw = process.env.ADMIN_AUTH_MODE ?? process.env.AUTH_MODE ?? "dev";
  if (raw === "firebase") return "firebase";
  if (process.env.NODE_ENV === "production") {
    // Fail closed: a production deployment must opt in to a real identity provider.
    throw new Error("ADMIN_AUTH_MODE=dev is not allowed in production; set ADMIN_AUTH_MODE=firebase");
  }
  return "dev";
}

export const adminConfig = {
  /** Base URL of the bebu API (no trailing slash). */
  apiUrl: (process.env.BEBU_API_URL ?? "http://127.0.0.1:4180").replace(/\/$/, ""),
  /**
   * Evaluated lazily so `next build` (which runs with NODE_ENV=production) can
   * analyse the module graph without a configured identity provider.
   */
  get authMode(): AdminAuthMode {
    return readAuthMode();
  },
  sessionCookie: "bebu_admin_session",
  /** Upper bound for any single API call from the panel. */
  requestTimeoutMs: 8_000,
};
