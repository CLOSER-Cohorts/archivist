import React, { useEffect, useState } from 'react';
import { useDispatch, useSelector } from 'react-redux'
import { User } from '../actions'
import { Dashboard } from '../components/Dashboard'
import ButtonGroup from '@material-ui/core/ButtonGroup';
import Button from '@material-ui/core/Button';
import { Link } from 'react-router-dom';
import { reverse as url } from 'named-urls'
import routes from '../routes'
import { DataTable } from '../components/DataTable'
import { ConfirmationModal } from '../components/ConfirmationModal'
import AddCircleOutlineIcon from '@material-ui/icons/AddCircleOutline';

const AdminUsers = () => {

  const dispatch = useDispatch()

  const actions = (row) => {
    return (
      <>
        {/* <ButtonGroup variant="outlined">
          <Button>
            <Link to={url(routes.admin.users.user.edit, { user_id: row.id })}>Edit</Link>
          </Button>
        </ButtonGroup> */}
      </>
    )
  }

  const headers = ["ID", "Email", "First Name", "Last Name", "Group", "Role"]
  const rowRenderer = (row) => {
    return [row.id, row.email, row.first_name, row.last_name, row.group_label, row.role]
  }
  return (
    <div style={{ height: 500, width: '100%' }}>
      <Dashboard title={'Admin Users'}>
        <DataTable actions={actions}
          fetch={[dispatch(User.all())]}
          stateKey={'users'}
          searchKeys={['email', 'first_name', 'last_name']}
          filters={[{ key: 'group_label', label: 'Group', options: [] }]}
          headers={headers}
          sortKeys={[{ key: 'id', label: 'ID' }, { key: 'email', label: 'Email' }, { key: 'last_name', label: 'Last Name' }]}
          rowRenderer={rowRenderer}
          />
      </Dashboard>
    </div>
  );
}

export default AdminUsers;
