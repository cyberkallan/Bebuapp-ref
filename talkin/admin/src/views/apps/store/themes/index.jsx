'use client'

import React, { useEffect, useState } from 'react'

import { useDispatch, useSelector } from 'react-redux'
import { Card, CardContent, Typography, Switch, Tooltip, IconButton, Button } from '@mui/material'
import dayjs from 'dayjs'
import { toast } from 'react-toastify'

import { getAllThemes, deleteTheme, toggleThemeActive, toggleThemeRecommendation } from '@/redux-store/slices/themes'

import { getFullImageUrl } from '@/utils/commonfunctions'
import CreateEditThemeDialog from './CreateEditThemeDialog'
import ConfirmationDialog from '@/components/dialogs/confirmation-dialog'
import Shimmer from '../Shimmer'

const ThemesTable = () => {
  const dispatch = useDispatch()
  const { themes, initialLoading, loading, error } = useSelector(state => state.themeReducer)

  



  const [openDialog, setOpenDialog] = useState(false)
  const [themeToEdit, setThemeToEdit] = useState(null)
  const [confirmDelete, setConfirmDelete] = useState({ open: false, id: null })

  useEffect(() => {
    dispatch(getAllThemes())
  }, [dispatch])

  const handleToggle = (themeId, key) => {
   

    if (key === 'isActive') {
      dispatch(toggleThemeActive(themeId))
    } else if (key === 'isRecommended') {
      dispatch(toggleThemeRecommendation(themeId))
    }
  }

  const handleDelete = themeId => {
    

    setConfirmDelete({ open: true, id: themeId })

    // console.log(loading)
  }

  const confirmDeleteAction = () => {
    if (confirmDelete.id) {
      dispatch(deleteTheme(confirmDelete.id))
    }

    setConfirmDelete({ open: false, id: null })
  }

  const handleEdit = theme => {
   

    setThemeToEdit(theme)
    setOpenDialog(true)
  }

  if (initialLoading) return <Shimmer title='Themes Collection' />

  return (
    <div className='container mx-auto px-4 py-8'>
      <div className='flex justify-between items-center mb-6'>
        <h2 className='text-3xl font-bold'>Themes Collection</h2>
        <Button
          variant='contained'
          onClick={() => {
           
            setOpenDialog(true)
          }}
        >
          + Create Theme
        </Button>
      </div>

      {themes?.length === 0 && !loading && !error ? (
        <div className='text-center text-gray-500 py-16'>
          <i className='tabler-palette-off text-6xl text-gray-300 mb-4' />
          <Typography variant='h5' className='mb-2'>
            No themes found
          </Typography>
          <Typography variant='body2'>
            You haven&apos;t created any themes yet. Click the button above to add one!
          </Typography>
        </div>
      ) : error ? (
        <div className='text-center text-red-500 py-16'>
          <i className='tabler-alert-triangle text-6xl text-red-300 mb-4' />
          <Typography variant='h5' className='mb-2'>
            Something went wrong
          </Typography>
          <Typography variant='body2'>{error}</Typography>
        </div>
      ) : (
        <div className='grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6'>
          {themes.map(theme => {
            const imageUrl = getFullImageUrl(theme.image)

            return (
              <Card
                key={theme._id}
                className='overflow-hidden shadow-md rounded-xl border hover:shadow-xl transition-shadow duration-300'
              >
                <div className='relative bg-black h-36 flex items-center justify-center'>
                  {imageUrl ? (
                    <img src={imageUrl} alt='theme visual' className='object-cover w-full h-full' loading='lazy' />
                  ) : (
                    <div className='text-white text-6xl'>🎨</div>
                  )}

                  <Tooltip title='Recommended'>
                    <Switch
                      checked={theme.isRecommended}
                      onChange={() => handleToggle(theme._id, 'isRecommended')}
                      color='warning'
                      className='absolute top-2 left-2'
                      sx={{
                        '& .MuiSwitch-switchBase.Mui-checked': {
                          // Keep existing style for checked state
                        },
                        '& .MuiSwitch-switchBase:not(.Mui-checked) + .MuiSwitch-track': {
                          // Only modify unchecked state
                          backgroundColor: 'rgba(255, 255, 255, 0.4) !important',
                          opacity: 0.7
                        }
                      }}
                    />
                  </Tooltip>

                  <Tooltip title='Active Status'>
                    <Switch
                      checked={theme.isActive}
                      onChange={() => handleToggle(theme._id, 'isActive')}
                      color='success'
                      className='absolute top-2 right-2'
                      sx={{
                        '& .MuiSwitch-switchBase.Mui-checked': {
                          // Keep existing style for checked state
                        },
                        '& .MuiSwitch-switchBase:not(.Mui-checked) + .MuiSwitch-track': {
                          // Only modify unchecked state
                          backgroundColor: 'rgba(255, 255, 255, 0.4) !important',
                          opacity: 0.7
                        }
                      }}
                    />
                  </Tooltip>
                </div>

                <CardContent>
                  <Typography className='text-xl font-semibold mb-1'>{theme.name}</Typography>

                  <div className='border-t pt-3 mt-3 flex justify-between text-sm text-gray-700'>
                    <div>
                      <Typography className='block'>Price</Typography>
                      <Typography className='block'>{theme.coin.toLocaleString()} Coins</Typography>
                    </div>
                    <div>
                      <Typography className='block'>Validity</Typography>
                      <Typography className='block'>
                        📅 {theme.validity}{' '}
                        {theme.validityType === 1 ? 'Days' : theme.validityType === 2 ? 'Months' : 'Years'}
                      </Typography>
                    </div>
                  </div>

                  <div className='flex justify-between items-center mt-4'>
                    <div className='text-xs text-gray-400'>
                      <Typography className='block'>Added on {dayjs(theme.createdAt).format('MMM D, YYYY')}</Typography>
                    </div>
                    <div className='flex space-x-1'>
                      <IconButton onClick={() => handleEdit(theme)}>
                        <i className='tabler-edit text-primary' />
                      </IconButton>
                      <IconButton onClick={() => handleDelete(theme._id)}>
                        <i className='tabler-trash text-error' />
                      </IconButton>
                    </div>
                  </div>
                </CardContent>
              </Card>
            )
          })}
        </div>
      )}

      <CreateEditThemeDialog
        open={openDialog}
        onClose={() => {
          setOpenDialog(false)
          setThemeToEdit(null)
        }}
        mode={themeToEdit ? 'edit' : 'create'}
        theme={themeToEdit}
      />

      <ConfirmationDialog
        open={confirmDelete.open}
        setOpen={val => setConfirmDelete({ open: val, id: null })}
        type='delete-theme'
        onConfirm={confirmDeleteAction}
        loading={loading}
      />
    </div>
  )
}

export default ThemesTable
