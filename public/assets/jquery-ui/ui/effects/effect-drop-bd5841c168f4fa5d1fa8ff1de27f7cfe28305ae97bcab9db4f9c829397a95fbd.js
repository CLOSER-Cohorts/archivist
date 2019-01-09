/*!
 * jQuery UI Effects Drop 1.12.1
 * http://jqueryui.com
 *
 * Copyright jQuery Foundation and other contributors
 * Released under the MIT license.
 * http://jquery.org/license
 */
!function(e){"function"==typeof define&&define.amd?define(["jquery","../version","../effect"],e):e(jQuery)}(function(e){return e.effects.define("drop","hide",function(t,i){var n,o=e(this),f="show"===t.mode,c=t.direction||"left",d="up"===c||"down"===c?"top":"left",u="up"===c||"left"===c?"-=":"+=",r="+="===u?"-=":"+=",a={opacity:0};e.effects.createPlaceholder(o),n=t.distance||o["top"===d?"outerHeight":"outerWidth"](!0)/2,a[d]=u+n,f&&(o.css(a),a[d]=r+n,a.opacity=1),o.animate(a,{queue:!1,duration:t.duration,easing:t.easing,complete:i})})});