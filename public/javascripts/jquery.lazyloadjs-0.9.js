/**
 * Lazy Load JS - jQuery plugin for lazy loading JavaScript snippets
 *
 * Copyright (c) 2011 Cyril Mazur
 *
 * Licensed under the MIT license:
 *   http://www.opensource.org/licenses/mit-license.php
 *
 * Project home:
 *   http://code.google.com/p/jquery-lazyloadjs/
 * 
 * Online documentation & live examples
 *   http://cyrilmazur.com/jquery-lazyloadjs
 *
 * Version:  0.9.0
 *
 */
(function($) {
	$.fn.lazyloadjs = function(f) {
		// default settings
		var settings = {
			uri			: "",
			event		: "scroll",
			threshold	: 0,
			container	: window
		};

		var f = f;

		var elements = this;

		// don't add up an event if there is nothing to lazy load at first
		if (this.length > 0) {

			// bind function to event scroll
			$(settings.container).bind("scroll", function(event) {
				elements.each(function(key) {

					// check if element is in view port
					if ($.inviewport(this, settings)) {

						// execute Javascript
						f();

						// remove element from array so that we don't process it next time
						elements.splice(key,1);
					}
				});

				// if all elements have been processed, remove event handler
				if (elements.length == 0) {
					$(window).unbind('scroll', arguments.callee);
				}
			});
		}

		// force initial checking
		$(settings.container).trigger(settings.event);
	};

	/**
	 * These functions are to calculate position of an element in relation to the window's viewport
	 * 
	 * @see http://www.appelsiini.net/projects/viewport
	 */
	$.belowthefold = function(element, settings) {
		var fold = $(window).height() + $(window).scrollTop();
		return fold <= $(element).offset().top - settings.threshold;
	};

	$.abovethetop = function(element, settings) {
		var top = $(window).scrollTop();
		return top >= $(element).offset().top + $(element).height() - settings.threshold;
	};

	$.rightofscreen = function(element, settings) {
		var fold = $(window).width() + $(window).scrollLeft();
		return fold <= $(element).offset().left - settings.threshold;
	};

	$.leftofscreen = function(element, settings) {
		var left = $(window).scrollLeft();
		return left >= $(element).offset().left + $(element).width() - settings.threshold;
	};

	$.inviewport = function(element, settings) {
		return !$.rightofscreen(element, settings) && !$.leftofscreen(element, settings) && !$.belowthefold(element, settings) && !$.abovethetop(element, settings);
	};
})(jQuery);