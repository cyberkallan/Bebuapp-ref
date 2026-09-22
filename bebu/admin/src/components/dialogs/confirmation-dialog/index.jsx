'use client'

import { Fragment, useEffect, useState } from 'react'

import Dialog from '@mui/material/Dialog'
import DialogContent from '@mui/material/DialogContent'
import DialogActions from '@mui/material/DialogActions'
import Typography from '@mui/material/Typography'
import Button from '@mui/material/Button'
import CircularProgress from '@mui/material/CircularProgress'

// Icons
import ErrorOutlineIcon from '@mui/icons-material/ErrorOutline'
import CheckCircleOutlineIcon from '@mui/icons-material/CheckCircleOutline'
import CancelOutlinedIcon from '@mui/icons-material/CancelOutlined'

const ConfirmationDialog = ({
  open,
  onClose,
  type,
  title,
  content,
  onConfirm,
  loading,
  error,
  confirmButtonText = 'Yes, Confirm',
  cancelButtonText = 'Cancel'
}) => {
  const [dialogState, setDialogState] = useState('confirmation') // 'confirmation', 'success', 'error', 'cancelled'
  const [isProcessing, setIsProcessing] = useState(false)

  // Use Fragment or div based on type
  const Wrapper = type === 'suspend-account' ? 'div' : Fragment

  // Reset state when dialog opens/closes
  useEffect(() => {
    if (!open) {
      // Reset state when dialog closes
      setTimeout(() => {
        setDialogState('confirmation')
        setIsProcessing(false)
      }, 300) // Short delay to prevent flashing between state changes
    }
  }, [open])

  // Handle API result changes
  useEffect(() => {
    if (isProcessing && !loading) {
      if (error) {
        setDialogState('error')
      } else {
        setDialogState('success')
      }

      setIsProcessing(false)
    }
  }, [loading, error, isProcessing])

  // Handle primary confirmation
  const handleConfirmation = () => {
    setIsProcessing(true)
    if (onConfirm) onConfirm()
  }

  // Handle cancellation
  const handleCancel = () => {
    setDialogState('cancelled')
  }

  // Close all dialogs and reset state
  const handleFinalClose = () => {
    if (onClose) onClose()
  }

  // Get success message based on action type
  const getSuccessMessage = () => {
    if (title) return `${title.replace(/\?/g, '')} successful.`

    const messages = {
      'delete-account': 'Your account has been deactivated successfully.',
      unsubscribe: 'Your subscription cancelled successfully.',
      'suspend-account': 'User has been suspended.',
      'delete-order': 'Your order deleted successfully.',
      'delete-customer': 'Your customer removed successfully.',
      'delete-listener': 'Listener deleted succefully.',
      'delete-category': 'Your category deleted successfully.',
      'delete-ride': 'Your ride deleted successfully.',
      'delete-theme': 'Your theme deleted successfully.',
      'delete-frame': 'Your frame deleted successfully.',
      'delete-wealth-level': 'Your wealth level deleted successfully.',
      'delete-gift': 'Your gift deleted successfully.',
      'delete-hashtag': 'Your hashtag deleted successfully.',
      'delete-talk-topic': 'Your talk topic deleted successfully.',
      'delete-identity-proof': 'Identity proof deleted successfully.',
      'delete-reason': 'Report reason deleted successfully.',
      'delete-post': 'Post deleted successfully.',
      'delete-reaction': 'Reaction deleted successfully.',
      'approve-payout': 'Payout request approved successfully.',
      'reject-payout': 'Payout request rejected successfully.',
      'approve-request': 'Requset approve successfully.',
      default: 'Success!'
    }

    return messages[type] || messages.default
  }

  // Get cancel message based on action type
  const getCancelMessage = () => {
    if (title) return `${title.replace(/\?/g, '')} cancelled.`

    const messages = {
      'delete-account': 'Account Deactivation Cancelled!',
      unsubscribe: 'Unsubscription Cancelled!',
      'suspend-account': 'Cancelled Suspension :)',
      'delete-order': 'Order Deletion Cancelled',
      'delete-customer': 'Customer Deletion Cancelled',
      'delete-listener': 'Listener Deletion Cancelled',
      'delete-category': 'Category Deletion Cancelled',
      'delete-ride': 'Ride Deletion Cancelled',
      'delete-theme': 'Theme Deletion Cancelled',
      'delete-frame': 'Frame Deletion Cancelled',
      'delete-wealth-level': 'Wealth Level Deletion Cancelled',
      'delete-gift': 'Gift Deletion Cancelled',
      'delete-hashtag': 'Hashtag Deletion Cancelled',
      'delete-talk-topic': 'Talk Topic Deletion Cancelled',
      'delete-identity-proof': 'Identity Proof Deletion Cancelled',
      'delete-reason': 'Report Reason Deletion Cancelled',
      'delete-post': 'Post Deletion Cancelled',
      'delete-reaction': 'Reaction Deletion Cancelled',
      'approve-payout': 'Payout approval cancelled',
      'reject-payout': 'Payout rejection cancelled',
      'approve-request': 'Request approval cancelled',
      default: 'Action Cancelled'
    }

    return messages[type] || messages.default
  }

  // Get confirmation title based on action type
  const getConfirmationTitle = () => {
    if (title) return title

    const titles = {
      'delete-account': 'Are you sure you want to deactivate your account?',
      unsubscribe: 'Are you sure to cancel your subscription?',
      'suspend-account': 'Are you sure?',
      'delete-order': 'Are you sure?',
      'delete-customer': 'Are you sure?',
      'delete-listener': 'Are you sure you want to delete this listener?',
      'delete-category': 'Are you sure you want to delete this category?',
      'delete-ride': 'Are you sure you want to delete this ride?',
      'delete-theme': 'Are you sure you want to delete this theme?',
      'delete-frame': 'Are you sure you want to delete this frame?',
      'delete-wealth-level': 'Are you sure you want to delete this wealth level?',
      'delete-gift': 'Are you sure you want to delete this gift?',
      'delete-hashtag': 'Are you sure you want to delete this hashtag?',
      'delete-talk-topic': 'Are you sure you want to delete this talk topic?',
      'delete-identity-proof': 'Are you sure you want to delete this identity proof?',
      'delete-reason': 'Are you sure you want to delete this report reason?',
      'delete-post': 'Are you sure you want to delete this post?',
      'delete-reaction': 'Are you sure you want to delete this reaction?',
      'approve-request': 'Are you sure you want to approve this request?',
      default: 'Are you sure?'
    }

    return titles[type] || titles.default
  }

  // Get confirmation content
  const getConfirmationContent = () => {
    if (content) return content

    return `You won't be able to revert this ${type?.replace('delete-', '').replace('-', ' ') || 'action'}!`
  }

  // Determine if the result dialog should be shown
  const isConfirmationDialog = dialogState === 'confirmation'
  const isResultDialog = ['success', 'error', 'cancelled'].includes(dialogState)

  return (
    <>
      {/* Confirmation Dialog */}
      <Dialog
        fullWidth
        maxWidth='xs'
        open={open && isConfirmationDialog}
        onClose={() => !loading && handleCancel()}
        closeAfterTransition={false}
      >
        <DialogContent className='flex items-center flex-col text-center sm:pbs-16 sm:pbe-6 sm:pli-16'>
          <ErrorOutlineIcon color='warning' sx={{ fontSize: 80, mb: 2 }} />
          <Typography variant='h5' sx={{ mb: 1 }}>
            {getConfirmationTitle()}
          </Typography>
          <Typography color='text.secondary'>{getConfirmationContent()}</Typography>
        </DialogContent>
        <DialogActions className='justify-center pbs-0 sm:pbe-16 sm:pli-16'>
          <Button variant='contained' onClick={handleConfirmation} disabled={loading}>
            {loading ? <CircularProgress size={20} sx={{ color: 'white' }} /> : confirmButtonText}
          </Button>
          <Button variant='tonal' color='secondary' onClick={handleCancel} disabled={loading}>
            {cancelButtonText}
          </Button>
        </DialogActions>
      </Dialog>

      {/* Result Dialog */}
      <Dialog open={open && isResultDialog} onClose={handleFinalClose} closeAfterTransition={false}>
        <DialogContent className='flex items-center flex-col text-center sm:pbs-16 sm:pbe-6 sm:pli-16'>
          {dialogState === 'success' ? (
            <CheckCircleOutlineIcon color='success' sx={{ fontSize: 80, mb: 2 }} />
          ) : dialogState === 'error' ? (
            <CancelOutlinedIcon color='error' sx={{ fontSize: 80, mb: 2 }} />
          ) : (
            <CancelOutlinedIcon color='warning' sx={{ fontSize: 80, mb: 2 }} />
          )}
          <Typography variant='h5' className='mbe-2'>
            {dialogState === 'error' ? 'Action Failed' : dialogState === 'success' ? 'Success' : 'Cancelled'}
          </Typography>
          <Typography color='text.secondary'>
            {dialogState === 'error' ? error : dialogState === 'success' ? getSuccessMessage() : getCancelMessage()}
          </Typography>
        </DialogContent>
        <DialogActions className='justify-center pbs-0 sm:pbe-16 sm:pli-16'>
          <Button
            variant='contained'
            color={dialogState === 'error' ? 'error' : dialogState === 'success' ? 'success' : 'secondary'}
            onClick={handleFinalClose}
          >
            Ok
          </Button>
        </DialogActions>
      </Dialog>
    </>
  )
}

export default ConfirmationDialog
