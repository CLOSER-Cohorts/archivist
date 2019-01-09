/*!
 * jQuery UI Effects Highlight 1.12.1
 * http://jqueryui.com
 *
 * Copyright jQuery Foundation and other contributors
 * Released under the MIT license.
 * http://jquery.org/license
 */
!function(e){"function"==typeof define&&define.amd?define(["jquery","../version","../effect"],e):e(jQuery)}(function(e){return e.effects.define("highlight","show",function(n,o){var f=e(this),i={backgroundColor:f.css("backgroundColor")};"hide"===n.mode&&(i.opacity=0),e.effects.saveStyle(f),f.css({backgroundImage:"none",backgroundColor:n.color||"#ffff99"}).animate(i,{queue:!1,duration:n.duration,easing:n.easing,complete:o})})});