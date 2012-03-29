/*jslint browser: true */ /*global jQuery: true */

/**
 * jQuery Cookie plugin
 *
 * Copyright (c) 2010 Klaus Hartl (stilbuero.de)
 * Dual licensed under the MIT and GPL licenses:
 * http://www.opensource.org/licenses/mit-license.php
 * http://www.gnu.org/licenses/gpl.html
 *
 */

// TODO JsDoc

/**
 * Create a cookie with the given key and value and other optional parameters.
 *
 * @example $.cookie('the_cookie', 'the_value');
 * @desc Set the value of a cookie.
 * @example $.cookie('the_cookie', 'the_value', { expires: 7, path: '/', domain: 'jquery.com', secure: true });
 * @desc Create a cookie with all available options.
 * @example $.cookie('the_cookie', 'the_value');
 * @desc Create a session cookie.
 * @example $.cookie('the_cookie', null);
 * @desc Delete a cookie by passing null as value. Keep in mind that you have to use the same path and domain
 *       used when the cookie was set.
 *
 * @param String key The key of the cookie.
 * @param String value The value of the cookie.
 * @param Object options An object literal containing key/value pairs to provide optional cookie attributes.
 * @option Number|Date expires Either an integer specifying the expiration date from now on in days or a Date object.
 *                             If a negative value is specified (e.g. a date in the past), the cookie will be deleted.
 *                             If set to null or omitted, the cookie will be a session cookie and will not be retained
 *                             when the the browser exits.
 * @option String path The value of the path atribute of the cookie (default: path of page that created the cookie).
 * @option String domain The value of the domain attribute of the cookie (default: domain of page that created the cookie).
 * @option Boolean secure If true, the secure attribute of the cookie will be set and the cookie transmission will
 *                        require a secure protocol (like HTTPS).
 * @type undefined
 *
 * @name $.cookie
 * @cat Plugins/Cookie
 * @author Klaus Hartl/klaus.hartl@stilbuero.de
 */

/**
 * Get the value of a cookie with the given key.
 *
 * @example $.cookie('the_cookie');
 * @desc Get the value of a cookie.
 *
 * @param String key The key of the cookie.
 * @return The value of the cookie.
 * @type String
 *
 * @name $.cookie
 * @cat Plugins/Cookie
 * @author Klaus Hartl/klaus.hartl@stilbuero.de
 */
jQuery.cookie = function (key, value, options) {
    
    // key and at least value given, set cookie...
    if (arguments.length > 1 && String(value) !== "[object Object]") {
        options = jQuery.extend({}, options);

        if (value === null || value === undefined) {
            options.expires = -1;
        }

        if (typeof options.expires === 'number') {
            var days = options.expires, t = options.expires = new Date();
            t.setDate(t.getDate() + days);
        }
        
        value = String(value);
        
        return (document.cookie = [
            encodeURIComponent(key), '=',
            options.raw ? value : encodeURIComponent(value),
            options.expires ? '; expires=' + options.expires.toUTCString() : '', // use expires attribute, max-age is not supported by IE
            options.path ? '; path=' + options.path : '',
            options.domain ? '; domain=' + options.domain : '',
            options.secure ? '; secure' : ''
        ].join(''));
    }

    // key and possibly options given, get cookie...
    options = value || {};
    var result, decode = options.raw ? function (s) { return s; } : decodeURIComponent;
    return (result = new RegExp('(?:^|; )' + encodeURIComponent(key) + '=([^;]*)').exec(document.cookie)) ? decode(result[1]) : null;
};

/**
* Condense 0.1 - Condense and expand text heavy elements
*
* (c) 2008 Joseph Sillitoe
* Dual licensed under the MIT License (MIT-LICENSE) and GPL License,version 2 (GPL-LICENSE).
*/

/*
* jQuery plugin
*
* usage:
*
*   $(document).ready(function(){
*     $('#example1').condense();
*   });
*
* Options:
*  condensedLength: Target length of condensed element. Default: 200
*  minTrail: Minimun length of the trailing text. Default: 20
*  delim: Delimiter used for finding the break point. Default: " " - {space}
*  moreText: Text used for the more control. Default: [more]
*  lessText: Text used for the less control. Default: [less]
*  ellipsis: Text added to condensed element. Default:  ( ... )
*  moreSpeed: Animation Speed for expanding. Default: "normal"
*  lessSpeed: Animation Speed for condensing. Default: "normal"
*  easing: Easing algorith. Default: "linear"
*/

(function($) {

  // plugin definition
  $.fn.condense = function(options) {

    $.metadata ? debug('metadata plugin detected') : debug('metadata plugin not present');//detect the metadata plugin?

    var opts = $.extend({}, $.fn.condense.defaults, options); // build main options before element iteration

    // iterate each matched element
    return this.each(function() {
	    $this = $(this);

      // support metadata plugin (v2.0)
	    var o = $.metadata ? $.extend({}, opts, $this.metadata()) : opts; // build element specific options

      debug('Condensing ['+$this.text().length+']: '+$this.text());

      var clone = cloneCondensed($this,o);

      if (clone){
        // id attribute switch.  make sure that the visible elem keeps the original id (if set).
        $this.attr('id') ? $this.attr('id','condensed_'+$this.attr('id')) : false;

        var controlMore = " <span class='condense_control condense_control_more' style='cursor:pointer;'>"+o.moreText+"</span>";
        var controlLess = " <span class='condense_control condense_control_less' style='cursor:pointer;'>"+o.lessText+"</span>";
        clone.append(o.ellipsis + controlMore);
        $this.after(clone).hide().append(controlLess);

        $('.condense_control_more',clone).click(function(){
          debug('moreControl clicked.');
          triggerExpand($(this),o)
        });

        $('.condense_control_less',$this).click(function(){
          debug('lessControl clicked.');
          triggerCondense($(this),o)
        });
      }

	  });
  };

  function cloneCondensed(elem, opts){
    // Try to clone and condense the element.  if not possible because of the length/minTrail options, return false.
    // also, dont count tag declarations as part of the text length.
    // check the length of the text first, return false if too short.
    if ($.trim(elem.text()).length <= opts.condensedLength + opts.minTrail){
      debug('element too short: skipping.');
      return false;
    }

    var fullbody = $.trim(elem.html());
    var fulltext = $.trim(elem.text());
    var delim = opts.delim;
    var clone = elem.clone();
    var delta = 0;
    // overcome consecutive deliminator loop
    var buffer = 0;
    var lastCloneTextLength = 0;

    do {
      // find the location of the next potential break-point.
      var loc = findDelimiterLocation(fullbody, opts.delim, (opts.condensedLength + delta + buffer));
      //set the html of the clone to the substring html of the original
      clone.html($.trim(fullbody.substring(0,(loc+1))));
      var cloneTextLength = clone.text().length;
      var cloneHtmlLength = clone.html().length;
      delta = clone.html().length - cloneTextLength;
      // check for loop
      if (lastCloneTextLength == cloneTextLength) {
          buffer++;
      }
      lastCloneTextLength = cloneTextLength;
      debug ("condensing... [html-length:"+cloneHtmlLength+" text-length:"+cloneTextLength+" delta: "+delta+" break-point: "+loc+"]");
    //is the length of the clone text long enough?
    }while(clone.text().length < opts.condensedLength )

    //  after skipping ahead to the delimiter, do we still have enough trailing text?
    if ((fulltext.length - cloneTextLength) < opts.minTrail){
      debug('not enough trailing text: skipping.');
      return false;
    }

    debug('clone condensed. [text-length:'+cloneTextLength+']');
    return clone;
  }


  function findDelimiterLocation(html, delim, startpos){
    // find the location inside the html of the delimiter, starting at the specified length.
    var foundDelim = false;
    var loc = startpos;
    do {
      var loc = html.indexOf(delim, loc);
      if (loc < 0){
        debug ("No delimiter found.");
        return html.length;
      } // if there is no delimiter found, just return the length of the entire html string.
      foundDelim = true;
      while (isInsideTag(html, loc)) {
        // if we are inside a tag, this delim doesn't count.  keep looking...
        loc++;
        foundDelim = false;
      }
    }while(!foundDelim)
    debug ("Delimiter found in html at: "+loc);
    return loc;
  }


  function isInsideTag(html, loc){
    return (html.indexOf('>',loc) < html.indexOf('<',loc));
  }


  function triggerCondense(control, opts){
    debug('Condense Trigger: '+control.html());
    var orig = control.parent(); // The original element will be the control's immediate parent.
    var condensed = orig.next(); // The condensed element will be the original immediate next sibling.
    condensed.show();
    var con_w  = condensed.width();
    var con_h = condensed.height();
    condensed.hide(); //briefly flashed the condensed element so we can get the target width/height
    var orig_w  = orig.width();
    var orig_h = orig.height();
    orig.animate({height:con_h, width:con_w, opacity: 1}, opts.lessSpeed, opts.easing,
      function(){
        orig.height(orig_h).width(orig_w).hide();
        condensed.show();
      });
  }


  function triggerExpand(control, opts){
    debug('Expand Trigger: '+control.html());
    var condensed = control.parent(); // The condensed element will be the control's immediate parent.
    var orig = condensed.prev(); // The original element will be the condensed immediate previous sibling.
    orig.show();
    var orig_w  = orig.width();
    var orig_h = orig.height();
    orig.width(condensed.width()+"px").height(condensed.height()+"px");
    condensed.hide();
    orig.animate({height:orig_h, width:orig_w, opacity: 1}, opts.moreSpeed, opts.easing);
    if(condensed.attr('id')){
      var idAttr = condensed.attr('id');
      condensed.attr('id','condensed_'+idAttr);
      orig.attr('id',idAttr);
    }
  }


  /**
   * private function for debugging
   */
  function debug($obj) {if (window.console && window.console.log){window.console.log($obj);}};


  // plugin defaults
  $.fn.condense.defaults = {
    condensedLength: 200,
    minTrail: 20,
    delim: " ",
    moreText: "[more]",
    lessText: "[less]",
    ellipsis: " ( ... )",
    moreSpeed: "normal",
    lessSpeed: "normal",
    easing: "linear"
  };

})(jQuery);

