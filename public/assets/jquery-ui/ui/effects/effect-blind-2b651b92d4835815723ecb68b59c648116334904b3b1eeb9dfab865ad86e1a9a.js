/*!
 * jQuery UI Effects Blind 1.12.1
 * http://jqueryui.com
 *
 * Copyright jQuery Foundation and other contributors
 * Released under the MIT license.
 * http://jquery.org/license
 */
!function(e){"function"==typeof define&&define.amd?define(["jquery","../version","../effect"],e):e(jQuery)}(function(e){return e.effects.define("blind","hide",function(t,i){var o={up:["bottom","top"],vertical:["bottom","top"],down:["top","bottom"],left:["right","left"],horizontal:["right","left"],right:["left","right"]},n=e(this),c=t.direction||"up",f=n.cssClip(),l={clip:e.extend({},f)},r=e.effects.createPlaceholder(n);l.clip[o[c][0]]=l.clip[o[c][1]],"show"===t.mode&&(n.cssClip(l.clip),r&&r.css(e.effects.clipToBox(l)),l.clip=f),r&&r.animate(e.effects.clipToBox(l),t.duration,t.easing),n.animate(l,{queue:!1,duration:t.duration,easing:t.easing,complete:i})})});