import { NextResponse } from "next/server";

export async function GET() {
  const response = NextResponse.json({ success: true });

  // Clear token cookie
  response.headers.set("Set-Cookie", "token=; Path=/; HttpOnly; Secure; SameSite=Strict; Max-Age=0");

  return response;
}
