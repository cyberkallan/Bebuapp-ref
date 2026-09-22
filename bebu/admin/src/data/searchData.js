const data = [
  // === DASHBOARD ===
  {
    id: '1',
    name: 'Dashboard',
    url: '/dashboard',
    icon: 'tabler-smart-home',
    section: 'Dashboard'
  },

  // === USER MANAGEMENT ===
  {
    id: '2',
    name: 'Users',
    url: '/apps/user',
    icon: 'tabler-user',
    section: 'User Management'
  },
  {
    id: '3',
    name: 'Host Application',
    url: '/host/application',
    icon: 'tabler-user-scan',
    section: 'User Management'
  },
  {
    id: '4',
    name: 'Host',
    url: '/host/list',
    icon: 'tabler-users-plus',
    section: 'User Management'
  },
  {
    id: '5',
    name: 'Agency',
    url: '/agency',
    icon: 'tabler-users-group',
    section: 'User Management'
  },

  // === CONTENT ===
  {
    id: '6',
    name: 'Social Media - Posts',
    url: '/social-media/posts',
    icon: 'tabler-brand-instagram',
    section: 'Content'
  },
  {
    id: '7',
    name: 'Social Media - Videos',
    url: '/social-media/videos',
    icon: 'tabler-brand-instagram',
    section: 'Content'
  },
  {
    id: '8',
    name: 'Song Categories',
    url: '/songs/categories',
    icon: 'tabler-music',
    section: 'Content'
  },
  {
    id: '9',
    name: 'Songs',
    url: '/songs/list',
    icon: 'tabler-music',
    section: 'Content'
  },
  {
    id: '10',
    name: 'Hashtags',
    url: '/hashtags',
    icon: 'tabler-hash',
    section: 'Content'
  },

  // === ENGAGEMENT ===
  {
    id: '11',
    name: 'Gift Categories',
    url: '/gift-categories',
    icon: 'tabler-gift',
    section: 'Engagement'
  },
  {
    id: '12',
    name: 'Gifts',
    url: '/gifts',
    icon: 'tabler-gift',
    section: 'Engagement'
  },
  {
    id: '13',
    name: 'Store - Rides',
    url: '/store/rides',
    icon: 'tabler-shopping-bag-edit',
    section: 'Engagement'
  },
  {
    id: '14',
    name: 'Store - Themes',
    url: '/store/themes',
    icon: 'tabler-shopping-bag-edit',
    section: 'Engagement'
  },
  {
    id: '15',
    name: 'Store - Frames',
    url: '/store/frames',
    icon: 'tabler-shopping-bag-edit',
    section: 'Engagement'
  },
  {
    id: '16',
    name: 'Reactions',
    url: '/reaction',
    icon: 'tabler-mood-happy',
    section: 'Engagement'
  },

  // === PACKAGE ===
  {
    id: '17',
    name: 'Coin Plans',
    url: '/coin-plan',
    icon: 'tabler-coins',
    section: 'Package'
  },
  {
    id: '18',
    name: 'VIP Plans',
    url: '/vip-plan',
    icon: 'tabler-vip',
    section: 'Package'
  },
  {
    id: '19',
    name: 'Coin Trader',
    url: '/coin-trader',
    icon: 'tabler-database-share',
    section: 'Package'
  },

  // === WEALTH ===
  {
    id: '20',
    name: 'Wealth Levels',
    url: '/wealth-level',
    icon: 'tabler-trending-up',
    section: 'Wealth'
  },

  // === SUPPORT & REPORTING ===
  {
    id: '21',
    name: 'Help',
    url: '/help',
    icon: 'tabler-help',
    section: 'Support'
  },
  {
    id: '22',
    name: 'Reports',
    url: '/reports',
    icon: 'tabler-report',
    section: 'Support'
  },

  // === FINANCIAL ===
  {
    id: '23',
    name: 'Referral System',
    url: '/referral-system',
    icon: 'tabler-users',
    section: 'Finance'
  },
  {
    id: '24',
    name: 'Agency Commission',
    url: '/agency-commission',
    icon: 'tabler-receipt-inr', // Or tabler-receipt-{currency} dynamically
    section: 'Finance'
  },
  {
    id: '25',
    name: 'Payout Methods',
    url: '/payment-methods',
    icon: 'tabler-credit-card',
    section: 'Finance'
  },

  // === SYSTEM ===
  {
    id: '26',
    name: 'Setting',
    url: '/settings',
    icon: 'tabler-settings',
    section: 'System'
  },
  {
    id: '27',
    name: 'Profile',
    url: '/profile',
    icon: 'tabler-user-circle',
    section: 'System'
  },
  {
    id: '28',
    name: 'Logout',
    url: '/logout', // You can handle this with a route guard or button
    icon: 'tabler-logout',
    section: 'System'
  }
]

export default data
