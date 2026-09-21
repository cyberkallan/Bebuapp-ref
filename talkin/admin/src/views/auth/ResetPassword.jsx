'use client'

// React Imports
import { useState, useEffect } from 'react'

// Next Imports
import Link from 'next/link'
import { useRouter, useSearchParams } from 'next/navigation'

// MUI Imports
import useMediaQuery from '@mui/material/useMediaQuery'
import { styled, useTheme } from '@mui/material/styles'
import Typography from '@mui/material/Typography'
import Button from '@mui/material/Button'
import Alert from '@mui/material/Alert'
import IconButton from '@mui/material/IconButton'
import InputAdornment from '@mui/material/InputAdornment'

// Form & Validation Imports
import { useForm } from 'react-hook-form'
import { yupResolver } from '@hookform/resolvers/yup'
import * as yup from 'yup'

// Third-party Imports
import axios from 'axios'
import classnames from 'classnames'
import { toast } from 'react-toastify'
import { confirmPasswordReset, verifyPasswordResetCode } from 'firebase/auth'

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
const ResetPasswordIllustration = styled('img')(({ theme }) => ({
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
  password: yup.string().min(6, 'Password must be at least 6 characters').required('Password is required'),
  confirmPassword: yup
    .string()
    .oneOf([yup.ref('password')], 'Passwords must match')
    .required('Confirm password is required')
})

const ResetPassword = ({ mode }) => {
  // States
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState(null)
  const [success, setSuccess] = useState(false)
  const [showPassword, setShowPassword] = useState(false)
  const [showConfirmPassword, setShowConfirmPassword] = useState(false)
  const [oobCode, setOobCode] = useState(null)
  const [isValidCode, setIsValidCode] = useState(false)
  const [validatingCode, setValidatingCode] = useState(true)
  const [email, setEmail] = useState('')

  // Vars
  const darkImg = '/images/pages/auth-mask-dark.png'
  const lightImg = '/images/pages/auth-mask-light.png'
  const darkIllustration = '/images/illustrations/auth/v2-reset-password-dark.png'
  const lightIllustration = '/images/illustrations/auth/v2-reset-password-light.png'
  const forgetPasswordImage = '/images/forgetpassword.png'

  // Hooks
  const router = useRouter()
  const searchParams = useSearchParams()
  const { settings } = useSettings()
  const theme = useTheme()
  const hidden = useMediaQuery(theme.breakpoints.down('md'))
  const authBackground = useImageVariant(mode, lightImg, darkImg)
  const characterIllustration = useImageVariant(mode, lightIllustration, darkIllustration)

  // Form handling
  const {
    register,
    handleSubmit,
    formState: { errors }
  } = useForm({ resolver: yupResolver(schema) })

  // Toggle password visibility
  const handleClickShowPassword = () => setShowPassword(show => !show)
  const handleClickShowConfirmPassword = () => setShowConfirmPassword(show => !show)

  // Validate the reset code when component mounts
  useEffect(() => {
    const code = searchParams.get('oobCode')

    if (!code) {
      setValidatingCode(false)
      setError('Invalid or expired password reset link')

      return
    }

    setOobCode(code)

    // Verify the code is valid
    verifyPasswordResetCode(auth, code)
      .then(email => {
        setEmail(email)
        setIsValidCode(true)
        setValidatingCode(false)
      })
      .catch(err => {
        console.error('Error verifying reset code:', err)
        setError('Invalid or expired password reset link')
        setValidatingCode(false)
      })
  }, [searchParams])

  const onSubmit = async data => {
    if (!isValidCode || !oobCode) {
      setError('Invalid or expired password reset link')

      return
    }

    setLoading(true)
    setError(null)

    try {
      // Reset password in Firebase
      await confirmPasswordReset(auth, oobCode, data.password)

      // Reset password in your backend
      await axios.patch(
        `${baseURL}/api/admin/confirmPasswordReset`,
        {
          newPassword: data.password,
          confirmPassword: data.confirmPassword
        },
        {
          headers: {
            key: secretKey
          },
          params: {
            email
          }
        }
      )

      setSuccess(true)
      toast.success('Password has been reset successfully!')

      // Redirect to login after 3 seconds
      setTimeout(() => {
        router.replace('/login')
      }, 3000)
    } catch (err) {
      console.error('Password reset error:', err)
      setError(err?.message || 'Failed to reset password. Please try again.')
    } finally {
      setLoading(false)
    }
  }

  // if (validatingCode) {
  //   return (
  //     <div className='flex justify-center items-center min-bs-[100dvh]'>
  //       <Typography>Verifying reset link...</Typography>
  //     </div>
  //   )
  // }

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
        <ResetPasswordIllustration
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
            <Typography variant='h4'>Reset Password 🔒</Typography>
            <Typography>Your new password must be different from previously used passwords</Typography>
          </div>

          {/* Show success/error messages */}
          {error && <Alert severity='error'>{error}</Alert>}
          {success && <Alert severity='success'>Password reset successfully! Redirecting to login page...</Alert>}

          {isValidCode && !success && (
            <form noValidate autoComplete='off' onSubmit={handleSubmit(onSubmit)} className='flex flex-col gap-6'>
              <CustomTextField
                autoFocus
                fullWidth
                label='New Password'
                placeholder='············'
                type={showPassword ? 'text' : 'password'}
                {...register('password')}
                error={!!errors.password}
                helperText={errors.password?.message}
                slotProps={{
                  input: {
                    endAdornment: (
                      <InputAdornment position='end'>
                        <IconButton edge='end' onClick={handleClickShowPassword} onMouseDown={e => e.preventDefault()}>
                          <i className={showPassword ? 'tabler-eye-off' : 'tabler-eye'} />
                        </IconButton>
                      </InputAdornment>
                    )
                  }
                }}
              />
              <CustomTextField
                fullWidth
                label='Confirm Password'
                placeholder='············'
                type={showConfirmPassword ? 'text' : 'password'}
                {...register('confirmPassword')}
                error={!!errors.confirmPassword}
                helperText={errors.confirmPassword?.message}
                slotProps={{
                  input: {
                    endAdornment: (
                      <InputAdornment position='end'>
                        <IconButton
                          edge='end'
                          onClick={handleClickShowConfirmPassword}
                          onMouseDown={e => e.preventDefault()}
                        >
                          <i className={showConfirmPassword ? 'tabler-eye-off' : 'tabler-eye'} />
                        </IconButton>
                      </InputAdornment>
                    )
                  }
                }}
              />
              <Button fullWidth variant='contained' type='submit' disabled={loading}>
                {loading ? 'Processing...' : 'Set New Password'}
              </Button>
              <Typography className='flex justify-center items-center' color='primary.main'>
                <Link href={'/login'} className='flex items-center gap-1.5'>
                  <i className='tabler-chevron-left' />
                  <span>Back to login</span>
                </Link>
              </Typography>
            </form>
          )}
        </div>
        </div>
      </div>
    </div>
  )
}

export default ResetPassword
