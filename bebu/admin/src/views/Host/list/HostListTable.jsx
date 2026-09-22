// ✅ HostListTable.jsx (same layout as UserListTable)
'use client'

import { useEffect, useMemo, useRef, useState } from 'react'

import { usePathname, useRouter, useSearchParams } from 'next/navigation'

import { useDispatch, useSelector } from 'react-redux'
import { useTheme } from '@mui/material/styles'
import Card from '@mui/material/Card'
import Typography from '@mui/material/Typography'
import TablePagination from '@mui/material/TablePagination'
import MenuItem from '@mui/material/MenuItem'
import CircularProgress from '@mui/material/CircularProgress'
import Box from '@mui/material/Box'
import { IconButton, Switch } from '@mui/material'

import { toast } from 'react-toastify'
import { getCoreRowModel, useReactTable, flexRender, getPaginationRowModel } from '@tanstack/react-table'

import tableStyles from '@core/styles/table.module.css'

import CustomTextField from '@core/components/mui/TextField'
import CustomAvatar from '@core/components/mui/Avatar'
import TablePaginationComponent from '@/components/TablePaginationComponent'

import { getInitials } from '@/utils/getInitials'
import { getFullImageUrl } from '@/utils/commonfunctions'

import {
  setHostPage,
  setHostPageSize,
  setHostSearch,
  setHostType,
  toggleHostBlockStatus
} from '@/redux-store/slices/hostList'
import Link from '@/components/Link'

// import UserDetailDialog from '@/views/apps/user/list/UserDetailDialog/UserDetailDialog'

