/*!
 * jQuery UI Effects Scale 1.12.1
 * http://jqueryui.com
 *
 * Copyright jQuery Foundation and other contributors
 * Released under the MIT license.
 * http://jquery.org/license
 */
!function(e){"function"==typeof define&&define.amd?define(["jquery","../version","../effect","./effect-size"],e):e(jQuery)}(function(e){return e.effects.define("scale",function(f,t){var n=e(this),i=f.mode,c=parseInt(f.percent,10)||(0===parseInt(f.percent,10)?0:"effect"!==i?0:100),o=e.extend(!0,{from:e.effects.scaledDimensions(n),to:e.effects.scaledDimensions(n,c,f.direction||"both"),origin:f.origin||["middle","center"]},f);f.fade&&(o.from.opacity=1,o.to.opacity=0),e.effects.effect.size.call(this,o,t)})});