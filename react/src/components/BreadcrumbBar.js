import React from 'react';
import Breadcrumbs from '@material-ui/core/Breadcrumbs';
import NavigateNextIcon from '@material-ui/icons/NavigateNext';
import { Link } from 'react-router-dom';
import Paper from '@material-ui/core/Paper';
import Typography from '@material-ui/core/Typography';
import { isEmpty, get } from 'lodash'
import routes from '../routes'
import { reverse as url } from 'named-urls'
import { useLocation } from 'react-router-dom';
import { makeStyles } from '@material-ui/core/styles';

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

const useStyles = makeStyles((theme) => ({
  root: {
    'margin-bottom': '10px',
    padding: '15px'
  }
}));

const BreadcrumbBar = (props) => {
  const {instrumentId} = props

  const location = useLocation();

  const paramsFromPath = () => {
    const capturingRegex = `/instruments\\/${instrumentId}\\/(?<type>build|map)\/?(?<subtype>question_grids|question_items|response_domains|code_lists|constructs)?\/?`;
    const found = location.pathname.match(new RegExp(capturingRegex));
    return get(found, 'groups',{})
  }

  const buildBreadcrumbs = () => {
    var crumbs = [{text: 'Instruments', link: url(routes.instruments.all)}]

    if(instrumentId){
      crumbs.push(
        {
          text: instrumentId,
          link: url(routes.instruments.instrument.map.show, { instrument_id: instrumentId })
        }
      )
      const params = paramsFromPath();
      if(params){
        switch (params.type) {
          case 'map':
            crumbs.push(
                {
                  text: 'Map',
                  link: url(routes.instruments.instrument.map.show, { instrument_id: instrumentId })
                }
              )
            break
          case 'build':
            crumbs.push(
                {
                  text: 'Build',
                  link: url(routes.instruments.instrument.build.show, { instrument_id: instrumentId })
                }
              )
            if(params.subtype){
              console.log(params)
              if(params.subtype === 'question_items'){
                  crumbs.push(
                      {
                        text: 'Question Items',
                        link: url(routes.instruments.instrument.build.questionItems.all, { instrument_id: instrumentId })
                      }
                    )
              }else if(params.subtype === 'question_grids'){
                  crumbs.push(
                      {
                        text: 'Question Grids',
                        link: url(routes.instruments.instrument.build.questionGrids.all, { instrument_id: instrumentId })
                      }
                    )
              }else if(params.subtype === 'code_lists'){
                  crumbs.push(
                      {
                        text: 'CodeLists',
                        link: url(routes.instruments.instrument.build.codeLists.all, { instrument_id: instrumentId })
                      }
                    )
              }else if(params.subtype === 'response_domains'){
                  crumbs.push(
                      {
                        text: 'Response Domains',
                        link: url(routes.instruments.instrument.build.responseDomains.all, { instrument_id: instrumentId })
                      }
                    )
              }else if(params.subtype === 'constructs'){
                  crumbs.push(
                      {
                        text: 'Constructs',
                        link: url(routes.instruments.instrument.build.constructs.show, { instrument_id: instrumentId })
                      }
                    )
              }

            }
        }
      }
    }
    return crumbs
  }

  const breadcrumbs = buildBreadcrumbs()

  const classes = useStyles()

  return (
      <Paper className={classes.root}>
        <Breadcrumbs separator={<NavigateNextIcon fontSize="small" />} aria-label="breadcrumb">
          {breadcrumbs.map((breadcrumb) => {
            return <BreadcrumbBarItem text={breadcrumb.text} link={breadcrumb.link} />
          })}
        </Breadcrumbs>
      </Paper>
  )
}

export default BreadcrumbBar
