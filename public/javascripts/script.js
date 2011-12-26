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
    $('.tooltip-trigger').tooltip({
    	// place tooltip on the right edge
    	position: "center right",

    	// a little tweaking of the position
    	offset: [-2, 5],

    	// use the built-in fadeIn/fadeOut effect
    	effect: "fade"

    });
}


function init_footer(){
  var url = "/footer_container.html";
  $('.footer-dynamic').load(url);
  $.get(url,function(data){
    // init_lazy_load_facebook();
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
  var cols = $('.column .widget');
  equalHeight(cols);


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