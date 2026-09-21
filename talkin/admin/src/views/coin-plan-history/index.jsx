'use client'

import React, { useEffect, useMemo, useState } from 'react'

import { usePathname, useRouter, useSearchParams } from 'next/navigation'

import { IconButton } from '@mui/material'

import { createColumnHelper, flexRender, getCoreRowModel, useReactTable } from '@tanstack/react-table'
import { useDispatch, useSelector } from 'react-redux'

// MUI Imports
import FilterListIcon from '@mui/icons-material/FilterList'
import Box from '@mui/material/Box'
import Card from '@mui/material/Card'
import CircularProgress from '@mui/material/CircularProgress'
import MenuItem from '@mui/material/MenuItem'
import Typography from '@mui/material/Typography'

// Component Imports
import CustomTextField from '@/@core/components/mui/TextField'
import tableStyles from '@core/styles/table.module.css'

// Redux Actions
import { fetchCoinPlanHistory, setDateRange, setPage, setPageSize } from '@/redux-store/slices/coinPlanHistory'

// Helper Functions
import CustomAvatar from '@/@core/components/mui/Avatar'
import { getFullImageUrl } from '@/utils/commonfunctions'

import { getInitials } from '@/utils/getInitials'



// import { useRouter } from 'next/router'
import TablePaginationComponent from '@/components/TablePaginationComponent'
import DateRangePicker from '@/components/common/DateRangePicker'
import EmprtyTableRow from '@/components/common/EmprtyTableRow'

import { fetchDefaultCurrencies } from '@/redux-store/slices/currency'



const columnHelper = createColumnHelper()

const formatDate = dateString => {
  if (!dateString) return '-'
  const date = new Date(dateString)

  return date.toLocaleDateString('en-US', {
    year: 'numeric',
    month: 'short',
    day: 'numeric'
  })
}

