import React from 'react'

import { Card } from '@mui/material'
import { useTheme } from '@mui/material/styles'

const Shimmer = ({ title }) => {
  const theme = useTheme()

  return (
    <div className='container mx-auto px-4 py-6'>
      <h1 className='text-3xl font-bold mb-6'>{title}</h1>
      <div className='grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6'>
        {[1, 2, 3, 4].map(item => (
          <Card key={item} className='overflow-hidden rounded-xl shadow-md relative'>
            {/* Card header with toggle switches */}
            <div className='p-3 flex justify-between items-center absolute top-0 left-0 right-0'>
              <div
                className='w-10 h-5 rounded-full animate-pulse'
                style={{ backgroundColor: theme.palette.action.hover }}
              ></div>
              <div
                className='w-10 h-5 rounded-full animate-pulse'
                style={{ backgroundColor: theme.palette.action.hover }}
              ></div>
            </div>

            {/* Image section */}
            <div className='h-40 animate-pulse' style={{ backgroundColor: theme.palette.action.hover }}></div>

            {/* Content section */}
            <div className='p-4 space-y-4'>
              {/* Title */}
              <div
                className='h-6 rounded w-3/4 animate-pulse'
                style={{ backgroundColor: theme.palette.action.hover }}
              ></div>

              {/* Divider line */}
              <div className='border-t' style={{ borderColor: theme.palette.divider }}></div>

              {/* Price and validity row */}
              <div className='flex justify-between'>
                <div className='space-y-2'>
                  <div
                    className='h-4 rounded w-16 animate-pulse'
                    style={{ backgroundColor: theme.palette.action.hover }}
                  ></div>
                  <div
                    className='h-5 rounded w-24 animate-pulse'
                    style={{ backgroundColor: theme.palette.action.hover }}
                  ></div>
                </div>
                <div className='space-y-2'>
                  <div
                    className='h-4 rounded w-16 animate-pulse'
                    style={{ backgroundColor: theme.palette.action.hover }}
                  ></div>
                  <div className='h-5 rounded flex items-center'>
                    <div
                      className='w-5 h-5 rounded animate-pulse'
                      style={{ backgroundColor: theme.palette.action.hover }}
                    ></div>
                    <div
                      className='w-16 h-4 rounded ml-2 animate-pulse'
                      style={{ backgroundColor: theme.palette.action.hover }}
                    ></div>
                  </div>
                </div>
              </div>

              <div className='flex justify-between mt-2'>
                {/* Added date */}
                <div
                  className='h-6 rounded w-32 animate-pulse'
                  style={{ backgroundColor: theme.palette.action.hover }}
                ></div>
                <div className='flex space-x-2'>
                  {/* Action buttons */}
                  <div
                    className='w-6 h-6 rounded animate-pulse'
                    style={{ backgroundColor: theme.palette.action.hover }}
                  ></div>
                  <div
                    className='w-6 h-6 rounded animate-pulse'
                    style={{ backgroundColor: theme.palette.action.hover }}
                  ></div>
                </div>
              </div>
            </div>
          </Card>
        ))}
      </div>
    </div>
  )
}

export default Shimmer
