import { useId } from 'react'

import { Button, Typography } from '@mui/material'

const StyledFileInput = ({ onChange, label = 'Upload File', accept, required = false }) => {
  const uniqueId = useId()
  const inputId = `upload-button-file-${uniqueId}`

  return (
    <div className='flex flex-col gap-1'>
      <input
        accept={accept}
        type='file'
        onChange={onChange}
        id={inputId}
        required={required}
        style={{ display: 'none' }}
      />
      <label htmlFor={inputId}>
        <Button variant='outlined' component='span' startIcon={<i className='tabler-upload text-[18px]' />} fullWidth>
          {label}
        </Button>
        {accept && (
          <Typography variant='caption' color='text.secondary' className='mt-1 block'>
            Accepted formats: {accept.split(',').join(', ')}
          </Typography>
        )}
      </label>
    </div>
  )
}

export default StyledFileInput
