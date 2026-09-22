'use client'

import React, { useEffect, useState } from 'react'

import { useDispatch, useSelector } from 'react-redux'
import { Button, Card, CardContent, IconButton, Switch, Tooltip, Typography } from '@mui/material'
import { toast } from 'react-toastify'
import dayjs from 'dayjs'

import { getAllFrames, deleteFrame, toggleFrameActive, toggleFrameRecommendation } from '@/redux-store/slices/frames'

import Shimmer from '../Shimmer'
import SVGAPlayer from '@/components/SVGAPlayer'
import { getFullImageUrl } from '@/utils/commonfunctions'
import CreateEditFrameDialog from './CreateEditFrameDialog'
import ConfirmationDialog from '@/components/dialogs/confirmation-dialog'

const Frames = () => {
  const { frames, initialLoading, loading, error } = useSelector(state => state.frameReducer)

  

  

  const dispatch = useDispatch()

  const [openDialog, setOpenDialog] = useState(false)
  const [frameToEdit, setFrameToEdit] = useState(null)
  const [confirmDelete, setConfirmDelete] = useState({ open: false, id: null })

  useEffect(() => {
    dispatch(getAllFrames())
  }, [dispatch])

  const handleToggle = (frameId, key) => {
    

    if (key === 'isActive') dispatch(toggleFrameActive(frameId))
    else if (key === 'isRecommended') dispatch(toggleFrameRecommendation(frameId))
  }

  const handleDelete = frameId => {
   

    setConfirmDelete({ open: true, id: frameId })
  }

  const confirmDeleteAction = () => {
    if (confirmDelete.id) {
      dispatch(deleteFrame(confirmDelete.id))
    }

    setConfirmDelete({ open: false, id: null })
  }

  const handleEdit = frame => {
    

    setFrameToEdit(frame)
    setOpenDialog(true)
  }

  const handleCreate = () => {
   

    setFrameToEdit(null)
    setOpenDialog(true)
  }

  if (initialLoading) return <Shimmer title='Frames Collection' />

  return (
    <div className='container mx-auto px-4 py-8'>
      <div className='flex justify-between items-center mb-6'>
        <h2 className='text-3xl font-bold'>Frames Collection</h2>
        <Button variant='contained' onClick={handleCreate}>
          + Create Frame
        </Button>
      </div>

      {frames?.length === 0 && !loading && !error ? (
        <div className='text-center text-gray-500 py-16'>
          <i className='tabler-car-off text-6xl text-gray-300 mb-4' />
          <Typography variant='h5' className='mb-2'>
            No frames found
          </Typography>
          <Typography variant='body2'>
            You haven&apos;t created any frames yet. Click the button above to add one!
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
          {frames.map(frame => {
            const imageUrl = getFullImageUrl(frame.image)

            return (
              <Card
                key={frame._id}
                className='overflow-hidden shadow-md rounded-xl border hover:shadow-xl transition-shadow duration-300'
              >
                <div className='relative bg-black h-36 flex items-center justify-center'>
                  {imageUrl ? (
                    imageUrl.endsWith('.svga') ? (
                      <SVGAPlayer url={imageUrl} width={320} height={143} />
                    ) : (
                      <img src={imageUrl} alt='frame preview' className=' h-full' loading='lazy' />
                    )
                  ) : (
                    <div className='text-white text-6xl'>🖼️</div>
                  )}

                  <Tooltip title='Recommended'>
                    <Switch
                      checked={frame.isRecommended}
                      onChange={() => handleToggle(frame._id, 'isRecommended')}
                      color='warning'
                      className='absolute top-2 left-2'
                      sx={{
                        '& .MuiSwitch-switchBase:not(.Mui-checked) + .MuiSwitch-track': {
                          backgroundColor: 'rgba(255, 255, 255, 0.4) !important',
                          opacity: 0.7
                        }
                      }}
                    />
                  </Tooltip>

                  <Tooltip title='Active Status'>
                    <Switch
                      checked={frame.isActive}
                      onChange={() => handleToggle(frame._id, 'isActive')}
                      color='success'
                      className='absolute top-2 right-2'
                      sx={{
                        '& .MuiSwitch-switchBase:not(.Mui-checked) + .MuiSwitch-track': {
                          backgroundColor: 'rgba(255, 255, 255, 0.4) !important',
                          opacity: 0.7
                        }
                      }}
                    />
                  </Tooltip>
                </div>

                <CardContent>
                  <Typography className='text-xl font-semibold mb-1'>{frame.name}</Typography>

                  <div className='border-t pt-3 mt-3 flex justify-between text-sm text-gray-700'>
                    <div>
                      <Typography className='block'>Price</Typography>
                      <Typography className='block'>{frame.coin.toLocaleString()} Coins</Typography>
                    </div>
                    <div>
                      <Typography className='block'>Validity</Typography>
                      <Typography className='block'>
                        📅 {frame.validity}{' '}
                        {frame.validityType === 1 ? 'Days' : frame.validityType === 2 ? 'Months' : 'Years'}
                      </Typography>
                    </div>
                  </div>

                  <div className='flex justify-between items-center mt-4'>
                    <div className='text-xs text-gray-400'>
                      <Typography className='block'>Added on {dayjs(frame.createdAt).format('MMM D, YYYY')}</Typography>
                    </div>
                    <div className='flex space-x-1'>
                      <IconButton onClick={() => handleEdit(frame)}>
                        <i className='tabler-edit text-primary' />
                      </IconButton>
                      <IconButton onClick={() => handleDelete(frame._id)}>
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

      <CreateEditFrameDialog
        open={openDialog}
        onClose={() => {
          setOpenDialog(false)
          setFrameToEdit(null)
        }}
        mode={frameToEdit ? 'edit' : 'create'}
        frame={frameToEdit}
      />

      <ConfirmationDialog
        open={confirmDelete.open}
        setOpen={val => setConfirmDelete({ open: val, id: null })}
        type='delete-frame'
        onConfirm={confirmDeleteAction}
        loading={loading}
      />
    </div>
  )
}

export default Frames
