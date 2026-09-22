export async function callNextLoginAPI({ email, password, token, uid }) {
  try {
    const response = await fetch('/api/auth/login', {
      method: 'POST',
      headers: {
        'x-email': email,
        'x-password': password,
        'x-token': token,
        'x-uid': uid
      },
      credentials: 'include' // 🔥 Required for cookie
    })

    const data = await response.json()

    return data
  } catch (error) {
    return {
      success: false,
      error: 'Something went wrong'
    }
  }
}
