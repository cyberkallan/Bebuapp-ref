'use client'

import { useEffect, useMemo, useState } from 'react'

import { usePathname, useRouter, useSearchParams } from 'next/navigation'

import { createColumnHelper, flexRender, getCoreRowModel, useReactTable } from '@tanstack/react-table'
import { useDispatch, useSelector } from 'react-redux'

import Box from '@mui/material/Box'
import Button from '@mui/material/Button'
import Card from '@mui/material/Card'
import CircularProgress from '@mui/material/CircularProgress'
import IconButton from '@mui/material/IconButton'
import MenuItem from '@mui/material/MenuItem'
import Switch from '@mui/material/Switch'
import Typography from '@mui/material/Typography'
import { toast } from 'react-toastify'

import CustomAvatar from '@/@core/components/mui/Avatar'
import CustomTextField from '@/@core/components/mui/TextField'
import TablePaginationComponent from '@/components/TablePaginationComponent'
import EmprtyTableRow from '@/components/common/EmprtyTableRow'
import ConfirmationDialog from '@/components/dialogs/confirmation-dialog'
import { baseURL } from '@/config'
import {
  deletePaymentOption,
  fetchPaymentOptions,
  setPage,
  setPageSize,
  togglePaymentOptionStatus
} from '@/redux-store/slices/paymentOptions'

import tableStyles from '@core/styles/table.module.css'


import PaymentOptionDialog from './PaymentOptionDialog'

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

