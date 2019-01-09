/*!
 * jQuery UI Effects Puff 1.12.1
 * http://jqueryui.com
 *
 * Copyright jQuery Foundation and other contributors
 * Released under the MIT license.
 * http://jquery.org/license
 */
!function(e){"function"==typeof define&&define.amd?define(["jquery","../version","../effect","./effect-scale"],e):e(jQuery)}(function(e){return e.effects.define("puff","hide",function(f,n){var t=e.extend(!0,{},f,{fade:!0,percent:parseInt(f.percent,10)||150});e.effects.effect.scale.call(this,t,n)})});