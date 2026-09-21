import NextAuth from 'next-auth'
import CredentialsProvider from 'next-auth/providers/credentials'

import jwt from 'jsonwebtoken'

import { secretKey, baseURL } from '@/config'

export const authOptions = {
  providers: [
    CredentialsProvider({
      name: 'Credentials',
      credentials: {
        email: { label: 'Email', type: 'text' },
        password: { label: 'Password', type: 'password' },
        token: { label: 'Firebase Token', type: 'text' },
        uid: { label: 'Firebase UID', type: 'text' }
      },
      async authorize(credentials) {
        const payload = {
          email: credentials.email,
          password: credentials.password
        }

        try {
          const res = await fetch(`${baseURL}/api/admin/admin/adminLogin`, {
            method: 'POST',
            headers: {
              'Content-Type': 'application/json',
              key: secretKey,
              Authorization: `Bearer ${credentials.token}`,
              'x-auth-adm': credentials.uid
            },
            body: JSON.stringify(payload)
          })

          console.log('res', res.json())

          const raw = await res.text()

          let data

          try {
            data = JSON.parse(raw)
          } catch (e) {
            console.error('❌ Failed to parse response:', raw)
            throw new Error('Invalid server response')
          }

          if (!data.status || !data.data) {
            throw new Error(data.message || 'Login failed')
          }

          const token = data.data
          const decoded = jwt.decode(token)

          // console.log('login decoded token', decoded)

          return {
            id: decoded._id,
            email: decoded.email,
            name: decoded.name || decoded.username || '',
            image: decoded.image || '', // optional
            accessToken: token,
            message: data.message,
            uid: credentials.uid
          }
        } catch (err) {
          console.error('❌ Auth Error:', err.message)
          throw new Error(err.message || 'Login failed')
        }
      }
    })
  ],

  callbacks: {
    async jwt({ token, user }) {
      if (user) {
        token.accessToken = user.accessToken
        token.email = user.email
        token.name = user.name
        token.image = user.image
        token.uid = user.uid
      }

      return token
    },
    async session({ session, token }) {
      session.accessToken = token.accessToken
      session.user.email = token.email
      session.user.name = token.name
      session.user.image = token.image
      session.user.uid = token.uid

      return session
    }
  },

  session: {
    strategy: 'jwt'
  },

  secret: process.env.NEXTAUTH_SECRET
}

const handler = NextAuth(authOptions)

export { handler as GET, handler as POST }
