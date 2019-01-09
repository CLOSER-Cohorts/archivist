/*!
 * jQuery UI Effects Fade 1.12.1
 * http://jqueryui.com
 *
 * Copyright jQuery Foundation and other contributors
 * Released under the MIT license.
 * http://jquery.org/license
 */
!function(e){"function"==typeof define&&define.amd?define(["jquery","../version","../effect"],e):e(jQuery)}(function(e){return e.effects.define("fade","toggle",function(n,i){var t="show"===n.mode;e(this).css("opacity",t?0:1).animate({opacity:t?1:0},{queue:!1,duration:n.duration,easing:n.easing,complete:i})})});