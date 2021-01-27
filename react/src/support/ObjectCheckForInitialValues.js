import { merge, isObject } from 'lodash';

export const ObjectCheckForInitialValues = (initialValues, values) => {
    // For every field initially provided, we check whether it value has been removed
    // and set it explicitly to an empty string
    if (!initialValues) return values;
    const initialValuesWithEmptyFields = Object.keys(initialValues).reduce(
        (acc, key) => {
            if (values[key] instanceof Date || Array.isArray(values[key])) {
                acc[key] = values[key];
            } else if (
                typeof values[key] === 'object' &&
                values[key] !== null
            ) {
                acc[key] = ObjectCheckForInitialValues(initialValues[key], values[key]);
            } else {
                acc[key] =
                    typeof values[key] === 'undefined' ? null : values[key];
            }
            return acc;
        },
        {}
    );

    // Finally, we merge back the values to not miss any which wasn't initially provided
    return merge(initialValuesWithEmptyFields, values);
}
