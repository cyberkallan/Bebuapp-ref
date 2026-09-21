'use client'

import { useCallback, useEffect, useMemo, useRef, useState } from 'react'

import { useRouter, useSearchParams } from 'next/navigation'

import { useDispatch, useSelector } from 'react-redux'

// MUI Imports
import AddIcon from '@mui/icons-material/Add'
import DeleteIcon from '@mui/icons-material/Delete'
import EditIcon from '@mui/icons-material/Edit'
import { Box, Button, CircularProgress } from '@mui/material'
import Card from '@mui/material/Card'
import IconButton from '@mui/material/IconButton'
import { useTheme } from '@mui/material/styles'
import Switch from '@mui/material/Switch'
import TablePagination from '@mui/material/TablePagination'
import Typography from '@mui/material/Typography'

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

import InfiniteScroll from 'react-infinite-scroll-component'

// Component Imports
import CustomAvatar from '@core/components/mui/Avatar'
import CustomTextField from '@core/components/mui/TextField'
import DeleteConfirmDialog from './DeleteConfirmDialog'
import ListenerDialog from './ListenerDialog'

// Style Imports
import tableStyles from '@core/styles/table.module.css'

// Actions
import {
  deleteListener,
  fetchListeners,
  setDateRange,
  setIsFake,
  setPage,
  setPageSize,
  setSearchQuery,
  setSelectedListener
} from '@/redux-store/slices/listener'

// Utils
import { getFullImageUrl } from '@/utils/commonfunctions'
import { getInitials } from '@/utils/getInitials'
import DateRangePicker from '@/components/common/DateRangePicker'

// Fuzzy filter for search functionality
const fuzzyFilter = (row, columnId, value, addMeta) => {
  const itemRank = rankItem(row.getValue(columnId), value)

  addMeta({ itemRank })

  return itemRank.passed
}

