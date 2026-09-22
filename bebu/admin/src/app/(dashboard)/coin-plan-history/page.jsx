'use client'

import dynamic from 'next/dynamic'

// Dynamically import the client component
const CoinPlanHistoryClient = dynamic(() => import('@/views/coin-plan-history/ClientWrapper'), {
  ssr: false
})

const CoinPlanHistoryPage = () => {
  return <CoinPlanHistoryClient />
}

export default CoinPlanHistoryPage
