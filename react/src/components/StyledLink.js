import React from 'react';
import { Link } from 'react-router-dom';
import Chip from '@material-ui/core/Chip';

const StyledLink = ({ to, label, ...props }) => {
  return (
    <Link to={to} style={{ textDecoration: 'none', margin: '2px' }}>
      <Chip label={label} variant="outlined" color="primary" {...props} />
    </Link>
  );
};

export default StyledLink;