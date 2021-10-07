import React from 'react';
import { makeStyles } from '@material-ui/core/styles';
import TextField from '@material-ui/core/TextField';
import Modal from '@material-ui/core/Modal';
import Button from '@material-ui/core/Button';

function rand() {
  return Math.round(Math.random() * 20) - 10;
}

function getModalStyle() {
  const top = 50 + rand();
  const left = 50 + rand();

  return {
    top: `${top}%`,
    left: `${left}%`,
    transform: `translate(-${top}%, -${left}%)`,
  };
}

const useStyles = makeStyles((theme) => ({
  paper: {
    position: 'absolute',
    width: 400,
    backgroundColor: theme.palette.background.paper,
    border: '2px solid #000',
    boxShadow: theme.shadows[5],
    padding: theme.spacing(2, 4, 3),
  },
}));

export const ConfirmationModal = (props) => {
  const { textToConfirm="", key="prefix", objectType="instrument", onConfirm=()=>{} } = props;
  const classes = useStyles();
  // getModalStyle is not a pure function, we roll the style only on the first render
  const [modalStyle] = React.useState(getModalStyle);
  const [open, setOpen] = React.useState(false);
  const [keyConfirmed, setKeyConfirmed] = React.useState(false);

  const handleOpen = () => {
    setOpen(true);
  };

  const handleClose = () => {
    setOpen(false);
  };

  const handleConfirm = () => {
    onConfirm()
    handleClose()
  }

  const checkTextToConfirm= (event) => {
    if(event.target.value === textToConfirm){
      setKeyConfirmed(true)
    }
  }

  const body = (
    <div style={modalStyle} className={classes.paper}>
      <h2 id="simple-modal-title">Delete {objectType}</h2>
      <p id="simple-modal-description">
        Please write the {key} of the {objectType} you would like to delete for confirmation.
      </p>
      <p>
        <TextField
          error={!keyConfirmed}
          onChange={checkTextToConfirm}
          id="outlined-error-helper-text"
          label={`Confirm ${key}`}
          defaultValue=""
          variant="outlined"
        />
      </p>
      <p>
        <Button
          type="button"
          variant="contained"
          disabled={!keyConfirmed}
          onClick={handleConfirm}
        >
          Delete
        </Button>
      </p>
    </div>
  );

  return (
    <div>
      <Button onClick={handleOpen}>
        Delete
      </Button>
      <Modal
        open={open}
        onClose={handleClose}
        aria-labelledby="simple-modal-title"
        aria-describedby="simple-modal-description"
      >
        {body}
      </Modal>
    </div>
  );
}