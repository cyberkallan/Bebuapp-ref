// MUI Imports
import { useTheme } from '@mui/material/styles'

// Component Imports
import HorizontalNav, { Menu, MenuItem, SubMenu } from '@menu/horizontal-menu'
import VerticalNavContent from './VerticalNavContent'

// Hook Imports
import useVerticalNav from '@menu/hooks/useVerticalNav'

// Styled Component Imports
import StyledHorizontalNavExpandIcon from '@menu/styles/horizontal/StyledHorizontalNavExpandIcon'
import StyledVerticalNavExpandIcon from '@menu/styles/vertical/StyledVerticalNavExpandIcon'

// Style Imports
import menuItemStyles from '@core/styles/horizontal/menuItemStyles'
import menuRootStyles from '@core/styles/horizontal/menuRootStyles'
import verticalNavigationCustomStyles from '@core/styles/vertical/navigationCustomStyles'
import verticalMenuItemStyles from '@core/styles/vertical/menuItemStyles'
import verticalMenuSectionStyles from '@core/styles/vertical/menuSectionStyles'

const RenderExpandIcon = ({ level }) => (
  <StyledHorizontalNavExpandIcon level={level}>
    <i className='tabler-chevron-right' />
  </StyledHorizontalNavExpandIcon>
)

const RenderVerticalExpandIcon = ({ open, transitionDuration }) => (
  <StyledVerticalNavExpandIcon open={open} transitionDuration={transitionDuration}>
    <i className='tabler-chevron-right' />
  </StyledVerticalNavExpandIcon>
)

const HorizontalMenu = () => {
  // Hooks
  const verticalNavOptions = useVerticalNav()
  const theme = useTheme()

  // Vars
  const { transitionDuration } = verticalNavOptions

  return (
    <HorizontalNav
      switchToVertical
      verticalNavContent={VerticalNavContent}
      verticalNavProps={{
        customStyles: verticalNavigationCustomStyles(verticalNavOptions, theme),
        backgroundColor: 'var(--mui-palette-background-paper)'
      }}
    >
      <Menu
        rootStyles={menuRootStyles(theme)}
        renderExpandIcon={({ level }) => <RenderExpandIcon level={level} />}
        menuItemStyles={menuItemStyles(theme, 'tabler-circle')}
        renderExpandedMenuItemIcon={{ icon: <i className='tabler-circle text-xs' /> }}
        popoutMenuOffset={{
          mainAxis: ({ level }) => (level && level > 0 ? 14 : 12),
          alignmentAxis: 0
        }}
        verticalMenuProps={{
          menuItemStyles: verticalMenuItemStyles(verticalNavOptions, theme),
          renderExpandIcon: ({ open }) => (
            <RenderVerticalExpandIcon open={open} transitionDuration={transitionDuration} />
          ),
          renderExpandedMenuItemIcon: { icon: <i className='tabler-circle text-xs' /> },
          menuSectionStyles: verticalMenuSectionStyles(verticalNavOptions, theme)
        }}
      >
        {/* Dashboard */}
        <SubMenu label='Dashboard'>
          <MenuItem href='/dashboard' icon={<i className='tabler-chart-pie-2' />}>
            Dashboard
          </MenuItem>
        </SubMenu>

        {/* User Management */}
        <SubMenu label='User Management'>
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
        </SubMenu>

        {/* CONTENT*/}
        <SubMenu label='Content'>
          <MenuItem href='/faq' icon={<i className='tabler-device-ipad-question' />}>
            FAQ
          </MenuItem>

          <MenuItem href='/talk-topics' icon={<i className='tabler-message-circle' />}>
            Talk Topic
          </MenuItem>
          <MenuItem href='/identity-proofs' icon={<i className='tabler-id' />}>
            Identity Proof
          </MenuItem>
        </SubMenu>

        {/* PACKAGE*/}
        <SubMenu label='Package'>
          <MenuItem href='/coin-plans' icon={<i className='tabler-coins' />}>
            Coin Plan
          </MenuItem>
          <MenuItem
            href='/coin-plan-history'
            exactMatch={false}
            activeUrl='/coin-plan-history'
            icon={<i className='tabler-history' />}
          >
            Coin Plan History
          </MenuItem>
        </SubMenu>

        {/* FINANCIAL*/}
        <SubMenu label='Financial'>
          <MenuItem href='/payment-options' icon={<i className='tabler-cash' />}>
            Payment Option
          </MenuItem>
          <MenuItem href='/payout-requests' icon={<i className='tabler-cash-banknote' />}>
            Payout Request
          </MenuItem>
        </SubMenu>

        {/* Setting*/}
        <SubMenu label='Setting'>
          <MenuItem href='/settings' icon={<i className='tabler-settings' />}>
                     Setting
                   </MenuItem>
                   <MenuItem href='/profile' icon={<i className='tabler-user-circle' />}>
                     Profile
                   </MenuItem>
                   <MenuItem onClick={() => setConfirmOpen(true)} icon={<i className='tabler-logout' />}>
                     Logout
                   </MenuItem>
        </SubMenu>
      </Menu>
    </HorizontalNav>
  )
}

export default HorizontalMenu
