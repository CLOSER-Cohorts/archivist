/*!
 * jQuery UI Effects Bounce 1.12.1
 * http://jqueryui.com
 *
 * Copyright jQuery Foundation and other contributors
 * Released under the MIT license.
 * http://jquery.org/license
 */
!function(e){"function"==typeof define&&define.amd?define(["jquery","../version","../effect"],e):e(jQuery)}(function(e){return e.effects.define("bounce",function(t,i){var n,o,f,a=e(this),c=t.mode,u="hide"===c,s="show"===c,d=t.direction||"up",r=t.distance,p=t.times||5,h=2*p+(s||u?1:0),m=t.duration/h,y=t.easing,l="up"===d||"down"===d?"top":"left",g="up"===d||"left"===d,q=0,w=a.queue().length;for(e.effects.createPlaceholder(a),f=a.css(l),r||(r=a["top"===l?"outerHeight":"outerWidth"]()/3),s&&((o={opacity:1})[l]=f,a.css("opacity",0).css(l,g?2*-r:2*r).animate(o,m,y)),u&&(r/=Math.pow(2,p-1)),(o={})[l]=f;q<p;q++)(n={})[l]=(g?"-=":"+=")+r,a.animate(n,m,y).animate(o,m,y),r=u?2*r:r/2;u&&((n={opacity:0})[l]=(g?"-=":"+=")+r,a.animate(n,m,y)),a.queue(i),e.effects.unshift(a,w,h+1)})});