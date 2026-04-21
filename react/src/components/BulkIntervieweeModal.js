import React, { useState } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import { get } from 'lodash';
import {
  Button,
  Dialog,
  DialogActions,
  DialogContent,
  DialogTitle,
  FormControl,
  InputLabel,
  MenuItem,
  Select,
  Typography,
} from '@material-ui/core';
import { CcQuestions } from '../actions';

export const BulkIntervieweeModal = ({ open, onClose, instrumentId }) => {
  const dispatch = useDispatch();
  const responseUnits = useSelector(state => get(state.response_units, instrumentId, {}));
  const ccQuestions = useSelector(state => get(state.cc_questions, instrumentId, {}));
  const updateStatus = useSelector(state => get(state.statuses, `CcQuestionUpdateAll:${instrumentId}`, {}));

  const [selectedId, setSelectedId] = useState('');
  const [successMessage, setSuccessMessage] = useState('');

  const questionCount = Object.keys(ccQuestions).length;

  const handleClose = () => {
    setSelectedId('');
    setSuccessMessage('');
    dispatch({ type: 'CLEAR', payload: { id: instrumentId, type: 'CcQuestionUpdateAll' } });
    onClose();
  };

  const handleApply = () => {
    if (!selectedId) return;
    setSuccessMessage('');
    dispatch(
      CcQuestions.update_all(instrumentId, { response_unit_id: selectedId }, (data) => {
        setSuccessMessage(data.message);
        dispatch(CcQuestions.all(instrumentId));
      })
    );
  };

  const errorMessage = updateStatus.error
    ? (updateStatus.errors?.message || 'An error occurred')
    : '';

  return (
    <Dialog open={open} onClose={handleClose} maxWidth="sm" fullWidth>
      <DialogTitle>Change Interviewee</DialogTitle>
      <DialogContent>
        <Typography variant="body2" gutterBottom>
          This will update {questionCount} questions.
        </Typography>
        {successMessage && (
          <Typography variant="body2" style={{ color: 'green' }}>
            {successMessage}
          </Typography>
        )}
        {errorMessage && (
          <Typography variant="body2" color="error">
            {errorMessage}
          </Typography>
        )}
        <FormControl fullWidth margin="normal">
          <InputLabel id="interviewee-label">Interviewee</InputLabel>
          <Select
            labelId="interviewee-label"
            value={selectedId}
            onChange={(e) => setSelectedId(e.target.value)}
          >
            {Object.values(responseUnits).map((ru) => (
              <MenuItem key={ru.id} value={ru.id}>{ru.label}</MenuItem>
            ))}
          </Select>
        </FormControl>
      </DialogContent>
      <DialogActions>
        <Button onClick={handleClose}>Cancel</Button>
        <Button
          onClick={handleApply}
          color="primary"
          variant="contained"
          disabled={!selectedId || updateStatus.saving}
        >
          Apply
        </Button>
      </DialogActions>
    </Dialog>
  );
};
