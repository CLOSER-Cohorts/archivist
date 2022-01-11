import React, { useEffect, useState } from 'react';
import { useDispatch, useSelector } from 'react-redux'
import { User } from '../actions'
import { Dashboard } from '../components/Dashboard'
import { AdminUserForm } from '../components/AdminUserForm'
import { get } from 'lodash'
import { Loader } from '../components/Loader'

const AdminUserEdit = (props) => {

  const dispatch = useDispatch()

  const userId = get(props, "match.params.user_id", "")
  const user = useSelector(state => get(state.users, userId));

  const [dataLoaded, setDataLoaded] = useState(false);

  useEffect(() => {
    Promise.all([
      dispatch(User.show(userId)),
    ]).then(() => {
      setDataLoaded(true)
    });
  }, []);

  return (
    <div style={{ height: 500, width: '100%' }}>
      <Dashboard title={'Admin Edit User'}>
        {!dataLoaded
          ? <Loader />
          : <AdminUserForm user={user} />
        }
      </Dashboard>
    </div>
  );
}

export default AdminUserEdit;
