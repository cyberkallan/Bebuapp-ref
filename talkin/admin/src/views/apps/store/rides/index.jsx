'use client'

import React, { useEffect, useState } from 'react'

import { useDispatch, useSelector } from 'react-redux'
import { Card, CardContent, Typography, Switch, Tooltip, IconButton, Button } from '@mui/material'
import { toast } from 'react-toastify'

import dayjs from 'dayjs'

import { deleteRide, fetchRides, toggleRideRecommendation, toggleRideStatus } from '@/redux-store/slices/rides'
import SVGAPlayer from '@/components/SVGAPlayer'
import CreateRideDialog from './CreateRideDialog'
import ConfirmationDialog from '@/components/dialogs/confirmation-dialog'
import { getFullImageUrl } from '@/utils/commonfunctions'
import Shimmer from '../Shimmer'

const RidesTable = () => {
  const dispatch = useDispatch()
  const { rides, initialLoading, loading, error } = useSelector(state => state.ridesReducer)

  

  

  const [openDialog, setOpenDialog] = useState(false)
  const [confirmDelete, setConfirmDelete] = useState({ open: false, id: null })
  const [rideToEdit, setRideToEdit] = useState(null)

  useEffect(() => {
    dispatch(fetchRides())
  }, [dispatch])

  const handleToggle = (rideId, key) => {
    

    // console.log(`Toggle ${key} for ride ${rideId}`)

    if (key === 'isActive') {
      dispatch(toggleRideStatus(rideId))
    }

    if (key === 'isRecommended') {
      dispatch(toggleRideRecommendation(rideId))
    }
  }

  const handleDelete = categoryId => {
   

    setConfirmDelete({ open: true, id: categoryId })
  }

  const confirmDeleteAction = () => {
    if (confirmDelete.id) {
      dispatch(deleteRide(confirmDelete.id))
    }

    setConfirmDelete({ open: false, id: null })
  }

  const handleEdit = ride => {
   

    setRideToEdit(ride)
    setOpenDialog(true)
  }

  if (initialLoading) {
    return <Shimmer title='Rides Collection' />
  }

  return (
    <div className='container mx-auto px-4 py-8'>
      <div className='flex justify-between items-center mb-6'>
        <h2 className='text-3xl font-bold'>Rides Collection</h2>
        <Button
          variant='contained'
          onClick={() => {
            

            setOpenDialog(true)
          }}
        >
          + Create Ride
        </Button>
      </div>
      {rides?.length === 0 && !loading && !error ? (
        <div className='text-center text-gray-500 py-16'>
          <i className='tabler-car-off text-6xl text-gray-300 mb-4' />
          <Typography variant='h5' className='mb-2'>
            No rides found
          </Typography>
          <Typography variant='body2'>
            You haven&apos;t created any rides yet. Click the button above to add one!
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
          {rides?.map(ride => {
            const imageUrl = getFullImageUrl(ride.image)

            return (
              <Card
                key={ride._id}
                className='overflow-hidden shadow-md rounded-xl border hover:shadow-xl transition-shadow duration-300'
              >
                <div className='relative bg-black h-36 flex items-center justify-center'>
                  {imageUrl ? (
                    imageUrl.endsWith('.svga') ? (
                      <SVGAPlayer url={imageUrl} width={320} height={143} />
                    ) : (
                      <img src={imageUrl} alt='ride visual' className='object-cover w-full h-full' loading='lazy' />
                    )
                  ) : (
                    <div className='text-white text-6xl'>🚗</div>
                  )}
                  {/* Badges */}
                  <Tooltip title='Recommended'>
                    <Switch
                      checked={ride.isRecommended}
                      onChange={() => handleToggle(ride._id, 'isRecommended')}
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
                      checked={ride.isActive}
                      onChange={() => handleToggle(ride._id, 'isActive')}
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
                  <Typography variant='h4' color='text.primary'>
                    {ride.name}
                  </Typography>

                  <div className='border-t pt-3 mt-3 flex justify-between text-sm text-gray-700'>
                    <div>
                      <Typography className='block'>Price</Typography>
                      <Typography variant='body2' color='text.primary'>
                        {ride.coin.toLocaleString()} Coins
                      </Typography>
                    </div>
                    <div>
                      <Typography className='block'>Validity</Typography>
                      <Typography variant='body2' color='text.primary'>
                        📅 {ride.validity}{' '}
                        {ride.validityType === 1 ? 'Days' : ride.validityType === 2 ? 'Months' : 'Years'}
                      </Typography>
                    </div>
                  </div>

                  <div className='flex justify-between items-center mt-4'>
                    <div className='text-xs text-gray-400'>
                      <Typography className='block'>Added on {dayjs(ride.createdAt).format('MMM D, YYYY')}</Typography>
                    </div>
                    <div className='flex space-x-1'>
                      <IconButton onClick={() => handleEdit(ride)}>
                        <i className='tabler-edit text-primary' />
                      </IconButton>
                      <IconButton onClick={() => handleDelete(ride._id)}>
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
      <CreateRideDialog
        open={openDialog}
        onClose={() => {
          setOpenDialog(false), setRideToEdit(null)
        }}
        mode={rideToEdit ? 'edit' : 'create'}
        ride={rideToEdit}
      />
      <ConfirmationDialog
        open={confirmDelete.open}
        setOpen={val => setConfirmDelete({ open: val, id: null })}
        type='delete-ride'
        onConfirm={confirmDeleteAction}
        loading={loading}
      />
    </div>
  )
}

export default RidesTable
