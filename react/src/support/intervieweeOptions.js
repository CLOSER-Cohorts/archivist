import { difference } from 'lodash';

export const INTERVIEWEE_DEFAULT_LABELS = [
  'Cohort/sample member',
  'Main parent of cohort/sample member',
  'Partner of main parent/Father',
  'Child of cohort/panel member',
  'Proxy',
  'Interviewer',
  'Other',
];

export const missingDefaultIntervieweeLabels = (responseUnits) => {
  const existingLabels = Object.values(responseUnits).map((ru) => ru.label);
  return difference(INTERVIEWEE_DEFAULT_LABELS, existingLabels);
};
