import React, { useEffect } from 'react';
import { useDispatch, useSelector } from 'react-redux'
import { Dashboard } from '../components/Dashboard'
import { AdminInstrumentForm } from '../components/AdminInstrumentForm'
import { AdminDatasetForm } from '../components/AdminDatasetForm'
import Button from '@material-ui/core/Button';
import { Link } from 'react-router-dom';
import { reverse as url } from 'named-urls'
import routes from '../routes'

const AdminImport = () => {

  const dispatch = useDispatch()

  useEffect(() => {
    // eslint-disable-next-line react-hooks/exhaustive-deps
  },[]);

  return (
    <div style={{ height: 500, width: '100%' }}>
      <Dashboard title={'Import'}>
        <AdminInstrumentForm />
        <AdminDatasetForm />
      </Dashboard>
    </div>
  );
}

export default AdminImport;