(function(a){var r=a.fn.domManip,d="_tmplitem",q=/^[^<]*(<[\w\W]+>)[^>]*$|\{\{\! /,b={},f={},e,p={key:0,data:{}},h=0,c=0,l=[];function g(e,d,g,i){var c={data:i||(d?d.data:{}),_wrap:d?d._wrap:null,tmpl:null,parent:d||null,nodes:[],calls:u,nest:w,wrap:x,html:v,update:t};e&&a.extend(c,e,{nodes:[],parent:d});if(g){c.tmpl=g;c._ctnt=c._ctnt||c.tmpl(a,c);c.key=++h;(l.length?f:b)[h]=c}return c}a.each({appendTo:"append",prependTo:"prepend",insertBefore:"before",insertAfter:"after",replaceAll:"replaceWith"},function(f,d){a.fn[f]=function(n){var g=[],i=a(n),k,h,m,l,j=this.length===1&&this[0].parentNode;e=b||{};if(j&&j.nodeType===11&&j.childNodes.length===1&&i.length===1){i[d](this[0]);g=this}else{for(h=0,m=i.length;h<m;h++){c=h;k=(h>0?this.clone(true):this).get();a.fn[d].apply(a(i[h]),k);g=g.concat(k)}c=0;g=this.pushStack(g,f,i.selector)}l=e;e=null;a.tmpl.complete(l);return g}});a.fn.extend({tmpl:function(d,c,b){return a.tmpl(this[0],d,c,b)},tmplItem:function(){return a.tmplItem(this[0])},template:function(b){return a.template(b,this[0])},domManip:function(d,l,j){if(d[0]&&d[0].nodeType){var f=a.makeArray(arguments),g=d.length,i=0,h;while(i<g&&!(h=a.data(d[i++],"tmplItem")));if(g>1)f[0]=[a.makeArray(d)];if(h&&c)f[2]=function(b){a.tmpl.afterManip(this,b,j)};r.apply(this,f)}else r.apply(this,arguments);c=0;!e&&a.tmpl.complete(b);return this}});a.extend({tmpl:function(d,h,e,c){var j,k=!c;if(k){c=p;d=a.template[d]||a.template(null,d);f={}}else if(!d){d=c.tmpl;b[c.key]=c;c.nodes=[];c.wrapped&&n(c,c.wrapped);return a(i(c,null,c.tmpl(a,c)))}if(!d)return[];if(typeof h==="function")h=h.call(c||{});e&&e.wrapped&&n(e,e.wrapped);j=a.isArray(h)?a.map(h,function(a){return a?g(e,c,d,a):null}):[g(e,c,d,h)];return k?a(i(c,null,j)):j},tmplItem:function(b){var c;if(b instanceof a)b=b[0];while(b&&b.nodeType===1&&!(c=a.data(b,"tmplItem"))&&(b=b.parentNode));return c||p},template:function(c,b){if(b){if(typeof b==="string")b=o(b);else if(b instanceof a)b=b[0]||{};if(b.nodeType)b=a.data(b,"tmpl")||a.data(b,"tmpl",o(b.innerHTML));return typeof c==="string"?(a.template[c]=b):b}return c?typeof c!=="string"?a.template(null,c):a.template[c]||a.template(null,q.test(c)?c:a(c)):null},encode:function(a){return(""+a).split("<").join("&lt;").split(">").join("&gt;").split('"').join("&#34;").split("'").join("&#39;")}});a.extend(a.tmpl,{tag:{tmpl:{_default:{$2:"null"},open:"if($notnull_1){_=_.concat($item.nest($1,$2));}"},wrap:{_default:{$2:"null"},open:"$item.calls(_,$1,$2);_=[];",close:"call=$item.calls();_=call._.concat($item.wrap(call,_));"},each:{_default:{$2:"$index, $value"},open:"if($notnull_1){$.each($1a,function($2){with(this){",close:"}});}"},"if":{open:"if(($notnull_1) && $1a){",close:"}"},"else":{_default:{$1:"true"},open:"}else if(($notnull_1) && $1a){"},html:{open:"if($notnull_1){_.push($1a);}"},"=":{_default:{$1:"$data"},open:"if($notnull_1){_.push($.encode($1a));}"},"!":{open:""}},complete:function(){b={}},afterManip:function(f,b,d){var e=b.nodeType===11?a.makeArray(b.childNodes):b.nodeType===1?[b]:[];d.call(f,b);m(e);c++}});function i(e,g,f){var b,c=f?a.map(f,function(a){return typeof a==="string"?e.key?a.replace(/(<\w+)(?=[\s>])(?![^>]*_tmplitem)([^>]*)/g,"$1 "+d+'="'+e.key+'" $2'):a:i(a,e,a._ctnt)}):e;if(g)return c;c=c.join("");c.replace(/^\s*([^<\s][^<]*)?(<[\w\W]+>)([^>]*[^>\s])?\s*$/,function(f,c,e,d){b=a(e).get();m(b);if(c)b=j(c).concat(b);if(d)b=b.concat(j(d))});return b?b:j(c)}function j(c){var b=document.createElement("div");b.innerHTML=c;return a.makeArray(b.childNodes)}function o(b){return new Function("jQuery","$item","var $=jQuery,call,_=[],$data=$item.data;with($data){_.push('"+a.trim(b).replace(/([\\'])/g,"\\$1").replace(/[\r\t\n]/g," ").replace(/\$\{([^\}]*)\}/g,"{{= $1}}").replace(/\{\{(\/?)(\w+|.)(?:\(((?:[^\}]|\}(?!\}))*?)?\))?(?:\s+(.*?)?)?(\(((?:[^\}]|\}(?!\}))*?)\))?\s*\}\}/g,function(m,l,j,d,b,c,e){var i=a.tmpl.tag[j],h,f,g;if(!i)throw"Template command not found: "+j;h=i._default||[];if(c&&!/\w$/.test(b)){b+=c;c=""}if(b){b=k(b);e=e?","+k(e)+")":c?")":"";f=c?b.indexOf(".")>-1?b+c:"("+b+").call($item"+e:b;g=c?f:"(typeof("+b+")==='function'?("+b+").call($item):("+b+"))"}else g=f=h.$1||"null";d=k(d);return"');"+i[l?"close":"open"].split("$notnull_1").join(b?"typeof("+b+")!=='undefined' && ("+b+")!=null":"true").split("$1a").join(g).split("$1").join(f).split("$2").join(d?d.replace(/\s*([^\(]+)\s*(\((.*?)\))?/g,function(d,c,b,a){a=a?","+a+")":b?")":"";return a?"("+c+").call($item"+a:d}):h.$2||"")+"_.push('"})+"');}return _;")}function n(c,b){c._wrap=i(c,true,a.isArray(b)?b:[q.test(b)?b:a(b).html()]).join("")}function k(a){return a?a.replace(/\\'/g,"'").replace(/\\\\/g,"\\"):null}function s(b){var a=document.createElement("div");a.appendChild(b.cloneNode(true));return a.innerHTML}function m(o){var n="_"+c,k,j,l={},e,p,i;for(e=0,p=o.length;e<p;e++){if((k=o[e]).nodeType!==1)continue;j=k.getElementsByTagName("*");for(i=j.length-1;i>=0;i--)m(j[i]);m(k)}function m(j){var p,i=j,k,e,m;if(m=j.getAttribute(d)){while(i.parentNode&&(i=i.parentNode).nodeType===1&&!(p=i.getAttribute(d)));if(p!==m){i=i.parentNode?i.nodeType===11?0:i.getAttribute(d)||0:0;if(!(e=b[m])){e=f[m];e=g(e,b[i]||f[i],null,true);e.key=++h;b[h]=e}c&&o(m)}j.removeAttribute(d)}else if(c&&(e=a.data(j,"tmplItem"))){o(e.key);b[e.key]=e;i=a.data(j.parentNode,"tmplItem");i=i?i.key:0}if(e){k=e;while(k&&k.key!=i){k.nodes.push(j);k=k.parent}delete e._ctnt;delete e._wrap;a.data(j,"tmplItem",e)}function o(a){a=a+n;e=l[a]=l[a]||g(e,b[e.parent.key+n]||e.parent,null,true)}}}function u(a,d,c,b){if(!a)return l.pop();l.push({_:a,tmpl:d,item:this,data:c,options:b})}function w(d,c,b){return a.tmpl(a.template(d),c,b,this)}function x(b,d){var c=b.options||{};c.wrapped=d;return a.tmpl(a.template(b.tmpl),b.data,c,b.item)}function v(d,c){var b=this._wrap;return a.map(a(a.isArray(b)?b.join(""):b).filter(d||"*"),function(a){return c?a.innerText||a.textContent:a.outerHTML||s(a)})}function t(){var b=this.nodes;a.tmpl(null,null,null,this).insertBefore(b[0]);a(b).remove()}})(jQuery);

// remap jQuery to $
(function($){

  
})(this.jQuery);

// usage: log('inside coolFunc',this,arguments);
// paulirish.com/2009/log-a-lightweight-wrapper-for-consolelog/
window.log = function(){
  log.history = log.history || [];   // store logs to an array for reference
  log.history.push(arguments);
  if(this.console){
    console.log( Array.prototype.slice.call(arguments) );
  }
};



// catch all document.write() calls
(function(doc){
  var write = doc.write;
  doc.write = function(q){ 
    log('document.write(): ',arguments); 
    if (/docwriteregexwhitelist/.test(q)) write.apply(doc,arguments);  
  };
})(document);



//
// jQuery Plugin for Form Styles
// http://pixelmatrixdesign.com/weblog/comments/announcing_uniform/
// 
(function(a){a.uniform={options:{selectClass:"selector",radioClass:"radio",checkboxClass:"checker",fileClass:"uploader",filenameClass:"filename",fileBtnClass:"action",fileDefaultText:"No file selected",fileBtnText:"Choose File",checkedClass:"checked",focusClass:"focus",disabledClass:"disabled",buttonClass:"button",activeClass:"active",hoverClass:"hover",useID:true,idPrefix:"uniform",resetSelector:false,autoHide:true},elements:[]};if(a.browser.msie&&a.browser.version<7){a.support.selectOpacity=false}else{a.support.selectOpacity=true}a.fn.uniform=function(k){k=a.extend(a.uniform.options,k);var d=this;if(k.resetSelector!=false){a(k.resetSelector).mouseup(function(){function l(){a.uniform.update(d)}setTimeout(l,10)})}function j(l){$el=a(l);$el.addClass($el.attr("type"));b(l)}function g(l){a(l).addClass("uniform");b(l)}function i(o){var m=a(o);var p=a("<div>"),l=a("<span>");p.addClass(k.buttonClass);if(k.useID&&m.attr("id")!=""){p.attr("id",k.idPrefix+"-"+m.attr("id"))}var n;if(m.is("a")||m.is("button")){n=m.text()}else{if(m.is(":submit")||m.is(":reset")||m.is("input[type=button]")){n=m.attr("value")}}n=n==""?m.is(":reset")?"Reset":"Submit":n;l.html(n);m.css("opacity",0);m.wrap(p);m.wrap(l);p=m.closest("div");l=m.closest("span");if(m.is(":disabled")){p.addClass(k.disabledClass)}p.bind({"mouseenter.uniform":function(){p.addClass(k.hoverClass)},"mouseleave.uniform":function(){p.removeClass(k.hoverClass);p.removeClass(k.activeClass)},"mousedown.uniform touchbegin.uniform":function(){p.addClass(k.activeClass)},"mouseup.uniform touchend.uniform":function(){p.removeClass(k.activeClass)},"click.uniform touchend.uniform":function(r){if(a(r.target).is("span")||a(r.target).is("div")){if(o[0].dispatchEvent){var q=document.createEvent("MouseEvents");q.initEvent("click",true,true);o[0].dispatchEvent(q)}else{o[0].click()}}}});o.bind({"focus.uniform":function(){p.addClass(k.focusClass)},"blur.uniform":function(){p.removeClass(k.focusClass)}});a.uniform.noSelect(p);b(o)}function e(o){var m=a(o);var p=a("<div />"),l=a("<span />");if(!m.css("display")=="none"&&k.autoHide){p.hide()}p.addClass(k.selectClass);if(k.useID&&o.attr("id")!=""){p.attr("id",k.idPrefix+"-"+o.attr("id"))}var n=o.find(":selected:first");if(n.length==0){n=o.find("option:first")}l.html(n.html());o.css("opacity",0);o.wrap(p);o.before(l);p=o.parent("div");l=o.siblings("span");o.bind({"change.uniform":function(){l.text(o.find(":selected").html());p.removeClass(k.activeClass)},"focus.uniform":function(){p.addClass(k.focusClass)},"blur.uniform":function(){p.removeClass(k.focusClass);p.removeClass(k.activeClass)},"mousedown.uniform touchbegin.uniform":function(){p.addClass(k.activeClass)},"mouseup.uniform touchend.uniform":function(){p.removeClass(k.activeClass)},"click.uniform touchend.uniform":function(){p.removeClass(k.activeClass)},"mouseenter.uniform":function(){p.addClass(k.hoverClass)},"mouseleave.uniform":function(){p.removeClass(k.hoverClass);p.removeClass(k.activeClass)},"keyup.uniform":function(){l.text(o.find(":selected").html())}});if(a(o).attr("disabled")){p.addClass(k.disabledClass)}a.uniform.noSelect(l);b(o)}function f(n){var m=a(n);var o=a("<div />"),l=a("<span />");if(!m.css("display")=="none"&&k.autoHide){o.hide()}o.addClass(k.checkboxClass);if(k.useID&&n.attr("id")!=""){o.attr("id",k.idPrefix+"-"+n.attr("id"))}a(n).wrap(o);a(n).wrap(l);l=n.parent();o=l.parent();a(n).css("opacity",0).bind({"focus.uniform":function(){o.addClass(k.focusClass)},"blur.uniform":function(){o.removeClass(k.focusClass)},"click.uniform touchend.uniform":function(){if(!a(n).attr("checked")){l.removeClass(k.checkedClass)}else{l.addClass(k.checkedClass)}},"mousedown.uniform touchbegin.uniform":function(){o.addClass(k.activeClass)},"mouseup.uniform touchend.uniform":function(){o.removeClass(k.activeClass)},"mouseenter.uniform":function(){o.addClass(k.hoverClass)},"mouseleave.uniform":function(){o.removeClass(k.hoverClass);o.removeClass(k.activeClass)}});if(a(n).attr("checked")){l.addClass(k.checkedClass)}if(a(n).attr("disabled")){o.addClass(k.disabledClass)}b(n)}function c(n){var m=a(n);var o=a("<div />"),l=a("<span />");if(!m.css("display")=="none"&&k.autoHide){o.hide()}o.addClass(k.radioClass);if(k.useID&&n.attr("id")!=""){o.attr("id",k.idPrefix+"-"+n.attr("id"))}a(n).wrap(o);a(n).wrap(l);l=n.parent();o=l.parent();a(n).css("opacity",0).bind({"focus.uniform":function(){o.addClass(k.focusClass)},"blur.uniform":function(){o.removeClass(k.focusClass)},"click.uniform touchend.uniform":function(){if(!a(n).attr("checked")){l.removeClass(k.checkedClass)}else{var p=k.radioClass.split(" ")[0];a("."+p+" span."+k.checkedClass+":has([name='"+a(n).attr("name")+"'])").removeClass(k.checkedClass);l.addClass(k.checkedClass)}},"mousedown.uniform touchend.uniform":function(){if(!a(n).is(":disabled")){o.addClass(k.activeClass)}},"mouseup.uniform touchbegin.uniform":function(){o.removeClass(k.activeClass)},"mouseenter.uniform touchend.uniform":function(){o.addClass(k.hoverClass)},"mouseleave.uniform":function(){o.removeClass(k.hoverClass);o.removeClass(k.activeClass)}});if(a(n).attr("checked")){l.addClass(k.checkedClass)}if(a(n).attr("disabled")){o.addClass(k.disabledClass)}b(n)}function h(q){var o=a(q);var r=a("<div />"),p=a("<span>"+k.fileDefaultText+"</span>"),m=a("<span>"+k.fileBtnText+"</span>");if(!o.css("display")=="none"&&k.autoHide){r.hide()}r.addClass(k.fileClass);p.addClass(k.filenameClass);m.addClass(k.fileBtnClass);if(k.useID&&o.attr("id")!=""){r.attr("id",k.idPrefix+"-"+o.attr("id"))}o.wrap(r);o.after(m);o.after(p);r=o.closest("div");p=o.siblings("."+k.filenameClass);m=o.siblings("."+k.fileBtnClass);if(!o.attr("size")){var l=r.width();o.attr("size",l/10)}var n=function(){var s=o.val();if(s===""){s=k.fileDefaultText}else{s=s.split(/[\/\\]+/);s=s[(s.length-1)]}p.text(s)};n();o.css("opacity",0).bind({"focus.uniform":function(){r.addClass(k.focusClass)},"blur.uniform":function(){r.removeClass(k.focusClass)},"mousedown.uniform":function(){if(!a(q).is(":disabled")){r.addClass(k.activeClass)}},"mouseup.uniform":function(){r.removeClass(k.activeClass)},"mouseenter.uniform":function(){r.addClass(k.hoverClass)},"mouseleave.uniform":function(){r.removeClass(k.hoverClass);r.removeClass(k.activeClass)}});if(a.browser.msie){o.bind("click.uniform.ie7",function(){setTimeout(n,0)})}else{o.bind("change.uniform",n)}if(o.attr("disabled")){r.addClass(k.disabledClass)}a.uniform.noSelect(p);a.uniform.noSelect(m);b(q)}a.uniform.restore=function(l){if(l==undefined){l=a(a.uniform.elements)}a(l).each(function(){if(a(this).is(":checkbox")){a(this).unwrap().unwrap()}else{if(a(this).is("select")){a(this).siblings("span").remove();a(this).unwrap()}else{if(a(this).is(":radio")){a(this).unwrap().unwrap()}else{if(a(this).is(":file")){a(this).siblings("span").remove();a(this).unwrap()}else{if(a(this).is("button, :submit, :reset, a, input[type='button']")){a(this).unwrap().unwrap()}}}}}a(this).unbind(".uniform");a(this).css("opacity","1");var m=a.inArray(a(l),a.uniform.elements);a.uniform.elements.splice(m,1)})};function b(l){l=a(l).get();if(l.length>1){a.each(l,function(m,n){a.uniform.elements.push(n)})}else{a.uniform.elements.push(l)}}a.uniform.noSelect=function(l){function m(){return false}a(l).each(function(){this.onselectstart=this.ondragstart=m;a(this).mousedown(m).css({MozUserSelect:"none"})})};a.uniform.update=function(l){if(l==undefined){l=a(a.uniform.elements)}l=a(l);l.each(function(){var n=a(this);if(n.is("select")){var m=n.siblings("span");var p=n.parent("div");p.removeClass(k.hoverClass+" "+k.focusClass+" "+k.activeClass);m.html(n.find(":selected").html());if(n.is(":disabled")){p.addClass(k.disabledClass)}else{p.removeClass(k.disabledClass)}}else{if(n.is(":checkbox")){var m=n.closest("span");var p=n.closest("div");p.removeClass(k.hoverClass+" "+k.focusClass+" "+k.activeClass);m.removeClass(k.checkedClass);if(n.is(":checked")){m.addClass(k.checkedClass)}if(n.is(":disabled")){p.addClass(k.disabledClass)}else{p.removeClass(k.disabledClass)}}else{if(n.is(":radio")){var m=n.closest("span");var p=n.closest("div");p.removeClass(k.hoverClass+" "+k.focusClass+" "+k.activeClass);m.removeClass(k.checkedClass);if(n.is(":checked")){m.addClass(k.checkedClass)}if(n.is(":disabled")){p.addClass(k.disabledClass)}else{p.removeClass(k.disabledClass)}}else{if(n.is(":file")){var p=n.parent("div");var o=n.siblings(k.filenameClass);btnTag=n.siblings(k.fileBtnClass);p.removeClass(k.hoverClass+" "+k.focusClass+" "+k.activeClass);o.text(n.val());if(n.is(":disabled")){p.addClass(k.disabledClass)}else{p.removeClass(k.disabledClass)}}else{if(n.is(":submit")||n.is(":reset")||n.is("button")||n.is("a")||l.is("input[type=button]")){var p=n.closest("div");p.removeClass(k.hoverClass+" "+k.focusClass+" "+k.activeClass);if(n.is(":disabled")){p.addClass(k.disabledClass)}else{p.removeClass(k.disabledClass)}}}}}}})};return this.each(function(){if(a.support.selectOpacity){var l=a(this);if(l.is("select")){if(l.attr("multiple")!=true){if(l.attr("size")==undefined||l.attr("size")<=1){e(l)}}}else{if(l.is(":checkbox")){f(l)}else{if(l.is(":radio")){c(l)}else{if(l.is(":file")){h(l)}else{if(l.is(":text, :password, input[type='email']")){j(l)}else{if(l.is("textarea")){g(l)}else{if(l.is("a")||l.is(":submit")||l.is(":reset")||l.is("button")||l.is("input[type=button]")){i(l)}}}}}}}}})}})(jQuery);



(function($){
    if(!$.Indextank){
        $.Indextank = new Object();
    };
    
    $.Indextank.Ize = function(el, apiurl, indexName, options){
        // To avoid scope issues, use 'base' instead of 'this'
        // to reference this class from internal events and functions.
        var base = this;
        
        // Access to jQuery and DOM versions of element
        base.$el = $(el);
        base.el = el;
       
        // some parameter validation
        var urlrx = /http(s)?:\/\/[a-z0-9]+.api.indextank.com/; 
        // if (!urlrx.test(apiurl)) throw("invalid api url!");
        if (indexName == undefined) throw("index name is not defined!");

        // Add a reverse reference to the DOM object
        base.$el.data("Indextank.Ize", base);
        
        base.init = function(){
            base.apiurl = apiurl;
            base.indexName = indexName;
            
            base.options = $.extend({},$.Indextank.Ize.defaultOptions, options);
            
            // Put your initialization code here
        };
        
        // Sample Function, Uncomment to use
        // base.functionName = function(paramaters){
        // 
        // };
        
        // Run initializer
        base.init();
    };
    
    $.Indextank.Ize.defaultOptions = {
    };
    
    $.fn.indextank_Ize = function(apiurl, indexName, options){
        return this.each(function(){
            (new $.Indextank.Ize(this, apiurl, indexName, options));
        });
    };
    
    // This function breaks the chain, but returns
    // the Indextank.Ize if it has been attached to the object.
    $.fn.getIndextank_Ize = function(){
        this.data("Indextank.Ize");
    };
    
})(jQuery);

// An Indextank Query. Inspired by indextank-java's com.flaptor.indextank.apiclient.IndextankClient.Query.


function Query (queryString) {
    this.queryString = queryString;
}

Query.prototype.withQueryString = function (qstr) {
    this.queryString = qstr;
    return this;
};

Query.prototype.withStart = function (start) {
    this.start = start;
    return this;
};


Query.prototype.withLength = function (rsLength) {
    this.rsLength = rsLength;
    return this;
};

Query.prototype.withScoringFunction = function ( scoringFunction ) {
    this.scoringFunction = scoringFunction;
    return this;
};

Query.prototype.withSnippetFields = function ( snippetFields ){
    if (typeof(snippetFields) == "string") {
        snippetFields = snippetFields.split(/ *: */);
    }

    if (this.snippetFields == null) {
        this.snippetFields = [];
    }

    this.snippetFields.push(snippetFields);
    return this;
};

Query.prototype.withFetchFields = function ( fetchFields ){
    if (typeof(fetchFields) == "string") {
        fetchFields = fetchFields.split(/ *: */);
    }

    if (this.fetchFields == null) {
        this.fetchFields = [];
    }

    this.fetchFields.push(fetchFields);
    return this;
};

Query.prototype.withDocumentVariableFilter = function (idx, floor, ceil) {
    if (this.documentVariableFilters == null) {
        this.documentVariableFilters = [];
    }

    this.documentVariableFilters.push(new Range(id, floor, ceil));
    return this;
};

Query.prototype.withFunctionFilter = function (idx, floor, ceil) {
    if (this.functionFilters == null) {
        this.functionFilters = [];
    }

    this.functionFilters.push(new Range(id, floor, ceil));
    return this;
};

Query.prototype.resetCategoryFilters = function() {
    this.categoryFilters = null;
};
Query.prototype.withCategoryFilters = function (categoryFilters) {
    if (this.categoryFilters == null) {
        this.categoryFilters = {};
    }

    for (c in categoryFilters) {
        this.categoryFilters[c] = categoryFilters[c];
    }

    return this;
};

Query.prototype.withoutCategories = function (categories) {
    if (this.categoryFilters == null) {
        this.categoryFilters = {};
    } else {
        for (idx in categories) {
            delete this.categoryFilters[categories[idx]];
        }
    }

    return this;
};

Query.prototype.withQueryVariables = function (queryVariables) {
    if (this.queryVariables == null) {
        this.queryVariables = {};
    }

    for (qv in queryVariables) {
        this.queryVariables[qv] = queryVariables[qv];
    }

    return this;
};


Query.prototype.withQueryReWriter = function (qrw) {
    this.queryReWriter = qrw;
    return this;
}

Query.prototype.withFetchVariables = function(fv) {
    this.fetchVariables = fv;
    return this;
}

Query.prototype.withFetchCategories = function(fc) {
    this.fetchCategories = fc;
    return this;
}


Query.prototype.clone = function() {
    q = new Query(this.queryString);

    // XXX should arrays and dicts be deep copied?
    if (this.start != null) q.start = this.start;
    if (this.rsLength != null) q.rsLength = this.rsLength;
    if (this.scoringFunction != null) q.scoringFunction = this.scoringFunction;
    if (this.snippetFields != null) q.snippetFields = this.snippetFields;
    if (this.fetchFields != null) q.fetchFields = this.fetchFields;
    if (this.categoryFilters != null) q.categoryFilters = this.categoryFilters;
    if (this.documentVariableFilters != null) q.documentVariableFilters = this.documentVariableFilters;
    if (this.functionFilters != null) q.functionFilters = this.functionFilters;
    if (this.queryVariables != null) q.queryVariables = this.queryVariables;
    if (this.queryReWriter != null) q.queryReWriter = this.queryReWriter;
    if (this.fetchVariables != null) q.fetchVariables = this.fetchVariables;
    if (this.fetchCategories != null) q.fetchCategories = this.fetchCategories;

    return q;
}

Query.prototype.asParameterMap = function() {
    var qMap = {};
    
    // start with the query.
    qMap["q"] = this.queryReWriter(this.queryString);

    if (this.start != null)         
        qMap['start'] = this.start;
    if (this.rsLength != null)
        qMap['len'] = this.rsLength;
    if (this.scoringFunction != null)
        qMap['function'] = this.scoringFunction;

    if (this.snippetFields != null)
        qMap['snippet'] = this.snippetFields.join(",");
    if (this.fetchFields != null)
        qMap['fetch'] = this.fetchFields.join(",");
    if (this.categoryFilters != null)
        qMap['category_filters'] = JSON.stringify(this.categoryFilters);
    if (this.fetchVariables != null)
        qMap['fetch_variables'] = this.fetchVariables;
    if (this.fetchCategories != null)
        qMap['fetch_categories'] = this.fetchCategories;

    if (this.documentVariableFilters != null) {
        for (dvf in this.documentVariableFilters) {
            rng = this.documentVariableFilters[dvf];
            key = rng.getFilterDocVar();
            val = rng.getValue();

            if (qMap[key]) { 
                qMap[key] += "," + val;
            } else {
                qMap[key] = val;
            }
        }
    }
 
    if (this.functionFilters != null) {
        for (ff in this.functionFilters) {
            rng = this.functionFilters[ff];
            key = rng.getFilterFunction();
            val = rng.getValue();

            if (qMap[key]) { 
                qMap[key] += "," + val;
            } else {
                qMap[key] = val;
            }
        }
    }

    if (this.queryVariables != null) {
        for (qv in this.queryVariables) {
            qMap[qv] = this.queryVariables[qv];
        }
    }

    return qMap;
};


function Range(id, floor, ceil) {
    this.id = id;
    this.floor = floor;
    this.ceil = ceil;
} 

Range.prototype.getFilterDocVar = function() {
    return "filter_docvar" + this.id;
};

Range.prototype.getFilterFunction = function() {
    return "filter_function" + this.id;
};

Range.prototype.getValue = function() {
    var value = [ (this.floor == null ? "*" : this.floor) , 
                  (this.ceil  == null ? "*" : this.ceil) ];

    return value.join(":");
};


(function($){
    if(!$.Indextank){
        $.Indextank = new Object();
    };

    // this is a hacky way of getting querybuilder dependencies 
    // XXX remove this once there's a minified / bundled version of indextank-jquery
    try {
        new Query();
    } catch(e) {
        // ok, I need to include querybuilder
        var qscr = $("<script/>").attr("src", "https://raw.github.com/flaptor/indextank-jquery/master/querybuilder.js");
        $("head").append(qscr);
    }; 



    $.Indextank.AjaxSearch = function(el, options){
        // To avoid scope issues, use 'base' instead of 'this'
        // to reference this class from internal events and functions.
        var base = this;
        
        // Access to jQuery and DOM versions of element
        base.$el = $(el);
        base.el = el;
        
        // Add a reverse reference to the DOM object
        base.$el.data("Indextank.AjaxSearch", base);
        
        base.init = function(){
            
            base.options = $.extend({},$.Indextank.AjaxSearch.defaultOptions, options);
            base.xhr = undefined;

            // base.options.listeners is ASSUMED to be a jQuery set .. 
            // if we got an Array, we need to convert it
            if (base.options.listeners instanceof Array) {
                var listeners = $();
                $.map(base.options.listeners, function(e, i) {
                    listeners = listeners.add(e);
                });

                base.options.listeners = listeners;
            }
            
            // TODO: make sure ize is an Indextank.Ize element somehow
            base.ize = $(base.el.form).data("Indextank.Ize");
            
            // create the default query, and map default parameters on it
            base.defaultQuery = new Query("")
                                    .withStart(base.options.start)
                                    .withLength(base.options.rsLength)
                                    .withFetchFields(base.options.fields)
                                    .withSnippetFields(base.options.snippets)
                                    .withScoringFunction(base.options.scoringFunction)
                                    .withFetchVariables(base.options.fetchVariables)
                                    .withFetchCategories(base.options.fetchCategories)
                                    .withCategoryFilters(base.options.categoryFilters)
                                    .withQueryReWriter(base.options.rewriteQuery);
            
            
            base.ize.$el.bind("submit", base.hijackFormSubmit);


            // make it possible for other to trigger an ajax search
            base.$el.bind( "Indextank.AjaxSearch.runQuery", base.runQuery );
            base.$el.bind( "Indextank.AjaxSearch.displayNoResults", base.displayNoResults );
        };
        
        // Sample Function, Uncomment to use
        // base.functionName = function(paramaters){
        // 
        // };

        base.displayNoResults = function() {
            base.options.listeners.trigger("Indextank.AjaxSearch.noResults", base.el.value);
        }

        // gets a copy of the default query.
        base.getDefaultQuery = function() {
            return base.defaultQuery.clone();
        };
            
            
        base.runQuery = function( event, query ) {
            // don't run a query twice
            if (base.query == query ) {
                return;
            } 
            
            // if we are running a query, an old one makes no sense.
            if (base.xhr != undefined ) {
                base.xhr.abort();
            }
           

            // remember the current running query
            base.query = query;

            base.options.listeners.trigger("Indextank.AjaxSearch.searching");
            base.$el.trigger("Indextank.AjaxSearch.searching");


            // run the query, with ajax
            base.xhr = $.ajax( {
                url: base.ize.apiurl + "/v1/indexes/" + base.ize.indexName + "/search",
                dataType: "jsonp",
                data: query.asParameterMap(),
                timeout: 1000,
                success: function( data ) { 
                            // Indextank API does not send the query back.
                            // I'll save the current query inside 'data',
                            // so our listeners can use it.
                            data.query = query;
                            // Add a pointer to us, so our listeners can call us back
                            data.searcher = base.$el;
                            // notify our listeners
                            base.options.listeners.trigger("Indextank.AjaxSearch.success", data);
                            base.$el.trigger("Indextank.AjaxSearch.success");
                            },
                error: function( jqXHR, textStatus, errorThrown) {
                            base.options.listeners.trigger("Indextank.AjaxSearch.failure");
                            base.$el.trigger("Indextank.AjaxSearch.failure");
                }
            } );
        } 

        base.hijackFormSubmit = function(event) {
            // make sure the form is not submitted
            event.preventDefault();
            base.runQuery( event, base.getDefaultQuery().withQueryString(base.el.value) );
        };


        // unbind everything
        base.destroy = function() {
            base.$el.unbind("Indextank.AjaxSearch.runQuery", base.runQuery);
            base.$el.unbind("Indextank.AjaxSearch.displayNoResults", base.displayNoResults );            
            base.ize.$el.unbind("submit", base.hijackFormSubmit);
            base.$el.removeData("Indextank.AjaxSearch");
        };


        // Run initializer
        base.init();
    };
    
    $.Indextank.AjaxSearch.defaultOptions = {
        // first result to fetch .. it can be overrided at query-time,
        // but we need a default. 99.95% of the times you'll want to keep the default
        start : 0,
        // how many results to fetch on every query? 
        // it can be overriden at query-time.
        rsLength : 10, 
        // default fields to fetch .. 
        fields : "name,title,image,url,link",
        // fields to make snippets for
        snippets : "text",
        // no one listening .. sad
        listeners: $([]),
        // scoring function to use
        scoringFunction: 0,
        // fetch all variables,
        fetchVariables: 'true',
        // fetch all categories,
        fetchCategories: 'true',
        // added by yigit, to filter by category
        categoryFilters : {},
        // the default query re-writer is identity
        rewriteQuery: function(q) {return q}
    };
    
    $.fn.indextank_AjaxSearch = function(options){
        return this.each(function(){
            (new $.Indextank.AjaxSearch(this, options));
        });
    };
    
})(jQuery);

(function($){
    if(!$.Indextank){
        $.Indextank = new Object();
    };
    
    $.Indextank.Renderer = function(el, options){
        // To avoid scope issues, use 'base' instead of 'this'
        // to reference this class from internal events and functions.
        var base = this;
        
        // Access to jQuery and DOM versions of element
        base.$el = $(el);
        base.el = el;
        
        // Add a reverse reference to the DOM object
        base.$el.data("Indextank.Renderer", base);
        
        base.init = function(){
            base.options = $.extend({},$.Indextank.Renderer.defaultOptions, options);
            
            // Put your initialization code here
            base.$el.bind("Indextank.AjaxSearch.searching", function(e) {
                base.$el.css({opacity: 0.5});
            });

            base.$el.bind("Indextank.AjaxSearch.success", function(e, data) {
                base.options.setupContainer(base.$el);
                $(data.results).each( function (i, item) {
                    var r = base.options.format(item);
                    r.appendTo(base.$el);
                });
                base.$el.css({opacity: 1});
                base.options.afterRender(base.$el);
            });

            base.$el.bind("Indextank.AjaxSearch.noResults", function(e, query) {
                base.$el.html("<div class='result'> No results were found for " + query + '.</div>');
            });
            
            base.$el.bind("Indextank.AjaxSearch.failure", function(e) {
                base.$el.css({opacity: 1});
            });
            
        };
        
        // Sample Function, Uncomment to use
        // base.functionName = function(paramaters){
        // 
        // };
        
        // Run initializer
        base.init();
    };
    
    $.Indextank.Renderer.defaultOptions = {
        format: function(item){
                    return $("<div></div>")
                            .addClass("result")
                            .append( $("<a></a>").attr("href", item.link || item.url ).text(item.title || item.name) )
                            .append( $("<span></span>").addClass("description").html(item.snippet_text || item.text) );
                    },
        setupContainer: function($el){
            $el.html("");
        },
        afterRender: function($el) {
            // do nothing. You may want to re arrange items,
            // append some sort of legend, zebra items, you name it.      
        }
    };
    
    $.fn.indextank_Renderer = function(options){
        return this.each(function(){
            (new $.Indextank.Renderer(this, options));
        });
    };
    
})(jQuery);

$.fn.preload = function() {
    this.each(function(){
        $('<img/>')[0].src = this;
    });
};
(function($) {
    // if ($.fn.Bv == null) {
    //     $.fn.Bv = {};
    // }
    var defaultFormat = function(item) {
        return $("<div></div>")
        .addClass("result")
        .append($("<a href='" + settings.urlPrefix + item.docid + "'></a>").html(item.human_readable_name));
    };
    var defaultSetupContainer = function($el) {
        $el.html("");
    };

    var defaultSetupFacetContainer = function($el) {
        $el.html("Kategoriler");
    };

    var defaultFacetFormat = function(facet, facetAtrr, facetClass) {
        return $("<ul/>").append($("<span/>").html(facetAtrr));
    };
    var settings = {
        format: defaultFormat,
        setupContainer: defaultSetupContainer,
        renderer: null,
        facetRenderer: null,
        setupFacetContainer : defaultSetupFacetContainer,
        facetFormat : defaultFacetFormat,
        runQueryAfterInit : true, //if text is not empty and there is a renderer, sends first query
        categoryFacetClass : "bv-search-facet",
        categoryAttr : "bv-category",
        urlPrefix : "/ara/d/",
        loadingIcon : null,
        autocompleteSearchingClass : null
    };
    $.fn.bvSearchAutocomplete = function(options) {
        var $this = this;
        var init = function() {
            return $this.each(
            function() {
                var $that = $(this);
                if (options) {
                    $.extend(settings, options);
                }
                var inputElms = $that.children("input[type=text]");
                if(inputElms.length == 0) {
                    $.error("form needs to have at least 1 input element.");
                    return;
                }
                var $inputElm = $(inputElms[0]);
                $that.indextank_Ize(Bv.Config.Search.publicApiUrl, Bv.Config.Search.indexName);
                var listeners = [];
                if (settings.renderer) {
                    var r = $(settings.renderer).indextank_Renderer({
                        format: settings.format,
                        setupContainer: settings.setupContainer
                    });
                    listeners.push(r);
                    if(settings.facetRenderer) {
                        var fr = $(settings.facetRenderer).indextank_FacetsRenderer( {
                            format : settings.facetFormat,
                            setupContainer : settings.setupFacetContainer
                        });
                        listeners.push(fr);
                    }
                    
                    $inputElm.indextank_AjaxSearch({
                        listeners: listeners,
                        fields: "name, human_readable_name, description, logo",
                        rewriteQuery : function(txt) {
                            var words = txt.split(" ");
                            var query = "text:\"" + txt + "\"^10 OR description:\"" + txt + "\"^9";
                            $(words).each(function(i,w) {
                                query += " OR text:\"" + w + "\"";
                                query += " OR description:\"" + w + "\"";
                            });

                            return query;
                        }
                    });
                    
                    if(settings.loadingIcon) {
                        $inputElm.bind("Indextank.AjaxSearch.success",
                            function() {
                                settings.loadingIcon.hide();
                            });
                        $inputElm.bind("Indextank.AjaxSearch.searching",
                            function() {
                                settings.loadingIcon.show();
                            });
                        $inputElm.bind("Indextank.AjaxSearch.failure",
                            function() {
                                settings.loadingIcon.hide();
                            });
                    }
                };
                
                

                var searchForm = $("<form></form>");
                var searchInput = $("<input type='text'>");
                searchForm.append(searchInput);
                searchForm.indextank_Ize(Bv.Config.Search.publicApiUrl, Bv.Config.Search.indexName);
                var searchDummyRenderer = $("<div/>").indextank_Renderer({format:defaultFormat, setupContainer:defaultSetupContainer});
                searchInput.indextank_AjaxSearch({
                    listeners: searchDummyRenderer,
                    fields: "name, human_readable_name",
                    rsLength : 10
                });

                searchDummyRenderer.bind("Indextank.AjaxSearch.success",
                    function(e, data) {
                        var results = [];
                        if (data && data.results) {
                            $(data.results).each(function(i, obj) {
                                results.push({
                                    id: obj.docid,
                                    label: obj.human_readable_name
                                });
                            });
                        }
                        callback = $inputElm.data("bv.cb");
                        callback && callback(results);
                    });
                    
                if(settings.autocompleteSearchingClass) {
                    searchInput.bind("Indextank.AjaxSearch.success",
                        function() {
                            $that.removeClass(settings.autocompleteSearchingClass);
                        });
                    searchInput.bind("Indextank.AjaxSearch.searching",
                        function() {
                            $that.addClass(settings.autocompleteSearchingClass);
                        });
                    searchInput.bind("Indextank.AjaxSearch.failure",
                        function() {
                            $that.removeClass(settings.autocompleteSearchingClass);
                        });
                }

                $inputElm.autocomplete({
                    source: function(x,callback) {
                        var term = x.term;
                        $inputElm.data("bv.cb", callback);
                        searchInput.val(term);
                        searchInput.submit();
                    },
                    minLength: 1,
                    select : function(event, obj) {
                        event.preventDefault();
                        if(obj && obj.item && obj.item.id) {
                            window.location = settings.urlPrefix + obj.item.id;
                        }
                    }
                });

                if(settings.renderer) {
                    var updateCategories = function() {
                        var searchBase = $inputElm.data("Indextank.AjaxSearch");
                        searchBase.defaultQuery.resetCategoryFilters();
                        if($inputElm.attr(settings.categoryAttr) && $inputElm.attr(settings.categoryAttr) != "") {
                            var types = $inputElm.attr(settings.categoryAttr).split();
                            if(types.length) {
                                searchBase.defaultQuery.withCategoryFilters({
                                    type : types
                                });
                            }

                        }
                    };
                    updateCategories();
                    $(".bv-search-facet").live("click", function() {
                        $inputElm.attr(settings.categoryAttr, this.attr(settings.categoryAttr));
                        updateCategories();
                    });
                    $inputElm.bind("updateCategory", updateCategories);

                    if(settings.renderer && settings.runQueryAfterInit && $inputElm.val().length > 0) {
                        $that.submit();
                    }
                }

            });
        };
        init();
    };
})(jQuery);

(function($){
   if(!$.Indextank){
        $.Indextank = new Object();
    };

    $.Indextank.FacetsRenderer = function(el, options){
        // To avoid scope issues, use 'base' instead of 'this'
        // to reference this class from internal events and functions.
        var base = this;

        // Access to jQuery and DOM versions of element
        base.$el = $(el);
        base.el = el;

        // Add a reverse reference to the DOM object
        base.$el.data("Indextank.FacetsRenderer", base);

        base.translations = {
            "Organization" : "Kurum",
            "Project" : "Proje",
            "Page" : "Sayfa",
            "type" : "Kategoriler"
        };

        base.translate = function(key) {
            if(base.translations[key]) {
                return base.translations[key];
            }
            return key;
        };

        base.init = function(){
            base.options = $.extend({},$.Indextank.FacetsRenderer.defaultOptions, options);

            base.$el.bind( "Indextank.AjaxSearch.success", function (event, data) {
                base.$el.show();
                base.$el.html("");

                var queriedFacets = data.query.categoryFilters || {};

                var $selectedFacetsContainer = $("<ul/>").attr("id", "indextank-selected-facets");
                var $availableFacetsContainer = $("<div/>").attr("id", "indextank-available-facets");

                $.each( data.facets, function (catName, values){
                    if (catName in queriedFacets) {
                        var $selectedFacet = base.renderSelectedFacet(queriedFacets, catName, data);
                        $selectedFacetsContainer.append($selectedFacet);
                    } else {
                        var $availableFacet = base.renderAvailableFacet(queriedFacets, catName, values, data);
                        $availableFacetsContainer.append($availableFacet);
                    }
                });

                var $facetsContent = $("<div/>").append($selectedFacetsContainer, $availableFacetsContainer);
                // var $facetsTitle = $("<h3/>").text("Filtrele");
                var $facetsTitle = $("<h3/>").text("");

                base.$el.append($facetsTitle, $facetsContent);

            });
        };

        base.renderSelectedFacet = function(queriedFacets, categoryName, data) {
            // Render selected facet as a <li/> and return it
            $item = $("<li/>");
            console.log(queriedFacets, categoryName, data);
            $selectedCategory = $("<span/>").append(
                $("<a/>").attr("href","#")
                    .append($("<span/>").text(base.translate(queriedFacets[categoryName]) + " x"))
                    .click(function(){
                        // ensure query data has something on it
                        var query = data.query.clone();
                        // remove the selected category from the query
                        query.withoutCategories([categoryName]);
                        // start over!
                        query.withStart(0);
                        data.searcher.trigger("Indextank.AjaxSearch.runQuery", [query]);
                    })
            );

            $item.append($selectedCategory);

            return $item;
        }

        base.renderAvailableFacet = function(queriedFacets, categoryName, categoryValues, data) {
            // Render available facet as a <dl> (definition list) and return it

            $facetContainer = $("<div/>");
            $availableFacet = $("<dl/>");
            $facetContainer.append($availableFacet);
            $availableFacet.append($("<dt/>").text(base.translate(categoryName)));

            // find out if we should collapse facets, or not
            var sorted = [];
            var categoriesCount = 0;
            $.each(categoryValues, function( categoryValue, count) { categoriesCount += 1; sorted.push([categoryValue, count])});
            sorted.sort(function(a,b){return b[1]-a[1];});
            $extraValues = $();

            if (categoriesCount > base.options.showableFacets) {
                $more = $("<div/>").addClass("indextank-more-facets").hide();
                $btn = $("<a/>").attr("href", "#").text("more " + categoryName + " options");

                $extraValues = $("<dl/>");
                $more.append($extraValues);

                $btn.click(function(event) {
                    // need to call parents here, as 'button' messes up objects.
                    $(event.target).parents().children(".indextank-more-facets").toggle();
                } );

                $facetContainer.append($btn);
                $facetContainer.append($more);
            }

            // for this category, render all the controls
            $.each(sorted, function (idx, categoryCount) {
                var categoryValue = categoryCount[0];
                var count = categoryCount[1];
                var dd = $("<dd/>").append(
                    $("<a/>")
                    .attr("href", "#")
                    .text(base.translate(categoryValue) + " (" + count + ")")
                    .click(function(){
                        // ensure query data has something on it
                        var query = data.query.clone();
                        filter = {};
                        filter[categoryName] = categoryValue;
                        query.withCategoryFilters(filter);
                        // start over!
                        query.withStart(0);
                        data.searcher.trigger("Indextank.AjaxSearch.runQuery", [query]);
                    })
                );

                if (idx < base.options.showableFacets) {
                    $availableFacet.append(dd);
                } else {
                    $extraValues.append(dd);
                }
            });
            return $facetContainer;
        }

        // Run initializer
        base.init();
    };

    $.Indextank.FacetsRenderer.defaultOptions = {
        showableFacets: 4
    };

    $.fn.indextank_FacetsRenderer = function(options){
        return this.each(function(){
            (new $.Indextank.FacetsRenderer(this, options));
        });
    };

})(jQuery);

/*
 * Facebox (for jQuery)
 * version: 1.2 (05/05/2008)
 * @requires jQuery v1.2 or later
 *
 * Examples at http://famspam.com/facebox/
 *
 * Licensed under the MIT:
 *   http://www.opensource.org/licenses/mit-license.php
 *
 * Copyright 2007, 2008 Chris Wanstrath [ chris@ozmm.org ]
 *
 * Usage:
 *
 *  jQuery(document).ready(function() {
 *    jQuery('a[rel*=facebox]').facebox()
 *  })
 *
 *  <a href="#terms" rel="facebox">Terms</a>
 *    Loads the #terms div in the box
 *
 *  <a href="terms.html" rel="facebox">Terms</a>
 *    Loads the terms.html page in the box
 *
 *  <a href="terms.png" rel="facebox">Terms</a>
 *    Loads the terms.png image in the box
 *
 *
 *  You can also use it programmatically:
 *
 *    jQuery.facebox('some html')
 *    jQuery.facebox('some html', 'my-groovy-style')
 *
 *  The above will open a facebox with "some html" as the content.
 *
 *    jQuery.facebox(function($) {
 *      $.get('blah.html', function(data) { $.facebox(data) })
 *    })
 *
 *  The above will show a loading screen before the passed function is called,
 *  allowing for a better ajaxy experience.
 *
 *  The facebox function can also display an ajax page, an image, or the contents of a div:
 *
 *    jQuery.facebox({ ajax: 'remote.html' })
 *    jQuery.facebox({ ajax: 'remote.html' }, 'my-groovy-style')
 *    jQuery.facebox({ image: 'stairs.jpg' })
 *    jQuery.facebox({ image: 'stairs.jpg' }, 'my-groovy-style')
 *    jQuery.facebox({ div: '#box' })
 *    jQuery.facebox({ div: '#box' }, 'my-groovy-style')
 *
 *  Want to close the facebox?  Trigger the 'close.facebox' document event:
 *
 *    jQuery(document).trigger('close.facebox')
 *
 *  Facebox also has a bunch of other hooks:
 *
 *    loading.facebox
 *    beforeReveal.facebox
 *    reveal.facebox (aliased as 'afterReveal.facebox')
 *    init.facebox
 *    afterClose.facebox
 *
 *  Simply bind a function to any of these hooks:
 *
 *   $(document).bind('reveal.facebox', function() { ...stuff to do after the facebox and contents are revealed... })
 *
 */
(function($) {
  $.facebox = function(data, klass) {
    $.facebox.loading()

    if (data.ajax) fillFaceboxFromAjax(data.ajax, klass)
    else if (data.image) fillFaceboxFromImage(data.image, klass)
    else if (data.div) fillFaceboxFromHref(data.div, klass)
    else if ($.isFunction(data)) data.call($)
    else $.facebox.reveal(data, klass)
  }

  /*
   * Public, $.facebox methods
   */

  $.extend($.facebox, {
    settings: {
      opacity      : 0.2,
      overlay      : true,
      loadingImage : '/stylesheets/images/loading.gif',
      closeImage   : '/stylesheets/images/closelabel.png',
      imageTypes   : [ 'png', 'jpg', 'jpeg', 'gif' ],
      faceboxHtml  : '\
    <div id="facebox" style="display:none;"> \
      <div class="popup"> \
        <div class="content"> \
        </div> \
        <a href="#" class="close"><img src="/stylesheets/images/closelabel.png" title="close" class="close_image" /></a> \
      </div> \
    </div>'
    },

    loading: function() {
      init()
      if ($('#facebox .loading').length == 1) return true
      showOverlay()

      $('#facebox .content').empty()
      $('#facebox .body').children().hide().end().
        append('<div class="loading"><img src="'+$.facebox.settings.loadingImage+'"/></div>')

      $('#facebox').css({
        top:	getPageScroll()[1] + (getPageHeight() / 10),
        left:	$(window).width() / 2 - 205
      }).show()

      $(document).bind('keydown.facebox', function(e) {
        if (e.keyCode == 27) $.facebox.close()
        return true
      })
      $(document).trigger('loading.facebox')
    },

    reveal: function(data, klass) {
      $(document).trigger('beforeReveal.facebox')
      if (klass) $('#facebox .content').addClass(klass)
      $('#facebox .content').append(data)
      $('#facebox .loading').remove()
      $('#facebox .body').children().fadeIn('normal')
      $('#facebox').css('left', $(window).width() / 2 - ($('#facebox .popup').width() / 2))
      $(document).trigger('reveal.facebox').trigger('afterReveal.facebox')
    },

    close: function() {
      $(document).trigger('close.facebox')
      return false
    }
  })

  /*
   * Public, $.fn methods
   */

  $.fn.facebox = function(settings) {
    if ($(this).length == 0) return

    init(settings)

    function clickHandler() {
      $.facebox.loading(true)

      // support for rel="facebox.inline_popup" syntax, to add a class
      // also supports deprecated "facebox[.inline_popup]" syntax
      var klass = this.rel.match(/facebox\[?\.(\w+)\]?/)
      if (klass) klass = klass[1]

      fillFaceboxFromHref(this.href, klass)
      return false
    }

    return this.bind('click.facebox', clickHandler)
  }

  /*
   * Private methods
   */

  // called one time to setup facebox on this page
  function init(settings) {
    if ($.facebox.settings.inited) return true
    else $.facebox.settings.inited = true

    $(document).trigger('init.facebox')
    makeCompatible()

    var imageTypes = $.facebox.settings.imageTypes.join('|')
    $.facebox.settings.imageTypesRegexp = new RegExp('\.(' + imageTypes + ')$', 'i')

    if (settings) $.extend($.facebox.settings, settings)
    $('body').append($.facebox.settings.faceboxHtml)

    var preload = [ new Image(), new Image() ]
    preload[0].src = $.facebox.settings.closeImage
    preload[1].src = $.facebox.settings.loadingImage

    $('#facebox').find('.b:first, .bl').each(function() {
      preload.push(new Image())
      preload.slice(-1).src = $(this).css('background-image').replace(/url\((.+)\)/, '$1')
    })

    $('#facebox .close').click($.facebox.close)
    $('#facebox .close_image').attr('src', $.facebox.settings.closeImage)
  }

  // getPageScroll() by quirksmode.com
  function getPageScroll() {
    var xScroll, yScroll;
    if (self.pageYOffset) {
      yScroll = self.pageYOffset;
      xScroll = self.pageXOffset;
    } else if (document.documentElement && document.documentElement.scrollTop) {	 // Explorer 6 Strict
      yScroll = document.documentElement.scrollTop;
      xScroll = document.documentElement.scrollLeft;
    } else if (document.body) {// all other Explorers
      yScroll = document.body.scrollTop;
      xScroll = document.body.scrollLeft;
    }
    return new Array(xScroll,yScroll)
  }

  // Adapted from getPageSize() by quirksmode.com
  function getPageHeight() {
    var windowHeight
    if (self.innerHeight) {	// all except Explorer
      windowHeight = self.innerHeight;
    } else if (document.documentElement && document.documentElement.clientHeight) { // Explorer 6 Strict Mode
      windowHeight = document.documentElement.clientHeight;
    } else if (document.body) { // other Explorers
      windowHeight = document.body.clientHeight;
    }
    return windowHeight
  }

  // Backwards compatibility
  function makeCompatible() {
    var $s = $.facebox.settings

    $s.loadingImage = $s.loading_image || $s.loadingImage
    $s.closeImage = $s.close_image || $s.closeImage
    $s.imageTypes = $s.image_types || $s.imageTypes
    $s.faceboxHtml = $s.facebox_html || $s.faceboxHtml
  }

  // Figures out what you want to display and displays it
  // formats are:
  //     div: #id
  //   image: blah.extension
  //    ajax: anything else
  function fillFaceboxFromHref(href, klass) {
    // div
    if (href.match(/#/)) {
      var url    = window.location.href.split('#')[0]
      var target = href.replace(url,'')
      if (target == '#') return
      $.facebox.reveal($(target).html(), klass)

    // image
    } else if (href.match($.facebox.settings.imageTypesRegexp)) {
      fillFaceboxFromImage(href, klass)
    // ajax
    } else {
      fillFaceboxFromAjax(href, klass)
    }
  }

  function fillFaceboxFromImage(href, klass) {
    var image = new Image()
    image.onload = function() {
      $.facebox.reveal('<div class="image"><img src="' + image.src + '" /></div>', klass)
    }
    image.src = href
  }

  function fillFaceboxFromAjax(href, klass) {
    $.get(href, function(data) { $.facebox.reveal(data, klass) })
  }

  function skipOverlay() {
    return $.facebox.settings.overlay == false || $.facebox.settings.opacity === null
  }

  function showOverlay() {
    if (skipOverlay()) return

    if ($('#facebox_overlay').length == 0)
      $("body").append('<div id="facebox_overlay" class="facebox_hide"></div>')

    $('#facebox_overlay').hide().addClass("facebox_overlayBG")
      .css('opacity', $.facebox.settings.opacity)
      .click(function() { $(document).trigger('close.facebox') })
      .fadeIn(200)
    return false
  }

  function hideOverlay() {
    if (skipOverlay()) return

    $('#facebox_overlay').fadeOut(200, function(){
      $("#facebox_overlay").removeClass("facebox_overlayBG")
      $("#facebox_overlay").addClass("facebox_hide")
      $("#facebox_overlay").remove()
    })

    return false
  }

  /*
   * Bindings
   */

  $(document).bind('close.facebox', function() {
    $(document).unbind('keydown.facebox')
    $('#facebox').fadeOut(function() {
      $('#facebox .content').removeClass().addClass('content')
      $('#facebox .loading').remove()
      $(document).trigger('afterClose.facebox')
    })
    hideOverlay()
  })

})(jQuery);

/**
 * @license
 * jQuery Tools @VERSION Tooltip - UI essentials
 *
 * NO COPYRIGHTS OR LICENSES. DO WHAT YOU LIKE.
 *
 * http://flowplayer.org/tools/tooltip/
 *
 * Since: November 2008
 * Date: @DATE
 */
(function($) {
	// static constructs
	$.tools = $.tools || {version: '@VERSION'};

	$.tools.tooltip = {

		conf: {

			// default effect variables
			effect: 'toggle',
			fadeOutSpeed: "fast",
			predelay: 0,
			delay: 30,
			opacity: 1,
			tip: 0,
      fadeIE: false, // enables fade effect in IE

			// 'top', 'bottom', 'right', 'left', 'center'
			position: ['top', 'center'],
			offset: [0, 0],
			relative: false,
			cancelDefault: true,

			// type to event mapping
			events: {
				def: 			"mouseenter,mouseleave",
				input: 		"focus,blur",
				widget:		"focus mouseenter,blur mouseleave",
				tooltip:		"mouseenter,mouseleave"
			},

			// 1.2
			layout: '<div/>',
			tipClass: 'tooltip'
		},

		addEffect: function(name, loadFn, hideFn) {
			effects[name] = [loadFn, hideFn];
		}
	};


	var effects = {
		toggle: [
			function(done) {
				var conf = this.getConf(), tip = this.getTip(), o = conf.opacity;
				if (o < 1) { tip.css({opacity: o}); }
				tip.show();
				done.call();
			},

			function(done) {
				this.getTip().hide();
				done.call();
			}
		],

		fade: [
			function(done) {
				var conf = this.getConf();
				if (!$.browser.msie || conf.fadeIE) {
					this.getTip().fadeTo(conf.fadeInSpeed, conf.opacity, done);
				}
				else {
					this.getTip().show();
					done();
				}
			},
			function(done) {
				var conf = this.getConf();
				if (!$.browser.msie || conf.fadeIE) {
					this.getTip().fadeOut(conf.fadeOutSpeed, done);
				}
				else {
					this.getTip().hide();
					done();
				}
			}
		]
	};


	/* calculate tip position relative to the trigger */
	function getPosition(trigger, tip, conf) {


		// get origin top/left position
		var top = conf.relative ? trigger.position().top : trigger.offset().top,
			 left = conf.relative ? trigger.position().left : trigger.offset().left,
			 pos = conf.position[0];

		top  -= tip.outerHeight() - conf.offset[0];
		left += trigger.outerWidth() + conf.offset[1];

		// iPad position fix
		if (/iPad/i.test(navigator.userAgent)) {
			top -= $(window).scrollTop();
		}

		// adjust Y
		var height = tip.outerHeight() + trigger.outerHeight();
		if (pos == 'center') 	{ top += height / 2; }
		if (pos == 'bottom') 	{ top += height; }


		// adjust X
		pos = conf.position[1];
		var width = tip.outerWidth() + trigger.outerWidth();
		if (pos == 'center') 	{ left -= width / 2; }
		if (pos == 'left')   	{ left -= width; }

		return {top: top, left: left};
	}



	function Tooltip(trigger, conf) {

		var self = this,
			 fire = trigger.add(self),
			 tip,
			 timer = 0,
			 pretimer = 0,
			 title = trigger.attr("title"),
			 tipAttr = trigger.attr("data-tooltip"),
			 effect = effects[conf.effect],
			 shown,

			 // get show/hide configuration
			 isInput = trigger.is(":input"),
			 isWidget = isInput && trigger.is(":checkbox, :radio, select, :button, :submit"),
			 type = trigger.attr("type"),
			 evt = conf.events[type] || conf.events[isInput ? (isWidget ? 'widget' : 'input') : 'def'];


		// check that configuration is sane
		if (!effect) { throw "Nonexistent effect \"" + conf.effect + "\""; }

		evt = evt.split(/,\s*/);
		if (evt.length != 2) { throw "Tooltip: bad events configuration for " + type; }


		// trigger --> show
		trigger.bind(evt[0], function(e) {

			clearTimeout(timer);
			if (conf.predelay) {
				pretimer = setTimeout(function() { self.show(e); }, conf.predelay);

			} else {
				self.show(e);
			}

		// trigger --> hide
		}).bind(evt[1], function(e)  {
			clearTimeout(pretimer);
			if (conf.delay)  {
				timer = setTimeout(function() { self.hide(e); }, conf.delay);

			} else {
				self.hide(e);
			}

		});


		// remove default title
		if (title && conf.cancelDefault) {
			trigger.removeAttr("title");
			trigger.data("title", title);
		}

		$.extend(self, {

			show: function(e) {

				// tip not initialized yet
				if (!tip) {

					// data-tooltip
					if (tipAttr) {
						tip = $(tipAttr);

					// single tip element for all
					} else if (conf.tip) {
						tip = $(conf.tip).eq(0);

					// autogenerated tooltip
					} else if (title) {
						tip = $(conf.layout).addClass(conf.tipClass).appendTo(document.body)
							.hide().append(title);

					// manual tooltip
					} else {
						tip = trigger.next();
						if (!tip.length) { tip = trigger.parent().next(); }
					}

					if (!tip.length) { throw "Cannot find tooltip for " + trigger;	}
				}

			 	if (self.isShown()) { return self; }

			 	// stop previous animation
			 	tip.stop(true, true);

				// get position
				var pos = getPosition(trigger, tip, conf);

				// restore title for single tooltip element
				if (conf.tip) {
					tip.html(trigger.data("title"));
				}

				// onBeforeShow
				e = $.Event();
				e.type = "onBeforeShow";
				fire.trigger(e, [pos]);
				if (e.isDefaultPrevented()) { return self; }


				// onBeforeShow may have altered the configuration
				pos = getPosition(trigger, tip, conf);

				// set position
				tip.css({position:'absolute', top: pos.top, left: pos.left});

				shown = true;

				// invoke effect
				effect[0].call(self, function() {
					e.type = "onShow";
					shown = 'full';
					fire.trigger(e);
				});


				// tooltip events
				var event = conf.events.tooltip.split(/,\s*/);

				if (!tip.data("__set")) {

					tip.unbind(event[0]).bind(event[0], function() {
						clearTimeout(timer);
						clearTimeout(pretimer);
					});

					if (event[1] && !trigger.is("input:not(:checkbox, :radio), textarea")) {
						tip.unbind(event[1]).bind(event[1], function(e) {

							// being moved to the trigger element
							if (e.relatedTarget != trigger[0]) {
								trigger.trigger(evt[1].split(" ")[0]);
							}
						});
					}

					// bind agein for if same tip element
					if (!conf.tip) tip.data("__set", true);
				}

				return self;
			},

			hide: function(e) {

				if (!tip || !self.isShown()) { return self; }

				// onBeforeHide
				e = $.Event();
				e.type = "onBeforeHide";
				fire.trigger(e);
				if (e.isDefaultPrevented()) { return; }

				shown = false;

				effects[conf.effect][1].call(self, function() {
					e.type = "onHide";
					fire.trigger(e);
				});

				return self;
			},

			isShown: function(fully) {
				return fully ? shown == 'full' : shown;
			},

			getConf: function() {
				return conf;
			},

			getTip: function() {
				return tip;
			},

			getTrigger: function() {
				return trigger;
			}

		});

		// callbacks
		$.each("onHide,onBeforeShow,onShow,onBeforeHide".split(","), function(i, name) {

			// configuration
			if ($.isFunction(conf[name])) {
				$(self).bind(name, conf[name]);
			}

			// API
			self[name] = function(fn) {
				if (fn) { $(self).bind(name, fn); }
				return self;
			};
		});

	}


	// jQuery plugin implementation
	$.fn.tooltip = function(conf) {

		// return existing instance
		var api = this.data("tooltip");
		if (api) { return api; }

		conf = $.extend(true, {}, $.tools.tooltip.conf, conf);

		// position can also be given as string
		if (typeof conf.position == 'string') {
			conf.position = conf.position.split(/,?\s/);
		}

		// install tooltip for each entry in jQuery object
		this.each(function() {
			api = new Tooltip($(this), conf);
			$(this).data("tooltip", api);
		});

		return conf.api ? api: this;
	};

}) (jQuery);




/**
 * @license 
 * jQuery Tools @VERSION / Tooltip Slide Effect
 * 
 * NO COPYRIGHTS OR LICENSES. DO WHAT YOU LIKE.
 * 
 * http://flowplayer.org/tools/tooltip/slide.html
 *
 * Since: September 2009
 * Date: @DATE 
 */
(function($) { 

	// version number
	var t = $.tools.tooltip;
		
	// extend global configuragion with effect specific defaults
	$.extend(t.conf, { 
		direction: 'up', // down, left, right 
		bounce: false,
		slideOffset: 10,
		slideInSpeed: 200,
		slideOutSpeed: 200, 
		slideFade: !$.browser.msie
	});			
	
	// directions for slide effect
	var dirs = {
		up: ['-', 'top'],
		down: ['+', 'top'],
		left: ['-', 'left'],
		right: ['+', 'left']
	};
	
	/* default effect: "slide"  */
	t.addEffect("slide", 
		
		// show effect
		function(done) { 

			// variables
			var conf = this.getConf(), 
				 tip = this.getTip(),
				 params = conf.slideFade ? {opacity: conf.opacity} : {}, 
				 dir = dirs[conf.direction] || dirs.up;

			// direction			
			params[dir[1]] = dir[0] +'='+ conf.slideOffset;
			
			// perform animation
			if (conf.slideFade) { tip.css({opacity:0}); }
			tip.show().animate(params, conf.slideInSpeed, done); 
		}, 
		
		// hide effect
		function(done) {
			
			// variables
			var conf = this.getConf(), 
				 offset = conf.slideOffset,
				 params = conf.slideFade ? {opacity: 0} : {}, 
				 dir = dirs[conf.direction] || dirs.up;
			
			// direction
			var sign = "" + dir[0];
			if (conf.bounce) { sign = sign == '+' ? '-' : '+'; }			
			params[dir[1]] = sign +'='+ offset;			
			
			// perform animation
			this.getTip().animate(params, conf.slideOutSpeed, function()  {
				$(this).hide();
				done.call();		
			});
		}
	);  
	
})(jQuery);	
		

/*
** benvarim.com user interactions
** author: gercek karakus - 2011
**
*/

/*jquery bugfix, see: http://bugs.jquery.com/ticket/10531*/
(function(){
    // remove layerX and layerY
    var all = $.event.props,
        len = all.length,
        res = [];
    while (len--) {
      var el = all[len];
      if (el != 'layerX' && el != 'layerY') res.push(el);
    }
    $.event.props = res;
}());

function fadeInOrder(elem) {
  elem.fadeIn(300, function() {

    if ($(this).next().length > 0) {
      // fadeIn() next element if exists
      fadeInOrder( $(this).next().delay(1500) );
    } else {
      // $('#featured-input').delay(1000).focus();

    }
  });
}

//
// Search Focus & Blur
//
function setup_search(){

  var searchDefaultText = $(".clear-on-focus").attr("value");

  $(".clear-on-focus").focus(function(){
    if($(this).attr("value") == searchDefaultText) $(this).attr("value", "");
  });
  $(".clear-on-focus").blur(function(){
     if($(this).attr("value") == "") $(this).attr("value", searchDefaultText);
  });
}

//
// Registration
//
function init_registration(){

  // Show the sign up with email form is necessary
  $('.toggle').click(function(){
    $this = $(this);
    $this.fadeOut('fast', function(){
      $this.next().slideDown();
    });
  });

  // Slide in the confirm password field on focus
  $('#user_password').focus(function(){
    $this = $(this);
    $this.parents('.field').next().css({'visibility':'visible','height':'0'}).slideDown('1000');
  });
}


//
// FAQ
//
function init_accordion(){
  $('.accordion h4').click(function(){
    $(this).next().slideToggle();
  })
};


function equalHeight(group) {
	var tallest = 0;
	group.each(function() {
		var thisHeight = $(this).height();
		if(thisHeight > tallest) {
			tallest = thisHeight;
		}
	});
	group.height(tallest);
}


/*
 * Assumes that $container has the markup below
 *

<div class="benvarim-gallery">
  <div class="bg-item">
    <div class="bg-image"></div>
    <div class="bg-container"></div>
  </div>
  ...
</div>
 */
function init_benvarim_gallery($container){ }





//
// function init_lazy_load_facebook(){
//
//   // lazyload for facebook
//   $('.fb-like-box').lazyloadjs(function() {
//     var d = document;
//     var s = 'script';
//     var id = 'facebook-jssdk';
//     var js, fjs = d.getElementsByTagName(s)[0];
//     if (d.getElementById(id)) {return;}
//     js = d.createElement(s); js.id = id;
//     js.src = "//connect.facebook.net/en_US/all.js#xfbml=1";
//     fjs.parentNode.insertBefore(js, fjs);
//   });
//
// }



//
// Tooltips
//
// Currently active on page, project and organization forms
//
function init_tooltips() {

    //
    // Bağış Sayfası Yarat Tooltipleri
    //
    $('.tooltip-trigger').tooltip({
    	// place tooltip on the right edge
    	position: "center right",

    	// a little tweaking of the position
    	offset: [-2, 10],

    	// use the built-in fadeIn/fadeOut effect
    	effect: "fade",

    	layout: "<div class='tooltip'><div class='tooltip-arrow-border'></div><div class='tooltip-arrow'></div></div>"

    });

    //
    // Hakkimizda Profil Tooltip
    //
    $('#i-home-hakkimizda .profile_pic').click(function(){

    });

}


function init_footer(){
  var url = "/footer_container.html";
  $('.footer-dynamic').load(url);
  $.get(url,function(data){
    // init_lazy_load_facebook();
  });


}


function init_vertical_align(){
  var $items = $('.p-item');
  $items.each(function(){
    $this = $(this)

    var $img_container = $this.find('.pi-img');
    var $img = $img_container.find('img');

    var margin_top = ($img_container.height() - $img.height())/2;
    $img.css('margin-top',margin_top);
  });


}


//
// Page Tracking
//

// _trackEvent(category, action, opt_label, opt_value, opt_noninteraction)
  // category (required): The name you supply for the group of objects you want to track.
  // action (required): A string that is uniquely paired with each category, and commonly used to define the type of user interaction for the web object.
  // label (optional): An optional string to provide additional dimensions to the event data.
  // value (optional): An integer that you can use to provide numerical data about the user event.
  // non-interaction (optional): A boolean that when set to true, indicates that the event hit will not be used in bounce-rate calculation.


function init_tracking(){

  // How many times donate button is clicked and how many people went to Paypal from the lightbox
  $('.button-donate').click(function(){
    _gaq.push(['_trackEvent', 'category-payment', 'payment-through-paypal', 'donation lightbox triggerred', 'value-1'])
  });

  $('.button-send-to-paypal').live('click',function(){
    _gaq.push(['_trackEvent', 'category-payment', 'payment-through-paypal', 'user sent to paypal to finish transaction', 'value-1'])
  });
}






/*
** DOM READY
*/
$(document).ready(function(){


  init_registration();

  init_accordion();

  fadeInOrder( $("#step-1") );

  $('.campaign-form-container h2, .steps').click(function(){
    $('#featured-input').focus();
  });

  setup_search();

  init_tracking();






  //  Custom Form Styles
  // $("select, :radio, :checkbox").uniform();


  //
  // Clear margin-bottom for .fullcontent-right p(last)
  //
  $('.fullcontent-right p').last().css('margin','0');

  $('.row').hover(  function(){ $(this).addClass('row-hover'); },
                    function(){ $(this).removeClass('row-hover'); });




  // Trigger link in the row element, if user clicks on the row
  $('.row').click(function(){
    var url = $(this).find('a').attr('href');
    if (url){
      window.location = url;
    }
  });


  $('.comment-bubble').append('<div class="comment-arrow"></div>');

  //
  // Autocomplete - Homepage
  //
  var availableOrganizations = window.availableOrganizations || [];

	$( "#featured-input" ).autocomplete({
		source: availableOrganizations,
		minLength: 1,
		select : function(event, ui) {
		  if(ui.item) {
		    $('#org_id').val(ui.item.id);
		  }
		}
	});


  //
  //  Homepage Tabs for non-profits and individuals
  //
	$('.profile-nonprofit').click(function(){
	  $this = $(this);
	  $p_individual = $('.profile-individual');
	  $this.removeClass('opaque');
	  $p_individual.addClass('opaque');

	  $('#fc-inner-individual').fadeOut(function(){
	    $('#fc-inner-nonprofit').fadeIn();
	  });
	});


	$('.profile-individual').click(function(){
	  $this = $(this);
	  $p_individual = $('.profile-nonprofit');
	  $this.removeClass('opaque');
	  $p_individual.addClass('opaque');

	  $('#fc-inner-nonprofit').fadeOut(function(){
	    $('#fc-inner-individual').fadeIn();
	  });
	});


  //
  // Homepage Video
  //
  $('.pfv-inner').click(function(){
    $(this).html('<iframe src="http://player.vimeo.com/video/29056779?title=0&amp;byline=0&amp;portrait=0&amp;color=ff9933&amp;autoplay=1" width="100%" height="100%" frameborder="0" webkitAllowFullScreen allowFullScreen></iframe>');
  });


  //
  // Homepage Equalize Columns
  //
  // var cols = $('.column .widget');
  // equalHeight(cols);


  //
  // Dialog global initialization
  //
  $('.dialog').dialog({
    modal: true,
    width: 600,
    show: "fade",
    hide: "fade",
    autoOpen: false
  });

  $('.dialog-trigger').live('click', function(e){
    e.preventDefault();
    var target_dialog = $(this).attr('data-dialog');
    $(target_dialog).dialog('open');
  });




	//
	// Tabs
	//
	$( "#tabs" ).tabs({
		cookie: {
			// store cookie for a day, without, it would be a session cookie
			expires: 3
		}
	});



  $("#un-search-form").bvSearchAutocomplete({
    renderer : null,
    format : null,
    facetRenderer : null,
    facetFormat : null,
    autocompleteSearchingClass : "search-loading"
  });


  init_tooltips();

  init_footer();

});



function popupCenter(url, width, height, name) {
  var left = (screen.width/2)-(width/2);
  var top = (screen.height/2)-(height/2);
  return window.open(url, name, "menubar=no,toolbar=no,status=no,width="+width+",height="+height+",toolbar=no,left="+left+",top="+top);
}

//indextank search autocomplete codes
$(document).ready(function(){
    $("a.popup").click(function(e) {
      popupCenter($(this).attr("href"), $(this).attr("data-width"), $(this).attr("data-height"), "authPopup");
      e.stopPropagation(); return false;
    });

    /*
    setTimeout(function(){
      $.facebox.settings.closeImage = '/stylesheets/images/closelabel.png';
      $.facebox.settings.loadingImage = '/stylesheets/images/loading.gif';
      //
      $('a[rel*=facebox]').facebox();
    }, 1000);
    */



    $.facebox.settings.closeImage = '/stylesheets/images/closelabel.png';
    $.facebox.settings.loadingImage = '/stylesheets/images/loading.gif';

    $('a[rel*=facebox]').facebox();


    $(".more-link").live("click", function() {
        // debugger;
        var that = this;
        $(that).html("<img src='/images/ajax-loader.gif'>");
        $.ajax({
            type: "GET",
            url: $(that).attr("url"),
            cache: false,
            success: function(html){
                $(that).before(html);
                $(that).remove();
            }
        });
    });

    $(['/stylesheets/images/search-loading.gif']).preload();

});