'use client'

import { useEffect, useRef, useState } from 'react'

import { usePathname, useRouter, useSearchParams } from 'next/navigation'

import { TabContext, TabPanel } from '@mui/lab'
import { Box, Tab, Typography } from '@mui/material'
import { useDispatch, useSelector } from 'react-redux'

import { toast } from 'react-toastify'

import CustomTabList from '@/@core/components/mui/TabList'
import ConfirmationDialog from '@/components/dialogs/confirmation-dialog'
import { fetchDefaultCurrencies } from '@/redux-store/slices/currency'
import {
  acceptPayoutRequest,
  fetchPayoutRequests,
  rejectPayoutRequest,
  setLoading
} from '@/redux-store/slices/payoutRequests'
import PayoutRequestsTable from './PayoutRequestsTable'
import ReasonDialog from './ReasonDialog'

import RejectReasonDialog from './RejectReasonDialog'


// Constants for person types
const WITHDRAWAL_STATUS = {
  DEFAULT: 0,
  PENDING: 1,
  ACCEPTED: 2,
  DECLINED: 3
}

// Constants for status types
const STATUS_TYPES = {
  PENDING: 1,
  ACCEPTED: 2,
  REJECTED: 3
}

const PayoutRequests = () => {
  const dispatch = useDispatch()
  const router = useRouter()
  const pathname = usePathname()
  const searchParams = useSearchParams()
  const [reasonDialouge, setReasonDialouge] = useState(false)
  const [reason, setReason] = useState('')

  const handleOpenReasonDialog = reason => {
    setReasonDialouge(true)
    setReason(reason)
  }

  const handleCloseReasonDialog = reason => {
    setReasonDialouge(false)
    setReason('')
  }

  // Get initial values from query params or default
  const initialTab = searchParams.get('tab') || 'pending'
  const initialStatus = searchParams.get('status') ? Number(searchParams.get('status')) : STATUS_TYPES.PENDING

  const [personTab, setPersonTab] = useState(initialTab)
  const [statusFilter, setStatusFilter] = useState(initialStatus)
  const { loading: apiLoading, page, pageSize } = useSelector(state => state.payoutRequests)
  const { defaultCurrency } = useSelector(state => state.currency)

  // console.log("page , pageSize-->" , page , pageSize)
  // Track previous request parameters to prevent duplicate calls
  const prevRequestRef = useRef({
    person: null,
    status: null
  })

  // Track if initial API call has been made
  const initialApiCallMade = useRef(false)

  // Reject reason dialog state
  const [rejectDialog, setRejectDialog] = useState({
    open: false,
    requestId: null,
    loading: false
  })

  // Confirmation dialog states
  const [confirmDialog, setConfirmDialog] = useState({
    open: false,
    type: '', // 'accept' or 'reject'
    title: '',
    requestId: null,
    listenerId: null,
    reason: '',
    loading: false,
    error: null
  })

  // Map tab values to API person params
  // eslint-disable-next-line react-hooks/exhaustive-deps
  const statusMapping = {
    pending: WITHDRAWAL_STATUS.PENDING,
    accept: WITHDRAWAL_STATUS.ACCEPTED,
    decline: WITHDRAWAL_STATUS.DECLINED,
    default: WITHDRAWAL_STATUS.DEFAULT
  }

  // Update query params when tab or status changes
  const updateQueryParams = (tab, status) => {
    const params = new URLSearchParams(searchParams)
    
    if (tab !== undefined) {
      params.set('tab', tab)
    }

    if (status !== undefined) {
      params.set('status', status.toString())
    }

    params.get("startDate") &&  params.delete("startDate")
    params.get("endDate") &&  params.delete("endDate")
    router.push(`${pathname}?${params.toString()}`, { scroll: false })
  }

  // Handle person tab change
  const handlePersonChange = (event, newValue) => {
    dispatch(setLoading(true))
    setPersonTab(newValue)
    updateQueryParams(newValue)
  }

  // Open confirmation dialog for accept action
  const handleAcceptAction = (requestId, listenerId) => {
    setConfirmDialog({
      open: true,
      type: 'accept',
      title: 'Are you sure you want to approve this payout request?',
      requestId,
      listenerId,
      reason: '',
      loading: false,
      error: null
    })
  }

  // Open reject reason dialog for reject action
  const handleRejectAction = (requestId, listenerId) => {
    console.log('requestId , listenerId -->', requestId, listenerId)
    setRejectDialog({
      open: true,
      requestId,
      listenerId,
      loading: false
    })
  }

  


  // Handle reject reason submission
  const handleRejectReasonSubmit = reason => {
     

    setRejectDialog(prev => ({ ...prev, open: false }))


    // Open confirmation dialog with the reason
    setConfirmDialog({
      open: true,
      type: 'reject',
      title: 'Are you sure you want to reject this payout request?',
      requestId: rejectDialog.requestId,
      listenerId: rejectDialog.listenerId,
      reason,
      loading: false,
      error: null
    })
  }

  // Handle reject reason dialog close
  const handleRejectDialogClose = () => {
    setRejectDialog(prev => ({ ...prev, open: false }))
  }

  // Handle confirmation dialog close
  const handleConfirmDialogClose = () => {
    setConfirmDialog(prev => ({ ...prev, open: false }))
  }

  // Handle confirmation dialog confirm action
  const handleConfirmAction = async () => {
     
    
    const { type, requestId, reason, listenerId } = confirmDialog

    // Set loading state
    setConfirmDialog(prev => ({ ...prev, loading: true }))

    try {
      if (type === 'accept') {
        // Call accept API
        const result = await dispatch(acceptPayoutRequest({ requestId, listenerId })).unwrap()
      } else if (type === 'reject') {
        // Call reject API with the reason provided by the user
        const result = await dispatch(
          rejectPayoutRequest({
            requestId,
            listenerId,
            reason
          })
        ).unwrap()
      }

      // Success: No need to make additional API calls as the reducer will update the state
      // No error, let the dialog transition to success state automatically
      setConfirmDialog(prev => ({ ...prev, loading: false, error: null }))
    } catch (error) {
      console.error('API error:', error)

      // Set error message to display in dialog
      setConfirmDialog(prev => ({
        ...prev,
        loading: false,
        error: error.message || 'An error occurred during the operation.'
      }))
    }
  }

  const urlPage = parseInt(searchParams.get('page') || '1')
  const urlPageSize = parseInt(searchParams.get('pageSize') || '10')
  const urlStatus = searchParams.get('tab') || 'pending'
  const urlStartDate = searchParams.get('startDate') || 'All'
  const urlEndDate = searchParams.get('endDate') || 'All'

  useEffect(() => {
    if (!searchParams) return

    const code = {
      pending: 1,
      accept: 2,
      decline: 3
    }

    const status = searchParams.get('tab') || 'pending'
    const statusCode = code[urlStatus] || 1
    
    dispatch(
      fetchPayoutRequests({
        status: statusCode,
        page: urlPage,
        limit: urlPageSize,
        startDate: urlStartDate,
        endDate: urlEndDate
      })
    )
  }, [dispatch, urlStatus, urlPage, urlPageSize , urlStartDate , urlEndDate])

  useEffect(() => {
    if (!defaultCurrency) {
      dispatch(fetchDefaultCurrencies())
    }
  }, [])

  return (
    <Box>
      {/* Page Title */}
      <Box mb={5} display='flex' justifyContent='space-between' alignItems='center'>
        <Typography variant='h5'>Payout Requests</Typography>  
      </Box>

      {/* Person Tab Selector */}
      <TabContext value={personTab}>
        <Box mb={3} >
          <CustomTabList onChange={handlePersonChange} variant='scrollable' pill='true'>
            <Tab
              label='Pending'
              value='pending'
              icon={<i className='tabler-users-group' />}
              iconPosition='start'
              sx={{ '& .MuiTab-iconWrapper': { mr: 1 } }}
            />
            <Tab
              label='Accept'
              value='accept'
              icon={<i className='tabler-users-plus' />}
              iconPosition='start'
              sx={{ '& .MuiTab-iconWrapper': { mr: 1 } }}
            />
            <Tab
              label='Decline'
              value='decline'
              icon={<i className='tabler-user' />}
              iconPosition='start'
              sx={{ '& .MuiTab-iconWrapper': { mr: 1 } }}
            />
          </CustomTabList>
         
        </Box>
        {/* Tab Content with Tables */}
        <TabPanel value='pending' sx={{ p: 0 }}>
          <PayoutRequestsTable
            personType={WITHDRAWAL_STATUS.PENDING}
            statusType={statusFilter}
            showActions={statusFilter === STATUS_TYPES.PENDING}
            onAccept={(id, lids) => handleAcceptAction(id, lids)}
            onReject={(id, lids) => handleRejectAction(id, lids)}
          />
        </TabPanel>

        <TabPanel value='accept' sx={{ p: 0 }}>
          <PayoutRequestsTable
            personType={WITHDRAWAL_STATUS.ACCEPTED}
            statusType={statusFilter}
            showActions={statusFilter === STATUS_TYPES.PENDING}
            onAccept={(id, lids) => handleAcceptAction(id, lids)}
            onReject={(id, lids) => handleRejectAction(id, lids)}
          />
        </TabPanel>

        <TabPanel value='decline' sx={{ p: 0 }}>
          <PayoutRequestsTable
            personType={WITHDRAWAL_STATUS.DECLINED}
            statusType={statusFilter}
            showActions={statusFilter === STATUS_TYPES.PENDING}
            onAccept={(id, lids) => handleAcceptAction(id, lids)}
            onReject={(id, lids) => handleRejectAction(id, lids)}
            handleReason={handleOpenReasonDialog}
          />
        </TabPanel>
      </TabContext>

      {/* Reject Reason Dialog */}
      <RejectReasonDialog
        open={rejectDialog.open}
        onClose={handleRejectDialogClose}
        onSubmit={handleRejectReasonSubmit}
        loading={rejectDialog.loading}
      />

      <ReasonDialog open={reasonDialouge} onClose={handleCloseReasonDialog} reason={reason} />

      {/* Confirmation Dialog */}
      <ConfirmationDialog
        open={confirmDialog.open}
        onClose={handleConfirmDialogClose}
        type={confirmDialog.type === 'accept' ? 'approve-payout' : 'reject-payout'}
        title={confirmDialog.title}
        content={`This action will ${confirmDialog.type === 'accept' ? 'approve' : 'reject'} the payout request.`}
        onConfirm={handleConfirmAction}
        loading={confirmDialog.loading}
        error={confirmDialog.error}
        confirmButtonText={confirmDialog.type === 'accept' ? 'Yes, Approve' : 'Yes, Reject'}
      />
    </Box>
  )
}

export default PayoutRequests
