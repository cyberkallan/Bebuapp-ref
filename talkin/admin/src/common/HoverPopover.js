import React, { useState } from 'react';

import { Box, Popover } from '@mui/material';

const HoverPopover = ({ children, popoverContent, sx, popoverSx }) => {
  const [anchorEl, setAnchorEl] = useState(null);
  const [isHovering, setIsHovering] = useState(false);
  const [isClicked, setIsClicked] = useState(false);

  const handlePopoverOpen = (event) => {
    setAnchorEl(event.currentTarget);
    setIsHovering(true);
  };

  const handlePopoverClick = (event) => {
    setAnchorEl(event.currentTarget);
    setIsClicked((prev) => !prev); // Toggle on click
  };

  const handlePopoverLeave = () => {
    setIsHovering(false);
  };

  const handleClose = () => {
    setAnchorEl(null);
    setIsClicked(false);
    setIsHovering(false);
  };

  const open = Boolean(anchorEl) && (isHovering || isClicked);

  return (
    <>
      <span
        onMouseEnter={handlePopoverOpen}
        onMouseLeave={handlePopoverLeave}
        onClick={handlePopoverClick}
        style={{ display: 'inline-block', cursor: 'pointer', ...sx }}
      >
        {children}
      </span>

      <Popover
        sx={{ pointerEvents: isClicked ? 'auto' : 'none', ...popoverSx }}
        open={open}
        anchorEl={anchorEl}
        onClose={handleClose}
        anchorOrigin={{
          vertical: 'bottom',
          horizontal: 'left',
        }}
        transformOrigin={{
          vertical: 'top',
          horizontal: 'left',
        }}
        disableRestoreFocus
      >
        <Box
          padding={2}
          maxWidth={300}
          onMouseEnter={() => setIsHovering(true)}
          onMouseLeave={() => {
            setIsHovering(false);
            if (!isClicked) handleClose();
          }}
        >
          {popoverContent}
        </Box>
      </Popover>
    </>
  );
};

export default HoverPopover;
