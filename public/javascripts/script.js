/*
** benvarim.com user interactions
** author: gercek karakus - 2011
**
*/

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
  $('.accordion h3').click(function(){
    $(this).next().slideToggle();
  })
};




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



  /*
  $('.truncate-short').truncatable({
    limit: 600,
    more: ' devamını göster &raquo; ',
    less: false,
    hideText: '[sakla]'
  });
  */

	//
	// Tabs
	//
	$( "#tabs" ).tabs({
		cookie: {
			// store cookie for a day, without, it would be a session cookie
			expires: 1
		}
	});


 /*
  *  condensedLength: Target length of condensed element. Default: 200
  *  minTrail: Minimun length of the trailing text. Default: 20
  *  delim: Delimiter used for finding the break point. Default: " " - {space}
  *  moreText: Text used for the more control. Default: [more]
  *  lessText: Text used for the less control. Default: [less]
  *  ellipsis: Text added to condensed element. Default:  ( ... )
  *  moreSpeed: Animation Speed for expanding. Default: "normal"
  *  lessSpeed: Animation Speed for condensing. Default: "normal"
  *  easing: Easing algorith. Default: "linear"


	$('.condense-200').condense({
	  condensedLength: 200,
	  moreText: "Devamını Göster",
	  lessText: "",
	  ellipsis: ""
	});
*/



});


setTimeout(function(){
  $.facebox.settings.closeImage = '/stylesheets/images/closelabel.png';
  $.facebox.settings.loadingImage = '/stylesheets/images/loading.gif';
  //
  $('a[rel*=facebox]').facebox();
}, 100);

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

function popupCenter(url, width, height, name) {
  var left = (screen.width/2)-(width/2);
  var top = (screen.height/2)-(height/2);
  return window.open(url, name, "menubar=no,toolbar=no,status=no,width="+width+",height="+height+",toolbar=no,left="+left+",top="+top);
}

$("a.popup").click(function(e) {
  popupCenter($(this).attr("href"), $(this).attr("data-width"), $(this).attr("data-height"), "authPopup");
  e.stopPropagation(); return false;
});

//indextank search autocomplete codes
var publicApiUrl = "<%=ENV['INDEXTANK_PUBLIC_URL']%>";
var indexName = "<%=BvSearch.get_default_index_name%>";


$(document).ready(function(){
    // let the form be 'indextank-aware'
    $("#search_form").indextank_Ize(Bv.Config.Search.publicApiUrl, Bv.Config.Search.indexName);
            
            var customFormat = function(item){
                return $("<div></div>")
                    .addClass("result")
                    .append( $("<span></span>").html(item.human_readable_name) );
            }
            var customSetupContainer = function($el) {
                $el.html("Search results!");
            }
    
    var r = $("#search_renderer").indextank_Renderer({format: customFormat, setupContainer:customSetupContainer});
    $("#search_query").indextank_AjaxSearch({listeners: r,
        fields: "name, human_readable_name",
        rewriteQuery : function(t) {return t;}});
    
    //keep it global for testing
    searchForm = $("<form></form>");
    searchInput = $("<input type='text'>");
    searchForm.append(searchInput);
    searchForm.indextank_Ize(Bv.Config.Search.publicApiUrl, Bv.Config.Search.indexName);
    searchDummyRenderer = $("<div/>").indextank_Renderer({format: customFormat, setupContainer:customSetupContainer});
    
    searchInput.indextank_AjaxSearch({listeners: searchDummyRenderer,
        fields: "name, human_readable_name"});
        
    var searchCb = function(e, data) {
        var results = [];
        if(data && data.results) {
            $(data.results).each(function(i, obj) {
                results.push({
                    id : obj.docid,
                    label : obj.human_readable_name
                    });
            });
        }
        callback = $("#search_query").data("bv.cb");
        callback && callback(results);
    };   
    searchDummyRenderer.bind("Indextank.AjaxSearch.success", searchCb); 
    $("#search_query").autocomplete({
        source: function(x,callback) {
            var term = x.term;
            $("#search_query").data("bv.cb", callback);
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
    }
);
                
                
    
    
                                    // $("#search_query").val()    
    // $("#search_query").trigger("Indextank.AjaxSearch.runQuery", $("#search_query").data("Indextank.AjaxSearch").getDefaultQuery().withQueryString("tttt"))
});