import React from 'react';
import Breadcrumbs from '@material-ui/core/Breadcrumbs';
import NavigateNextIcon from '@material-ui/icons/NavigateNext';
import { Link } from 'react-router-dom';
import Paper from '@material-ui/core/Paper';
import Typography from '@material-ui/core/Typography';
import { isEmpty } from 'lodash'

const BreadcrumbBarItem = (props) => {
  const {text, link} = props

  if(isEmpty(link)){
    return (
      <Typography color="textPrimary">{text}</Typography>
    )
  }else{
    return (
      <Link color="inherit" to={link}>
        {text}
      </Link>
    )
  }
}

const BreadcrumbBar = (props) => {
  const {breadcrumbs=[]} = props

  return (
      <Paper>
        <Breadcrumbs separator={<NavigateNextIcon fontSize="small" />} aria-label="breadcrumb">
          {breadcrumbs.map((breadcrumb) => {
            return <BreadcrumbBarItem text={breadcrumb.text} link={breadcrumb.link} />
          })}
        </Breadcrumbs>
      </Paper>
  )
}

export default BreadcrumbBar
