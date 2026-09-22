'use client'

import React, { forwardRef, useEffect, useState } from 'react'

import { useRouter, useSearchParams } from 'next/navigation'

import { useDispatch, useSelector } from 'react-redux'

// MUI Imports
import Accordion from '@mui/material/Accordion'
import AccordionDetails from '@mui/material/AccordionDetails'
import AccordionSummary from '@mui/material/AccordionSummary'
import Box from '@mui/material/Box'
import Button from '@mui/material/Button'
import Card from '@mui/material/Card'
import CircularProgress from '@mui/material/CircularProgress'
import IconButton from '@mui/material/IconButton'
import Slide from '@mui/material/Slide'
import ToggleButton from '@mui/material/ToggleButton'
import ToggleButtonGroup from '@mui/material/ToggleButtonGroup'
import Tooltip from '@mui/material/Tooltip'
import Typography from '@mui/material/Typography'

// Icons
import AddIcon from '@mui/icons-material/Add'
import DeleteIcon from '@mui/icons-material/Delete'
import EditIcon from '@mui/icons-material/Edit'
import ExpandMoreIcon from '@mui/icons-material/ExpandMore'

import { toast } from 'react-toastify'

// Third-party Imports
import {
  createColumnHelper
} from '@tanstack/react-table'

// Component Imports
import ConfirmationDialog from '@/components/dialogs/confirmation-dialog'
import FaqDialog from '@/components/dialogs/faq-dialog'

// Style Imports

// Action Imports
import { deleteFaq, fetchFaqs, setCategory, setLimit } from '@/redux-store/slices/faq'

const Transition = forwardRef(function Transition(props, ref) {
  return <Slide direction='up' ref={ref} {...props} />
})

// Column Helper
const columnHelper = createColumnHelper()

