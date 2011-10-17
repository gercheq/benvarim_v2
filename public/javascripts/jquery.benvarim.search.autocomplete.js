(function($) {
    // if ($.fn.Bv == null) {
    //     $.fn.Bv = {};
    // }
    var defaultFormat = function(item) {
        return $("<div></div>")
        .addClass("result")
        .append($("<a href='/ara/d/" + item.docid + "'></a>").html(item.human_readable_name));
    };
    var defaultSetupContainer = function($el) {
        $el.html("Search results!");
    };
    var settings = {
        format: defaultFormat,
        setupContainer: defaultSetupContainer,
        renderer: null
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
                var inputElm = inputElms[0];
                $that.indextank_Ize(Bv.Config.Search.publicApiUrl, Bv.Config.Search.indexName);
                var listeners = [];
                if (settings.renderer) {
                    var r = $(settings.renderer).indextank_Renderer({
                        format: settings.format,
                        setupContainer: settings.setupContainer
                    });
                    listeners.push(r);
                }
                $(inputElm).indextank_AjaxSearch({
                    listeners: listeners,
                    fields: "name, human_readable_name"
                });

                var searchForm = $("<form></form>");
                var searchInput = $("<input type='text'>");
                searchForm.append(searchInput);
                searchForm.indextank_Ize(Bv.Config.Search.publicApiUrl, Bv.Config.Search.indexName);
                var searchDummyRenderer = $("<div/>").indextank_Renderer({format:defaultFormat, setupContainer:defaultSetupContainer});
                searchInput.indextank_AjaxSearch({
                    listeners: searchDummyRenderer,
                    fields: "name, human_readable_name"
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
                    callback = $(inputElm).data("bv.cb");
                    callback && callback(results);
                });
                
                $(inputElm).autocomplete({
                    source: function(x,callback) {
                        var term = x.term;
                        $(inputElm).data("bv.cb", callback);
                        searchInput.val(term);
                        searchInput.submit();
                    },
                    minLength: 1,
                    select : function(event, obj) {
                        event.preventDefault();
                        if(obj && obj.item && obj.item.id) {
                            window.location = "/ara/d/" + obj.item.id;
                        }
                    }
                });

            });
        };
        init();
    };
})(jQuery);
$(document).ready(function(){
    
});
