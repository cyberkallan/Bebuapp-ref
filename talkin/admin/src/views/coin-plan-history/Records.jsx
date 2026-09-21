'use client'
import { useEffect, useMemo, useState } from 'react'

import { useSearchParams } from 'next/navigation' 



import { useDispatch, useSelector } from 'react-redux'


import { Box, Card, CircularProgress, Typography } from '@mui/material'

import { flexRender, getCoreRowModel, getPaginationRowModel, useReactTable } from '@tanstack/react-table'

import { fetchDefaultCurrencies } from '@/redux-store/slices/currency'
import { fetchPurchaseHistory } from '@/redux-store/slices/user'

import tableStyles from '@core/styles/table.module.css'






const Records = () => {
  const dispatch = useDispatch()
  const searchParams = useSearchParams()
    const [page, setPage] = useState(0)
    const [rowsPerPage, setRowsPerPage] = useState(10)
    const [history, setHistory] = useState([])
      const { defaultCurrency } = useSelector(state => state.currency)

  useEffect(()=>{
    setHistory(JSON.parse(localStorage.getItem("historyData")))

    if(!defaultCurrency){
      dispatch(fetchDefaultCurrencies())
    }
  },[])

    const loadHistoryData = () => {
      if (!searchParams.get('userId')) return
  
      const params = {
        userId: searchParams.get('userId'),
        start: page + 1, 
        limit: rowsPerPage,

        // startDate: startDate || 'All',
        // endDate: endDate || 'All'
      }

      dispatch(fetchPurchaseHistory(params))
     
    }
  
  // useEffect(() => {
  //   console.log("Run");
  //   loadHistoryData()
  // }, [searchParams , page , rowsPerPage ])

  const columns = useMemo(() => {
    const baseColumns = [
      {
        header: 'Unique ID',
        accessorKey: 'uniqueId'
      },
      {
        header: `Price (${defaultCurrency?.symbol || '₹'})`,
        accessorKey: 'price',
        cell: ({ getValue }) => <Typography>{((defaultCurrency?.symbol || '₹')  + " " ) + getValue().toFixed(2) || '0.00'}</Typography>
      },
      {
        header: 'Payment Gateway',
        accessorKey: 'paymentGateway'
      },
      {
        header: 'Purchase Date',
        accessorKey: 'date'
      },
    ]

    return baseColumns
  }, [])

  const table = useReactTable({
    data: history || [],
    columns,
    manualPagination: true,
    pageCount: Math.max(1, Math.ceil(history.total / history.limit)),
    state: {
      pagination: {
        pageIndex: history.page - 1,
        pageSize: history.limit
      }
    },

    // onPaginationChange: updater => {
    //   if (typeof updater === 'function') {
    //     const { pageIndex, pageSize: newPageSize } = updater({
    //       pageIndex: page - 1,
    //       pageSize
    //     })

    //     const newPage = pageIndex + 1

    //     if (newPage !== page) dispatch(setPage(newPage))

    //     if (newPageSize !== pageSize) {
    //       dispatch(setPageSize(newPageSize))
    //     }
    //   }
    // },
    getCoreRowModel: getCoreRowModel(),
    getPaginationRowModel: getPaginationRowModel()
  })
  
  return (
    <>
      <Card>
        <Box className='flex justify-between items-center p-6 border-b gap-4'>
          <Typography variant='h5'>History</Typography>
          {/* <CustomTextField
            select
            value={history.limit}
            onChange={e => {
              const newSize = Number(e.target.value)
              setPage(1)
              setRowsPerPage(newSize)
              dispatch(setHistoryPageSize(newSize))
              dispatch(setHistoryPage(1))
            }}
            className='max-sm:is-full sm:is-[70px]'
          >
            <MenuItem value='10'>10</MenuItem>
            <MenuItem value='25'>25</MenuItem>
            <MenuItem value='50'>50</MenuItem>
          </CustomTextField> */}
        </Box>

        {history.initialLoad || history.loading ? (
          <Box className='flex justify-center items-center py-10'>
            <CircularProgress />
          </Box>
        ) : (
          <div className='overflow-x-auto'>
            <table className={tableStyles.table}>
              <thead>
                {table.getHeaderGroups().map(headerGroup => (
                  <tr key={headerGroup.id}>
                    {headerGroup.headers.map(header => (
                      <th key={header.id} className='px-4 py-2 text-center'>
                        {header.isPlaceholder ? null : flexRender(header.column.columnDef.header, header.getContext())}
                      </th>
                    ))}
                  </tr>
                ))}
              </thead>
              <tbody>
                {history.length === 0 ? (
                  <tr>
                    <td colSpan={columns.length} className='text-center py-4'>
                      No History found
                    </td>
                  </tr>
                ) : (
                  table.getRowModel().rows.map(row => (
                    <tr key={row.id}>
                      {row.getVisibleCells().map(cell => (
                        <td key={cell.id} className='px-4 py-3 text-center'>
                          {flexRender(cell.column.columnDef.cell, cell.getContext())}
                        </td>
                      ))}
                    </tr>
                  ))
                )}
              </tbody>
            </table>
          </div>
        )}

        {/* <TablePagination
          component={() => (
            <TablePaginationComponent
              page={history?.page}
              pageSize={history?.limit}
              total={history?.total}
              onPageChange={newPage => {
                setPage(newPage)
                dispatch(setHistoryPage(newPage))
            }}
            />
          )}
          count={history?.total}
          rowsPerPage={history?.limit}
          page={history?.page - 1}
          onPageChange={(_, newPage) => {
            setPage(newPage + 1)
            dispatch(setHistoryPage(newPage + 1))}}
          onRowsPerPageChange={e => {
            setRowsPerPage(Number(e.target.value))
            dispatch(setHistoryPageSize(Number(e.target.value)))
            dispatch(setHistoryPage(1))
          }}
        /> */}
      </Card>
    </>
  )
}

export default Records