const PaymentOptions = () => {
  const dispatch = useDispatch()
  const searchParams = useSearchParams()
  const router = useRouter()
  const pathname = usePathname()

  const { paymentOptions, initialLoading, loading, error, page, pageSize, total } = useSelector(
    state => state.paymentOptions
  )

  



  const [openDialog, setOpenDialog] = useState(false)
  const [selectedPaymentOption, setSelectedPaymentOption] = useState(null)
  const [mode, setMode] = useState('create')
  const [confirmOpen, setConfirmOpen] = useState(false)
  const [confirmType, setConfirmType] = useState('delete-payment-option')

  const urlPage = parseInt(searchParams.get('page') || '1')
  const urlPageSize = parseInt(searchParams.get('pageSize') || '10')

  useEffect(() => {
    dispatch(fetchPaymentOptions({ page: urlPage, pageSize: urlPageSize }))
  }, [dispatch, urlPage, urlPageSize])

  // Client-side paginated data
  // const paginatedData = useMemo(() => {
  //   const start = (page - 1) * pageSize
  //   const end = start + pageSize

  //   return paymentOptions.slice(start, end)
  // }, [paymentOptions, page, pageSize])

  const handleOpenDeleteDialog = paymentOption => {
    setSelectedPaymentOption(paymentOption)
    setConfirmType('delete-payment-option')
    setConfirmOpen(true)
  }

  const handleConfirmDelete = () => {
    if (selectedPaymentOption) {
      dispatch(deletePaymentOption(selectedPaymentOption._id))
    }
  }

  const handleToggleStatus = paymentOptionId => {
    

    setSelectedPaymentOption({ _id: paymentOptionId })
    setConfirmType('toggle-status')
    setConfirmOpen(true)
  }

  const handleConfirmToggle = () => {
    if (selectedPaymentOption) {
      dispatch(togglePaymentOptionStatus(selectedPaymentOption._id))
    }
  }

  const handleConfirm = () => {
      
    
    if (confirmType === 'delete-payment-option') {
      handleConfirmDelete()
    } else if (confirmType === 'toggle-status') {
      handleConfirmToggle()
    }
  }

  const columns = useMemo(
    () => [
      columnHelper.accessor(row => row.image, {
        id: 'image',
        header: 'Image',
        cell: ({ row }) => (
          <div className='flex items-center gap-4'>
            <CustomAvatar
              size={56}
              alt='Victor Anderson'
              variant='rounded'
              src={`${baseURL}/${row?.original?.image}`}
            />
          </div>
        )
      }),
      columnHelper.accessor(row => row.name, {
        id: 'name',
        header: 'Name',
        cell: ({ getValue }) => <Typography>{getValue() || '-'}</Typography>
      }),

      columnHelper.accessor(row => row.details, {
        id: 'details',
        header: 'Details',
        cell: ({ getValue }) => (
          <div>
            {Array.isArray(getValue()) ? (
              <ul className='list-disc list-inside'>
                {getValue().map((detail, index) => (
                  <li key={index}>{detail}</li>
                ))}
              </ul>
            ) : (
              <Typography>-</Typography>
            )}
          </div>
        )
      }),
      columnHelper.accessor(row => row.isActive, {
        id: 'isActive',
        header: 'Active',
        cell: ({ getValue, row }) => (
          <Switch checked={getValue()} onChange={() => handleToggleStatus(row.original._id)}  />
        )
      }),
      columnHelper.accessor(row => row.createdAt, {
        id: 'createdAt',
        header: 'Created At',
        cell: ({ getValue }) => <Typography>{formatDate(getValue())}</Typography>
      }),
      columnHelper.display({
        id: 'actions',
        header: 'Actions',
        cell: ({ row }) => (
          <div className='flex gap-2'>
            <IconButton
              onClick={() => {
                setSelectedPaymentOption(row.original)
                setMode('edit')
                setOpenDialog(true)
              }}
            >
              <i className='tabler-edit text-primary' />
            </IconButton>
            <IconButton
              onClick={() => {
             
                handleOpenDeleteDialog(row.original)
              }}
            >
              <i className='tabler-trash text-error' />
            </IconButton>
          </div>
        )
      })
    ],
    []
  )

  const table = useReactTable({
    data: paymentOptions,
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
    <>
      <Box p={3}>
        <Typography variant='h5' gutterBottom>
          Payment Option
        </Typography>
      </Box>

      <Card className=''>
        <div className='flex justify-between flex-col items-start md:flex-row md:items-center p-6 gap-4'>
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
          <Button
            className='sm:w-auto w-full'
            variant='contained'
            onClick={() => {
              setMode('create')
              setSelectedPaymentOption(null)
              setOpenDialog(true)
            }}
          >
            + Create Payment Option
          </Button>
        </div>

        <div className='overflow-x-auto'>
          {initialLoading ? (
            <div className='flex justify-center items-center p-6 h-[55vh]'>
              <CircularProgress />
            </div>
          ) : (

            //  : paymentOptions.length === 0 ? (
            //   <>
            //   <Typography className='p-6 text-center'>No payment options found</Typography>
            //   <table>
            //     <tbody>
            //        <EmprtyTableRow limit={urlPageSize} data={paymentOptions} columns={columns} />
            //     </tbody>
            //   </table>
            //   </>
            // )
            <table className={tableStyles.table}>
              <thead>
                {table.getHeaderGroups().map(headerGroup => (
                  <tr key={headerGroup.id}>
                    {headerGroup.headers.map(header => (
                      <th key={header.id}>
                        {header.isPlaceholder ? null : flexRender(header.column.columnDef.header, header.getContext())}
                      </th>
                    ))}
                  </tr>
                ))}
              </thead>
              <tbody>
                {table.getRowModel().rows.map(row => (
                  <tr key={row.id}>
                    {row.getVisibleCells().map(cell => (
                      <td key={cell.id}>{flexRender(cell.column.columnDef.cell, cell.getContext())}</td>
                    ))}
                  </tr>
                ))}
                <EmprtyTableRow
                  limit={urlPageSize}
                  data={paymentOptions}
                  columns={columns}
                  noDataLebel={'No payment options found'}
                />
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

      <PaymentOptionDialog
        open={openDialog}
        onClose={() => setOpenDialog(false)}
        mode={mode}
        paymentOption={selectedPaymentOption}
      />

      <ConfirmationDialog
        open={confirmOpen}
        onClose={() => {
          setConfirmOpen(false)
          setMode('create')
        }}
        onConfirm={handleConfirm}
        type={confirmType}
        title={
          confirmType === 'delete-payment-option'
            ? 'Are you sure you want to delete this payment option?'
            : 'Are you sure you want to change the active status?'
        }
        loading={loading}
      />
    </>
  )
}

export default PaymentOptions
