// Optimized HostApplicationTable.jsx (based on UserListTable setup)
'use client'
import React, { useEffect, useMemo, useState } from 'react'

import { usePathname, useRouter, useSearchParams } from 'next/navigation'


import { useDispatch, useSelector } from 'react-redux'
import { useReactTable, getCoreRowModel, getPaginationRowModel, flexRender } from '@tanstack/react-table'

// MUI
import Card from '@mui/material/Card'
import Typography from '@mui/material/Typography'
import CircularProgress from '@mui/material/CircularProgress'
import TablePagination from '@mui/material/TablePagination'
import MenuItem from '@mui/material/MenuItem'
import Box from '@mui/material/Box'
import { Chip, IconButton } from '@mui/material'

// Components
import { toast } from 'react-toastify'

import CustomAvatar from '@/@core/components/mui/Avatar'
import CustomTextField from '@/@core/components/mui/TextField'
import TablePaginationComponent from '@/components/TablePaginationComponent'

// Utils
import { getInitials } from '@/utils/getInitials'
import { getFullImageUrl } from '@/utils/commonfunctions'

import tableStyles from '@core/styles/table.module.css'

// Redux

import {
  fetchlistenerRequest,
  setPage,
  setPageSize,
  setStatus,
  APPLICATION_STATUS,
  handleListenerRequest
} from '@/redux-store/slices/listenerRequest'



import ConfirmationDialog from '@/components/dialogs/confirmation-dialog'
import ReqReasonDialog from './ListenerReqDialouge'
import ReqViewDialog from './ListenerReqDialouge/ReqViewDialouge'


import EmprtyTableRow from '@/components/common/EmprtyTableRow'

