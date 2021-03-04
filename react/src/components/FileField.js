import React from 'react';
import { Field } from "react-final-form";

export const FileField = ({ name, ...props }) => (
  <Field name={name}>
    {({ input: { value, onChange, ...input } }) => (
      <input
        {...input}
        type="file"
        multiple
        onChange={({ target }) => onChange(target.files)} // instead of the default target.value
        {...props}
      />
    )}
  </Field>
);
