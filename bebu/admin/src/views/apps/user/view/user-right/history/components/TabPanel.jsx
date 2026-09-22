'use client'

import Box from '@mui/material/Box'

// TabPanel component for tab content
const TabPanel = ({ children, value, index, ...other }) => (
  <div
    role='tabpanel'
    hidden={value !== index}
    id={`history-tabpanel-${index}`}
    aria-labelledby={`history-tab-${index}`}
    {...other}
  >
    {value === index && <Box sx={{ pt: 3 }}>{children}</Box>}
  </div>
)

export default TabPanel
