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

import CustomTextField from '@/@core/components/mui/TextField'
import TablePaginationComponent from '@/components/TablePaginationComponent'
import EmprtyTableRow from '@/components/common/EmprtyTableRow'
import ConfirmationDialog from '@/components/dialogs/confirmation-dialog'
import {
  deleteCoinPlan,
  fetchCoinPlans,
  setPage,
  setPageSize,
  toggleCoinPlanField
} from '@/redux-store/slices/coinPlans'
import { fetchDefaultCurrencies } from '@/redux-store/slices/currency'

import tableStyles from '@core/styles/table.module.css'


import CoinPlanDialog from './CoinPlanDialog'

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

const CoinPlans = () => {
  const dispatch = useDispatch();
    const searchParams = useSearchParams()
    const router = useRouter()
    const pathname = usePathname()
  const { defaultCurrency } = useSelector(state => state.currency)

  const { coinPlans, initialLoading, loading, error, page, pageSize, total } = useSelector(
    state => state.coinPlansReducer
  )

  



  const [openDialog, setOpenDialog] = useState(false)
  const [selectedCoinPlan, setSelectedCoinPlan] = useState(null)
  const [mode, setMode] = useState('create')
  const [confirmOpen, setConfirmOpen] = useState(false)
  const [confirmType, setConfirmType] = useState('delete-coin-plan')

      const urlPage = parseInt(searchParams.get('page') || '1')
  const urlPageSize = parseInt(searchParams.get('pageSize') || '10')

  useEffect(() => {
    dispatch(fetchCoinPlans({page: urlPage, pageSize: urlPageSize}));
  }, [dispatch, urlPage, urlPageSize])

  useEffect(()=>{
     if(!defaultCurrency){
          dispatch(fetchDefaultCurrencies())
        }
  },[])

  // Client-side paginated data
  // const paginatedData = useMemo(() => {
  //   const start = (page - 1) * pageSize
  //   const end = start + pageSize

  //   return coinPlans.slice(start, end)
  // }, [coinPlans, page, pageSize])

  const handleOpenDeleteDialog = coinPlan => {
    setSelectedCoinPlan(coinPlan)
    setConfirmType('delete-coin-plan')
    setConfirmOpen(true)
  }

  const handleConfirmDelete = () => {
    if (selectedCoinPlan) {
      dispatch(deleteCoinPlan(selectedCoinPlan._id))
    }
  }

  const handleToggleField = (coinPlanId, field) => {
    setSelectedCoinPlan({ _id: coinPlanId })
    setConfirmType(`toggle-${field}`)
    setConfirmOpen(true)
  }

  const handleConfirmToggle = () => {
    if (selectedCoinPlan && confirmType) {
      const field = confirmType.replace('toggle-', '')

      dispatch(toggleCoinPlanField({ coinPlanId: selectedCoinPlan._id, field }))
    }
  }

  const handleConfirm = () => {
    
    
    if (confirmType === 'delete-coin-plan') {
      handleConfirmDelete()
    } else if (confirmType.startsWith('toggle-')) {
      handleConfirmToggle()
    }
  }

  const columns = useMemo(
    () => [
      columnHelper.accessor(row => row.productId, {
        id: 'productId',
        header: 'Product ID',
        cell: ({ getValue }) => <Typography>{getValue() || '-'}</Typography>
      }),
      columnHelper.accessor(row => row.coins, {
        id: 'coins',
        header: 'Coins',
        cell: ({ getValue }) => <Typography>{getValue() || '-'}</Typography>
      }),
      columnHelper.accessor(row => row.price, {
        id: 'price',
        header: `Price (${defaultCurrency?.symbol || '₹'})`,
        cell: ({ getValue }) => <Typography>{((defaultCurrency?.symbol || '₹')  + " " ) + getValue().toFixed(2) || '0.00'}</Typography>
      }),
      
      columnHelper.accessor(row => row.isPopular, {
        id: 'isPopular',
        header: 'Popular',
        cell: ({ getValue, row }) => (
          <Switch
            checked={getValue()}
            onChange={() => handleToggleField(row.original._id, 'isPopular')}
           
          />
        )
      }),
      columnHelper.accessor(row => row.isActive, {
        id: 'isActive',
        header: 'Active',
        cell: ({ getValue, row }) => (
          <Switch
            checked={getValue()}
            onChange={() => handleToggleField(row.original._id, 'isActive')}
           
          />
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
                setSelectedCoinPlan(row.original)
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
    data: coinPlans,
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
      <Box p={3}>
        <Typography variant='h5' gutterBottom>
          Coin Plan
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
            <MenuItem value='10'>10</MenuItem>
            <MenuItem value='25'>25</MenuItem>
            <MenuItem value='50'>50</MenuItem>
          </CustomTextField>
          <Button
            className='sm:w-auto w-full'
            variant='contained'
            onClick={() => {
              setMode('create')
              setSelectedCoinPlan(null)
              setOpenDialog(true)
            }}
          >
            + Create Coin Plan
          </Button>
        </div>

        <div className='overflow-x-auto'>
          {initialLoading ? (
            <div className='flex justify-center items-center p-6 h-[55vh]'>
              <CircularProgress />
            </div>
          )
          
        
           : (
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
                <EmprtyTableRow limit={9}  data={coinPlans} columns={columns} noDataLebel={"No coin plans found"}/>
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

      <CoinPlanDialog open={openDialog} onClose={() => setOpenDialog(false)} mode={mode} coinPlan={selectedCoinPlan} />

      <ConfirmationDialog
        open={confirmOpen}
        onClose={() => setConfirmOpen(false)}
        onConfirm={handleConfirm}
        type={confirmType}
        title={
          confirmType === 'delete-coin-plan'
            ? 'Are you sure you want to delete this coin plan?'
            : confirmType === 'toggle-isActive'
              ? 'Are you sure you want to change the active status?'
              : 'Are you sure you want to change the popular status?'
        }
        loading={loading}
      />
    </Box>
  )
}

export default CoinPlans
