/*!
 * jQuery UI Effects Shake 1.12.1
 * http://jqueryui.com
 *
 * Copyright jQuery Foundation and other contributors
 * Released under the MIT license.
 * http://jquery.org/license
 */
!function(e){"function"==typeof define&&define.amd?define(["jquery","../version","../effect"],e):e(jQuery)}(function(e){return e.effects.define("shake",function(n,t){var i=1,a=e(this),f=n.direction||"left",u=n.distance||20,s=n.times||3,o=2*s+1,c=Math.round(n.duration/o),r="up"===f||"down"===f?"top":"left",d="up"===f||"left"===f,m={},g={},h={},l=a.queue().length;for(e.effects.createPlaceholder(a),m[r]=(d?"-=":"+=")+u,g[r]=(d?"+=":"-=")+2*u,h[r]=(d?"-=":"+=")+2*u,a.animate(m,c,n.easing);i<s;i++)a.animate(g,c,n.easing).animate(h,c,n.easing);a.animate(g,c,n.easing).animate(m,c/2,n.easing).queue(t),e.effects.unshift(a,l,o+1)})});