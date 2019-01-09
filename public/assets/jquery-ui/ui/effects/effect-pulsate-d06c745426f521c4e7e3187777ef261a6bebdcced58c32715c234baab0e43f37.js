/*!
 * jQuery UI Effects Pulsate 1.12.1
 * http://jqueryui.com
 *
 * Copyright jQuery Foundation and other contributors
 * Released under the MIT license.
 * http://jquery.org/license
 */
!function(e){"function"==typeof define&&define.amd?define(["jquery","../version","../effect"],e):e(jQuery)}(function(e){return e.effects.define("pulsate","show",function(i,n){var t=e(this),f=i.mode,s="show"===f,o=s||"hide"===f,u=2*(i.times||5)+(o?1:0),a=i.duration/u,c=0,d=1,r=t.queue().length;for(!s&&t.is(":visible")||(t.css("opacity",0).show(),c=1);d<u;d++)t.animate({opacity:c},a,i.easing),c=1-c;t.animate({opacity:c},a,i.easing),t.queue(n),e.effects.unshift(t,r,u+1)})});