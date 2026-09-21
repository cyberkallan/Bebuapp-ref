'use client'

// React Imports
import { useEffect, useMemo, useState } from 'react'

// Next Imports
import { usePathname, useRouter, useSearchParams } from 'next/navigation'

// MUI Imports
import AddIcon from '@mui/icons-material/Add'
import DeleteIcon from '@mui/icons-material/Delete'
import EditIcon from '@mui/icons-material/Edit'
import FilterListIcon from '@mui/icons-material/FilterList'
import { Chip, CircularProgress } from '@mui/material'
import Button from '@mui/material/Button'
import Card from '@mui/material/Card'
import IconButton from '@mui/material/IconButton'
import MenuItem from '@mui/material/MenuItem'
import Typography from '@mui/material/Typography'
import { useTheme } from '@mui/material/styles'

// Third-party Imports
import { rankItem } from '@tanstack/match-sorter-utils'
import {
  createColumnHelper,
  flexRender,
  getCoreRowModel,
  getFacetedMinMaxValues,
  getFacetedRowModel,
  getFacetedUniqueValues,
  getFilteredRowModel,
  getSortedRowModel,
  useReactTable
} from '@tanstack/react-table'
import classnames from 'classnames'

import { useDispatch, useSelector } from 'react-redux'

// Component Imports
import { Visibility } from '@mui/icons-material'

import { toast } from 'react-toastify'

import TablePaginationComponent from '@components/TablePaginationComponent'

import CustomAvatar from '@core/components/mui/Avatar'
import CustomTextField from '@core/components/mui/TextField'
import ListenerDialog from './ListenerDialog'

// Style Imports
import tableStyles from '@core/styles/table.module.css'

// Actions
import {
  deleteListener,
  setDateRange,
  setPage,
  setPageSize,
  setSelectedListener
} from '@/redux-store/slices/listener'

// Utils
import Link from '@/components/Link'
import DateRangePicker from '@/components/common/DateRangePicker'
import EmprtyTableRow from '@/components/common/EmprtyTableRow'
import ConfirmationDialog from '@/components/dialogs/confirmation-dialog'
import { getFullImageUrl } from '@/utils/commonfunctions'

import { getInitials } from '@/utils/getInitials'
import { handleCopy, truncateString } from '../../user/list/UserListTable'





// Fuzzy filter for search functionality
const fuzzyFilter = (row, columnId, value, addMeta) => {

  const itemRank = rankItem(row.getValue(columnId), value)

  addMeta({ itemRank })

  return itemRank.passed
}

// Helper function for avatars
const getAvatar = ({ avatar, fullName }) => {
  if (avatar) {
    return <CustomAvatar src={avatar} skin='light' sx={{ width: 38, height: 38 }} />
  } else {
    return (
      <CustomAvatar skin='light' sx={{ width: 38, height: 38 }}>
        {getInitials(fullName || 'Unknown')}
      </CustomAvatar>
    )
  }
}

// Column helper
const columnHelper = createColumnHelper()

