// Component Imports
import Register from '@views/auth/Register'

// Server Action Imports
import { getServerMode } from '@core/utils/serverHelpers'
import Registration from '@/views/auth/Registration'

export const metadata = {
  title: 'Register',
  description: 'Register to your account'
}

const RegisterPage = async () => {
  // Vars
  const mode = await getServerMode()

  return <Registration/>
}

export default RegisterPage
