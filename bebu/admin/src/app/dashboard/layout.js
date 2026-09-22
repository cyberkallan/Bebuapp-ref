'use client'

import ProtectedLayout from '@/@layouts/ProtectedLayout'

const DashboardLayout = ({ children }) => {
  return (
    <ProtectedLayout>
      {/* Add your dashboard layout components here */}
      {children}
    </ProtectedLayout>
  )
}

export default DashboardLayout