const Faqs = () => {
  const dispatch = useDispatch()
  const router = useRouter()
  const searchParams = useSearchParams()

  const { faqs, loading, initialLoading, selectedCategory, hasMore, start, limit, total } = useSelector(
    state => state.faqs
  )

  const [faqDialogOpen, setFaqDialogOpen] = useState(false)
  const [editData, setEditData] = useState(null)
  const [globalFilter, setGlobalFilter] = useState('')
  const [confirmDeleteDialogOpen, setConfirmDeleteDialogOpen] = useState(false)
  const [faqToDelete, setFaqToDelete] = useState(null)
  const [deleteLoading, setDeleteLoading] = useState(false)
  const [deleteError, setDeleteError] = useState(null)
  const [expandedPanel, setExpandedPanel] = useState(null)

  
  

  // Track the previous URL parameters to avoid duplicate API calls
  const prevParamsRef = React.useRef({
    category: null,
    page: null,
    limit: null
  })

  // Load FAQs based on URL parameters
  useEffect(() => {
    // Parse URL parameters
    const category = searchParams.get('category') || 'User'
    const page = parseInt(searchParams.get('page'), 10) || 1
    const pageSize = parseInt(searchParams.get('limit'), 10) || 10

    // Check if any relevant URL parameters have changed
    if (
      category !== prevParamsRef.current.category ||
      page !== prevParamsRef.current.page ||
      pageSize !== prevParamsRef.current.limit
    ) {
      // Update state based on URL parameters
      if (category !== selectedCategory) {
        dispatch(setCategory(category))
      }

      // Fetch FAQs with the parameters from URL
      dispatch(
        fetchFaqs({
          category,
          start: page,
          limit: pageSize
        })
      )

      // Update previous parameters for future comparison
      prevParamsRef.current = {
        category,
        page,
        limit: pageSize
      }
    }
  }, [searchParams, dispatch, selectedCategory , limit])

  // Change category handler
  const handleCategoryChange = (event, newCategory) => {
    if (newCategory) {
      const params = new URLSearchParams(searchParams.toString())

      params.set('category', newCategory)
      router.push(`?${params.toString()}`, undefined, { shallow: true })
    }
  }

  // Handle closing the FAQ dialog
  const handleCloseDialog = () => {
    setFaqDialogOpen(false)
    setEditData(null)
  }

  // Handle creating a new FAQ
  const handleCreateFaq = () => {
    setEditData(null)
    setFaqDialogOpen(true)
  }

  // Handle editing a FAQ
  const handleEditFaq = faq => {
    setEditData(faq)
    setFaqDialogOpen(true)
  }

  // Handle deleting a FAQ
  const handleDeleteFaq = faq => {
    setFaqToDelete(faq)
    setDeleteError(null)
    setConfirmDeleteDialogOpen(true)
  }

  // Confirm delete action
  const confirmDelete = async () => {
    
    
    if (!faqToDelete) return

    setDeleteLoading(true)
    setDeleteError(null)

    try {
      await dispatch(deleteFaq(faqToDelete._id)).unwrap()

      // Success - close dialog
      setConfirmDeleteDialogOpen(false)
      setFaqToDelete(null)

      // If we deleted the expanded panel, collapse it
      if (expandedPanel === faqToDelete._id) {
        setExpandedPanel(null)
      }
    } catch (error) {
      setDeleteError(error.message || 'Failed to delete FAQ')
    }

    setDeleteLoading(false)
  }

  // Cancel delete action
  const handleCancelDelete = () => {
    setConfirmDeleteDialogOpen(false)
    setFaqToDelete(null)
    setDeleteError(null)
  }

  // Handle accordion expansion
  const handleAccordionChange = panel => (event, isExpanded) => {
    setExpandedPanel(isExpanded ? panel : null)
  }

  return (
    <Box className='container'>
      <Box className='flex justify-between items-center flex-wrap gap-4 mbe-6'>
        <Typography variant='h5' >
          {selectedCategory === 'User' ? 'User FAQs' : 'Listener FAQs'}
        </Typography>
        <Box className='flex gap-2'>
          <Button
            variant='contained'
            startIcon={<AddIcon />}
            onClick={handleCreateFaq}
            className='shadow-sm hover:shadow-md transition-all'
          >
            Create {selectedCategory === "User" ? "User" : "Listener "} FAQ
          </Button>
        </Box>
      </Box>

      <Box className='mbe-6'>
        <ToggleButtonGroup
          value={selectedCategory}
          exclusive
          onChange={handleCategoryChange}
          aria-label='faq category'
          size='medium'
          color='primary'
          className='shadow-sm'
        >
          <ToggleButton value='User' className='px-6'>
            User FAQs
          </ToggleButton>
          <ToggleButton value='Listener' className='px-6'>
            Listener FAQs
          </ToggleButton>
        </ToggleButtonGroup>
      </Box>

      <Card>
        <div className='flex justify-between flex-col items-start md:flex-row md:items-center p-6 border-bs gap-4'>
          {/* <CustomTextField select value={limit} onChange={handlePageSizeChange} className='max-sm:is-full sm:is-[70px]'>
            <MenuItem value='10'>10</MenuItem>
            <MenuItem value='25'>25</MenuItem>
            <MenuItem value='50'>50</MenuItem>
          </CustomTextField> */}
        </div>

        {initialLoading ? (
          <div className='flex items-center justify-center gap-2 grow is-full my-10'>
            <CircularProgress />
          </div>
        ) : faqs.length === 0 ? (
          <div className='flex flex-col items-center justify-center py-10'>
            <Typography variant='h6'>No FAQs Found</Typography>
            <Typography color='text.secondary'>Add a new FAQ by clicking the &quot;Create FAQ&quot; button above.</Typography>
          </div>
        ) : (
          <div className='p-6 pt-0'>
            {faqs.map(faq => (
              <Accordion
                key={faq._id}
                expanded={expandedPanel === faq._id}
                onChange={handleAccordionChange(faq._id)}
                className='mb-4'
              >
                <AccordionSummary
                  expandIcon={<ExpandMoreIcon />}
                  aria-controls={`panel-${faq._id}-content`}
                  id={`panel-${faq._id}-header`}
                >
                  <Typography>{faq.question}</Typography>
                </AccordionSummary>
                <AccordionDetails>
                  <Box className='flex flex-col gap-4'>
                    <Typography color='text.secondary'>{faq.answer}</Typography>
                    <Box className='flex justify-end gap-2'>
                      <Tooltip title='Edit FAQ'>
                        <IconButton
                          onClick={e => {
                            e.stopPropagation()
                            handleEditFaq(faq)
                          }}
                          size='small'
                        >
                          <EditIcon fontSize='small' />
                        </IconButton>
                      </Tooltip>
                      <Tooltip title='Delete FAQ'>
                        <IconButton
                          onClick={e => {
                            e.stopPropagation()
                            handleDeleteFaq(faq)
                          }}
                          color='error'
                          size='small'
                        >
                          <DeleteIcon fontSize='small' />
                        </IconButton>
                      </Tooltip>
                    </Box>
                  </Box>
                </AccordionDetails>
              </Accordion>
            ))}
          </div>
        )}

      </Card>

      {/* FAQ dialog for create/edit */}
      <FaqDialog open={faqDialogOpen} onClose={handleCloseDialog} editData={editData} />

      {/* Delete Confirmation Dialog */}
      <ConfirmationDialog
        open={confirmDeleteDialogOpen}
        onClose={handleCancelDelete}
        onConfirm={confirmDelete}
        title='Delete FAQ'
        content='Are you sure you want to delete this FAQ?'
        loading={deleteLoading}
        error={deleteError}
        type='delete-faq'
      />
    </Box>
  )
}

export default Faqs
