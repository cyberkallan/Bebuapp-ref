// MUI Imports
import Avatar from "@mui/material/Avatar";
import Typography from "@mui/material/Typography";
import IconButton from "@mui/material/IconButton";

// Third-party Imports
import { toast } from "react-toastify";

/**
 * ✅ Show toast only on success.
 */
export const showSuccessToast = (user) => {
  if (!user) return;

  // console.log("entered toast", user)

  return toast(
    t => (
      <div className='is-full flex items-center justify-between'>
        <div className='flex items-center'>
          <Avatar alt='Victor Anderson' src={user?.image || '/images/avatars/3.png'} className='mie-3 is-10 bs-10' />
          <div>
            <Typography variant='h5' className='leading-6'>
              {user?.name}
            </Typography>
            <Typography variant='caption' color='text.secondary' sx={{ whiteSpace: 'nowrap' }}>
              {user?.message}
            </Typography>
          </div>
        </div>
        <IconButton onClick={() => toast.dismiss(t.toastProps.toastId)} size='small'>
          <i className='tabler-x text-[var(--mui-palette-text-primary)]' />
        </IconButton>
      </div>
    ),
    {
      style: {
        minWidth: '300px'
      },
      closeButton: false
    }
  )
};
