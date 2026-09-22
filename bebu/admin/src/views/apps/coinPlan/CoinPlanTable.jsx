'use client'

import React, { useEffect, useMemo, useState } from 'react'

import { useDispatch, useSelector } from 'react-redux'

import Card from '@mui/material/Card'
import Typography from '@mui/material/Typography'
import IconButton from '@mui/material/IconButton'
import Switch from '@mui/material/Switch'
import Button from '@mui/material/Button'
import CircularProgress from '@mui/material/CircularProgress'
import MenuItem from '@mui/material/MenuItem'
import Pagination from '@mui/material/Pagination'
import { Box } from '@mui/material'

import { createColumnHelper, useReactTable, getCoreRowModel, flexRender } from '@tanstack/react-table'
import { toast } from 'react-toastify'

import {
  fetchCoinPlans,
  toggleCoinPlanField,
  deleteCoinPlan,
  setPage,
  setPageSize
} from '@/redux-store/slices/coinPlans'

import tableStyles from '@core/styles/table.module.css'
import CustomTextField from '@/@core/components/mui/TextField'

import CoinPlanDialog from './CoinPlanDialog'
import ConfirmationDialog from '@/components/dialogs/confirmation-dialog'

const columnHelper = createColumnHelper()

const CoinPlanTable = () => {
  const dispatch = useDispatch()
  const { plans, loading, page, pageSize, initialLoading } = useSelector(state => state.coinPlansReducer)



 

  const { settings } = useSelector(state => state.settings)

  const [openDialog, setOpenDialog] = useState(false)
  const [selectedPlan, setSelectedPlan] = useState(null)
  const [mode, setMode] = useState('create') // 'create' or 'edit'
  const [confirmOpen, setConfirmOpen] = useState(false)

  const [formData, setFormData] = useState({
    coin: '',
    amount: '',
    productKey: ''
  })

  // ✅ Fetch once on mount
  useEffect(() => {
    dispatch(fetchCoinPlans())
  }, [dispatch])

  // ✅ Client-side paginated data
  // const paginatedData = useMemo(() => {
  //   const start = (page - 1) * pageSize
  //   const end = start + pageSize

  //   return plans.slice(start, end)
  // }, [plans, page, pageSize])

  const handlePageChange = (_, value) => {
    dispatch(setPage(value))
  }

  const handlePageSizeChange = e => {
    dispatch(setPageSize(Number(e.target.value)))
  }

  const handleOpenDeleteDialog = plan => {
    setSelectedPlan(plan)
    setConfirmOpen(true)
  }

  const columns = useMemo(
    () => [
      columnHelper.accessor(row => row.coin, {
        id: 'coin',
        header: 'Coins',
        cell: ({ getValue }) => <Typography>{getValue() || '-'}</Typography>
      }),
      columnHelper.accessor(row => row.amount, {
        id: 'amount',
        header: `Amount (${settings?.currency?.symbol})`,
        cell: ({ getValue }) => (
          <Typography>
            {settings?.currency?.symbol} {getValue() || '-'}
          </Typography>
        )
      }),
      columnHelper.accessor(row => row.productKey, {
        id: 'productKey',
        header: 'Product Key',
        cell: ({ getValue }) => <Typography>{getValue() || '-'}</Typography>
      }),
      columnHelper.accessor(row => row.isPopular, {
        id: 'isPopular',
        header: 'Popular',
        cell: ({ row }) => (
          <Switch
            checked={row.original.isPopular || false}
            onChange={() => {
             

              dispatch(toggleCoinPlanField({ id: row.original._id, field: 'isPopular' }))
            }}
          />
        )
      }),
      columnHelper.accessor(row => row.isActive, {
        id: 'isActive',
        header: 'Active',
        cell: ({ row }) => (
          <Switch
            checked={row.original.isActive || false}
            onChange={() => {
              

              dispatch(toggleCoinPlanField({ id: row.original._id, field: 'isActive' }))
            }}
          />
        )
      }),
      columnHelper.display({
        id: 'actions',
        header: 'Actions',
        cell: ({ row }) => (
          <div className='flex gap-2'>
            <IconButton
              onClick={() => {
                setSelectedPlan(row.original) // where plan = row.original
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
    [dispatch, settings]
  )

  const table = useReactTable({
    data: plans,
    columns,
    getCoreRowModel: getCoreRowModel()
  })

  return (
    <>
      <Box className='flex justify-between items-center mb-4'>
        <Typography variant='h5'>Coin Plans</Typography>
      </Box>
      <Card className='p-4'>
        <div className='flex justify-between flex-col items-start md:flex-row md:items-center p-6 gap-4'>
          <CustomTextField
            select
            value={pageSize}
            onChange={e => {
              const newPageSize = Number(e.target.value)

              dispatch(setPageSize(newPageSize))
              dispatch(setPage(1)) // reset to first page on change
            }}
            className='max-sm:is-full sm:is-[70px]'
          >
            <MenuItem value='1'>10</MenuItem>
            <MenuItem value='25'>25</MenuItem>
            <MenuItem value='50'>50</MenuItem>
          </CustomTextField>
          <Button
            className='sm:w-auto w-full'
            variant='contained'
            onClick={() => {
              setOpenDialog(true)
            }}
          >
            + Create Coin Plan
          </Button>
        </div>

        {initialLoading ? (
          <div className='flex justify-center items-center gap-2 my-10'>
            <CircularProgress />
            <Typography>Loading...</Typography>
          </div>
        ) : (
          <>
            <div className='overflow-x-auto'>
              <table className={tableStyles.table}>
                <thead>
                  {table.getHeaderGroups().map(headerGroup => (
                    <tr key={headerGroup.id}>
                      {headerGroup.headers.map(header => (
                        <th key={header.id}>{flexRender(header.column.columnDef.header, header.getContext())}</th>
                      ))}
                    </tr>
                  ))}
                </thead>
                <tbody>
                  {plans.length === 0 ? (
                    <tr>
                      <td colSpan={columns.length} className='text-center py-6'>
                        No Coin Plans Found
                      </td>
                    </tr>
                  ) : (
                    table.getRowModel().rows.map(row => (
                      <tr key={row.id}>
                        {row.getVisibleCells().map(cell => (
                          <td key={cell.id}>{flexRender(cell.column.columnDef.cell, cell.getContext())}</td>
                        ))}
                      </tr>
                    ))
                  )}
                </tbody>
              </table>
            </div>

            {/* Pagination footer */}
            <div className='flex justify-between items-center mt-6'>
              <Pagination count={Math.ceil(plans.length / pageSize)} page={page} onChange={handlePageChange} />
            </div>
          </>
        )}
      </Card>
      <CoinPlanDialog
        open={openDialog}
        onClose={() => setOpenDialog(false)}
        mode={mode} // 'create' or 'edit'
        plan={selectedPlan}
      />
      <ConfirmationDialog
        open={confirmOpen}
        setOpen={setConfirmOpen}
        type='delete-customer' // or 'delete-order' if you want different icon/text
        onConfirm={() => {
           
    
          dispatch(deleteCoinPlan(selectedPlan._id))}
        }
        onClose={() => setConfirmOpen(false)}
      />
    </>
  )
}

export default CoinPlanTable
