'use client'

import { useMemo } from 'react'

import { usePathname, useRouter, useSearchParams } from 'next/navigation'

import { useDispatch, useSelector } from 'react-redux'

// MUI Imports
import {
  Button,
  Card,
  CircularProgress,
  IconButton,
  MenuItem,
  Typography
} from '@mui/material'

// Third-party Imports
import {
  createColumnHelper,
  flexRender,
  getCoreRowModel,
  getPaginationRowModel,
  getSortedRowModel,
  useReactTable
} from '@tanstack/react-table'
import classnames from 'classnames'
import { toast } from 'react-toastify'

// Component Imports
import CustomAvatar from '@/@core/components/mui/Avatar'
import CustomTextField from '@/@core/components/mui/TextField'
import TablePaginationComponent from '@/components/TablePaginationComponent'

// Style Imports
import tableStyles from '@/@core/styles/table.module.css'
import { setPage, setPageSize } from '@/redux-store/slices/payoutRequests'
import { getFullImageUrl } from '@/utils/commonfunctions'
import { getInitials } from '@/utils/getInitials'


import DateRangePicker from '@/components/common/DateRangePicker'
import EmprtyTableRow from '@/components/common/EmprtyTableRow'

// Column Definitions
const columnHelper = createColumnHelper()

const PayoutRequestsTable = ({ personType, statusType, showActions, onAccept, onReject, handleReason }) => {
  const dispatch = useDispatch()
  const { requests, loading, page, pageSize, total } = useSelector(state => state.payoutRequests)
  
  const { defaultCurrency } = useSelector(state => state.currency)
  const searchParams = useSearchParams()
  const router = useRouter()
  const pathname = usePathname()
  const urlPageSize = parseInt(searchParams.get('pageSize')) || 10



  console.log('personType-->', personType)

  // Get appropriate person label
  const getPersonLabel = useMemo(() => {
    switch (personType) {
      case 1:
        return 'Agency'
      case 2:
        return 'Host'
      case 3:
        return 'User'
      default:
        return 'Unknown'
    }
  }, [personType])

  // Format date
  const formatDate = dateString => {
    if (!dateString) return '-'

    return new Date(dateString).toLocaleString()
  }

  const getAvatar = params => {
    const { avatar, fullName } = params

    if (avatar) {
      return <CustomAvatar src={avatar} size={34} />
    } else {
      return <CustomAvatar size={34}>{getInitials(fullName)}</CustomAvatar>
    }
  }

  // Define columns
  const columns = useMemo(
    () => [
      columnHelper.accessor('user', {
        header: 'User',
        cell: ({ row }) => {
          const { listenerId } = row?.original
          const { name, image, uniqueId } = listenerId || {}

          return (
            <div className='flex items-center gap-4'>
              {getAvatar({ avatar: getFullImageUrl(image), fullName: name })}
              <div className='flex flex-col'>
                <Typography color='text.primary' className='font-medium'>
                  {name || '-'}
                </Typography>
                {uniqueId && <Typography variant='body2'>{uniqueId}</Typography>}
              </div>
            </div>
          )
        }
      }),
      columnHelper.accessor('uniqueId', {
        header: 'Unique Id',
        cell: ({ row }) => (
          <Typography className='font-medium' color='text.primary'>
            {row.original.uniqueId || '-'}
          </Typography>
        )
      }),
      columnHelper.accessor('coin', {
        header: 'Coins',
        cell: ({ row }) => <Typography color='text.primary'>{row.original.coin || '0'}</Typography>
      }),
      columnHelper.accessor('amount', {
        header: `Amount (${defaultCurrency?.symbol || '₹'})`,
        cell: ({ row }) => (
          <Typography color='text.primary'>
            {defaultCurrency?.symbol + ' ' + row.original.amount || defaultCurrency?.symbol + ' ' + '0'}
          </Typography>
        )
      }),
      columnHelper.accessor('paymentGateway', {
        header: 'Payment Method',
        cell: ({ row }) => <Typography color='text.primary'>{row.original.paymentGateway || '-'}</Typography>
      }),
      columnHelper.accessor('paymentDetails', {
        header: 'Payment Details',
        cell: ({ row }) => {
          const details = row.original.paymentDetails || {}

          return (
            <div className='flex flex-col'>
              {Object.entries(details).map(([key, value]) => (
                <Typography key={key} color='text.primary'>
                  {`${key}: ${value}`}
                </Typography>
              ))}
            </div>
          )
        }
      }),

      columnHelper.accessor('requestDate', {
        header: 'Request Date',
        cell: ({ row }) => <Typography color='text.primary'>{formatDate(row.original.requestDate)}</Typography>
      }),
      ...(personType !== 1
        ? [
            columnHelper.accessor('acceptOrDeclineDate', {
              header: personType === 2 ? 'Accepted Date' : 'Rejected Date',
              cell: ({ row }) => (
                <Typography color='text.primary'>{formatDate(row.original.acceptOrDeclineDate)}</Typography>
              )
            }),
            ...(personType === 3
              ? [
                  columnHelper.accessor('reason', {
                    header: 'Reason',
                    cell: ({ row }) => (
                      <IconButton
                        color='text.primary'
                        onClick={() => {
                          handleReason && handleReason(row.original.reason)
                        }}
                      >
                        <i className='tabler-eye text-textSecondary' />
                      </IconButton>
                    )

                    // cell: ({ row }) => <Typography color='text.primary' className='truncate'>{row.original.reason || '-'}</Typography>
                  })
                ]
              : [])
          ]
        : []),
      ...(personType === 1
        ? [
            columnHelper.accessor('actions', {
              header: () => <div className='text-center'>Actions</div>,
              cell: ({ row }) => (
                <div className='flex items-center justify-center gap-2'>
                  <Button
                    variant='contained'
                    color='success'
                    size='small'
                    onClick={() => {
                      
                      onAccept && onAccept(row.original._id, row.original.listenerId._id)
                    }}
                  >
                    Approve
                  </Button>
                  <Button
                    variant='outlined'
                    color='error'
                    size='small'
                    onClick={() => {
                      onReject && onReject(row.original._id, row.original.listenerId._id)
                    }}
                  >
                    Reject
                  </Button>
                </div>
              ),
              enableSorting: false
            })
          ]
        : [])
    ],
    [personType, statusType, showActions, getPersonLabel, onAccept, onReject]
  )

  // Initialize table
  const table = useReactTable({
    data: requests || [],
    columns,
    state: {
      pagination: {
        pageIndex: page - 1,
        pageSize: pageSize
      }
    },
    manualPagination: true,
    enableSorting: false,
    getCoreRowModel: getCoreRowModel(),
    getSortedRowModel: getSortedRowModel(),
    getPaginationRowModel: getPaginationRowModel()
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
    <>
      <Card>
        <div className='flex justify-between flex-col items-start md:flex-row md:items-center p-6 border-bs gap-4'>
          <CustomTextField
            select
            value={searchParams.get('pageSize') || 10}
            onChange={handleRowsPerPageChange}
            className='max-sm:is-full sm:is-[70px]'
          >
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
            buttonStartIcon={<i className='tabler-calendar' />}

            // setAction={setDateRange}
            initialStartDate={searchParams.get('startDate') || null}
            initialEndDate={searchParams.get('endDate') || null}
            showClearButton={searchParams.get('startDate') && searchParams.get('endDate')}
            onApply={(newStartDate, newEndDate) => {
              const params = new URLSearchParams(searchParams.toString())

              if (newStartDate !== 'All') params.set('startDate', newStartDate)
              else params.delete('startDate')
              if (newEndDate !== 'All') params.set('endDate', newEndDate)
              else params.delete('endDate')
              params.get('page') && params.set('page', '1')
              router.replace(`${pathname}?${params.toString()}`, { scroll: false })
            }}
            onClear={() => {
              const params = new URLSearchParams(searchParams.toString())

              params.delete('startDate')
              params.delete('endDate')
              router.replace(`${pathname}?${params.toString()}`, { scroll: false })
            }}
          />
        </div>

        {loading ? (
          <div className='flex items-center justify-center p- h-[55vh]'>
            <CircularProgress />
          </div>
        ) : (
          <div className='overflow-x-auto'>
            <table className={tableStyles.table}>
              <thead className='border-b'>
                {table.getHeaderGroups().map(headerGroup => (
                  <tr key={headerGroup.id}>
                    {headerGroup.headers.map(header => (
                      <th key={header.id}>
                        {header.isPlaceholder ? null : (
                          <div
                            className={classnames({
                              'flex items-center': header.column.getIsSorted(),
                              'cursor-pointer select-none': header.column.getCanSort()
                            })}
                            onClick={header.column.getToggleSortingHandler()}
                          >
                            {flexRender(header.column.columnDef.header, header.getContext())}
                            {{
                              asc: <i className='tabler-chevron-up text-xl' />,
                              desc: <i className='tabler-chevron-down text-xl' />
                            }[header.column.getIsSorted()] ?? null}
                          </div>
                        )}
                      </th>
                    ))}
                  </tr>
                ))}
              </thead>
              <tbody>
                {table.getRowModel().rows.length > 0
                  ? table.getRowModel().rows.map(row => (
                      <tr key={row.id}>
                        {row.getVisibleCells().map(cell => (
                          <td key={cell.id}>{flexRender(cell.column.columnDef.cell, cell.getContext())}</td>
                        ))}
                      </tr>
                    ))
                  : // <tr style={{borderBottom : "none"}}>
                    //   <td colSpan={columns.length} className='text-center p-4'>
                    //     <Typography>No payout requests found</Typography>
                    //   </td>
                    // </tr>
                    ''}
                <EmprtyTableRow limit={9} data={requests} columns={columns} noDataLebel={'No payout requests found'} />
              </tbody>
            </table>
          </div>
        )}

        <TablePaginationComponent
          page={searchParams.get('page') ? parseInt(searchParams.get('page'), 10) : page}
          pageSize={searchParams.get('pageSize') ? parseInt(searchParams.get('pageSize'), 10) : pageSize}
          total={total}
          onPageChange={handlePageChange}
        />
      </Card>
    </>
  )
}

export default PayoutRequestsTable
