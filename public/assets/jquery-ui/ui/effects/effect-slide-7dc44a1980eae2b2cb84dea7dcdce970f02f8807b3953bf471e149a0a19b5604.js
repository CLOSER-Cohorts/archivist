/*!
 * jQuery UI Effects Slide 1.12.1
 * http://jqueryui.com
 *
 * Copyright jQuery Foundation and other contributors
 * Released under the MIT license.
 * http://jquery.org/license
 */
!function(e){"function"==typeof define&&define.amd?define(["jquery","../version","../effect"],e):e(jQuery)}(function(e){return e.effects.define("slide","show",function(t,i){var o,n,c=e(this),f={up:["bottom","top"],down:["top","bottom"],left:["right","left"],right:["left","right"]},s=t.mode,l=t.direction||"left",p="up"===l||"down"===l?"top":"left",r="up"===l||"left"===l,u=t.distance||c["top"===p?"outerHeight":"outerWidth"](!0),d={};e.effects.createPlaceholder(c),o=c.cssClip(),n=c.position()[p],d[p]=(r?-1:1)*u+n,d.clip=c.cssClip(),d.clip[f[l][1]]=d.clip[f[l][0]],"show"===s&&(c.cssClip(d.clip),c.css(p,d[p]),d.clip=o,d[p]=n),c.animate(d,{queue:!1,duration:t.duration,easing:t.easing,complete:i})})});