'use client'

import { useState } from 'react'

import { usePathname, useRouter } from 'next/navigation'

import { signOut as firebaseSignOut } from 'firebase/auth'

import { useTheme } from '@mui/material/styles'

// Third-party Imports
import PerfectScrollbar from 'react-perfect-scrollbar'

import { useDispatch, useSelector } from 'react-redux'

// Component Imports
import { Menu, MenuItem } from '@menu/vertical-menu'

// Hook Imports
import useVerticalNav from '@menu/hooks/useVerticalNav'

// Styled Component Imports
import StyledVerticalNavExpandIcon from '@menu/styles/vertical/StyledVerticalNavExpandIcon'

// Style Imports
import ConfirmationDialog from '@/components/dialogs/confirmation-dialog'
import { auth } from '@/libs/firebase'
import { logoutAdmin } from '@/redux-store/slices/admin'
import menuItemStyles from '@core/styles/vertical/menuItemStyles'
import menuSectionStyles from '@core/styles/vertical/menuSectionStyles'

const RenderExpandIcon = ({ open, transitionDuration }) => (
  <StyledVerticalNavExpandIcon open={open} transitionDuration={transitionDuration}>
    <i className='tabler-chevron-right' />
  </StyledVerticalNavExpandIcon>
)

const VerticalMenu = ({ scrollMenu }) => {
  // Hooks
  const theme = useTheme()
  const pathname = usePathname()
  const verticalNavOptions = useVerticalNav()
  const dispatch = useDispatch()
  const router = useRouter()
  const { settings } = useSelector(state => state.settings)

  // Vars
  const { isBreakpointReached, transitionDuration } = verticalNavOptions
  const ScrollWrapper = isBreakpointReached ? 'div' : PerfectScrollbar

  // Check if current path is user/view or starts with /apps/user
  const isUserPath = pathname === '/user/view' || pathname?.startsWith('/apps/user')

  const [confirmOpen, setConfirmOpen] = useState(false)

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

      setConfirmOpen(false)
      
      // Redirect to login

      // router.push('/login')
    } catch (error) {
      console.error('Logout error:', error)
    }
  }

  return (
    <>
      {/* Custom scrollbar instead of browser scroll, remove if you want browser scroll only */}
      <ScrollWrapper
        {...(isBreakpointReached
          ? {
              className: 'bs-full overflow-y-auto overflow-x-hidden',
              onScroll: container => scrollMenu(container, false)
            }
          : {
              options: { wheelPropagation: false, suppressScrollX: true },
              onScrollY: container => scrollMenu(container, true)
            })}
      >
        {/* Incase you also want to scroll NavHeader to scroll with Vertical Menu, remove NavHeader from above and paste it below this comment */}
        {/* Vertical Menu */}
        <Menu
          popoutMenuOffset={{ mainAxis: 23 }}
          menuItemStyles={menuItemStyles(verticalNavOptions, theme)}
          renderExpandIcon={({ open }) => <RenderExpandIcon open={open} transitionDuration={transitionDuration} />}
          renderExpandedMenuItemIcon={{ icon: <i className='tabler-circle text-xs' /> }}
          menuSectionStyles={menuSectionStyles(verticalNavOptions, theme)}
        >
          {/* Dashboard */}
          <MenuItem href='/dashboard' icon={<i className='tabler-smart-home' />}>
            Dashboard
          </MenuItem>
          {/* User Management */}
          <MenuItem disabled>USER MANAGEMENT</MenuItem>
          <MenuItem href='/apps/user' icon={<i className='tabler-user' />} exactMatch={false} activeUrl='/apps/user'>
            User
          </MenuItem>
          <MenuItem
            href='/apps/listener'
            icon={<i className='tabler-user-star' />}
            exactMatch={false}
            activeUrl='/apps/listener'
          >
            Listener
          </MenuItem>
          <MenuItem href='/listener/request' icon={<i className='tabler-user-scan' />}>
            Listener Request
          </MenuItem>

          <MenuItem disabled>CONTENT</MenuItem>
          <MenuItem href='/faq' icon={<i className='tabler-device-ipad-question' />}>
            FAQ
          </MenuItem>
        
          <MenuItem href='/talk-topics' icon={<i className='tabler-message-circle' />}>
            Talk Topic
          </MenuItem>
          <MenuItem href='/identity-proofs' icon={<i className='tabler-id' />}>
            Identity Proof
          </MenuItem>
         
          {/* CoinTrader */}
          <MenuItem disabled>PACKAGE</MenuItem>
          <MenuItem href='/coin-plans' icon={<i className='tabler-coins' />}>
            Coin Plan
          </MenuItem>
          <MenuItem href='/coin-plan-history'  exactMatch={false}
            activeUrl='/coin-plan-history' icon={<i className='tabler-history' />}>
            Coin Plan History 
          </MenuItem>
         
          {/* Finance */}
          <MenuItem disabled>FINANCIAL</MenuItem>
         
          <MenuItem href='/payment-options' icon={<i className='tabler-cash' />}>
            Payment Option
          </MenuItem>
          <MenuItem href='/payout-requests' icon={<i className='tabler-cash-banknote' />}>
            Payout Request
          </MenuItem>
          {/* General Admin Settings */}
          <MenuItem disabled>SETTINGS</MenuItem>
          <MenuItem href='/settings' icon={<i className='tabler-settings' />}>
            Setting
          </MenuItem>
          <MenuItem href='/profile' icon={<i className='tabler-user-circle' />}>
            Profile
          </MenuItem>
          <MenuItem onClick={() => setConfirmOpen(true)} icon={<i className='tabler-logout' />}>
            Logout
          </MenuItem>
        </Menu>
      </ScrollWrapper>

      <ConfirmationDialog
        open={confirmOpen}
        setOpen={setConfirmOpen}
        title='Are you sure you want to logout?'
        content='You will be logged out of the system.'
        onConfirm={handleUserLogout}
        onClose={()=>{
          setConfirmOpen(false)
        }}
      />
    </>
  )
}

export default VerticalMenu
