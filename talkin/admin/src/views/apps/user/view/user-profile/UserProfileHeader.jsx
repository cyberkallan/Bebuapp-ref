// MUI Imports


import Card from '@mui/material/Card'
import CardContent from '@mui/material/CardContent'
import CardMedia from '@mui/material/CardMedia'
import Typography from '@mui/material/Typography'

import { getFullImageUrl } from '@/utils/commonfunctions'
import CustomAvatar from '@/@core/components/mui/Avatar'

const UserProfileHeader = ({ data }) => {
  //  const { userDetails } = useSelector(state => state.userReducer)
   const userDetails  = localStorage.getItem('selectedUser') ? JSON.parse(localStorage.getItem('selectedUser')) : {}

console.log(userDetails)

  return (
    <Card>
      <CardMedia image={"/images/profile-banner.png"} className='bs-[250px]' />
      <CardContent className='flex gap-5 justify-center flex-col items-center md:items-end md:flex-row !pt-0 md:justify-start'>
        <div className='flex rounded-bs-md mbs-[-40px] border-[5px] mis-[-5px] border-be-0  border-backgroundPaper bg-backgroundPaper'>
          {/* <img height={120} width={120} src={getFullImageUrl(data?.profilePic)} className='rounded' alt='Profile Background' /> */}
          <CustomAvatar
            alt='user-profile'
            src={getFullImageUrl(userDetails?.profilePic) || '/images/avatars/1.png'}
            variant='rounded'
            size={120}
          />
        </div>
        <div className='flex is-full justify-start self-end flex-col items-center gap-6 sm-gap-0 sm:flex-row sm:justify-between sm:items-end '>
          <div className='flex flex-col items-center sm:items-start gap-2'>
            <Typography variant='h4'>{userDetails?.fullName}</Typography>
            <div className='flex flex-wrap gap-6 justify-center sm:justify-normal'>
              {/* <div className='flex items-center gap-2'>
                {userDetails?.designationIcon && <i className={data?.designationIcon} />}
                <Typography className='font-medium'>{data?.designation}</Typography>
              </div> */}
              <div className='flex items-center gap-2'>
                <i className='tabler-gender-genderqueer' />
                <Typography textTransform={"capitalize"} className='font-medium'>{userDetails?.gender}</Typography>
              </div>
              <div className='flex items-center gap-2'>
                <i className='tabler-calendar' />
                <Typography className='font-medium' >{userDetails?.birthDate}</Typography>
              </div>
            </div>
          </div>
          {/* <Button variant='contained' className='flex gap-2'>
            <i className='tabler-user-check !text-base'></i>
            <span>Connected</span>
          </Button> */}
        </div>
      </CardContent>
    </Card>
  )
}

export default UserProfileHeader
