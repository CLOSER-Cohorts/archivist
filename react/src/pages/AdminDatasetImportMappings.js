import React, { useEffect, useState } from 'react';
import { useDispatch, useSelector } from 'react-redux'
import { Dashboard } from '../components/Dashboard'
import { AdminImportMappingsForm } from '../components/AdminImportMappingsForm'
import { DataTable } from '../components/DataTable'
import { Loader } from '../components/Loader'
import { AdminImportMapping } from '../actions'
import { get } from 'lodash';
import Divider from '@material-ui/core/Divider';
import { FileToBase64 } from '../support/FileToBase64'
import ButtonGroup from '@material-ui/core/ButtonGroup';
import Button from '@material-ui/core/Button';
import { Link } from 'react-router-dom';
import { reverse as url } from 'named-urls'
import routes from '../routes'

const AdminDatasetImportMappings = (props) => {
  const dispatch = useDispatch()
  const type = "Dataset"
  const hint = "You can import multiple T-V and DV mapping files. Only TXT files are accepted."
  const datasetId = get(props, "match.params.datasetId", "")

  const onSubmit = (values) => {
    dispatch({type: 'CLEAR', payload: {id: 'new', type: 'AdminImportMapping'}})

    let imports = []

    Promise.all(
      [...values.files].map((imp, index) => { return FileToBase64(imp)})
      ).then((base64_files) => {
        base64_files.map((file, index) => {
          imports.push({ file: file.split(',')[1], type: values.types[index]})
        })
        dispatch(AdminImportMapping.create('datasets', datasetId, imports))
      });
    }

    const actions = (row) => {
      return (
          <ButtonGroup variant="outlined">
            <Button>
                  <Link to={url(routes.admin.datasets.importMapping, { datasetId: row.dataset_id, id: row.id })}>
                    View logs
                  </Link>
            </Button>
          </ButtonGroup>
      )
    }

    const headers = ["ID", "File", "Type","State","Created At"]
    const rowRenderer = (row) => {
      return [row.id, row.file, row.import_type, row.state, row.created_at]
    }

    return (
      <div style={{ height: 500, width: '100%' }}>
      <Dashboard title={'Instruments Import Mappings'}>
      <AdminImportMappingsForm type={type} hint={hint} onSubmit={onSubmit} typeOptions={ [{value: 'topicv', label: 'T-V Mapping'}, {value: 'dv', label: 'DV Mapping'}] } />
      <Divider style={{ margin: 16 }} variant="middle" />
      <DataTable actions={actions}
      fetch={[dispatch(AdminImportMapping.all('datasets',datasetId))]}
      stateKey={'datasetImportMappings'}
      parentStateKey={datasetId}
      searchKey={'filename'}
      headers={headers}
      rowRenderer={rowRenderer}
      />
      </Dashboard>
      </div>
      );
  }

  export default AdminDatasetImportMappings;
