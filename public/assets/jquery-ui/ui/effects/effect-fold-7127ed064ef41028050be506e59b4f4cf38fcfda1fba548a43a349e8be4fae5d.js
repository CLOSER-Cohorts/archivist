/*!
 * jQuery UI Effects Fold 1.12.1
 * http://jqueryui.com
 *
 * Copyright jQuery Foundation and other contributors
 * Released under the MIT license.
 * http://jquery.org/license
 */
!function(e){"function"==typeof define&&define.amd?define(["jquery","../version","../effect"],e):e(jQuery)}(function(e){return e.effects.define("fold","hide",function(i,t){var n=e(this),c=i.mode,f="show"===c,o="hide"===c,s=i.size||15,a=/([0-9]+)%/.exec(s),l=!!i.horizFirst?["right","bottom"]:["bottom","right"],u=i.duration/2,p=e.effects.createPlaceholder(n),r=n.cssClip(),d={clip:e.extend({},r)},h={clip:e.extend({},r)},m=[r[l[0]],r[l[1]]],g=n.queue().length;a&&(s=parseInt(a[1],10)/100*m[o?0:1]),d.clip[l[0]]=s,h.clip[l[0]]=s,h.clip[l[1]]=0,f&&(n.cssClip(h.clip),p&&p.css(e.effects.clipToBox(h)),h.clip=r),n.queue(function(t){p&&p.animate(e.effects.clipToBox(d),u,i.easing).animate(e.effects.clipToBox(h),u,i.easing),t()}).animate(d,u,i.easing).animate(h,u,i.easing).queue(t),e.effects.unshift(n,g,4)})});