'use client'

import { useState, useEffect } from 'react'

import { useRouter, useSearchParams } from 'next/navigation'

import { useDispatch } from 'react-redux'

// Form & Validation Imports
import { useForm } from 'react-hook-form'
import { yupResolver } from '@hookform/resolvers/yup'
import * as yup from 'yup'

// MUI Imports
import useMediaQuery from '@mui/material/useMediaQuery'
import { styled, useTheme } from '@mui/material/styles'
import Typography from '@mui/material/Typography'
import IconButton from '@mui/material/IconButton'
import InputAdornment from '@mui/material/InputAdornment'
import Checkbox from '@mui/material/Checkbox'
import Button from '@mui/material/Button'
import FormControlLabel from '@mui/material/FormControlLabel'
import Alert from '@mui/material/Alert'
import classNames from 'classnames'
import { Box, CircularProgress } from '@mui/material'

// Third-party Imports
import { toast } from 'react-toastify'
import { signInWithEmailAndPassword, onAuthStateChanged } from 'firebase/auth'

import axios from 'axios'

import { auth } from '@/libs/firebase'

// Component Imports
import Link from '@components/Link'
import Logo from '@components/layout/shared/Logo'
import CustomTextField from '@core/components/mui/TextField'

// Config Imports
import themeConfig from '@configs/themeConfig'

// Hooks
import { useImageVariant } from '@core/hooks/useImageVariant'
import { useSettings } from '@core/hooks/useSettings'
import { loginAdmin } from '@/redux-store/slices/admin'




// Auth Utils
import { setRememberMe } from '@/utils/firebase-auth'
import { baseURL, projectName } from '@/config'


// Styled Custom Components
const LoginIllustration = styled('div')(({ theme }) => ({
  zIndex: 2,
  width: '100%',
  height: '100%',
  display: 'flex',
  alignItems: 'center',
  justifyContent: 'center'
}))

const PhotoContainer = styled('div')({
  width: '100%',
  position: 'relative',
  height: '100%',
  display: 'flex',
  alignItems: 'center',
  justifyContent: 'center'
})

const MainImage = styled('img')({
  width: '100%',

  // objectFit: 'contain',
  height: '100dvh',
  objectFit: 'cover'

  // borderRadius: '16px'
})

// Validation Schema
const schema = yup.object().shape({
  email: yup.string().email('Invalid email format').required('Email is required'),
  password: yup.string().min(5, 'Password must be at least 5 characters').required('Password is required')
})

// Firebase Error Messages
const firebaseErrorMessages = {
  'auth/user-not-found': 'User does not exist.',
  'auth/wrong-password': 'Invalid password.',
  'auth/invalid-email': 'Invalid email address.',
  'auth/too-many-requests': 'Too many login attempts. Please try again later.',
  'auth/network-request-failed': 'Network error. Please check your connection.',
  'auth/invalid-credential': 'Invalid credentials. Please check your email and password.'
}

