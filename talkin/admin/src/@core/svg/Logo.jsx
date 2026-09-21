import Image from 'next/image'

const Logo = props => {
  return <Image src='/images/logo/talkin-logo.png' alt='logo' width={35} height={35} className='object-contain' />
}

export default Logo
