import React, { useEffect } from 'react';
import { useDispatch, useSelector } from 'react-redux'
import { Dashboard } from '../components/Dashboard'
import { AdminImportInstrumentForm } from '../components/AdminImportInstrumentForm'
import { AdminDatasetForm } from '../components/AdminDatasetForm'

const AdminImport = () => {

  const dispatch = useDispatch()

  useEffect(() => {
    // eslint-disable-next-line react-hooks/exhaustive-deps
  },[]);

  return (
    <div style={{ height: 500, width: '100%' }}>
      <Dashboard title={'Import'}>
        <AdminImportInstrumentForm />
        <AdminDatasetForm />
      </Dashboard>
    </div>
  );
}

export default AdminImport;
