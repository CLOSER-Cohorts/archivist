/*!
 * jQuery UI Effects Clip 1.12.1
 * http://jqueryui.com
 *
 * Copyright jQuery Foundation and other contributors
 * Released under the MIT license.
 * http://jquery.org/license
 */
!function(t){"function"==typeof define&&define.amd?define(["jquery","../version","../effect"],t):t(jQuery)}(function(t){return t.effects.define("clip","hide",function(e,i){var o,n={},c=t(this),f=e.direction||"vertical",r="both"===f,l=r||"horizontal"===f,a=r||"vertical"===f;o=c.cssClip(),n.clip={top:a?(o.bottom-o.top)/2:o.top,right:l?(o.right-o.left)/2:o.right,bottom:a?(o.bottom-o.top)/2:o.bottom,left:l?(o.right-o.left)/2:o.left},t.effects.createPlaceholder(c),"show"===e.mode&&(c.cssClip(n.clip),n.clip=o),c.animate(n,{queue:!1,duration:e.duration,easing:e.easing,complete:i})})});