// Deployment configuration. Values come from NEXT_PUBLIC_* variables at build
// time (see ../deploy/docker-compose.yml) so the same source builds for every
// environment without editing this file.
//
// Next.js inlines these only when accessed as literal `process.env.NAME`
// expressions, so keep the static form below.
const trimSlash = (value) => (value || '').replace(/\/+$/, '')

// Backend origin without a trailing slash, e.g. https://example.com
export const baseURL = trimSlash(process.env.NEXT_PUBLIC_BASE_URL)
export const secretKey = process.env.NEXT_PUBLIC_SECRET_KEY || ''
export const projectName = process.env.NEXT_PUBLIC_PROJECT_NAME || 'bebu'

export const firebase_apiKey = process.env.NEXT_PUBLIC_FIREBASE_API_KEY || ''
export const firebase_authDomain = process.env.NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN || ''
export const firebase_projectId = process.env.NEXT_PUBLIC_FIREBASE_PROJECT_ID || ''
export const firebase_storageBucket = process.env.NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET || ''
export const firebase_messagingSenderId = process.env.NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID || ''
export const firebase_appId = process.env.NEXT_PUBLIC_FIREBASE_APP_ID || ''
export const firebase_measurementId = process.env.NEXT_PUBLIC_FIREBASE_MEASUREMENT_ID || ''
