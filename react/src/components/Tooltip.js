import React from 'react';
import ReactDOM from 'react-dom';

class Tooltip extends React.Component {
  constructor(props) {
    super(props)

    this.state = {
      displayTooltip: false
    }
    this.hideTooltip = this.hideTooltip.bind(this)
    this.showTooltip = this.showTooltip.bind(this)
    this.mouseMoved = this.mouseMoved.bind(this)
  }

  hideTooltip (event) {
    this.setState({
      displayTooltip: false,
      left: null,
      top: null
    })
  }

  showTooltip (event) {

    var bounds = event.currentTarget.getBoundingClientRect();
    var x = bounds.left + (bounds.width / 2);
    // var y = bounds.top + (bounds.height / 2);

    this.setState({
      displayTooltip: true,
      left: x,
      top: bounds.top
    })

  }

  mouseMoved (event) {
    var bounds = event.target.getBoundingClientRect();
    var x = event.clientX;// - bounds.left;
    this.setState({left: x, top: bounds.top})
  }

  render() {
    let message = this.props.message
    let position = this.props.position
    let size = this.props.size

    return (
      <span className='tooltip'
          onMouseMove={ size === 'small' ? this.mouseMoved : function() { return false }}
        >
        {this.state.displayTooltip &&
          (
            ReactDOM.createPortal(
              <div 
                className={`tooltip-bubble tooltip-${position} tooltip-${size}`}
                style={{left: this.state.left, top: this.state.top}}
                dangerouslySetInnerHTML={{__html: message}}>
              </div>,
              document.querySelector('main')
            )
          )
        }
        <span
          className='tooltip-trigger'
          onMouseOver={this.showTooltip}
          onMouseLeave={this.hideTooltip}
          >
          {this.props.children}
        </span>
      </span>
    )

  }

}

export default Tooltip;
