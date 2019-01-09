/*!
 * jQuery UI Focusable 1.12.1
 * http://jqueryui.com
 *
 * Copyright jQuery Foundation and other contributors
 * Released under the MIT license.
 * http://jquery.org/license
 */
!function(e){"function"==typeof define&&define.amd?define(["jquery","./version"],e):e(jQuery)}(function(e){function i(e){for(var i=e.css("visibility");"inherit"===i;)i=(e=e.parent()).css("visibility");return"hidden"!==i}return e.ui.focusable=function(t,n){var a,r,s,o,u,f=t.nodeName.toLowerCase();return"area"===f?(r=(a=t.parentNode).name,!(!t.href||!r||"map"!==a.nodeName.toLowerCase())&&((s=e("img[usemap='#"+r+"']")).length>0&&s.is(":visible"))):(/^(input|select|textarea|button|object)$/.test(f)?(o=!t.disabled)&&(u=e(t).closest("fieldset")[0])&&(o=!u.disabled):o="a"===f&&t.href||n,o&&e(t).is(":visible")&&i(e(t)))},e.extend(e.expr[":"],{focusable:function(i){return e.ui.focusable(i,null!=e.attr(i,"tabindex"))}}),e.ui.focusable});