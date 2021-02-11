import React from 'react';
import BounceLoader from "react-spinners/BounceLoader";
import { Box } from '@material-ui/core'
import { shuffle } from "lodash";
import { ObjectColour } from '../support/ObjectColour'

export const Loader = () => {
  return (
    <Box style={{ height: 200, 'margin-top': 50 }} m="auto"><BounceLoader color={`#${ObjectColour(shuffle(['sequence', 'condition', 'question', 'statement','loop'])[0])}`}/></Box>
  )
}
