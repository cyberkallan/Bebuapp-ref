import { useState, useEffect } from 'react'

import axios from 'axios'

// MUI Imports
import Drawer from '@mui/material/Drawer'
import Box from '@mui/material/Box'
import Typography from '@mui/material/Typography'
import IconButton from '@mui/material/IconButton'
import Avatar from '@mui/material/Avatar'
import List from '@mui/material/List'
import ListItem from '@mui/material/ListItem'
import Skeleton from '@mui/material/Skeleton'
import Divider from '@mui/material/Divider'
import Button from '@mui/material/Button'
import Dialog from '@mui/material/Dialog'
import DialogActions from '@mui/material/DialogActions'
import DialogContent from '@mui/material/DialogContent'
import DialogContentText from '@mui/material/DialogContentText'
import DialogTitle from '@mui/material/DialogTitle'

// Icons
import CloseIcon from '@mui/icons-material/Close'
import PersonIcon from '@mui/icons-material/Person'
import PublicIcon from '@mui/icons-material/Public'
import AccessTimeIcon from '@mui/icons-material/AccessTime'
import DeleteIcon from '@mui/icons-material/Delete'
import { toast } from 'react-toastify'

// API Key Import
import { secretKey, baseURL } from '@/config'
import { getFullImageUrl } from '@/utils/commonfunctions'
import CustomChip from '@/@core/components/mui/Chip'

// Helper function to get auth headers
const getAuthHeaders = () => {
  if (typeof window !== 'undefined') {
    const token = localStorage.getItem('admin_token')
    const uid = localStorage.getItem('uid')

    return {
      'Content-Type': 'application/json',
      key: secretKey,
      Authorization: `Bearer ${token}`,
      'x-admin-uid': uid
    }
  }

  return {}
}

// Helper function to format date
const formatDate = dateString => {
  if (!dateString) return ''

  const date = new Date(dateString)

  return date.toLocaleString('en-US', {
    year: 'numeric',
    month: 'short',
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit'
  })
}

// Loading skeleton component
const LoadingSkeleton = () => (
  <>
    {[1, 2, 3].map(index => (
      <ListItem key={index} sx={{ display: 'block', py: 2 }}>
        <Box sx={{ display: 'flex', alignItems: 'center', mb: 1 }}>
          <Skeleton variant='circular' width={40} height={40} sx={{ mr: 2 }} />
          <Skeleton variant='text' width={120} height={24} />
        </Box>
        <Skeleton variant='text' width={180} height={20} sx={{ ml: 7, mb: 0.5 }} />
        <Skeleton variant='text' width={150} height={20} sx={{ ml: 7, mb: 0.5 }} />
        <Skeleton variant='text' width={200} height={20} sx={{ ml: 7 }} />
      </ListItem>
    ))}
  </>
)

