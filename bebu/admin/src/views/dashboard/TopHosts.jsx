import Box from '@mui/material/Box'
import Card from '@mui/material/Card'
import Typography from '@mui/material/Typography'
import CardHeader from '@mui/material/CardHeader'
import CardContent from '@mui/material/CardContent'
import Tooltip from '@mui/material/Tooltip'
import Chip from '@mui/material/Chip'

import CustomAvatar from '@/@core/components/mui/Avatar'
import { getFullImageUrl } from '@/utils/commonfunctions'
import { getInitials } from '@/utils/getInitials'

const renderClient = row => {
  if (row?.hostImage) {
    return <CustomAvatar src={getFullImageUrl(row.hostImage)} sx={{ mr: 3, width: 38, height: 38 }} />
  } else {
    return (
      <CustomAvatar skin='light' sx={{ mr: 3, width: 38, height: 38, fontSize: '1rem' }}>
        {getInitials(row.name)}
      </CustomAvatar>
    )
  }
}

const TopHosts = ({ topHosts }) => {
  if (!topHosts || topHosts.length === 0) {
    return null
  }

  return (
    <Card>
      <CardHeader
        title='Top Earning Hosts'
        subheader='Based on total coins earned'
        subheaderTypographyProps={{ sx: { color: 'text.disabled' } }}
      />
      <CardContent>
        {topHosts.map((row, index) => {
          return (
            <Box
              key={row.hostId}
              sx={{
                display: 'flex',
                alignItems: 'center',
                mb: index !== topHosts.length - 1 ? 6 : undefined
              }}
            >
              {renderClient(row)}
              <Box sx={{ display: 'flex', flexDirection: 'column', flex: '1 1 0%' }}>
                <Box sx={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
                  <Typography sx={{ fontWeight: 500 }}>
                    {row.name} {row.hostFlagImage}
                  </Typography>
                  <Box sx={{ display: 'flex', alignItems: 'center' }}>
                    <Typography sx={{ color: 'primary.main', fontWeight: 500, mr: 1 }}>{row.totalCoins}</Typography>
                    <Typography sx={{ color: 'text.disabled' }}>Coins</Typography>
                  </Box>
                </Box>
                <Box sx={{ display: 'flex', alignItems: 'center', flexWrap: 'wrap' }}>
                  <Typography variant='body2' sx={{ mr: 1 }}>
                    {row.userName}
                  </Typography>
                  {row.agencyName && (
                    <Tooltip title={`Agency: ${row.agencyName}`}>
                      <Chip
                        size='small'
                        label={row.agencyCode}
                        color='primary'
                        variant='outlined'
                        sx={{ height: 20, fontSize: '0.75rem' }}
                      />
                    </Tooltip>
                  )}
                  {/* Adding the country flag and country name */}
                  {row.countryFlagImage && row.hostCountry && (
                    <Tooltip title={`Country: ${row.hostCountry}`}>
                      <Box sx={{ display: 'flex', alignItems: 'center', ml: 1 }}>
                        <img
                          src={row.countryFlagImage}
                          alt={row.hostCountry}
                          style={{ width: 20, height: 12, marginRight: 4 }}
                        />
                        <Typography variant='body2'>{row.hostCountry}</Typography>
                      </Box>
                    </Tooltip>
                  )}
                </Box>
              </Box>
            </Box>
          )
        })}
      </CardContent>
    </Card>
  )
}

export default TopHosts
