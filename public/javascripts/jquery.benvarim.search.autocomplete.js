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
        $el.html("Arama Sonucları");
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
        urlPrefix : "/ara/d/"
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

            });
        };
        init();
    };
})(jQuery);