// Debounced input component for search
const DebouncedInput = ({ value: initialValue, onChange, ...props }) => {
  const [value, setValue] = useState(initialValue)

  // Update local state when initialValue changes
  useEffect(() => {
    setValue(initialValue)
  }, [initialValue])

  useEffect(() => {
    const timeout = setTimeout(() => {
      if (onChange) {
        onChange(value)
      }
    }, 500)

    return () => clearTimeout(timeout)
  }, [value, onChange])

  return <CustomTextField {...props} value={value} onChange={e => setValue(e.target.value)} />
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
  const [dataLoaded, setDataLoaded] = useState(false)
  const [listenerToEdit, setListenerToEdit] = useState(null)
  const [isDeleteDialogOpen, setIsDeleteDialogOpen] = useState(false)
  const [listenerToDelete, setListenerToDelete] = useState(null)
  const [deleteLoading, setDeleteLoading] = useState(false)
  const [hasMoreData, setHasMoreData] = useState(true)
  const [infiniteScrollData, setInfiniteScrollData] = useState([])
  const [infiniteScrollPage, setInfiniteScrollPage] = useState(1)
  const [isLoadingMore, setIsLoadingMore] = useState(false)
  const scrollContainerRef = useRef(null)

  const router = useRouter()
  const searchParams = useSearchParams()
  const dispatch = useDispatch()
  const theme = useTheme()

  // Redux state
  const {
    listeners,
    total,
    loading,
    initialLoad,
    page,
    pageSize,
    searchQuery,
    startDate: reduxStartDate,
    endDate: reduxEndDate,
    isFake,
    selectedListener
  } = useSelector(state => state.listener)

  


  // Initialize infinite scroll data when listeners change
  useEffect(() => {
    if (page === 1) {
      // Reset infinite scroll data when filters change
      setInfiniteScrollData(listeners)
      setInfiniteScrollPage(1)
      setHasMoreData(listeners.length < total)
    } else if (page > infiniteScrollPage) {
      // Append data when loading more
      setInfiniteScrollData(prevData => [...prevData, ...listeners])
      setInfiniteScrollPage(page)
    }
  }, [listeners, page, total, infiniteScrollPage])

  // Initialize component with URL params
  useEffect(() => {
    // Only run this once at component mount
    if (dataLoaded) return

    const pageFromUrl = parseInt(searchParams.get('page')) || 1
    const sizeFromUrl = parseInt(searchParams.get('pageSize')) || 10
    const searchFromUrl = searchParams.get('search') || ''
    const isFakeFromUrl = searchParams.get('isFake') === 'true'
    const startDateFromUrl = searchParams.get('startDate') || 'All'
    const endDateFromUrl = searchParams.get('endDate') || 'All'

    // Synchronize URL params with Redux state
    if (pageFromUrl !== page) dispatch(setPage(pageFromUrl))
    if (sizeFromUrl !== pageSize) dispatch(setPageSize(sizeFromUrl))
    if (isFakeFromUrl !== isFake) dispatch(setIsFake(isFakeFromUrl))

    if (searchFromUrl !== searchQuery) {
      dispatch(setSearchQuery(searchFromUrl))
      setGlobalFilterValue(searchFromUrl) // Set the input field value
    }

    if (startDateFromUrl !== reduxStartDate || endDateFromUrl !== reduxEndDate) {
      dispatch(
        setDateRange({
          startDate: startDateFromUrl,
          endDate: endDateFromUrl
        })
      )
    }

    setDataLoaded(true)
  }, [searchParams, dispatch, page, pageSize, searchQuery, reduxStartDate, reduxEndDate, isFake, dataLoaded])

  // Fetch data when component mounts or filters change
  useEffect(() => {
    if (!dataLoaded) return

    // Fetch data with current filters
    dispatch(
      fetchListeners({
        page,
        limit: pageSize,
        searchQuery,
        startDate: reduxStartDate,
        endDate: reduxEndDate,
        isFake
      })
    )
  }, [dataLoaded, dispatch, page, pageSize, searchQuery, reduxStartDate, reduxEndDate, isFake])

  // Update URL when filters change
  useEffect(() => {
    if (!dataLoaded) return

    const params = new URLSearchParams()

    if (page !== 1) params.set('page', page.toString())
    if (pageSize !== 10) params.set('pageSize', pageSize.toString())
    if (isFake) params.set('isFake', isFake.toString())
    if (searchQuery) params.set('search', searchQuery)
    if (reduxStartDate !== 'All') params.set('startDate', reduxStartDate)
    if (reduxEndDate !== 'All') params.set('endDate', reduxEndDate)

    router.push(`?${params.toString()}`, { scroll: false })
  }, [dataLoaded, page, pageSize, isFake, searchQuery, reduxStartDate, reduxEndDate, router])

  // Column definitions
  const columns = useMemo(
    () => [
      columnHelper.accessor('name', {
        header: () => <div className='text-center'>Listener</div>,
        cell: ({ row }) => {
          const { name, image, uniqueId } = row.original

          return (
            <div className='flex items-center gap-4'>
              {getAvatar({ avatar: getFullImageUrl(image), fullName: name })}
              <div className='flex flex-col'>
                <Typography color='text.primary' className='font-medium'>
                  {name || '-'}
                </Typography>
                <Typography variant='body2'>{uniqueId || '-'}</Typography>
              </div>
            </div>
          )
        }
      }),
      columnHelper.accessor('email', {
        header: () => <div className='text-center'>Email</div>,
        cell: ({ row }) => (
          <div className='flex justify-center'>
            <Typography variant='body2'>{row.original.email || '-'}</Typography>
          </div>
        )
      }),
      columnHelper.accessor('talkTopics', {
        header: () => <div className='text-center'>Talk Topics</div>,
        cell: ({ row }) => {
          const talkTopics = row.original.talkTopics || []

          return (
            <div className='flex flex-wrap justify-center gap-1'>
              {talkTopics.map((topic, index) => (
                <Typography key={index} variant='caption' className='px-2 py-1 rounded-full bg-primary-100'>
                  {topic}
                </Typography>
              ))}
            </div>
          )
        }
      }),
      columnHelper.accessor('language', {
        header: () => <div className='text-center'>Languages</div>,
        cell: ({ row }) => {
          const languages = row.original.language || []

          return (
            <div className='flex flex-wrap justify-center gap-1'>
              {languages.map((lang, index) => (
                <Typography key={index} variant='caption' className='px-2 py-1 rounded-full bg-secondary-100'>
                  {lang}
                </Typography>
              ))}
            </div>
          )
        }
      }),
      columnHelper.accessor('rating', {
        header: () => <div className='text-center'>Rating</div>,
        cell: ({ row }) => (
          <div className='flex justify-center'>
            <Typography variant='body2'>{row.original.rating || '0'}</Typography>
          </div>
        )
      }),
      columnHelper.accessor('callCount', {
        header: () => <div className='text-center'>Call Count</div>,
        cell: ({ row }) => (
          <div className='flex justify-center'>
            <Typography variant='body2'>{row.original.callCount || '0'}</Typography>
          </div>
        )
      }),
      columnHelper.accessor('date', {
        header: () => <div className=''>Created At</div>,
        cell: ({ row }) => (
          <div className='flex justify-center'>
            <Typography variant='body2'>{row.original.date || '-'}</Typography>
          </div>
        )
      }),
      columnHelper.accessor('actions', {
        header: () => <div className='text-center'>Actions</div>,
        cell: ({ row }) => (
          <div className='flex justify-center gap-2'>
            <IconButton size='small' onClick={() => handleEditListener(row.original)} color='primary'>
              <EditIcon fontSize='small' />
            </IconButton>
            <IconButton size='small' onClick={() => handleDeleteListener(row.original._id)} color='error'>
              <DeleteIcon fontSize='small' />
            </IconButton>
          </div>
        )
      })
    ],
    []
  )

  const table = useReactTable({
    data: infiniteScrollData.length > 0 ? infiniteScrollData : listeners,
    columns,
    filterFns: {
      fuzzy: fuzzyFilter
    },
    state: {
      rowSelection,
      globalFilter: globalFilterValue
    },
    initialState: {
      pagination: {
        pageIndex: 0,
        pageSize: 100 // Use a large page size for infinite scroll
      }
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

  const handlePageChange = (_, newPage) => {
    // Page is 1-indexed in our state, but 0-indexed in the table
    dispatch(setPage(newPage + 1))
  }

  const handleRowsPerPageChange = e => {
    dispatch(setPageSize(parseInt(e.target.value, 10)))
    dispatch(setPage(1)) // Reset to first page
    setInfiniteScrollData([]) // Reset infinite scroll data
    setInfiniteScrollPage(1)
  }

  const handleSearch = value => {
    dispatch(setSearchQuery(value))
    dispatch(setPage(1)) // Reset to first page
    setInfiniteScrollData([]) // Reset infinite scroll data
    setInfiniteScrollPage(1)
  }

  const handleDateChange = ({ startDate, endDate }) => {
    dispatch(setDateRange({ startDate, endDate }))
    dispatch(setPage(1)) // Reset to first page
    setInfiniteScrollData([]) // Reset infinite scroll data
    setInfiniteScrollPage(1)
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
        console.error('Failed to delete listener:', error)
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

  const handleFilterToggle = () => {
    dispatch(setIsFake(!isFake))
    dispatch(setPage(1)) // Reset to first page
    setInfiniteScrollData([]) // Reset infinite scroll data
    setInfiniteScrollPage(1)
  }

  const handleDialogClose = () => {
    setOpen(false)
    setListenerToEdit(null)
    dispatch(setSelectedListener(null))
  }

  const loadMoreData = useCallback(() => {
    if (loading || !hasMoreData || isLoadingMore) return

    setIsLoadingMore(true)
    const nextPage = page + 1

    dispatch(
      fetchListeners({
        page: nextPage,
        limit: pageSize,
        searchQuery,
        startDate: reduxStartDate,
        endDate: reduxEndDate,
        isFake
      })
    ).finally(() => {
      setIsLoadingMore(false)
    })

    // Update page number in Redux state
    dispatch(setPage(nextPage))
  }, [dispatch, page, pageSize, searchQuery, reduxStartDate, reduxEndDate, isFake, loading, hasMoreData, isLoadingMore])

  return (
    <>
      <Card>
        <div className='flex flex-wrap gap-4 p-6 justify-between items-center'>
          <div className='flex items-center gap-4'>
            <DebouncedInput
              placeholder='Search listeners...'
              value={globalFilterValue}
              onChange={value => handleSearch(value)}
              className='min-w-[240px]'
            />
            <Box className='flex items-center gap-1'>
              <Typography variant='body2'>Real</Typography>
              <Switch checked={isFake} onChange={handleFilterToggle} color='primary' />
              <Typography variant='body2'>Fake</Typography>
            </Box>
          </div>
          <div className='flex gap-4'>
            <DateRangePicker startDate={reduxStartDate} endDate={reduxEndDate} onChange={handleDateChange} />
            <Button variant='contained' startIcon={<AddIcon />} onClick={handleCreateListener}>
              Add Listener
            </Button>
          </div>
        </div>

        <div className='overflow-x-auto' ref={scrollContainerRef} id='scrollableDiv'>
          <InfiniteScroll
            dataLength={infiniteScrollData.length || listeners.length}
            next={loadMoreData}
            hasMore={hasMoreData}
            loader={
              <div className='flex justify-center my-4'>
                <CircularProgress size={24} />
              </div>
            }
            endMessage={
              <div className='text-center my-4'>
                <Typography variant='body2' color='text.secondary'>
                  No more data to load
                </Typography>
              </div>
            }
            scrollableTarget='scrollableDiv'
            style={{ overflow: 'hidden' }}
          >
            <div className={tableStyles.tableContainer}>
              {loading && initialLoad ? (
                <div className='flex justify-center items-center py-8'>
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
                      table.getRowModel().rows.map(row => {
                        return (
                          <tr key={row.id} className={classnames({ selected: row.getIsSelected() })}>
                            {row.getVisibleCells().map(cell => (
                              <td key={cell.id} className={tableStyles.tableBodyCell}>
                                {flexRender(cell.column.columnDef.cell, cell.getContext())}
                              </td>
                            ))}
                          </tr>
                        )
                      })
                    ) : (
                      <tr>
                        <td colSpan={columns.length} className='text-center py-4'>
                          {loading ? (
                            <div className='flex justify-center'>
                              <CircularProgress size={24} />
                            </div>
                          ) : (
                            'No listeners found'
                          )}
                        </td>
                      </tr>
                    )}
                  </tbody>
                </table>
              )}
            </div>
          </InfiniteScroll>

          <div className='flex justify-between items-center p-4'>
            <div>
              <TablePagination
                component='div'
                count={total}
                page={page - 1}
                rowsPerPage={pageSize}
                onPageChange={handlePageChange}
                onRowsPerPageChange={handleRowsPerPageChange}
                rowsPerPageOptions={[10, 25, 50, 100]}
                className='mx-0'
              />
            </div>
          </div>
        </div>
      </Card>

      {/* Listener Dialog for Create/Edit */}
      <ListenerDialog open={open} onClose={handleDialogClose} listener={listenerToEdit} />

      {/* Delete Confirmation Dialog */}
      <DeleteConfirmDialog
        open={isDeleteDialogOpen}
        onClose={() => setIsDeleteDialogOpen(false)}
        onConfirm={confirmDeleteListener}
        loading={deleteLoading}
      />
    </>
  )
}

export default ListenerListTable
