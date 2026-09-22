'use client'

import { useEffect } from 'react'

// Next Imports

import { useSearchParams } from 'next/navigation'

// MUI Imports

import { useDispatch, useSelector } from 'react-redux'

// Component Imports
import UserProfileSkeleton from '@components/shimmer/UserProfileSkeleton'
import UserProfile from '@views/apps/listener/view/user-profile'

// Data Imports

import { fetchUserDetails } from '@/redux-store/slices/user'

const UserViewTab = () => {
  // Vars
  // const data = await getPricingData()

  const { initialLoading } = useSelector(state => state.userReducer)
  const dispatch = useDispatch()

  const searchParams = useSearchParams()
  const userId = searchParams.get('userId')

  // useEffect(() => {
  //   if (userId) {
  //     dispatch(fetchUserDetails(userId))
  //   }
  // }, [dispatch, userId])

  // Show shimmer loading when data is being fetched
  // if (initialLoading) {
  //   return <UserProfileSkeleton />
  // }

  return (
    <UserProfile/> 
  )
}

export default UserViewTab
