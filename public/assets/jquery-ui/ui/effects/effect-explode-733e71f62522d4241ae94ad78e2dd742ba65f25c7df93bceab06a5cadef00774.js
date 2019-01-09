/*!
 * jQuery UI Effects Explode 1.12.1
 * http://jqueryui.com
 *
 * Copyright jQuery Foundation and other contributors
 * Released under the MIT license.
 * http://jquery.org/license
 */
!function(e){"function"==typeof define&&define.amd?define(["jquery","../version","../effect"],e):e(jQuery)}(function(e){return e.effects.define("explode","hide",function(i,t){function o(){w.push(this),w.length===h*p&&s()}function s(){r.css({visibility:"visible"}),e(w).remove(),t()}var n,f,d,c,a,l,h=i.pieces?Math.round(Math.sqrt(i.pieces)):3,p=h,r=e(this),u="show"===i.mode,v=r.show().css("visibility","hidden").offset(),y=Math.ceil(r.outerWidth()/p),b=Math.ceil(r.outerHeight()/h),w=[];for(n=0;n<h;n++)for(c=v.top+n*b,l=n-(h-1)/2,f=0;f<p;f++)d=v.left+f*y,a=f-(p-1)/2,r.clone().appendTo("body").wrap("<div></div>").css({position:"absolute",visibility:"visible",left:-f*y,top:-n*b}).parent().addClass("ui-effects-explode").css({position:"absolute",overflow:"hidden",width:y,height:b,left:d+(u?a*y:0),top:c+(u?l*b:0),opacity:u?0:1}).animate({left:d+(u?0:a*y),top:c+(u?0:l*b),opacity:u?1:0},i.duration||500,i.easing,o)})});