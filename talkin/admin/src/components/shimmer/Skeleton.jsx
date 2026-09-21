'use client'

import Box from '@mui/material/Box'

// Base skeleton component with shimmer effect
const Skeleton = ({ width, height, variant = 'rectangular', animation = 'wave', sx = {} }) => {
  const baseStyles = {
    backgroundColor: 'rgba(var(--mui-palette-primary-mainChannel) / 0.08)',
    position: 'relative',
    overflow: 'hidden',
    borderRadius: variant === 'circular' ? '50%' : variant === 'rounded' ? '8px' : '4px',
    width: width || '100%',
    height: height || '100%',
    '&::after':
      animation === 'wave'
        ? {
            content: '""',
            position: 'absolute',
            top: 0,
            right: 0,
            bottom: 0,
            left: 0,
            animation: 'shimmer 2s infinite',
            background:
              'linear-gradient(90deg, transparent, rgba(var(--mui-palette-common-white) / 0.12), transparent)',
            transform: 'translateX(-100%)'
          }
        : undefined,
    '@keyframes shimmer': {
      '100%': {
        transform: 'translateX(100%)'
      }
    },
    ...sx
  }

  return <Box sx={baseStyles} />
}

export default Skeleton
