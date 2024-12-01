import React from 'react';

const Button = ({
  children,
  variant = 'contained',
  color = 'primary',
  size = 'medium',
  disabled = false,
  onClick,
  className = '',
  ...props
}) => {
  // Define base styles
  const baseStyles = 'inline-flex items-center justify-center border font-medium focus:outline-none focus:ring-2 focus:ring-offset-2 transition mr-4 rounded uppercase';

  // Define variant styles
  let variantStyles = '';
  switch (variant) {
    case 'contained':
      variantStyles = `text-white bg-${color}-600 hover:bg-${color}-700 focus:ring-${color}-500 border-transparent`;
      break;
    case 'outlined':
      variantStyles = `text-${color}-700 border-${color}-700 hover:bg-${color}-50 focus:ring-${color}-500`;
      break;
    case 'text':
      variantStyles = `text-${color}-700 border-transparent hover:bg-${color}-50 focus:ring-${color}-500`;
      break;
    default:
      variantStyles = `text-white bg-${color}-600 hover:bg-${color}-700 focus:ring-${color}-500 border-transparent`;
  }

  // Define size styles
  let sizeStyles = '';
  switch (size) {
    case 'small':
      sizeStyles = 'px-2 py-1 text-sm';
      break;
    case 'large':
      sizeStyles = 'px-6 py-3 text-lg';
      break;
    default:
      sizeStyles = 'px-4 py-2 text-base';
  }

  // Define disabled styles
  const disabledStyles = disabled ? 'opacity-50 cursor-not-allowed' : '';

  // Combine all styles
  const combinedStyles = `${baseStyles} ${variantStyles} ${sizeStyles} ${disabledStyles} ${className}`;

  return (
    <button
      type="button"
      className={combinedStyles}
      onClick={onClick}
      disabled={disabled}
      {...props}
    >
      {children}
    </button>
  );
};

export default Button;