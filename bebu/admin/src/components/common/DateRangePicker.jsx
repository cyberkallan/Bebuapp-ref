'use client'

import React, { useState, useEffect } from 'react'

import { useDispatch } from 'react-redux'

import Dialog from '@mui/material/Dialog'
import DialogTitle from '@mui/material/DialogTitle'
import DialogActions from '@mui/material/DialogActions'
import DialogContent from '@mui/material/DialogContent'
import Button from '@mui/material/Button'
import { DatePicker } from '@mui/x-date-pickers/DatePicker'
import { LocalizationProvider } from '@mui/x-date-pickers/LocalizationProvider'
import { AdapterDateFns } from '@mui/x-date-pickers/AdapterDateFns'
import moment from 'moment/moment'

const DateRangePicker = ({
  buttonText = 'Date Range',
  buttonVariant = 'outlined',
  buttonClassName = '',
  buttonStartIcon = null,
  initialStartDate = null,
  initialEndDate = null,
  onApply,
  setAction = null,
  showAsButton = true,
  isOpen = false,
  onClose = null,
  showClearButton = false,
  onClear = null
}) => {
  const dispatch = useDispatch()
  const [open, setOpen] = useState(isOpen)
  const [tempStartDate, setTempStartDate] = useState(initialStartDate)
  const [tempEndDate, setTempEndDate] = useState(initialEndDate)

  // Update local state when props change
  useEffect(() => {
    setTempStartDate(initialStartDate)
    setTempEndDate(initialEndDate)
  }, [initialStartDate, initialEndDate])

  // Handle open state from props
  useEffect(() => {
  setOpen(isOpen)
  }, [isOpen])

  const handleApply = () => {
    // If a custom apply function is provided, use it
    if (onApply) {
      console.log(`moment(tempStartDate).format("YYYY-MM-DD")--->` , moment(tempStartDate).format("YYYY-MM-DD") )
      console.log(`moment(tempEndDate).format("YYYY-MM-DD")--->` , moment(tempEndDate).format("YYYY-MM-DD") )
      onApply(
        tempStartDate ? moment(tempStartDate).format("YYYY-MM-DD") : 'All',
        tempEndDate ? moment(tempEndDate).format("YYYY-MM-DD") : 'All'
      )
    }

    // Otherwise use the provided Redux action if available
    else if (setAction) {
      dispatch(
        setAction({
          startDate: tempStartDate ? moment(tempStartDate).format("YYYY-MM-DD") : 'All',
          endDate: tempEndDate ? moment(tempEndDate).format("YYYY-MM-DD") : 'All'
        })
      )
    }

    if (onClose) {
      onClose()
    } else {
      setOpen(false)
    }
  }

  const handleClear = () => {
    // if (onApply) {
    //   onApply('All', 'All')
    // } else if (setAction) {
    //   dispatch(setAction({ startDate: 'All', endDate: 'All' }))
    // }

    setTempStartDate(null)
    setTempEndDate(null)

    if (onClear) onClear()

    if (onClose) {
      onClose()
    } else {
      setOpen(false)
    }
  }

  const handleDialogClose = () => {
    if (onClose) {
      onClose()
    } else {
      setOpen(false)
    }
  }

  // const isDateSelected = !!(initialStartDate || initialEndDate)

  return (
    <>
      <div style={{ display: 'inline-flex', gap: 8 }}>
        {showAsButton && (
          <Button
            variant={buttonVariant}
            onClick={() => setOpen(true)}
            className={buttonClassName}
            startIcon={buttonStartIcon}
          >
            {buttonText}
          </Button>
        )}
        {showClearButton && (
          <Button variant='outlined' color='secondary' onClick={handleClear}>
            Clear
          </Button>
        )}
      </div>
      <Dialog open={open} onClose={handleDialogClose} maxWidth='xs' fullWidth>
        <DialogTitle>Select Date Range</DialogTitle>
        <DialogContent className='flex flex-col gap-4 py-4'>
          <LocalizationProvider dateAdapter={AdapterDateFns}>
            <DatePicker
              label='Start Date'
              value={tempStartDate}
              onChange={setTempStartDate}
              slotProps={{ textField: { fullWidth: true, size: 'small' } }}
            />
            <DatePicker
              label='End Date'
              value={tempEndDate}
              onChange={setTempEndDate}
              slotProps={{ textField: { fullWidth: true, size: 'small' } }}
            />
          </LocalizationProvider>
        </DialogContent>
        <DialogActions>
          <Button onClick={handleClear}>Clear</Button>
          <Button variant='contained' onClick={handleApply}>
            Apply
          </Button>
        </DialogActions>
      </Dialog>
    </>
  )
}

export default DateRangePicker
