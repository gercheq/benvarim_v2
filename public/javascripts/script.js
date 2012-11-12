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

function redirect_ykpostnet(){
    $("#ykpostnet_xid").val(true);
    $("#donate-form").submit();
}


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


    // homepage feed tooltips
    $('.more-feed-trigger').tooltip({
      position: 'bottom center'
    })



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







function init_progress_bar(){
    var $progress_bar = $('.progress-bar');
    $progress_bar.width($progress_bar.data('width'));
}



// Equalize Columns on Homepage
function equalizeColumns() {

  var $projectsWidget = $('.column-projects .widget');
  var $pagesWidget = $('.column-pages .widget');


  var projectsColumnHeight = $pagesWidget.height();
  var pagesColumnHeight = $pagesWidget.height();

  var maxHeight = Math.max(pagesColumnHeight, projectsColumnHeight);
  console.log(maxHeight);

  $pagesWidget.height(maxHeight);
	$projectsWidget.height(maxHeight);
}

$(window).load(function(){
  var $homepage = $('#i-home-index');
  if($homepage.length){
    equalizeColumns();
  }
});


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
    if($( "#featured-input" ).length) {
	    $( "#featured-input" ).autocomplete({
    		source: availableOrganizations,
    		minLength: 1,
    		select : function(event, ui) {
    		  if(ui.item) {
    		    $('#org_id').val(ui.item.id);
    		  }
    		}
    	});
	}


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
  if($('.dialog').length) {
      $('.dialog').dialog({
        modal: true,
        width: 600,
        show: "fade",
        hide: "fade",
        autoOpen: false
      });
  }

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

    $('.organization-report-calendar').datepicker({dateFormat: "yy-mm-dd"})

    $(['/stylesheets/images/search-loading.gif']).preload();

});