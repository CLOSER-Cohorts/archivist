/******/
 (function(modules) { // webpackBootstrap
/******/ 	// The module cache
/******/ 	var installedModules = {};

/******/ 	// The require function
/******/ 	function __webpack_require__(moduleId) {

/******/ 		// Check if module is in cache
/******/ 		if(installedModules[moduleId])
/******/ 			return installedModules[moduleId].exports;

/******/ 		// Create a new module (and put it into the cache)
/******/ 		var module = installedModules[moduleId] = {
/******/ 			exports: {},
/******/ 			id: moduleId,
/******/ 			loaded: false
/******/ 		};

/******/ 		// Execute the module function
/******/ 		modules[moduleId].call(module.exports, module, module.exports, __webpack_require__);

/******/ 		// Flag the module as loaded
/******/ 		module.loaded = true;

/******/ 		// Return the exports of the module
/******/ 		return module.exports;
/******/ 	}


/******/ 	// expose the modules object (__webpack_modules__)
/******/ 	__webpack_require__.m = modules;

/******/ 	// expose the module cache
/******/ 	__webpack_require__.c = installedModules;

/******/ 	// __webpack_public_path__
/******/ 	__webpack_require__.p = "./dist/";

/******/ 	// Load entry module and return exports
/******/ 	return __webpack_require__(0);
/******/ })
/************************************************************************/
/******/ ([
/* 0 */
/***/ function(module, exports, __webpack_require__) {

	"use strict";
	// tslint:disable-next-line
	__webpack_require__(1);
	// tslint:disable-next-line
	__webpack_require__(4);
	Object.defineProperty(exports, "__esModule", { value: true });
	exports.default = angular.module('bsLoadingOverlaySpinJs', ['angularSpinner'])
	    .run([
	    '$templateCache',
	    function ($templateCache) {
	        return $templateCache.put('bsLoadingOverlaySpinJs', '<div us-spinner="{{bsLoadingOverlayTemplateOptions}}"></div>');
	    }
	]);


/***/ },
/* 1 */
/***/ function(module, exports, __webpack_require__) {

	__webpack_require__(2)(__webpack_require__(3))

/***/ },
/* 2 */
/***/ function(module, exports) {

	/*
		MIT License http://www.opensource.org/licenses/mit-license.php
		Author Tobias Koppers @sokra
	*/
	module.exports = function(src) {
		if (typeof execScript !== "undefined")
			execScript(src);
		else
			eval.call(null, src);
	}


/***/ },
/* 3 */
/***/ function(module, exports) {

	module.exports = "/**\n * Copyright (c) 2011-2014 Felix Gnass\n * Licensed under the MIT license\n * http://spin.js.org/\n *\n * Example:\n    var opts = {\n      lines: 12             // The number of lines to draw\n    , length: 7             // The length of each line\n    , width: 5              // The line thickness\n    , radius: 10            // The radius of the inner circle\n    , scale: 1.0            // Scales overall size of the spinner\n    , corners: 1            // Roundness (0..1)\n    , color: '#000'         // #rgb or #rrggbb\n    , opacity: 1/4          // Opacity of the lines\n    , rotate: 0             // Rotation offset\n    , direction: 1          // 1: clockwise, -1: counterclockwise\n    , speed: 1              // Rounds per second\n    , trail: 100            // Afterglow percentage\n    , fps: 20               // Frames per second when using setTimeout()\n    , zIndex: 2e9           // Use a high z-index by default\n    , className: 'spinner'  // CSS class to assign to the element\n    , top: '50%'            // center vertically\n    , left: '50%'           // center horizontally\n    , shadow: false         // Whether to render a shadow\n    , hwaccel: false        // Whether to use hardware acceleration (might be buggy)\n    , position: 'absolute'  // Element positioning\n    }\n    var target = document.getElementById('foo')\n    var spinner = new Spinner(opts).spin(target)\n */\n;(function (root, factory) {\n\n  /* CommonJS */\n  if (typeof module == 'object' && module.exports) module.exports = factory()\n\n  /* AMD module */\n  else if (typeof define == 'function' && define.amd) define(factory)\n\n  /* Browser global */\n  else root.Spinner = factory()\n}(this, function () {\n  \"use strict\"\n\n  var prefixes = ['webkit', 'Moz', 'ms', 'O'] /* Vendor prefixes */\n    , animations = {} /* Animation rules keyed by their name */\n    , useCssAnimations /* Whether to use CSS animations or setTimeout */\n    , sheet /* A stylesheet to hold the @keyframe or VML rules. */\n\n  /**\n   * Utility function to create elements. If no tag name is given,\n   * a DIV is created. Optionally properties can be passed.\n   */\n  function createEl (tag, prop) {\n    var el = document.createElement(tag || 'div')\n      , n\n\n    for (n in prop) el[n] = prop[n]\n    return el\n  }\n\n  /**\n   * Appends children and returns the parent.\n   */\n  function ins (parent /* child1, child2, ...*/) {\n    for (var i = 1, n = arguments.length; i < n; i++) {\n      parent.appendChild(arguments[i])\n    }\n\n    return parent\n  }\n\n  /**\n   * Creates an opacity keyframe animation rule and returns its name.\n   * Since most mobile Webkits have timing issues with animation-delay,\n   * we create separate rules for each line/segment.\n   */\n  function addAnimation (alpha, trail, i, lines) {\n    var name = ['opacity', trail, ~~(alpha * 100), i, lines].join('-')\n      , start = 0.01 + i/lines * 100\n      , z = Math.max(1 - (1-alpha) / trail * (100-start), alpha)\n      , prefix = useCssAnimations.substring(0, useCssAnimations.indexOf('Animation')).toLowerCase()\n      , pre = prefix && '-' + prefix + '-' || ''\n\n    if (!animations[name]) {\n      sheet.insertRule(\n        '@' + pre + 'keyframes ' + name + '{' +\n        '0%{opacity:' + z + '}' +\n        start + '%{opacity:' + alpha + '}' +\n        (start+0.01) + '%{opacity:1}' +\n        (start+trail) % 100 + '%{opacity:' + alpha + '}' +\n        '100%{opacity:' + z + '}' +\n        '}', sheet.cssRules.length)\n\n      animations[name] = 1\n    }\n\n    return name\n  }\n\n  /**\n   * Tries various vendor prefixes and returns the first supported property.\n   */\n  function vendor (el, prop) {\n    var s = el.style\n      , pp\n      , i\n\n    prop = prop.charAt(0).toUpperCase() + prop.slice(1)\n    if (s[prop] !== undefined) return prop\n    for (i = 0; i < prefixes.length; i++) {\n      pp = prefixes[i]+prop\n      if (s[pp] !== undefined) return pp\n    }\n  }\n\n  /**\n   * Sets multiple style properties at once.\n   */\n  function css (el, prop) {\n    for (var n in prop) {\n      el.style[vendor(el, n) || n] = prop[n]\n    }\n\n    return el\n  }\n\n  /**\n   * Fills in default values.\n   */\n  function merge (obj) {\n    for (var i = 1; i < arguments.length; i++) {\n      var def = arguments[i]\n      for (var n in def) {\n        if (obj[n] === undefined) obj[n] = def[n]\n      }\n    }\n    return obj\n  }\n\n  /**\n   * Returns the line color from the given string or array.\n   */\n  function getColor (color, idx) {\n    return typeof color == 'string' ? color : color[idx % color.length]\n  }\n\n  // Built-in defaults\n\n  var defaults = {\n    lines: 12             // The number of lines to draw\n  , length: 7             // The length of each line\n  , width: 5              // The line thickness\n  , radius: 10            // The radius of the inner circle\n  , scale: 1.0            // Scales overall size of the spinner\n  , corners: 1            // Roundness (0..1)\n  , color: '#000'         // #rgb or #rrggbb\n  , opacity: 1/4          // Opacity of the lines\n  , rotate: 0             // Rotation offset\n  , direction: 1          // 1: clockwise, -1: counterclockwise\n  , speed: 1              // Rounds per second\n  , trail: 100            // Afterglow percentage\n  , fps: 20               // Frames per second when using setTimeout()\n  , zIndex: 2e9           // Use a high z-index by default\n  , className: 'spinner'  // CSS class to assign to the element\n  , top: '50%'            // center vertically\n  , left: '50%'           // center horizontally\n  , shadow: false         // Whether to render a shadow\n  , hwaccel: false        // Whether to use hardware acceleration (might be buggy)\n  , position: 'absolute'  // Element positioning\n  }\n\n  /** The constructor */\n  function Spinner (o) {\n    this.opts = merge(o || {}, Spinner.defaults, defaults)\n  }\n\n  // Global defaults that override the built-ins:\n  Spinner.defaults = {}\n\n  merge(Spinner.prototype, {\n    /**\n     * Adds the spinner to the given target element. If this instance is already\n     * spinning, it is automatically removed from its previous target b calling\n     * stop() internally.\n     */\n    spin: function (target) {\n      this.stop()\n\n      var self = this\n        , o = self.opts\n        , el = self.el = createEl(null, {className: o.className})\n\n      css(el, {\n        position: o.position\n      , width: 0\n      , zIndex: o.zIndex\n      , left: o.left\n      , top: o.top\n      })\n\n      if (target) {\n        target.insertBefore(el, target.firstChild || null)\n      }\n\n      el.setAttribute('role', 'progressbar')\n      self.lines(el, self.opts)\n\n      if (!useCssAnimations) {\n        // No CSS animation support, use setTimeout() instead\n        var i = 0\n          , start = (o.lines - 1) * (1 - o.direction) / 2\n          , alpha\n          , fps = o.fps\n          , f = fps / o.speed\n          , ostep = (1 - o.opacity) / (f * o.trail / 100)\n          , astep = f / o.lines\n\n        ;(function anim () {\n          i++\n          for (var j = 0; j < o.lines; j++) {\n            alpha = Math.max(1 - (i + (o.lines - j) * astep) % f * ostep, o.opacity)\n\n            self.opacity(el, j * o.direction + start, alpha, o)\n          }\n          self.timeout = self.el && setTimeout(anim, ~~(1000 / fps))\n        })()\n      }\n      return self\n    }\n\n    /**\n     * Stops and removes the Spinner.\n     */\n  , stop: function () {\n      var el = this.el\n      if (el) {\n        clearTimeout(this.timeout)\n        if (el.parentNode) el.parentNode.removeChild(el)\n        this.el = undefined\n      }\n      return this\n    }\n\n    /**\n     * Internal method that draws the individual lines. Will be overwritten\n     * in VML fallback mode below.\n     */\n  , lines: function (el, o) {\n      var i = 0\n        , start = (o.lines - 1) * (1 - o.direction) / 2\n        , seg\n\n      function fill (color, shadow) {\n        return css(createEl(), {\n          position: 'absolute'\n        , width: o.scale * (o.length + o.width) + 'px'\n        , height: o.scale * o.width + 'px'\n        , background: color\n        , boxShadow: shadow\n        , transformOrigin: 'left'\n        , transform: 'rotate(' + ~~(360/o.lines*i + o.rotate) + 'deg) translate(' + o.scale*o.radius + 'px' + ',0)'\n        , borderRadius: (o.corners * o.scale * o.width >> 1) + 'px'\n        })\n      }\n\n      for (; i < o.lines; i++) {\n        seg = css(createEl(), {\n          position: 'absolute'\n        , top: 1 + ~(o.scale * o.width / 2) + 'px'\n        , transform: o.hwaccel ? 'translate3d(0,0,0)' : ''\n        , opacity: o.opacity\n        , animation: useCssAnimations && addAnimation(o.opacity, o.trail, start + i * o.direction, o.lines) + ' ' + 1 / o.speed + 's linear infinite'\n        })\n\n        if (o.shadow) ins(seg, css(fill('#000', '0 0 4px #000'), {top: '2px'}))\n        ins(el, ins(seg, fill(getColor(o.color, i), '0 0 1px rgba(0,0,0,.1)')))\n      }\n      return el\n    }\n\n    /**\n     * Internal method that adjusts the opacity of a single line.\n     * Will be overwritten in VML fallback mode below.\n     */\n  , opacity: function (el, i, val) {\n      if (i < el.childNodes.length) el.childNodes[i].style.opacity = val\n    }\n\n  })\n\n\n  function initVML () {\n\n    /* Utility function to create a VML tag */\n    function vml (tag, attr) {\n      return createEl('<' + tag + ' xmlns=\"urn:schemas-microsoft.com:vml\" class=\"spin-vml\">', attr)\n    }\n\n    // No CSS transforms but VML support, add a CSS rule for VML elements:\n    sheet.addRule('.spin-vml', 'behavior:url(#default#VML)')\n\n    Spinner.prototype.lines = function (el, o) {\n      var r = o.scale * (o.length + o.width)\n        , s = o.scale * 2 * r\n\n      function grp () {\n        return css(\n          vml('group', {\n            coordsize: s + ' ' + s\n          , coordorigin: -r + ' ' + -r\n          })\n        , { width: s, height: s }\n        )\n      }\n\n      var margin = -(o.width + o.length) * o.scale * 2 + 'px'\n        , g = css(grp(), {position: 'absolute', top: margin, left: margin})\n        , i\n\n      function seg (i, dx, filter) {\n        ins(\n          g\n        , ins(\n            css(grp(), {rotation: 360 / o.lines * i + 'deg', left: ~~dx})\n          , ins(\n              css(\n                vml('roundrect', {arcsize: o.corners})\n              , { width: r\n                , height: o.scale * o.width\n                , left: o.scale * o.radius\n                , top: -o.scale * o.width >> 1\n                , filter: filter\n                }\n              )\n            , vml('fill', {color: getColor(o.color, i), opacity: o.opacity})\n            , vml('stroke', {opacity: 0}) // transparent stroke to fix color bleeding upon opacity change\n            )\n          )\n        )\n      }\n\n      if (o.shadow)\n        for (i = 1; i <= o.lines; i++) {\n          seg(i, -2, 'progid:DXImageTransform.Microsoft.Blur(pixelradius=2,makeshadow=1,shadowopacity=.3)')\n        }\n\n      for (i = 1; i <= o.lines; i++) seg(i)\n      return ins(el, g)\n    }\n\n    Spinner.prototype.opacity = function (el, i, val, o) {\n      var c = el.firstChild\n      o = o.shadow && o.lines || 0\n      if (c && i + o < c.childNodes.length) {\n        c = c.childNodes[i + o]; c = c && c.firstChild; c = c && c.firstChild\n        if (c) c.opacity = val\n      }\n    }\n  }\n\n  if (typeof document !== 'undefined') {\n    sheet = (function () {\n      var el = createEl('style', {type : 'text/css'})\n      ins(document.getElementsByTagName('head')[0], el)\n      return el.sheet || el.styleSheet\n    }())\n\n    var probe = css(createEl('group'), {behavior: 'url(#default#VML)'})\n\n    if (!vendor(probe, 'transform') && probe.adj) initVML()\n    else useCssAnimations = vendor(probe, 'animation')\n  }\n\n  return Spinner\n\n}));\n"

/***/ },
/* 4 */
/***/ function(module, exports, __webpack_require__) {

	__webpack_require__(2)(__webpack_require__(5))

/***/ },
/* 5 */
/***/ function(module, exports) {

	module.exports = "/**\r\n * angular-spinner version 0.8.1\r\n * License: MIT.\r\n * Copyright (C) 2013, 2014, 2015, 2016, Uri Shaked and contributors.\r\n */\r\n\r\n'format amd';\r\n\r\n(function (root) {\r\n\t'use strict';\r\n\r\n\tfunction factory(angular, Spinner) {\r\n\r\n\t\treturn angular\r\n\t\t\t.module('angularSpinner', [])\r\n\r\n\t\t\t.constant('SpinJSSpinner', Spinner)\r\n\r\n\t\t\t.provider('usSpinnerConfig', function () {\r\n\t\t\t\tvar _config = {}, _themes = {};\r\n\r\n\t\t\t\treturn {\r\n\t\t\t\t\tsetDefaults: function (config) {\r\n\t\t\t\t\t\t_config = config || _config;\r\n\t\t\t\t\t},\r\n\t\t\t\t\tsetTheme: function(name, config) {\r\n\t\t\t\t\t\t_themes[name] = config;\r\n\t\t\t\t\t},\r\n\t\t\t\t\t$get: function () {\r\n\t\t\t\t\t\treturn {\r\n\t\t\t\t\t\t\tconfig: _config,\r\n\t\t\t\t\t\t\tthemes: _themes\r\n\t\t\t\t\t\t};\r\n\t\t\t\t\t}\r\n\t\t\t\t};\r\n\t\t\t})\r\n\r\n\t\t\t.factory('usSpinnerService', ['$rootScope', function ($rootScope) {\r\n\t\t\t\tvar config = {};\r\n\r\n\t\t\t\tconfig.spin = function (key) {\r\n\t\t\t\t\t$rootScope.$broadcast('us-spinner:spin', key);\r\n\t\t\t\t};\r\n\r\n\t\t\t\tconfig.stop = function (key) {\r\n\t\t\t\t\t$rootScope.$broadcast('us-spinner:stop', key);\r\n\t\t\t\t};\r\n\r\n\t\t\t\treturn config;\r\n\t\t\t}])\r\n\r\n\t\t\t.directive('usSpinner', ['SpinJSSpinner', 'usSpinnerConfig', function (SpinJSSpinner, usSpinnerConfig) {\r\n\t\t\t\treturn {\r\n\t\t\t\t\tscope: true,\r\n\t\t\t\t\tlink: function (scope, element, attr) {\r\n\t\t\t\t\t\tscope.spinner = null;\r\n\r\n\t\t\t\t\t\tscope.key = angular.isDefined(attr.spinnerKey) ? attr.spinnerKey : false;\r\n\r\n\t\t\t\t\t\tscope.startActive = angular.isDefined(attr.spinnerStartActive) ?\r\n\t\t\t\t\t\t\tscope.$eval(attr.spinnerStartActive) : scope.key ?\r\n\t\t\t\t\t\t\tfalse : true;\r\n\r\n\t\t\t\t\t\tfunction stopSpinner() {\r\n\t\t\t\t\t\t\tif (scope.spinner) {\r\n\t\t\t\t\t\t\t\tscope.spinner.stop();\r\n\t\t\t\t\t\t\t}\r\n\t\t\t\t\t\t}\r\n\r\n\t\t\t\t\t\tscope.spin = function () {\r\n\t\t\t\t\t\t\tif (scope.spinner) {\r\n\t\t\t\t\t\t\t\tscope.spinner.spin(element[0]);\r\n\t\t\t\t\t\t\t}\r\n\t\t\t\t\t\t};\r\n\r\n\t\t\t\t\t\tscope.stop = function () {\r\n\t\t\t\t\t\t\tscope.startActive = false;\r\n\t\t\t\t\t\t\tstopSpinner();\r\n\t\t\t\t\t\t};\r\n\r\n\t\t\t\t\t\tscope.$watch(attr.usSpinner, function (options) {\r\n\t\t\t\t\t\t\tstopSpinner();\r\n\r\n\t\t\t\t\t\t\t// order of precedence: element options, theme, defaults.\r\n\t\t\t\t\t\t\toptions = angular.extend(\r\n\t\t\t\t\t\t\t\t{},\r\n\t\t\t\t\t\t\t\tusSpinnerConfig.config,\r\n\t\t\t\t\t\t\t\tusSpinnerConfig.themes[attr.spinnerTheme],\r\n\t\t\t\t\t\t\t\toptions);\r\n\r\n\t\t\t\t\t\t\tscope.spinner = new SpinJSSpinner(options);\r\n\t\t\t\t\t\t\tif ((!scope.key || scope.startActive) && !attr.spinnerOn) {\r\n\t\t\t\t\t\t\t\tscope.spinner.spin(element[0]);\r\n\t\t\t\t\t\t\t}\r\n\t\t\t\t\t\t}, true);\r\n\r\n\t\t\t\t\t\tif (attr.spinnerOn) {\r\n\t\t\t\t\t\t\tscope.$watch(attr.spinnerOn, function (spin) {\r\n\t\t\t\t\t\t\t\tif (spin) {\r\n\t\t\t\t\t\t\t\t\tscope.spin();\r\n\t\t\t\t\t\t\t\t} else {\r\n\t\t\t\t\t\t\t\t\tscope.stop();\r\n\t\t\t\t\t\t\t\t}\r\n\t\t\t\t\t\t\t});\r\n\t\t\t\t\t\t}\r\n\r\n\t\t\t\t\t\tscope.$on('us-spinner:spin', function (event, key) {\r\n\t\t\t\t\t\t\tif (key === scope.key) {\r\n\t\t\t\t\t\t\t\tscope.spin();\r\n\t\t\t\t\t\t\t}\r\n\t\t\t\t\t\t});\r\n\r\n\t\t\t\t\t\tscope.$on('us-spinner:stop', function (event, key) {\r\n\t\t\t\t\t\t\tif (key === scope.key) {\r\n\t\t\t\t\t\t\t\tscope.stop();\r\n\t\t\t\t\t\t\t}\r\n\t\t\t\t\t\t});\r\n\r\n\t\t\t\t\t\tscope.$on('$destroy', function () {\r\n\t\t\t\t\t\t\tscope.stop();\r\n\t\t\t\t\t\t\tscope.spinner = null;\r\n\t\t\t\t\t\t});\r\n\t\t\t\t\t}\r\n\t\t\t\t};\r\n\t\t\t}]);\r\n\t}\n\n\tif ((typeof module === 'object') && module.exports) {\n\t\t/* CommonJS module */\r\n\t\tmodule.exports = factory(require('angular'), require('spin.js'));\r\n\t} else if (typeof define === 'function' && define.amd) {\r\n\t\t/* AMD module */\r\n\t\tdefine(['angular', 'spin'], factory);\n\t} else {\r\n\t\t/* Browser global */\r\n\t\tfactory(root.angular, root.Spinner);\r\n\t}\r\n}(this));\r\n"

/***/ }
/******/ ]);