const CoinPlanHistory = () => {
  const dispatch = useDispatch()
  const searchParams = useSearchParams()
  const router = useRouter()
  const pathname = usePathname()

  const { history, loading, page, pageSize, total, dateRange, adminEarnings } = useSelector(
    state => state.coinPlanHistory
  )

  const { defaultCurrency } = useSelector(state => state.currency)

  useEffect(() => {
    if (!defaultCurrency) {
      dispatch(fetchDefaultCurrencies())
    }
  }, [])

  const { startDate, endDate } = dateRange

  // Initialize date filter state
  const [dateFilter, setDateFilter] = useState({
    startDate: startDate || 'All',
    endDate: endDate || 'All'
  })

  const urlPage = parseInt(searchParams.get('page') || '1')
  const urlPageSize = parseInt(searchParams.get('pageSize') || '10')
  const urlStartDate = searchParams.get('startDate') || 'All'
  const urlEndDate = searchParams.get('endDate') || 'All'

  // Fetch data on initial load and when page, pageSize, or dateRange changes

  useEffect(() => {
    dispatch(
      fetchCoinPlanHistory({
        page: urlPage,
        limit: urlPageSize,
        startDate: urlStartDate,
        endDate: urlEndDate
      })
    )
  }, [dispatch, urlPage, urlPageSize, urlStartDate, urlEndDate])

  // Handle date range apply
  const handleDateRangeApply = (start, end) => {
    if (!(dateRange.endDate === end && dateRange.startDate === start)) {
      setDateFilter({ startDate: start, endDate: end })
      dispatch(setDateRange({ startDate: start, endDate: end }))
    }

    // setDateFilter({
    //   startDate: start,
    //   endDate: end
    // })
  }

  const [expandedRows, setExpandedRows] = useState({})

  // Clear date filter
  const clearDateFilter = () => {
    setDateFilter({
      startDate: 'All',
      endDate: 'All'
    })

    dispatch(setDateRange({ startDate: 'All', endDate: 'All' }))
  }

  // Check if date filter is applied
  const isDateFiltered = dateRange.startDate !== 'All' || dateRange.endDate !== 'All'

  // Define columns
  const columns = useMemo(
    () => [
      columnHelper.accessor('nickName', {
        header: 'User',
        cell: ({ row }) => {
          const { nickName, fullName, profilePic } = row.original

          return (
            <div className='flex items-center gap-3'>
              {profilePic ? (
                <CustomAvatar src={getFullImageUrl(profilePic)} size={40} />
              ) : (
                <CustomAvatar size={40}>{getInitials(fullName || nickName)}</CustomAvatar>
              )}
              <div>
                <Typography variant='body2' className='font-medium'>
                  {fullName || '-'}
                </Typography>
                <Typography variant='caption' color='text.secondary'>
                  {nickName || '-'}
                </Typography>
              </div>
            </div>
          )
        }
      }),
      columnHelper.accessor('totalSpent', {
        header: `Total Spent (${defaultCurrency?.symbol || '₹'})`,
        cell: ({ getValue }) => (
          <Typography>{(defaultCurrency?.symbol || '₹') + ' ' + getValue().toFixed(2) || '0.00'}</Typography>
        )
      }),
      columnHelper.accessor('plansBought', {
        header: 'Plans Bought',
        cell: ({ getValue }) => <Typography>{getValue() || '0'}</Typography>
      }),

      // columnHelper.accessor('records', {
      //   header: 'Records',
      //   cell: ({ row }) => (
      //     <div className='flex items-center justify-start'>
      //       <IconButton>
      //         <Link
      //           onClick={() => {
      //             localStorage.setItem('historyData', JSON.stringify(row.original.records))
      //           }}
      //           href={`/coin-plan-history/records`}
      //           className='flex'
      //         >
      //           <i className='tabler-eye text-textSecondary' />
      //         </Link>
      //       </IconButton>
      //     </div>
      //   )
      // }),
      columnHelper.accessor('records', {
        id: 'expander',
        header: 'Records',
        cell: ({ row }) => (
          <>
            <IconButton
              onClick={() =>
                setExpandedRows(prev => ({
                  ...prev,
                  [row.id]: !prev[row.id]
                }))
              }
            >
              <i className={`tabler-chevron-${expandedRows[row.id] ? 'down' : 'right'}`} />
            </IconButton>
          </>
        )
      })
    ],
    [expandedRows, defaultCurrency?.symbol]
  )

  const table = useReactTable({
    data: history,
    columns,
    getCoreRowModel: getCoreRowModel()
  })

  const updateUrlPagination = (page, pageSize) => {
    const params = new URLSearchParams(searchParams.toString())

    if (page !== 1) {
      params.set('page', page.toString())
    } else {
      params.delete('page')
    }

    if (pageSize !== 10) {
      params.set('pageSize', pageSize.toString())
    } else {
      params.delete('pageSize')
    }

    router.replace(`${pathname}?${params.toString()}`, { scroll: false })
  }

  const handleRowsPerPageChange = e => {
    const newPageSize = parseInt(e.target.value, 10)

    dispatch(setPageSize(newPageSize))
    dispatch(setPage(1))
    updateUrlPagination(1, newPageSize)
  }

  const handlePageChange = newPage => {
    dispatch(setPage(newPage))
    updateUrlPagination(newPage, searchParams.get('pageSize') ? parseInt(searchParams.get('pageSize'), 10) : pageSize)
  }

  return (
    <Box>
      <Box p={3} display='flex' justifyContent='space-between' alignItems='center'>
        <Typography variant='h5' gutterBottom>
          Coin Plan Purchase History
        </Typography>

     
          <div className='flex items-center gap-4'>
            <CustomAvatar variant='rounded' color='success' skin='light'>
              <i className='tabler-coin' />
            </CustomAvatar>
            <div>
              <Typography variant='h5'>
                {defaultCurrency?.symbol || '₹'} {adminEarnings.toFixed(2) || '0'}
              </Typography>
              <Typography>Total Earnings</Typography>
            </div>
          </div>
        
      </Box>

      <Card className=''>
        <div className='flex justify-between flex-col md:flex-row md:items-center p-6 gap-4'>
          <div className='flex items-center justify-between gap-4 w-full'>
            <CustomTextField
              select
              value={searchParams.get('pageSize') || 10}
              onChange={handleRowsPerPageChange}
              className='max-sm:is-full sm:is-[70px]'
            >
              <MenuItem value='2'>2</MenuItem>
              <MenuItem value='10'>10</MenuItem>
              <MenuItem value='25'>25</MenuItem>
              <MenuItem value='50'>50</MenuItem>
            </CustomTextField>
            <DateRangePicker
              buttonText={
                searchParams.get('startDate') && searchParams.get('endDate')
                  ? `${searchParams.get('startDate')} - ${searchParams.get('endDate')}`
                  : 'Date Range'
              }
              buttonStartIcon={<FilterListIcon />}
              buttonClassName='ms-2'
              setAction={setDateRange}
              initialStartDate={searchParams.get('startDate') ? new Date(startDate) : null}
              initialEndDate={searchParams.get('endDate') ? new Date(endDate) : null}
              showClearButton={searchParams.get('startDate') && searchParams.get('endDate')}
              onClear={() => {
                dispatch(setDateRange({ startDate: 'All', endDate: 'All' }))
                dispatch(setPage(1))
                const params = new URLSearchParams(searchParams.toString())

                params.delete('startDate')
                params.delete('endDate')
                params.set('page', '1')
                router.replace(`${pathname}?${params.toString()}`, { scroll: false })
              }}
              onApply={(newStartDate, newEndDate) => {
                dispatch(setDateRange({ startDate: newStartDate, endDate: newEndDate }))
                dispatch(setPage(1))
                const params = new URLSearchParams(searchParams.toString())
                
                if (newStartDate !== 'All') params.set('startDate', newStartDate)
                else params.delete('startDate')
                if (newEndDate !== 'All') params.set('endDate', newEndDate)
                else params.delete('endDate')
                params.set('page', '1')
                router.replace(`${pathname}?${params.toString()}`, { scroll: false })
              }}
            />
          </div>
        </div>

        <div className='overflow-x-auto'>
          {loading ? (
            <div className='flex justify-center items-center p-6 h-[55vh]'>
              <CircularProgress />
            </div>
          ) : (
            <table className={tableStyles.table}>
              <thead>
                {table.getHeaderGroups().map(headerGroup => (
                  <tr key={headerGroup.id}>
                    {headerGroup.headers.map(header => (
                      <th key={header.id} className='text-left py-2 px-4 border-b'>
                        {header.isPlaceholder ? null : flexRender(header.column.columnDef.header, header.getContext())}
                      </th>
                    ))}
                  </tr>
                ))}
              </thead>
              <tbody>
                {table.getRowModel().rows.map(row => (
                  <React.Fragment key={row.id}>
                    <tr>
                      {row.getVisibleCells().map(cell => (
                        <td key={cell.id} className='py-2 px-4  border-b'>
                          {flexRender(cell.column.columnDef.cell, cell.getContext())}
                        </td>
                      ))}
                    </tr>
                    {expandedRows[row.id] && (
                      <tr>
                        <td colSpan={columns.length} className='pt-1 px-0'>
                          <div className=''>
                            <table className='min-w-full text-sm'>
                              <thead className='bg-gray-100'>
                                <tr className='text-left'>
                                  <th style={{ fontSize: '13px', fontWeight: 500 }}>Unique ID</th>
                                  <th style={{ fontSize: '13px', fontWeight: 500 }}>Payment Gateway</th>
                                  <th style={{ fontSize: '13px', fontWeight: 500 }}>Price</th>
                                  <th style={{ fontSize: '13px', fontWeight: 500 }}>Date</th>
                                </tr>
                              </thead>
                              <tbody>
                                {row.original.records.map((record, idx) => (
                                  <tr key={idx} className='border-t'>
                                    <td>{record.uniqueId}</td>
                                    <td>{record.paymentGateway}</td>
                                    <td>{defaultCurrency?.symbol + ' ' + record.price.toFixed(2)}</td>
                                    <td>{record.date}</td>
                                  </tr>
                                ))}
                              </tbody>
                            </table>
                          </div>
                        </td>
                      </tr>
                    )}
                  </React.Fragment>
                ))}
                <EmprtyTableRow limit={9} data={history} columns={columns} noDataLebel={"No coin plan purchase history found"}/>
              </tbody>
            </table>
          )}
        </div>

        <TablePaginationComponent
          page={searchParams.get('page') ? parseInt(searchParams.get('page'), 10) : page}
          pageSize={searchParams.get('pageSize') ? parseInt(searchParams.get('pageSize'), 10) : pageSize}
          total={total}
          onPageChange={handlePageChange}
        />
      </Card>
    </Box>
  )
}

export default CoinPlanHistory
