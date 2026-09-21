// Third-party Imports
import { configureStore } from '@reduxjs/toolkit'

// Slice Imports
import chatReducer from '@/redux-store/slices/chat'
import calendarReducer from '@/redux-store/slices/calendar'
import kanbanReducer from '@/redux-store/slices/kanban'
import emailReducer from '@/redux-store/slices/email'
import userReducer from '@/redux-store/slices/user'
import adminSlice from '@/redux-store/slices/admin'
import coinPlansReducer from '@/redux-store/slices/coinPlans'
import coinPlanHistoryReducer from '@/redux-store/slices/coinPlanHistory'
import giftReducer from '@/redux-store/slices/gifts'
import ridesReducer from '@/redux-store/slices/rides'
import themeReducer from '@/redux-store/slices/themes'
import frameReducer from '@/redux-store/slices/frames'
import wealthLevelReducer from '@/redux-store/slices/wealthLevels'
import hashtagsReducer from '@/redux-store/slices/hashtags'
import talkTopicsReducer from '@/redux-store/slices/talkTopics'
import identityProofsReducer from '@/redux-store/slices/identityProofs'
import reportReasonsReducer from '@/redux-store/slices/reportReasons'
import settingsReducer from '@/redux-store/slices/settings'
import postsReducer from '@/redux-store/slices/posts'
import faqsReducer from '@/redux-store/slices/faq'
import videosReducer from '@/redux-store/slices/videos'
import songsReducer from '@/redux-store/slices/songs'
import reactionsReducer from '@/redux-store/slices/reactions'
import dashboardReducer from '@/redux-store/slices/dashboard'
import helpReducer from '@/redux-store/slices/help'
import reportsReducer from '@/redux-store/slices/reports'
import referralSystemReducer from '@/redux-store/slices/referralSystem'
import currencyReducer from '@/redux-store/slices/currency'
import agencyCommissionReducer from '@/redux-store/slices/agencyCommission'
import agencyReducer from '@/redux-store/slices/agency'
import payoutMethodsReducer from '@/redux-store/slices/payoutMethods'
import hostApplicationReducer from '@/redux-store/slices/listenerRequest'
import hostListReducer from '@/redux-store/slices/hostList'
import coinTraderReducer from '@/redux-store/slices/coinTrader'
import payoutRequestsReducer from '@/redux-store/slices/payoutRequests'
import gameHistoryReducer from '@/redux-store/slices/gameHistory'
import paymentOptionsReducer from '@/redux-store/slices/paymentOptions'
import listenerReducer from '@/redux-store/slices/listener'

export const store = configureStore({
  reducer: {
    // chatReducer,
    // calendarReducer,
    // kanbanReducer,
    // emailReducer,
    adminSlice,
    userReducer,
    coinPlansReducer,
    coinPlanHistory: coinPlanHistoryReducer,

    // giftReducer,
    // ridesReducer,
    // themeReducer,
    // frameReducer,
    // wealthLevelReducer,
    // hashtagsReducer,
    talkTopicsReducer,
    identityProofsReducer,

    // reportReasons: reportReasonsReducer,
    settings: settingsReducer,

    // posts: postsReducer,
    faqs: faqsReducer,

    // videos: videosReducer,
    // songs: songsReducer,
    // reaction: reactionsReducer,
    dashboard: dashboardReducer,

    // help: helpReducer,
    // reports: reportsReducer,
    // referralSystem: referralSystemReducer,
    currency: currencyReducer,

    // agencyCommissionReducer,
    // agency: agencyReducer,
    // payoutMethodsReducer,
    hostApplication: hostApplicationReducer,

    // hostList: hostListReducer,
    // coinTrader: coinTraderReducer,
    payoutRequests: payoutRequestsReducer,
    
    // gameHistory: gameHistoryReducer,
    paymentOptions: paymentOptionsReducer,
    listener: listenerReducer
  },
  middleware: getDefaultMiddleware => getDefaultMiddleware({ serializableCheck: false })
})
