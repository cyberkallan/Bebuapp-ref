'use client'

// React Imports
import { useEffect, useRef, useState } from 'react'

// Next Imports
import { useRouter } from 'next/navigation'

import { signOut as firebaseSignOut } from 'firebase/auth'

// MUI Imports
import { styled } from '@mui/material/styles'
import Badge from '@mui/material/Badge'
import Avatar from '@mui/material/Avatar'
import Popper from '@mui/material/Popper'
import Fade from '@mui/material/Fade'
import Paper from '@mui/material/Paper'
import ClickAwayListener from '@mui/material/ClickAwayListener'
import MenuList from '@mui/material/MenuList'
import Typography from '@mui/material/Typography'
import Divider from '@mui/material/Divider'
import MenuItem from '@mui/material/MenuItem'
import Button from '@mui/material/Button'

import { useDispatch, useSelector } from 'react-redux'

import { getAdminProfile, logoutAdmin } from '@/redux-store/slices/admin'

// Hooks
import { useSettings } from '@core/hooks/useSettings'
import { auth } from '@/libs/firebase'
import { getFullImageUrl } from '@/utils/commonfunctions'

// Badge dot style
const BadgeContentSpan = styled('span')({
  width: 8,
  height: 8,
  borderRadius: '50%',
  cursor: 'pointer',
  backgroundColor: 'var(--mui-palette-success-main)',
  boxShadow: '0 0 0 2px var(--mui-palette-background-paper)'
})

const UserDropdown = () => {
  const [open, setOpen] = useState(false)
  const [user, setUser] = useState(null)

  const anchorRef = useRef(null)

  const router = useRouter()
  const { settings } = useSettings()
  const dispatch = useDispatch()



  useEffect(() => {
    const loadUser = async () => {
      if (typeof window !== 'undefined') {
        const user = JSON.parse(localStorage.getItem('user'))

        setUser(user)
      }
    }

    loadUser()
  }, [])

  useEffect(() => {
    dispatch(getAdminProfile())
  }, [dispatch])

  const handleDropdownOpen = () => setOpen(prev => !prev)

  const handleDropdownClose = (event, url) => {
    if (url) router.push(url)
    if (anchorRef.current?.contains(event?.target)) return
    setOpen(false)
  }

  const handleUserLogout = async () => {
    try {
      // Sign out from Firebase
      await firebaseSignOut(auth)

      // Clear localStorage
      localStorage.removeItem('uid')
      localStorage.removeItem('admin_token')
      localStorage.removeItem('user')

      // Update Redux store
      dispatch(logoutAdmin())

      // Redirect to login
      router.push('/')
      
      // router.push('/login')
    } catch (error) {
      console.error('Logout error:', error)
    }
  }

  return (
    <>
      <Badge
        ref={anchorRef}
        overlap='circular'
        badgeContent={<BadgeContentSpan onClick={handleDropdownOpen} />}
        anchorOrigin={{ vertical: 'bottom', horizontal: 'right' }}
        className='mis-2'
      >
        <Avatar
          alt={user?.name || 'User'}
          src={getFullImageUrl(user?.image) || '/images/avatars/1.png'}
          onClick={handleDropdownOpen}
          className='cursor-pointer bs-[38px] is-[38px]'
        />
      </Badge>

      <Popper
        open={open}
        transition
        disablePortal
        placement='bottom-end'
        anchorEl={anchorRef.current}
        className='min-is-[240px] !mbs-3 z-[1]'
      >
        {({ TransitionProps, placement }) => (
          <Fade {...TransitionProps} style={{ transformOrigin: placement === 'bottom-end' ? 'right top' : 'left top' }}>
            <Paper className={settings.skin === 'bordered' ? 'border shadow-none' : 'shadow-lg'}>
              <ClickAwayListener onClickAway={handleDropdownClose}>
                <MenuList>
                  <div className='flex items-center plb-2 pli-6 gap-2' tabIndex={-1}>
                    <Avatar alt={user?.name} src={getFullImageUrl(user?.image) || '/images/avatars/1.png'} />
                    <div className='flex items-start flex-col'>
                      <Typography className='font-medium' color='text.primary'>
                        {user?.name || 'User'}
                      </Typography>
                      <Typography variant='caption'>{user?.email}</Typography>
                    </div>
                  </div>

                  <Divider className='mlb-1' />

                  <MenuItem
                    className='mli-2 gap-3'
                    onClick={e => {
                      handleDropdownClose(e)
                      router.push('/profile')
                    }}
                  >
                    <i className='tabler-user' />
                    <Typography color='text.primary'>My Profile</Typography>
                  </MenuItem>
                  <MenuItem
                    className='mli-2 gap-3'
                    onClick={e => {
                      handleDropdownClose(e)
                      router.push('/settings')
                    }}
                  >
                    <i className='tabler-settings' />
                    <Typography color='text.primary'>Settings</Typography>
                  </MenuItem>

                  <div className='flex items-center plb-2 pli-3'>
                    <Button
                      fullWidth
                      variant='contained'
                      color='error'
                      size='small'
                      endIcon={<i className='tabler-logout' />}
                      onClick={handleUserLogout}
                      sx={{ '& .MuiButton-endIcon': { marginInlineStart: 1.5 } }}
                    >
                      Logout
                    </Button>
                  </div>
                </MenuList>
              </ClickAwayListener>
            </Paper>
          </Fade>
        )}
      </Popper>
    </>
  )
}

export default UserDropdown
