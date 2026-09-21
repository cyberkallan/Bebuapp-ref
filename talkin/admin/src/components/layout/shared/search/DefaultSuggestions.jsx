// Next Imports
import Link from 'next/link'
import { useParams } from 'next/navigation'

// Third-party Imports
import classnames from 'classnames'

// Util Imports

const defaultSuggestions = [
  {
    sectionLabel: 'User Management',
    items: [
      {
        label: 'Users',
        href: '/apps/user',
        icon: 'tabler-user'
      },
      {
        label: 'Listener',
        href: '/apps/listener',
        icon: 'tabler-user-star'
      },
      {
        label: 'Listener Request',
        href: '/listener/request',
        icon: 'tabler-user-scan'
      },
    ]
  },
  {
    sectionLabel: 'Content',
    items: [
      {
        label: 'FAQ',
        href: '/faq',
        icon: 'tabler-device-ipad-question'
      },
      {
        label: 'Talk Topic',
        href: '/talk-topics',
        icon: 'tabler-message-circle'
      },
      {
        label: 'Identity Proof',
        href: '/identity-proofs',
        icon: 'tabler-id'
      },
    ]
  },
  {
    sectionLabel: 'Package',
    items: [
      {
        label: 'Coin Plan',
        href: '/coin-plans',
        icon: 'tabler-coins'
      },
      {
        label: 'Coin Plan History',
        href: '/coin-plan-history',
        icon: 'tabler-history'
      },
    ]
  },
  {
    sectionLabel: 'Financial',
    items: [
      {
        label: 'Payment Option',
        href: '/payment-options',
        icon: 'tabler-cash'
      },
      {
        label: 'Payout Requests',
        href: '/payout-requests',
        icon: 'tabler-cash-banknote'
      },
    ]
  },
  {
    sectionLabel: 'Setting',
    items: [
      {
        label: 'Settings',
        href: '/settings',
        icon: 'tabler-settings'
      },
      {
        label: 'Profile',
        href: '/profile',
        icon: 'tabler-user-circle'
      },
    ]
  },
]

const DefaultSuggestions = ({ setOpen }) => {
  // Hooks
  const { lang: locale } = useParams()

  return (
    <div className='flex grow flex-wrap gap-x-[48px] gap-y-8 plb-14 pli-16 overflow-y-auto overflow-x-hidden bs-full'>
      {defaultSuggestions.map((section, index) => (
        <div
          key={index}
          className='flex flex-col justify-start overflow-x-hidden gap-4 basis-full sm:basis-[calc((100%-3rem)/2)]'
        >
          <p className='text-xs leading-[1.16667] uppercase text-textDisabled tracking-[0.8px]'>
            {section.sectionLabel}
          </p>
          <ul className='flex flex-col gap-4'>
            {section.items.map((item, i) => (
              <li key={i} className='flex'>
                <Link
                  href={item.href}
                  className='flex items-center overflow-x-hidden cursor-pointer gap-2 hover:text-primary focus-visible:text-primary focus-visible:outline-0'
                  onClick={() => setOpen(false)}
                >
                  {item.icon && <i className={classnames(item.icon, 'flex text-xl')} />}
                  <p className='text-[15px] leading-[1.4667] truncate'>{item.label}</p>
                </Link>
              </li>
            ))}
          </ul>
        </div>
      ))}
    </div>
  )
}

export default DefaultSuggestions
