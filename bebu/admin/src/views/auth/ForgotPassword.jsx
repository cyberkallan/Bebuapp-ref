'use client'

// Next Imports
import { useState } from 'react'

import Link from 'next/link'
import { useRouter } from 'next/navigation'

// React Imports

// MUI Imports
import useMediaQuery from '@mui/material/useMediaQuery'
import { styled, useTheme } from '@mui/material/styles'
import Typography from '@mui/material/Typography'
import Button from '@mui/material/Button'
import Alert from '@mui/material/Alert'

// Form & Validation Imports
import { useForm } from 'react-hook-form'
import { yupResolver } from '@hookform/resolvers/yup'
import * as yup from 'yup'

// Third-party Imports
import axios from 'axios'
import classnames from 'classnames'
import { toast } from 'react-toastify'
import { sendPasswordResetEmail } from 'firebase/auth'

import { auth } from '@/libs/firebase'

// Component Imports
import Logo from '@components/layout/shared/Logo'
import CustomTextField from '@core/components/mui/TextField'

// Config Imports
import { secretKey, baseURL } from '@/config'

// Hook Imports
import { useImageVariant } from '@core/hooks/useImageVariant'
import { useSettings } from '@core/hooks/useSettings'


// Styled Custom Components
const ForgotPasswordIllustration = styled('img')(({ theme }) => ({
  zIndex: 2,
  blockSize: 'auto',
  maxBlockSize: 650,
  maxInlineSize: '100%',
  margin: theme.spacing(12),
  [theme.breakpoints.down(1536)]: {
    maxBlockSize: 550
  },
  [theme.breakpoints.down('lg')]: {
    maxBlockSize: 450
  }
}))

const MaskImg = styled('img')({
  blockSize: 'auto',
  maxBlockSize: 355,
  inlineSize: '100%',
  position: 'absolute',
  insetBlockEnd: 0,
  zIndex: -1
})

// Schema for form validation
const schema = yup.object().shape({
  email: yup.string().email('Please enter a valid email').required('Email is required')
})

const ForgotPassword = ({ mode }) => {
  // States
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState(null)
  const [success, setSuccess] = useState(false)

  // Vars
  const darkImg = '/images/pages/auth-mask-dark.png'
  const lightImg = '/images/pages/auth-mask-light.png'
  const darkIllustration = '/images/illustrations/auth/v2-forgot-password-dark.png'
  const lightIllustration = '/images/illustrations/auth/v2-forgot-password-light.png'
  const forgetPasswordImage = '/images/forgetpassword1.png'

  // Hooks
  const router = useRouter()
  const { settings } = useSettings()
  const theme = useTheme()
  const hidden = useMediaQuery(theme.breakpoints.down('md'))
  const authBackground = useImageVariant(mode, lightImg, darkImg)
  const characterIllustration = useImageVariant(mode, lightIllustration, darkIllustration)

  // Form handling
  const {
    register,
    handleSubmit,
    reset,
    formState: { errors }
  } = useForm({ resolver: yupResolver(schema) })

  const checkMail = async email => {
    const response = await axios.get(`${baseURL}/api/admin/verifyAdminEmail`, {
      params: { email },
      headers: {
        key: secretKey,
        Authorization: `Bearer ${localStorage.getItem('admin_token') || ''}`,
        'x-auth-adm': localStorage.getItem('uid') || ''
      }
    })

    return response.data.status
  }

  const onSubmit = async data => {
    setLoading(true)
    setError(null)
    setSuccess(false)

    try {
      const isValidMail = await checkMail(data.email)
      
      if (isValidMail) {
        await sendPasswordResetEmail(auth, data.email)
        setSuccess(true)
        toast.success('Password reset email sent successfully!')
        reset({ email: '' })
      } else {
        setError('Admin not found with the provided email.')
      }
    } catch (err) {
      console.error('Password reset error:', err)
      setError(err?.message || 'Failed to send password reset email. Please try again.')
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className='flex bs-full justify-center'>
      {/* <div
        className={classnames(
          'flex bs-full items-center justify-center flex-1 min-bs-[100dvh] relative p-6 max-md:hidden',
          {
            'border-ie': settings.skin === 'bordered'
          }
        )}
      >
        <ForgotPasswordIllustration
          src={characterIllustration}
          alt='character-illustration'
          className={classnames({ 'scale-x-[-1]': theme.direction === 'rtl' })}
        />
        {!hidden && (
          <MaskImg
            alt='mask'
            src={authBackground}
            className={classnames({ 'scale-x-[-1]': theme.direction === 'rtl' })}
          />
        )}
      </div> */}
      {
        !hidden && (
          <>
          <div className='w-full flex justify-center items-center'>
        <img src={forgetPasswordImage} className='rounded-4xl  shadow-xl' />
      </div>
          </>
        )
      }
    
      <div className='flex justify-center items-center bs-full bg-backgroundPaper !min-is-full p-6 md:!min-is-[unset] md:p-12 w-full'>
        <div>
        <Link href={'/'} className='absolute block-start-5 sm:block-start-[33px] inline-start-6 sm:inline-start-[38px]'>
          <Logo />
        </Link>
        <div className='flex flex-col gap-6 is-full sm:is-auto md:is-full sm:max-is-[400px] md:max-is-[unset] mbs-11 sm:mbs-14 md:mbs-0'>
          <div className='flex flex-col gap-1'>
            <Typography variant='h4'>Forgot Password 🔒</Typography>
            <Typography>Enter your email and we&#39;ll send you instructions to reset your password</Typography>
          </div>

          {/* Show success/error messages */}
          {error && <Alert severity='error'>{error}</Alert>}
          {success && (
            <Alert severity='success'>Password reset email sent successfully! Please check your email inbox.</Alert>
          )}

          <form noValidate autoComplete='off' onSubmit={handleSubmit(onSubmit)} className='flex flex-col gap-6'>
            <CustomTextField
              autoFocus
              fullWidth
              label='Email'
              placeholder='Enter your email'
              {...register('email')}
              error={!!errors.email}
              helperText={errors.email?.message}
            />
            <Button fullWidth variant='contained' type='submit' disabled={loading}>
              {loading ? 'Sending...' : 'Send Reset Link'}
            </Button>
            <Typography className='flex justify-center items-center' color='primary.main'>
              <Link href={'/login'} className='flex items-center gap-1.5'>
                <i className='tabler-chevron-left' />
                <span>Back to login</span>
              </Link>
            </Typography>
          </form>
        </div>

        </div>
      </div>
    </div>
  )
}

export default ForgotPassword