const ListenerRequestTable = () => {
  const dispatch = useDispatch()
  const searchParams = useSearchParams()
  const router = useRouter()
  const pathname = usePathname()

  

  const { applications, total, page, pageSize, loading, initialLoad, status } = useSelector(
    state => state.hostApplication
  )




  const [confirmDelete, setConfirmDelete] = useState({ open: false, data: null, type: null })
  const [openDialog, setOpenDialog] = useState(false)
  const [openViewDialog, setOpenViewDialog] = useState(false)
  const [selectedData, setSelectedData] = useState(null)

  const urlPage = parseInt(searchParams.get('page') || '1')
  const urlPageSize = parseInt(searchParams.get('pageSize') || '10')

  useEffect(() => {
    const fetchData = () => {
      dispatch(fetchlistenerRequest({ page: urlPage, pageSize: urlPageSize, status }))
    }

    const timeoutId = setTimeout(fetchData, 50)

    return () => {
      clearTimeout(timeoutId)
    }
  }, [dispatch, urlPage, urlPageSize, status])

  const confirmDeleteAction = () => {
    
    
    if (confirmDelete.data) {
      dispatch(
        handleListenerRequest({
          requestId: confirmDelete?.data._id,
          userId: confirmDelete?.data.userId._id,
          type: confirmDelete.type
        })
      )
    }

    setConfirmDelete({ open: false, data: null, type: null })
  }

  const columns = useMemo(() => {
    const baseColumns = [
      {
        header: 'User',
        accessorKey: 'userId.nickName',
        cell: ({ row }) => {
          const user = row.original.userId

          return (
            <div className='flex items-center gap-4'>
              <CustomAvatar src={user?.profilePic ? getFullImageUrl(user.profilePic) : ''} size={50}>
                {getInitials(user?.fullName || 'U')}
              </CustomAvatar>
              <div className='flex flex-col'>
                <div className='flex items-center gap-1'>
                  <Typography color='text.primary' className='font-medium'>
                    {user?.fullName || '-'}
                  </Typography>
                  <Chip label={user?.gender || '-'} size='small' />
                </div>
                <Typography variant='body2'>{user?.nickName || '-'}</Typography>
                <Typography variant='body2'>{user?.uniqueId || '-'}</Typography>
              </div>
            </div>
          )
        }
      },
      {
        header: 'Listener',
        accessorKey: 'userId.email',
        cell: ({ row }) => {
          const user = row.original

          return (
            <div className='flex items-center gap-4'>
              <CustomAvatar src={user?.profilePic ? getFullImageUrl(user?.image) : ''} size={50}>
                {getInitials(user?.name || 'U')}
              </CustomAvatar>
              <div className='flex flex-col'>
                <div className='flex items-center gap-1'>
                  <Typography color='text.primary' className='font-medium'>
                    {user?.name || '-'}
                  </Typography>
                  {/* <Chip label={user?.gender || '-'} size='small' /> */}
                </div>
                <Typography variant='body2'>{user?.nickName || '-'}</Typography>
                <Typography variant='body2'>{user?.email || '-'}</Typography>
              </div>
            </div>
          )
        }
      },
      {
        header: 'Status',
        accessorKey: 'status',
        cell: ({ row }) => {
          const statusCode = Number(row.original.status)

          const statusMap = {
            [APPLICATION_STATUS.PENDING]: 'Pending',
            [APPLICATION_STATUS.APPROVED]: 'Approved',
            [APPLICATION_STATUS.REJECTED]: 'Rejected'
          }

          return (
            <Chip
              label={statusMap[statusCode] || 'Unknown'}
              size='small'
              color={
                statusMap[statusCode] === 'Approved'
                  ? 'success'
                  : statusMap[statusCode] === 'Rejected'
                    ? 'error'
                    : 'warning'
              }
              variant='tonal'
            />
          )
        }
      },
      {
        header: 'Requested Date',
        accessorKey: 'createdAt',
        cell: ({ row }) => {
          const date = new Date(row.original.createdAt)

          return date.toLocaleDateString()
        }
      }
    ]

    if (status === APPLICATION_STATUS.APPROVED || status === APPLICATION_STATUS.REJECTED) {
      baseColumns.push({
        header: 'Review Date',
        accessorKey: 'reviewedAt',

        cell: ({ row }) => {
          const reviewedAt = row.original.reviewAt

          return reviewedAt ? new Date(reviewedAt).toLocaleDateString() : '-'
        }
      })
    }

    if (status === APPLICATION_STATUS.REJECTED) {
      baseColumns.push({
        header: 'Reason',
        accessorKey: 'reason',
        cell: ({ row }) => {
          const reason = row.original.reason
            ? row.original.reason.length > 30
              ? row.original.reason.slice(0, 30) + '...'
              : row.original.reason
            : ''

          return (
            <Typography variant='p' className='truncate'>
              {reason}
            </Typography>
          )
        }
      })
    }

    // if (status === APPLICATION_STATUS.PENDING) {
    baseColumns.push({
      header: status === APPLICATION_STATUS.PENDING ? 'Action' : 'Preview',
      cell: ({ row }) => (
        <div className=''>
          {status === APPLICATION_STATUS.PENDING ? (
            <>
              <IconButton
                onClick={() => {
                  handleApprove(row.original)
                }}
                title='Approve'
              >
                <i className='tabler-circle-dashed-check text-textSecondary' />
              </IconButton>
              <IconButton
                onClick={() => {
                  handleReject(row.original)
                }}
                title='Cancel'
              >
                <i className='tabler-circle-dashed-x text-textSecondary' />
              </IconButton>
            </>
          ) : (
            ''
          )}
          <IconButton
            onClick={() => {
              setSelectedData(row.original)
              setOpenViewDialog(true)
            }}
            title='Info'
          >
            <i className='tabler-info-circle text-textSecondary' />
          </IconButton>
        </div>
      )
    })

    return baseColumns
  }, [status])

  const table = useReactTable({
    data: applications || [],
    columns,
    manualPagination: true,
    pageCount: Math.max(1, Math.ceil(total / pageSize)),
    state: {
      pagination: {
        pageIndex: page - 1,
        pageSize
      }
    },
    onPaginationChange: updater => {
      if (typeof updater === 'function') {
        const { pageIndex, pageSize: newPageSize } = updater({
          pageIndex: page - 1,
          pageSize
        })

        const newPage = pageIndex + 1

        if (newPage !== page) dispatch(setPage(newPage))

        if (newPageSize !== pageSize) {
          dispatch(setPageSize(newPageSize))
        }
      }
    },
    getCoreRowModel: getCoreRowModel(),
    getPaginationRowModel: getPaginationRowModel()
  })

  const handleApprove = data => {
    setConfirmDelete({ open: true, data: data, type: 2 })
  }

  const handleReject = data => {
    setSelectedData(data)
    setOpenDialog(true)
  }

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
        <Box className='flex justify-between items-center p-6 border-b gap-4'>
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
        </Box>

        {initialLoad || loading ? (
          <Box className='flex justify-center items-center py-10 h-[60vh] '>
            <CircularProgress />
          </Box>
        ) : (
          <div className='overflow-x-auto'>
            <table className={tableStyles.table}>
              <thead>
                {table.getHeaderGroups().map(headerGroup => (
                  <tr key={headerGroup.id} className='border-b'>
                    {headerGroup.headers.map(header => (
                      <th
                        key={header.id}
                        className='px-4 py-2 text-left'
                        style={{ width: header.column.columnDef.meta?.width }}
                      >
                        {header.isPlaceholder ? null : flexRender(header.column.columnDef.header, header.getContext())}
                      </th>
                    ))}
                  </tr>
                ))}
              </thead>
              <tbody>
                {applications.length === 0 ? (
                  
                  // <tr style={{ borderBottom: 'none' }}>
                  //   <td colSpan={columns.length} className='text-center py-4'>
                  //     No applications found
                  //   </td>
                  // </tr>
                  ""
                ) : (
                  table.getRowModel().rows.map(row => (
                    <tr key={row.id}>
                      {row.getVisibleCells().map(cell => (
                        <td key={cell.id} style={{ width: cell.column.columnDef.meta?.width }} className='px-4 py-3'>
                          {flexRender(cell.column.columnDef.cell, cell.getContext())}
                        </td>
                      ))}
                    </tr>
                  ))
                )}

                <EmprtyTableRow limit={9} data={applications} columns={columns} noDataLebel={" No applications found"} />
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
      <ConfirmationDialog
        open={confirmDelete.open}
        setOpen={val => setConfirmDelete({ open: val, data: null, type: null })}
        type='approve-request'
        onConfirm={confirmDeleteAction}
        onCancel={() => setConfirmDelete({ open: false, data: null, type: null })}
        onClose={() => setConfirmDelete({ open: false, data: null, type: null })}
      />
      <ReqReasonDialog open={openDialog} onClose={() => setOpenDialog(false)} data={selectedData} />
      <ReqViewDialog open={openViewDialog} onClose={() => setOpenViewDialog(false)} data={selectedData} />
    </>
  )
}

export default ListenerRequestTable
