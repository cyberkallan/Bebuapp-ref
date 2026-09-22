'use client'
import { useEffect } from 'react'

// Third-party Imports
import classnames from 'classnames'

// Redux Imports
import { useSelector, useDispatch } from 'react-redux'

import axios from 'axios'


// Component Imports
import NavToggle from './NavToggle'
import ModeDropdown from '@components/layout/shared/ModeDropdown'
import UserDropdown from '@components/layout/shared/UserDropdown'

// Util Imports
import { verticalLayoutClasses } from '@layouts/utils/layoutClasses'
import NavSearch from '../shared/search'
import { baseURL } from '@/config'

const NavbarContent = () => {
  const dispatch = useDispatch()

  const checkLogin = async ()=>{

    const  response  = await axios.get(`${baseURL}/api/admin/login`);

    if(response.data.login){
      window.location.href = "/login"
    }else{
      window.location.href = "/register"
    }
  }

  useEffect(() => {
// checkLogin()

    // dispatch(fetchSettings())
  }, [])

  return (
    <div className={classnames(verticalLayoutClasses.navbarContent, 'flex items-center justify-between gap-4 is-full')}>
      <div className='flex items-center gap-4'>
        <NavToggle />
        <NavSearch />
      </div>
      <div className='flex items-center'>
        <ModeDropdown />
        <UserDropdown />
      </div>
    </div>
  )
}

export default NavbarContent