const ListenerListTable = () => {
  // States
  const [rowSelection, setRowSelection] = useState({})
  const [globalFilterValue, setGlobalFilterValue] = useState('')
  const [open, setOpen] = useState(false)
  const [listenerToEdit, setListenerToEdit] = useState(null)
  const [isDeleteDialogOpen, setIsDeleteDialogOpen] = useState(false)
  const [listenerToDelete, setListenerToDelete] = useState(null)
  const [deleteLoading, setDeleteLoading] = useState(false)

  const router = useRouter()
  const pathname = usePathname()
  const searchParams = useSearchParams()
  const dispatch = useDispatch()
  const theme = useTheme()
  const tabFromQuery = searchParams.get('tab')
  const [activeTab, setActiveTab] = useState(tabFromQuery ? tabFromQuery : 'real')
  const urlPageSize = parseInt(searchParams.get('pageSize') || '10')

  useEffect(() => {
    setActiveTab(tabFromQuery ? tabFromQuery : 'real')
  }, [tabFromQuery])

  // Redux state
  const { listeners, total, loading, initialLoad, page, pageSize, startDate, endDate } = useSelector(
    state => state.listener
  )

  
 

  // Handle URL updates for pagination
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

  // Column definitions
  const columns = useMemo(
    () => [
      columnHelper.accessor('name', {
        header: () => <div className=''>Listener</div>,
        cell: ({ row }) => {
          const { name, image, uniqueId, nickName } = row.original

          return (
            <div className='flex items-center gap-4'>
              {getAvatar({ avatar: getFullImageUrl(image), fullName: name })}
              <div className='flex flex-col'>
                <Typography color='text.primary' className='font-medium'>
                  {name || '-'}
                </Typography>
                {/* {nickName && <Chip color='info' variant='tonal' size='small' label={nickName} />} */}
                <Typography variant='body2'>{nickName || '-'}</Typography>
              </div>
            </div>
          )
        }
      }),
      
      // columnHelper.accessor('email', {
      //   header: () => <div className=''>Email</div>,
      //   cell: ({ row }) => <Typography  color='text.primary' className='cursor-pointer' onClick={()=>handleCopy(row.original.email)}>
      //       {row.original.loginType !== 2 ? row.original.email || '-' : truncateString(row.original.email, 20)}
      //     </Typography>
      // }),

      // columnHelper.accessor('nickName', {
      //   header: () => <div className=''>Nickname</div>,
      //   cell: ({ row }) => <Typography color='text.primary'>{row.original.nickName || '-'}</Typography>
      // }),
      columnHelper.accessor('uniqueId', {
        header: () => <div className=''>Unique Id</div>,
        cell: ({ row }) => <Typography color='text.primary'>{row.original.uniqueId || '-'}</Typography>
      }),
      columnHelper.accessor('age', {
        header: () => <div className=''>Age</div>,
        cell: ({ row }) => <Typography color='text.primary'>{row.original.age || '-'}</Typography>
      }),
      columnHelper.accessor('coin', {
        header: () => <div className=''>Coin</div>,
        cell: ({ row }) => (
          <Typography textTransform={'capitalize'} color='text.primary'>
            {row.original.totalCoins || 0}
          </Typography>
        )
      }),

      columnHelper.accessor('isOnline', {
        header: () => <div className=''>Status</div>,
        cell: ({ row }) => {
          if (row.original.isOnline) {
            return <Chip size='small' label='Online' color='success' variant='tonal' />
          } else {
            return <Chip size='small' label='Offline' color='error' variant='tonal' />
          }
        }
      }),

      columnHelper.accessor('isBusy', {
        header: () => <div className=''>Busy</div>,
        cell: ({ row }) => {
          if (row.original.isBusy) {
            return <Chip size='small' label={'Busy'} color='info' variant='tonal' />
          } else {
            return <Chip size='small' label={'Available'} color='info' variant='tonal' />
          }
        }
      }),
      columnHelper.accessor('rating', {
        header: () => <div className='text-center'>Rating</div>,
        cell: ({ row }) => (
          <Typography textTransform={'capitalize'} color='text.primary'>
            {row.original.rating || 0}
          </Typography>
        )
      }),
      columnHelper.accessor('callCount', {
        header: () => <div className='text-center'>Call Count</div>,
        cell: ({ row }) => (
          <Typography textTransform={'capitalize'} color='text.primary'>
            {row.original.callCount || 0}
          </Typography>
        )
      }),
      columnHelper.accessor('date', {
        header: () => <div className=''>Created At</div>,
        cell: ({ row }) => (
          <Typography textTransform={'capitalize'} color='text.primary'>
            {row.original.date || 0}
          </Typography>
        )
      }),
      columnHelper.accessor('action', {
        header: () => <div className=''>Action</div>,
        cell: ({ row }) => (
          <div className='flex justify-between gap-1'>
            {/* {activeTab === 'fake' && (
              <>
                <IconButton size='small' onClick={() => handleEditListener(row.original)}>
                  <EditIcon fontSize='small' />
                </IconButton>
                <IconButton size='small' onClick={() => handleDeleteListener(row.original._id)}>
                  <DeleteIcon fontSize='small' />
                </IconButton>
              </>
            )} */}

<IconButton size='small' onClick={() => handleEditListener(row.original)}>
                  <EditIcon fontSize='small' />
                </IconButton>
                <IconButton size='small' onClick={() => handleDeleteListener(row.original._id)}>
                  <DeleteIcon fontSize='small' />
                </IconButton>
            <IconButton>
              <Link
                onClick={() => {
                  // dispatch(setUserData(row.original))
                  localStorage.setItem(
                    'selectedListener',
                    JSON.stringify({ ...row.original, isFake: activeTab === 'fake' })
                  )
                  dispatch(setDateRange({ startDate: 'All', endDate: 'All' }))
                }}
                href={`/apps/listener/view?userId=${row.original._id}`}
                className='flex'
              >
                <Visibility fontSize={'small'} />
              </Link>
            </IconButton>
          </div>
        )
      })
    ],
    [activeTab]
  )

  const table = useReactTable({
    data: listeners,
    columns,
    filterFns: {
      fuzzy: fuzzyFilter
    },
    state: {
      rowSelection,
      globalFilter: globalFilterValue
    },
    enableRowSelection: true,
    onRowSelectionChange: setRowSelection,
    globalFilterFn: fuzzyFilter,
    onGlobalFilterChange: setGlobalFilterValue,
    getCoreRowModel: getCoreRowModel(),
    getFilteredRowModel: getFilteredRowModel(),
    getSortedRowModel: getSortedRowModel(),
    getFacetedRowModel: getFacetedRowModel(),
    getFacetedUniqueValues: getFacetedUniqueValues(),
    getFacetedMinMaxValues: getFacetedMinMaxValues()
  })

  const handlePageChange = newPage => {
    dispatch(setPage(newPage))
    updateUrlPagination(newPage, searchParams.get('pageSize') ? parseInt(searchParams.get('pageSize'), 10) : pageSize)
  }

  const handleRowsPerPageChange = e => {
    const newPageSize = parseInt(e.target.value, 10)

    dispatch(setPageSize(newPageSize))
    dispatch(setPage(1))
    updateUrlPagination(1, newPageSize)
  }

  const handleEditListener = listener => {
    setListenerToEdit(listener)
    dispatch(setSelectedListener(listener))
    setOpen(true)
  }

  const handleDeleteListener = listenerId => {
    setListenerToDelete(listenerId)
    setIsDeleteDialogOpen(true)
  }

  const confirmDeleteListener = async () => {
    
              
    if (listenerToDelete) {
      setDeleteLoading(true)

      try {
        await dispatch(deleteListener(listenerToDelete)).unwrap()
        setIsDeleteDialogOpen(false)
        setListenerToDelete(null)
      } catch (error) {
        console.log('Failed to delete listener:', error)
      } finally {
        setDeleteLoading(false)
      }
    }
  }

  const handleCreateListener = () => {
    setListenerToEdit(null)
    dispatch(setSelectedListener(null))
    setOpen(true)
  }

  const handleDialogClose = () => {
    setOpen(false)
    setListenerToEdit(null)
    dispatch(setSelectedListener(null))
  }

  return (
    <>
      <Card>
        <div className='flex flex-wrap gap-4 p-6 justify-between items-center'>
          <div className='flex items-center gap-4'>
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
          </div>
          <div className='flex gap-4'>
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
                params.get("page") && params.set('page', '1')
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
                params.get("page") && params.set('page', '1')
                router.replace(`${pathname}?${params.toString()}`, { scroll: false })
              }}
            />
              <Button variant='contained' startIcon={<AddIcon />} onClick={handleCreateListener}>
                Add Listener
              </Button>
          </div>
        </div>

        <div className='overflow-x-auto'>
          <div className={tableStyles.tableContainer}>
            {loading || initialLoad ? (
              <div className='flex justify-center items-center py-8 h-[55vh]'>
                <CircularProgress />
              </div>
            ) : (
              <table className={tableStyles.table}>
                <thead>
                  {table.getHeaderGroups().map(headerGroup => (
                    <tr key={headerGroup.id}>
                      {headerGroup.headers.map(header => (
                        <th key={header.id} className={tableStyles.tableHeadCell}>
                          {header.isPlaceholder
                            ? null
                            : flexRender(header.column.columnDef.header, header.getContext())}
                        </th>
                      ))}
                    </tr>
                  ))}
                </thead>
                <tbody>
                  {table.getRowModel().rows.length > 0 ? (
                    table.getRowModel().rows.map(row => (
                      <tr key={row.id} className={classnames({ selected: row.getIsSelected() })}>
                        {row.getVisibleCells().map(cell => (
                          <td key={cell.id} className={tableStyles.tableBodyCell}>
                            {flexRender(cell.column.columnDef.cell, cell.getContext())}
                          </td>
                        ))}
                      </tr>
                    ))
                  ) : (

                    // <>
                    //   <tr style={{borderBottom : "none"}}>
                    //     <td colSpan={columns.length} className='text-center py-4'>
                    //       {loading ? (
                    //         <div className='flex justify-center'>
                    //           <CircularProgress size={24} />
                    //         </div>
                    //       ) : (
                    //         'No listeners found'
                    //       )}
                    //     </td>
                    //   </tr>
                    // </>
                    ""
                  )}
                    <EmprtyTableRow limit={9} data={listeners} columns={{columns}} noDataLebel={'No listeners found'}/>
                </tbody>
              </table>
            )}
          </div>

          {/* Pagination Component */}
          <TablePaginationComponent
            page={searchParams.get('page') ? parseInt(searchParams.get('page'), 10) : page}
            pageSize={searchParams.get('pageSize') ? parseInt(searchParams.get('pageSize'), 10) : pageSize}
            total={total}
            onPageChange={handlePageChange}

            // customText={`Showing ${total === 0 ? 0 : (page - 1) * pageSize + 1} to ${Math.min(page * pageSize, total)} of ${total} entries`}
          />

        
        </div>
      </Card>

      {/* Listener Dialog for Create/Edit */}
      <ListenerDialog open={open} onClose={handleDialogClose} listener={listenerToEdit} role={activeTab} />

     

      <ConfirmationDialog
        open={isDeleteDialogOpen}
        setOpen={setIsDeleteDialogOpen}
        onClose={() => setIsDeleteDialogOpen(false)}
        type='delete-listener'
        onConfirm={confirmDeleteListener}
        loading={deleteLoading}
        
        // error={deleteError}
      />
    </>
  )
}

export default ListenerListTable
