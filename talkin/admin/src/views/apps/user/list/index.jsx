'use client'
import { useCallback, useEffect, useRef } from 'react'

import { useSearchParams } from 'next/navigation'

import { useDispatch, useSelector } from 'react-redux'

// MUI Imports
import Box from '@mui/material/Box'
import Grid from '@mui/material/Grid'
import Typography from '@mui/material/Typography'

// Component Imports
import UserListCards from './UserListCards'
import UserListTable from './UserListTable'

// Component Imports
import { fetchUsers, setFilters, setSearchQuery, setType } from '@/redux-store/slices/user'

const UserList = () => {
  const dispatch = useDispatch()
  const searchParams = useSearchParams()
  const fetchInProgress = useRef(false)
  const isInitialLoad = useRef(true)

  // Get values from URL
  const urlPage = parseInt(searchParams.get('page') || '1')
  const urlPageSize = parseInt(searchParams.get('pageSize') || '10')
  const urlType = parseInt(searchParams.get('type') || '1')
  const urlStatus = searchParams.get('status')
  const urlRole = searchParams.get('role')
  const urlIsBlock = searchParams.get('isBlock')
  const urlIsListener = searchParams.get('isListener')
  const urlIsOnline = searchParams.get('isOnline')
  const urlSearch = searchParams.get('search') || ''
  const urlStartDate = searchParams.get('startDate') || 'All'
  const urlEndDate = searchParams.get('endDate') || 'All'

  const { user, userCount, total, searchQuery, type, data, streamType, page, pageSize, startDate, endDate, filters } =
  useSelector(state => state.userReducer)
  
  // console.log('userCount: ', userCount);

  const getUsers = useCallback(
    params => {
      dispatch(fetchUsers(params)).finally(() => {
        fetchInProgress.current = false
      })
    },
    [dispatch]
  )

  useEffect(
    () => {
      if (true) {
        if (urlType) {
          dispatch(setType(urlType))
        }

        dispatch(setSearchQuery(urlSearch))
        const initialFilters = { status: 'All', role: 'All' }

        if (urlIsBlock === 'true') {
          initialFilters.status = 'Blocked'
        } else if (urlIsBlock === 'false') {
          initialFilters.status = 'Unblocked'
        } else if (urlIsOnline === 'true') {
          initialFilters.status = 'Online'
        } else if (urlIsOnline === 'false') {
          initialFilters.status = 'Offline'
        } else if (urlStatus) {
          initialFilters.status = urlStatus
        }

        if (urlRole && urlRole !== 'All') {
          initialFilters.role = urlRole
        }

        dispatch(setFilters(initialFilters))
        isInitialLoad.current = false

        // Trigger initial fetch after setting up the state
        getUsers({
          page: urlPage,
          pageSize: urlPageSize,
          searchQuery: urlSearch,
          startDate: urlStartDate,
          endDate: urlEndDate,
          isBlock: urlIsBlock === 'true' ? true : urlIsBlock === 'false' ? false : undefined,
          isListener: urlIsListener === 'true' ? true : urlIsListener === 'false' ? false : undefined,
          isOnline: urlIsOnline === 'true' ? true : urlIsOnline === 'false' ? false : undefined
        })
      }
    },
    // eslint-disable-next-line react-hooks/exhaustive-deps
    [dispatch, urlPage, urlPageSize, urlIsBlock, urlIsOnline, urlIsListener, urlSearch, urlStartDate, urlEndDate]
  )

  return (
    <Grid container spacing={6}>
      <Grid size={{ xs: 12 }}>
        <Box display='flex' alignItems='center' gap={2} mb={2}>
          <Typography variant='h5'>User Management</Typography>
        </Box>
        <UserListCards states={userCount} total={total} userCount={data} />
      </Grid>
      <Grid size={{ xs: 12 }}>
        <UserListTable />
      </Grid>
    </Grid>
  )
}

export default UserList
