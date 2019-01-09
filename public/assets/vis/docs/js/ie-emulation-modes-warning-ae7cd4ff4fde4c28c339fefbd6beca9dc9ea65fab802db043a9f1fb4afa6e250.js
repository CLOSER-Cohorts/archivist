/*!
 * Copyright 2014 Twitter, Inc.
 *
 * Licensed under the Creative Commons Attribution 3.0 Unported License. For
 * details, see http://creativecommons.org/licenses/by/3.0/.
 */
!function(){"use strict";function n(){var n=/MSIE ([0-9.]+)/.exec(window.navigator.userAgent);if(null===n)return null;var e=parseInt(n[1],10);return Math.floor(e)}function e(){var n=new Function("/*@cc_on return @_jscript_version; @*/")();return n===undefined?11:n<9?8:n}var r=window.navigator.userAgent;if(!(r.indexOf("Opera")>-1||r.indexOf("Presto")>-1)){var i=n();if(null!==i){var o=e();i!==o&&window.alert("WARNING: You appear to be using IE"+o+" in IE"+i+" emulation mode.\nIE emulation modes can behave significantly differently from ACTUAL older versions of IE.\nPLEASE DON'T FILE BOOTSTRAP BUGS based on testing in IE emulation modes!")}}}();