const SocialDrawer = ({ open, onClose, type, itemId, drawerType }) => {
  const [data, setData] = useState([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState(null)
  const [page, setPage] = useState(1)
  const [hasMore, setHasMore] = useState(true)
  const [total, setTotal] = useState(0)
  const [deleteDialogOpen, setDeleteDialogOpen] = useState(false)
  const [commentToDelete, setCommentToDelete] = useState(null)
  const [deleteLoading, setDeleteLoading] = useState(false)

  const fetchData = async () => {
    try {
      setLoading(true)
      setError(null)

      // Normalize the type parameter
      const normalizedType = type.includes('fake') ? 'fakePost' : type === 'video' ? 'video' : 'post'

      let url

      if (drawerType === 'likes') {
        url = `${baseURL}/api/admin/likeHistory/fetchUserLikeHistoryByType?start=${page}&limit=10&type=${normalizedType}&itemId=${itemId}`
      } else {
        // For comments, we need to specify the ID parameter based on the content type
        url = `${baseURL}/api/admin/comment/getComments?${normalizedType === 'video' ? 'videoId' : 'postId'}=${itemId}`
      }

      const response = await axios.get(url, {
        headers: getAuthHeaders()
      })

      if (response.data.status) {
        if (drawerType === 'likes') {
          setData(prev => [...prev, ...response.data.history])
          setTotal(response.data.total)
          setHasMore(response.data.history.length === 10)
        } else {
          setData(response.data.data || [])
          setTotal(response.data.data?.length || 0)
          setHasMore(false)
        }
      } else {
        setError(response.data.message)
      }
    } catch (error) {
      setError(error.message || 'Failed to fetch data')
    } finally {
      setLoading(false)
    }
  }

  // Handle comment deletion
  const handleDeleteComment = async () => {
    if (!commentToDelete) return

    try {
      setDeleteLoading(true)

      const response = await axios.delete(`${baseURL}/api/admin/comment/deleteComment?commentId=${commentToDelete}`, {
        headers: getAuthHeaders()
      })

      if (response.data.status) {
        // Remove the deleted comment from the list
        setData(prev => prev.filter(comment => comment._id !== commentToDelete))
        setTotal(prev => prev - 1)

        toast.success('Comment deleted successfully')
      } else {
        setError(response.data.message || 'Failed to delete comment')
        toast.error('Failed to delete comment')
      }
    } catch (error) {
      setError(error.message || 'Failed to delete comment')
      toast.error('Failed to delete comment')
    } finally {
      setDeleteLoading(false)
      setDeleteDialogOpen(false)
      setCommentToDelete(null)
    }
  }

  const openDeleteDialog = commentId => {
    setCommentToDelete(commentId)
    setDeleteDialogOpen(true)
  }

  useEffect(() => {
    if (open && itemId) {
      fetchData()
    }

    // Reset state when drawer closes
    if (!open) {
      setData([])
      setPage(1)
      setHasMore(true)
      setTotal(0)
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [open, itemId, page])

  const handleScroll = event => {
    const { scrollTop, clientHeight, scrollHeight } = event.target

    if (scrollHeight - scrollTop <= clientHeight * 1.5 && !loading && hasMore) {
      setPage(prev => prev + 1)
    }
  }

  // Render like item
  const renderLikeItem = item => {
    const user = item.user || {}

    return (
      <>
        <Box sx={{ mb: 1 }} display='flex' gap={1}>
          <Typography variant='body1' sx={{ fontWeight: 500 }}>
            {user.name}
          </Typography>
          <CustomChip label={user.userName} variant='tonal' skin='light' color='secondary' size='small' />
        </Box>

        <Box sx={{ display: 'flex', alignItems: 'center', mb: 0.5 }}>
          <PersonIcon fontSize='small' sx={{ mr: 1, color: 'text.secondary', fontSize: '1rem' }} />
          <Typography variant='body2' color='text.secondary'>
            ID: {user.uniqueId}
          </Typography>
        </Box>

        <Box sx={{ display: 'flex', alignItems: 'center', mb: 0.5 }}>
          <PublicIcon fontSize='small' sx={{ mr: 1, color: 'text.secondary', fontSize: '1rem' }} />
          <Typography variant='body2' color='text.secondary'>
            Country: {user.countryFlagImage && `${user.countryFlagImage} `}
            {user.country?.charAt(0).toUpperCase() + user.country?.slice(1)}
          </Typography>
        </Box>

        <Box sx={{ display: 'flex', alignItems: 'center' }}>
          <AccessTimeIcon fontSize='small' sx={{ mr: 1, color: 'text.secondary', fontSize: '1rem' }} />
          <Typography variant='body2' color='text.secondary'>
            Liked: {formatDate(item.likedAt)}
          </Typography>
        </Box>
      </>
    )
  }

  // Render comment item
  const renderCommentItem = item => {
    return (
      <>
        <Box sx={{ mb: 1, display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
          <Box>
            <Box sx={{ display: 'flex', justifyContent: 'space-between' }}>
              <Typography variant='body1' sx={{ fontWeight: 500 }}>
                {item.name}
              </Typography>
            </Box>
            <Typography variant='body2' color='text.secondary'>
              {item.userName}
            </Typography>
            <Typography variant='body2' sx={{ color: 'text.primary' }}>
              {item.commentText}
            </Typography>
          </Box>

          {drawerType === 'comments' && (
            <Box className='flex flex-col items-end gap-2'>
              <IconButton
                className='w-fit'
                size='small'
                color='error'
                onClick={() => openDeleteDialog(item._id)}
                sx={{ ml: 1 }}
              >
                <DeleteIcon fontSize='small' />
              </IconButton>
              <Typography variant='caption' color='text.secondary'>
                {item.time}
              </Typography>
            </Box>
          )}
        </Box>
      </>
    )
  }

  return (
    <>
      <Drawer
        anchor='right'
        open={open}
        onClose={onClose}
        PaperProps={{
          sx: {
            width: '100%',
            maxWidth: '400px',
            zIndex: 1300
          }
        }}
      >
        <Box sx={{ height: '100%', display: 'flex', flexDirection: 'column' }}>
          {/* Header */}
          <Box
            sx={{
              p: 2,
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'space-between',
              borderBottom: 1,
              borderColor: 'divider'
            }}
          >
            <Typography variant='h6'>{drawerType === 'likes' ? `Likes (${total})` : `Comments (${total})`}</Typography>
            <IconButton onClick={onClose} size='small'>
              <CloseIcon />
            </IconButton>
          </Box>

          {/* Content */}
          <List sx={{ flex: 1, overflow: 'auto', p: 0 }} onScroll={handleScroll}>
            {loading && data.length === 0 ? (
              <LoadingSkeleton />
            ) : error ? (
              <Box sx={{ p: 2, textAlign: 'center' }}>
                <Typography color='error'>{error}</Typography>
              </Box>
            ) : data.length === 0 ? (
              <Box sx={{ p: 2, textAlign: 'center' }}>
                <Typography color='text.secondary'>No {drawerType} yet</Typography>
              </Box>
            ) : (
              <>
                {data.map((item, index) => (
                  <Box key={index}>
                    <ListItem
                      sx={{
                        display: 'flex',
                        alignItems: 'flex-start',
                        p: 2
                      }}
                    >
                      <Avatar
                        src={getFullImageUrl(drawerType === 'likes' ? item.user?.image : item.image)}
                        alt={(drawerType === 'likes' ? item.user?.name : item.name) || ''}
                        sx={{ mr: 2 }}
                      />
                      <Box sx={{ flex: 1 }}>
                        {drawerType === 'likes' ? renderLikeItem(item) : renderCommentItem(item)}
                      </Box>
                    </ListItem>
                    {index < data.length - 1 && <Divider />}
                  </Box>
                ))}
                {loading && <LoadingSkeleton />}
              </>
            )}
          </List>
        </Box>
      </Drawer>

      {/* Delete Confirmation Dialog */}
      <Dialog open={deleteDialogOpen} onClose={() => setDeleteDialogOpen(false)}>
        <DialogTitle>Delete Comment</DialogTitle>
        <DialogContent>
          <DialogContentText>
            Are you sure you want to delete this comment? This action cannot be undone.
          </DialogContentText>
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setDeleteDialogOpen(false)} disabled={deleteLoading}>
            Cancel
          </Button>
          <Button
            onClick={handleDeleteComment}
            color='error'
            disabled={deleteLoading}
            startIcon={deleteLoading ? null : <DeleteIcon />}
          >
            {deleteLoading ? 'Deleting...' : 'Delete'}
          </Button>
        </DialogActions>
      </Dialog>
    </>
  )
}

export default SocialDrawer