const HostListTable = ({ tableData, isAgency = false }) => {
  const dispatch = useDispatch()
  const theme = useTheme()
  const router = useRouter()
  const pathname = usePathname()
  const searchParams = useSearchParams()

  const { hostPage, hostPageSize, hostInitialLoad, hostStats, hostSearch, hostType } = useSelector(
    state => state.hostList
  )

  



  const [search, setSearch] = useState(hostSearch || '')
  const [isUserDialogOpen, setIsUserDialogOpen] = useState(false)
  const [selectedUserId, setSelectedUserId] = useState(null)

  const urlPage = parseInt(searchParams.get('page')) || 1
  const urlPageSize = parseInt(searchParams.get('pageSize')) || 10

  const hasSyncedFromUrl = useRef(false)

  useEffect(() => {
    if (hasSyncedFromUrl.current) return

    const pageFromUrl = parseInt(searchParams.get('page'))
    const sizeFromUrl = parseInt(searchParams.get('pageSize'))

    if (!isNaN(pageFromUrl) && pageFromUrl !== hostPage) dispatch(setHostPage(pageFromUrl))
    if (!isNaN(sizeFromUrl) && sizeFromUrl !== hostPageSize) dispatch(setHostPageSize(sizeFromUrl))

    hasSyncedFromUrl.current = true
  }, [searchParams, dispatch, hostPage, hostPageSize])

  // 🔍 Debounced Search Effect
  useEffect(() => {
    const timer = setTimeout(() => {
      dispatch(setHostSearch(search))
      dispatch(setHostPage(1))
    }, 400)

    return () => clearTimeout(timer)
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [search])

  const updateUrlPagination = (page, pageSize) => {
    const params = new URLSearchParams(searchParams.toString())

    params.set('page', page.toString())
    params.set('pageSize', pageSize.toString())
    router.replace(`${pathname}?${params.toString()}`)
    dispatch(setHostPage(page))
    dispatch(setHostPageSize(pageSize))
  }

  // 📋 Define Table Columns
  const columns = useMemo(
    () => [
      {
        header: 'User',
        accessorKey: 'name',
        cell: ({ row }) => (
          <div className='flex items-center gap-4'>
            <CustomAvatar src={getFullImageUrl(row.original.image)} size={34}>
              {getInitials(row.original.name)}
            </CustomAvatar>
            <div className='flex flex-col'>
              <Typography color='text.primary' className='font-medium'>
                {row.original.name || '-'}
              </Typography>
              <Typography variant='body2'>{row.original.userName || '-'}</Typography>
            </div>
          </div>
        )
      },
      {
        header: 'Unique ID',
        accessorKey: 'uniqueId'
      },
      {
        header: 'Gender',
        accessorKey: 'gender'
      },
      {
        header: 'Age',
        accessorKey: 'age'
      },
      {
        header: 'Coin',
        accessorKey: 'coin'
      },
      {
        header: 'Earned Coin',
        accessorKey: 'earnedHostCoins'
      },
      {
        header: 'Country',
        accessorKey: 'country',
        cell: ({ row }) => (
          <div className='flex items-center gap-2'>
            <span>{row.original.countryFlagImage || '🌍'}</span>
            <Typography>{row.original.country || '-'}</Typography>
          </div>
        )
      },
      {
        header: 'Followers',
        accessorKey: 'totalFollowers',
        cell: ({ row }) => (
          <Typography className='capitalize' color='text.primary' textAlign='center'>
            {row.original.totalFollowers || '0'}
          </Typography>
        )
      },
      {
        header: 'Followings',
        accessorKey: 'totalFollowings',
        cell: ({ row }) => (
          <Typography className='capitalize' color='text.primary' textAlign='center'>
            {row.original.totalFollowings || '0'}
          </Typography>
        )
      },
      {
        header: 'Friends',
        accessorKey: 'totalFriends',
        cell: ({ row }) => (
          <Typography className='capitalize' color='text.primary' textAlign='center'>
            {row.original.totalFriends || '0'}
          </Typography>
        )
      },
      {
        header: 'Posts',
        accessorKey: 'totalPosts',
        cell: ({ row }) => (
          <Typography className='capitalize' color='text.primary' textAlign='center'>
            {row.original.totalPosts || '0'}
          </Typography>
        )
      },
      {
        header: 'Videos',
        accessorKey: 'totalVideos',
        cell: ({ row }) => (
          <Typography className='capitalize' color='text.primary' textAlign='center'>
            {row.original.totalVideos || '0'}
          </Typography>
        )
      },
      {
        header: 'Blocked',
        accessorKey: 'isBlock',
        cell: ({ row }) => (
          <Switch
            id={`block-switch-${row.original._id}`}
            checked={Boolean(row.original.isBlock)}
            onChange={() => {
             

              dispatch(toggleHostBlockStatus({ id: row.original._id }))
            }}
          />
        )
      },
      {
        header: 'Action',
        accessorKey: 'action',
        cell: ({ row }) => (
          <div className='flex items-center gap-2'>
            <IconButton
              onClick={() => {
                setSelectedUserId(row.original._id)
                setIsUserDialogOpen(true)
              }}
            >
              <i className='tabler-info-circle text-textSecondary' />
            </IconButton>
            <IconButton>
              <Link href={`/apps/user/view?userId=${row.original._id}`} className='flex'>
                <i className='tabler-eye text-textSecondary' />
              </Link>
            </IconButton>
          </div>
        )
      }
    ],
    [dispatch]
  )

  // 🧠 Table Instance
  const table = useReactTable({
    data: tableData || [],
    columns,
    manualPagination: true,
    pageCount: Math.ceil((hostStats?.total || 0) / urlPageSize),
    state: {
      pagination: {
        pageIndex: urlPage - 1,
        pageSize: urlPageSize
      }
    },
    onPaginationChange: up => {
      const newPage = up.pageIndex + 1
      const newSize = up.pageSize

      if (newPage !== urlPage) dispatch(setHostPage(newPage))
      if (newSize !== urlPageSize) dispatch(setHostPageSize(newSize))
    },
    getCoreRowModel: getCoreRowModel(),
    getPaginationRowModel: getPaginationRowModel(),
    onSortingChange: updateUrlPagination,
    onSearchChange: updateUrlPagination,
    onPageSizeChange: updateUrlPagination,
    onPaginationChange: updateUrlPagination
  })

  return (
    <Card>
      <Box className='flex justify-between flex-col md:flex-row items-start md:items-center p-6 border-bs gap-4'>
        <div className='flex flex-row justify-between gap-4'>
          <CustomTextField
            select
            value={hostPageSize}
            onChange={e => {
              dispatch(setHostPageSize(Number(e.target.value)))
              dispatch(setHostPage(1))
            }}
            className='is-[70px]'
          >
            <MenuItem value='10'>10</MenuItem>
            <MenuItem value='25'>25</MenuItem>
            <MenuItem value='50'>50</MenuItem>
          </CustomTextField>

          {!isAgency && (
            <CustomTextField
              select
              value={hostType}
              onChange={e => {
                dispatch(setHostType(e.target.value))
                dispatch(setHostPage(1))
              }}
              className='ms-2 min-w-[120px]'
            >
              <MenuItem value='All'>All</MenuItem>
              <MenuItem value='active'>Active</MenuItem>
              <MenuItem value='inactive'>Inactive</MenuItem>
            </CustomTextField>
          )}
        </div>

        <CustomTextField
          placeholder='Search Host'
          value={search}
          onChange={e => setSearch(e.target.value)}
          size='small'
        />
      </Box>

      {hostInitialLoad ? (
        <Box className='flex items-center justify-center py-10 gap-2'>
          <CircularProgress />
          <Typography>Loading hosts...</Typography>
        </Box>
      ) : (
        <div className='overflow-x-auto'>
          <table className={tableStyles.table}>
            <thead>
              {table.getHeaderGroups().map(headerGroup => (
                <tr key={headerGroup.id}>
                  {headerGroup.headers.map(header => (
                    <th key={header.id} className='px-4 py-2 text-left'>
                      {header.isPlaceholder ? null : flexRender(header.column.columnDef.header, header.getContext())}
                    </th>
                  ))}
                </tr>
              ))}
            </thead>
            <tbody>
              {tableData.length === 0 ? (
                <tr>
                  <td colSpan={columns.length} className='text-center py-4'>
                    No hosts found
                  </td>
                </tr>
              ) : (
                table.getRowModel().rows.map(row => (
                  <tr key={row.id}>
                    {row.getVisibleCells().map(cell => (
                      <td key={cell.id} className='px-4 py-3'>
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

      <TablePagination
        component={() => (
          <TablePaginationComponent
            page={hostPage}
            pageSize={hostPageSize}
            total={hostStats?.total || 0}
            onPageChange={page => dispatch(setHostPage(page))}
          />
        )}
        count={hostStats?.total || 0}
        rowsPerPage={hostPageSize}
        page={hostPage - 1}
        onPageChange={(_, newPage) => dispatch(setHostPage(newPage + 1))}
        onRowsPerPageChange={e => dispatch(setHostPageSize(Number(e.target.value)))}
      />

      {/* <UserDetailDialog
        open={isUserDialogOpen}
        onClose={() => {
          setIsUserDialogOpen(false)
          setSelectedUserId(null)
        }}
        userId={selectedUserId}
        user={tableData.find(host => host._id === selectedUserId) || null}
      /> */}
    </Card>
  )
}

export default HostListTable
