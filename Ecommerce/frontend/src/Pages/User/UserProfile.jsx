import React from 'react';
import { useParams } from 'react-router-dom';
import UserSideBar from '../../Components/UserProfile/UserSideBar';
import AccountSettings from '../../Components/UserProfile/AccountSettings'; // Correct import
import './UserProfile.css';
import ChangePassword from '../../Components/UserProfile/ChangePassword';

export const UserProfile = () => {
  const { activepage } = useParams();

  return (
    <div className='userprofile'>
      
      <div className='userprofilein'>
        <div className='left'>
          <UserSideBar activepage={activepage} />
        </div>
        <div className='right'>
          {activepage === 'accountsettings' && <AccountSettings />}
          {activepage === 'changepassword' && <ChangePassword />}
        </div>
      </div>
    </div>
  );
}

export default UserProfile;