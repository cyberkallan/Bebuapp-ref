import React, { useEffect, useState } from 'react'

import { useDispatch, useSelector } from 'react-redux'

import {
  Box,
  Button,
  Card,
  IconButton,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  Typography,
  Tooltip,
  CircularProgress
} from '@mui/material'
import { toast } from 'react-toastify'

import { fetchCurrencies, deleteCurrency, setDefaultCurrency } from '@/redux-store/slices/currency'
import CurrencyDialog from '../dialogs/CurrencyDialog'
import ConfirmationDialog from '@/components/dialogs/confirmation-dialog'
import EmprtyTableRow from '@/components/common/EmprtyTableRow'

const CurrencySettings = () => {
  const dispatch = useDispatch()
  const { currencies, loading, initialLoading } = useSelector(state => state.currency)
  



  const [dialogOpen, setDialogOpen] = useState(false)
  const [confirmDialogOpen, setConfirmDialogOpen] = useState(false)
  const [selectedCurrency, setSelectedCurrency] = useState(null)
  const [mode, setMode] = useState('create')

  useEffect(() => {
    dispatch(fetchCurrencies())
  }, [dispatch])

  const handleAdd = () => {
   
    setMode('create')
    setSelectedCurrency(null)
    setDialogOpen(true)
  }

  const handleEdit = currency => {
    

    setMode('edit')
    setSelectedCurrency(currency)
    setDialogOpen(true)
  }

  const handleDelete = currency => {
    

    setSelectedCurrency(currency)
    setConfirmDialogOpen(true)
  }

  const handleSetDefault = async currencyId => {
    

    try {
      await dispatch(setDefaultCurrency(currencyId)).unwrap()
    } catch (error) {
      console.error('Failed to set default currency:', error)
    }
  }

  const handleConfirmDelete = async () => {
    

    if (selectedCurrency) {
      try {
        await dispatch(deleteCurrency(selectedCurrency._id)).unwrap()
        setConfirmDialogOpen(false)
        setSelectedCurrency(null)
      } catch (error) {
        console.error('Failed to delete currency:', error)
      }
    }
  }

  return (
    <Box className='flex flex-col gap-6'>
      <Box className='flex justify-between items-center'>
        <Typography variant='h5'>Currency Setting</Typography>
        <Box className='flex justify-end'>
        <Button variant='contained' startIcon={<i className='tabler-plus' />} onClick={handleAdd}>
          Add Currency
        </Button>
      </Box>
      </Box>
     

      {initialLoading ? (
        <Box className='flex justify-center items-center h-[55vh]'>
          <CircularProgress />
        </Box>
      ) : (
        <Card>
          <TableContainer>
            <Table>
              <TableHead>
                <TableRow>
                  <TableCell >Name</TableCell>
                  <TableCell >Symbol</TableCell>
                  <TableCell >Country Code</TableCell>
                  <TableCell >Currency Code</TableCell>
                  <TableCell >Default</TableCell>
                  <TableCell >Actions</TableCell>
                </TableRow>
              </TableHead>
              <TableBody>
                {currencies.map(currency => (
                  <TableRow key={currency._id} hover>
                    <TableCell className='p-4' >{currency.name}</TableCell>
                    <TableCell className='p-4' >{currency.symbol}</TableCell>
                    <TableCell className='p-4' >{currency.countryCode}</TableCell>
                    <TableCell className='p-4' >{currency.currencyCode}</TableCell>
                    <TableCell className='p-4' >
                      <IconButton
                        color={currency.isDefault ? 'primary' : 'default'}
                        onClick={() => !currency.isDefault && handleSetDefault(currency._id)}
                        disabled={currency.isDefault}
                      >
                        <i className={currency.isDefault ? 'tabler-star-filled' : 'tabler-star'} />
                      </IconButton>
                    </TableCell>
                    <TableCell className='p-4'>
                      <Box className='flex justify-center gap-2'>
                        <Tooltip title='Edit'>
                          <span>
                            <IconButton color='primary' onClick={() => handleEdit(currency)}>
                              <i className='tabler-pencil' />
                            </IconButton>
                          </span>
                        </Tooltip>
                        <Tooltip title='Delete'>
                          <span>
                            <IconButton
                              color='error'
                              onClick={() => handleDelete(currency)}
                              disabled={currency.isDefault}
                            >
                              <i className='tabler-trash' />
                            </IconButton>
                          </span>
                        </Tooltip>
                      </Box>
                    </TableCell>
                  </TableRow>
                ))}

                {/* {!initialLoading && currencies.length === 0 && (
                  <TableRow>
                    <TableCell colSpan={6} align='center'>
                      <Typography color='text.secondary'>No currencies found</Typography>
                    </TableCell>
                  </TableRow>
                )} */}

                <EmprtyTableRow limit={7} data={currencies} columns={{length : 10}}  noDataLebel={"No currencies found"} paddingClass={"py-9"}/>
              </TableBody>
            </Table>
          </TableContainer>
        </Card>
      )}

     

      <CurrencyDialog
        open={dialogOpen}
        onClose={() => {
          setDialogOpen(false)
          setSelectedCurrency(null)
        }}
        mode={mode}
        currency={selectedCurrency}
      />

      <ConfirmationDialog
        open={confirmDialogOpen}
        onClose={() => {
          setConfirmDialogOpen(false)
          setSelectedCurrency(null)
        }}
        onConfirm={handleConfirmDelete}
        title='Delete Currency'
        message={`Are you sure you want to delete ${selectedCurrency?.name}? This action cannot be undone.`}
      />
    </Box>
  )
}

export default CurrencySettings
