import React from 'react';

const Info = (props) => {
  return (
    <span className="icon icon__info" data-title={props.title}>
      <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 16 16">
        <path d="M8,0C3.6,0,0,3.6,0,8s3.6,8,8,8s8-3.6,8-8S12.4,0,8,0z M9,12H7V7h2V12z M8,6C7.4,6,7,5.6,7,5s0.4-1,1-1 s1,0.4,1,1S8.6,6,8,6z"></path>
      </svg>
    </span>
  );
}

const Success = (props) => {
  return (
    <span className="icon icon__success" data-title={props.title}>
      <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 16 16">
        <g strokeWidth="1" fill="#00A1F9" stroke="#00A1F9">
          <circle cx="8" cy="8" r="7.5" fill="none" stroke="#00A1F9" strokeLinecap="round" strokeLinejoin="round"></circle>
          <circle cx="5" cy="6" r="1" data-color="color-2" data-stroke="none" stroke="none"></circle>
          <circle cx="11" cy="6" r="1" data-color="color-2" data-stroke="none" stroke="none"></circle>
          <path d="M11,9.8a3.5,3.5,0,0,1-6,0" fill="none" strokeLinecap="round" strokeLinejoin="round" data-color="color-2"></path>
        </g>
      </svg>
    </span>
  );
}

const Warning = (props) => {
  return (
    <span className="icon icon__warning" data-title={props.title}>
      <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 16 16">
        <g fill="#000000">
          <path fill="#000000" d="M8,0C3.6,0,0,3.6,0,8s3.6,8,8,8s8-3.6,8-8S12.4,0,8,0z M8,12c-0.6,0-1-0.4-1-1s0.4-1,1-1s1,0.4,1,1 S8.6,12,8,12z M9,9H7V4h2V9z"></path>
        </g>
      </svg>
    </span>
  );
}

export {
  Info,
  Success,
  Warning
}