const LoginV2 = ({ mode }) => {
  // States
  const [isPasswordShown, setIsPasswordShown] = useState(false)
  const [error, setError] = useState(null)
  const [loadingActualLogin, setLoadingActualLogin] = useState(false)
  const [checkingAuth, setCheckingAuth] = useState(true)
  const [rememberMe, setRememberMeState] = useState(false)

  // Vars
  const darkImg = '/images/pages/auth-mask-dark.png'
  const lightImg = '/images/pages/auth-mask-light.png'

  // Hooks
  const dispatch = useDispatch()
  const router = useRouter()
  const searchParams = useSearchParams()
  const { settings } = useSettings()
  const theme = useTheme()
  const hidden = useMediaQuery(theme.breakpoints.down('md'))
  const authBackground = useImageVariant(mode, lightImg, darkImg)

    // const checkLogin = async ()=>{
  
    //   const  response  = await axios.get(`${baseURL}/api/admin/login`);
  
    //   if(response.data.login){
    //      router.replace('/login')
    //   }else{
    //      router.replace('/register')
    //   }
    // }

    // useEffect(()=>{
    //   checkLogin()
    // },[])
  

  // Form Handling
  const {
    register,
    handleSubmit,
    formState: { errors }
  } = useForm({
    resolver: yupResolver(schema),
    defaultValues: {
      email: '',
      password: ''
    }
  })

  // Check authentication status when component mounts
  useEffect(() => {
    const unsubscribe = onAuthStateChanged(auth, async user => {
      if (user) {
        // Only proceed with auto-login if we're not in a login flow
        const manualLoginInProgress = sessionStorage.getItem('manual_login_in_progress')

        if (manualLoginInProgress) {
          // We're in the middle of a manual login flow, don't redirect
          setCheckingAuth(false)

          return
        }

        try {
          // Check if we have valid credentials in localStorage
          const storedUid = localStorage.getItem('uid')
          const storedToken = localStorage.getItem('admin_token')

          if (storedUid && storedToken) {
            // Verify token with backend before auto-redirecting
            const token = await user.getIdToken(true)

            if (token === storedToken) {
              // Valid token, redirect to dashboard
              const redirectURL = searchParams.get('redirectTo') ?? '/dashboard'

              router.replace(redirectURL)

              return
            }
          }

          // If we get here, tokens are invalid or missing
          setCheckingAuth(false)
        } catch (error) {
          console.error('Error during auth check:', error)
          setCheckingAuth(false)
        }
      } else {
        // User is not logged in
        setCheckingAuth(false)
      }
    })

    return () => unsubscribe() // Cleanup subscription on unmount
  }, [router, searchParams])

  // Toggle Password Visibility
  const handleClickShowPassword = () => setIsPasswordShown(prev => !prev)

  // Handle Remember Me change
  const handleRememberMeChange = event => {
    setRememberMeState(event.target.checked)
  }



  // Handle login (shared function for both login types)
  const handleLogin = async (credentials) => {
    

    setError(null)

    // Set flag to prevent auto-redirect during manual login
    sessionStorage.setItem('manual_login_in_progress', 'true')

    try {
      // Firebase authentication
      const userCredential = await signInWithEmailAndPassword(auth, credentials.email, credentials.password)
      const firebaseUser = userCredential.user
      const token = await firebaseUser.getIdToken()
      const uid = firebaseUser.uid

      if (typeof window !== 'undefined') {
        localStorage.setItem('uid', uid)
        localStorage.setItem('admin_token', token)

        // document.cookie = `admin_token=${token}; path=/; max-age=86400; SameSite=Strict; Secure`;
        // document.cookie = `uid=${uid}; path=/; max-age=86400; SameSite=Strict; Secure`;
      }

      try {
        // Backend authentication
        const response = await dispatch(
          loginAdmin({
            email: credentials.email,
            password: credentials.password
          })
        )

        if (!response.payload || !response.payload.status) {
          throw new Error('Authentication failed on server')
        }

        // Success! Store credentials
        localStorage.setItem('uid', uid)
        localStorage.setItem('admin_token', token)

        // document.cookie = `admin_token=${token}; path=/; max-age=86400; SameSite=Strict; Secure`;
        // document.cookie = `uid=${uid}; path=/; max-age=86400; SameSite=Strict; Secure`;

        // Store remember me preference
        setRememberMe(rememberMe)

        // Clear manual login flag
        sessionStorage.removeItem('manual_login_in_progress')

        toast.success('Login successful!')

        // Redirect to dashboard
        const redirectURL = searchParams.get('redirectTo') ?? '/dashboard'

        router.replace(redirectURL)
      } catch (backendError) {
        console.log('Backend Login Error:', backendError)

        // Sign out from Firebase on backend error
        await auth.signOut()

        // Clear stored credentials
        localStorage.removeItem('uid')
        localStorage.removeItem('admin_token')

        setError(backendError.message || 'Server authentication failed. Please try again later.')
      }
    } catch (firebaseError) {
      console.log('Firebase Login Error:', firebaseError)

      const errorCode = firebaseError?.code
      const errorMessage = firebaseErrorMessages[errorCode] || 'Login failed. Please check your credentials.'

      setError(errorMessage)
    } finally {
     
      
    }
  }

  // Handle Actual Login Submit
  const onSubmit = data => {
    handleLogin(data, false)
  }

  // Show loading state while checking authentication
  if (checkingAuth) {
    return (
      <div className='flex justify-center items-center min-bs-[100dvh]'>
        <CircularProgress />
      </div>
    )
  }

  return (
    <div className='flex bs-full justify-center overflow-hidden'>
      <div
        className={classNames(
          'flex bs-full items-center justify-center flex-1 min-bs-[100dvh] relative p-0 max-md:hidden',
          {
            'border-ie': settings.skin === 'bordered'
          }
        )}
      >
        {/* <SidebarBackground /> */}
        <LoginIllustration>
          <PhotoContainer >
            <div className=''>
            <img

              src='/images/illustrations/auth/login5.png'
              className='p-14 rounded-3xl'

              // src='/images/illustrations/auth/login-bg.webp'
              alt='login collage'
              style={{ width: '100%', height: '99dvh' }}
              width={100}
              height={100}
            />
            </div>
          
          </PhotoContainer>
        </LoginIllustration>
        {/* {!hidden && <MaskImg alt='mask' src={authBackground} />} */}
      </div>
      <div className='flex justify-center items-center bs-full bg-backgroundPaper p-6 md:px-16 w-full md:is-[50dvw]'>
        <div className='flex flex-col gap-3 is-[55%]'>
          <div className='flex'>
            <img src='/images/logo/talkin-logo.png' alt={projectName || ""} className='h-20' />
          </div>
          <Typography variant='h3' className='font-bold'>
            Login to your account
          </Typography>

          <Typography variant='body1' className='text-left'>
            Let&apos;s connect, chat, and spark real connections. Enter your credentials to continue your journey on {projectName}.
          </Typography>

          {/* Show Errors */}
          {error && <Alert severity='error'>{error}</Alert>}

          <form noValidate autoComplete='off' onSubmit={handleSubmit(onSubmit)} className='flex flex-col gap-5'>
            {/* Email Input */}
            <div>
              <Typography variant='body2' className='mb-2 text-left'>
                Enter your Email
              </Typography>
              {/* border bottom primary */}
              <CustomTextField
                fullWidth
                placeholder='Enter your mail here'
                {...register('email')}
                error={!!errors.email}
                helperText={errors.email?.message}
                sx={{
                  '& .MuiInputBase-root': {
                    borderBottom: '2px solid',
                    borderBottomColor: theme => theme.palette.primary.main,
                    borderRadius: 0
                  },
                  '& .MuiOutlinedInput-notchedOutline': {
                    border: 'none'
                  }
                }}
                slotProps={{
                  input: {
                    startAdornment: (
                      <InputAdornment position='start'>
                        <i className='tabler-mail' />
                      </InputAdornment>
                    )
                  }
                }}
              />
            </div>

            {/* Password Input */}
            <div>
              <Typography variant='body2' className='mb-2 text-left'>
                Enter your Password
              </Typography>
              <CustomTextField
                fullWidth
                placeholder='Type your password here'
                type={isPasswordShown ? 'text' : 'password'}
                {...register('password')}
                error={!!errors.password}
                helperText={errors.password?.message}
                slotProps={{
                  input: {
                    endAdornment: (
                      <InputAdornment position='end'>
                        <IconButton edge='end' onClick={handleClickShowPassword} onMouseDown={e => e.preventDefault()}>
                          <i className={isPasswordShown ? 'tabler-eye-off' : 'tabler-eye'} />
                        </IconButton>
                      </InputAdornment>
                    ),
                    startAdornment: (
                      <InputAdornment position='start'>
                        <i className='tabler-password' />
                      </InputAdornment>
                    )
                  }
                }}
              />
            </div>

            {/* Remember Me & Forgot Password */}
            <div className='flex justify-between items-center gap-x-3 gap-y-1 flex-wrap'>
              <FormControlLabel
                control={<Checkbox checked={rememberMe} onChange={handleRememberMeChange} size='small' />}
                label={<Typography variant='body2'>Remember me?</Typography>}
              />
              <Typography className='text-end' variant='body2' component={Link} href={'/forgot-password'}>
                Forgot Password ?
              </Typography>
            </div>

            {/* Login Buttons */}
            <Button
              fullWidth
              variant='contained'
              type='submit'
              disabled={loadingActualLogin}
              startIcon={loadingActualLogin ? <CircularProgress size={20} /> : null}
              sx={{ bgcolor: 'primary.main', borderRadius: '8px', py: 2.5, textTransform: 'none' }}
            >
              {loadingActualLogin ? 'Logging in...' : 'Log In'}
            </Button>

            
          </form>
        </div>
      </div>
    </div>
  )
}

export default LoginV2
