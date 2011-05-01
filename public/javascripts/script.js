/*
** benvarim.com user interactions
** author: gercek karakus - 2011
**
*/

function fadeInOrder(elem) {
  elem.fadeIn(500, function() {

    if ($(this).next().length > 0) {
      // fadeIn() next element if exists
      fadeInOrder( $(this).next().delay(2000) );
    } else {
      $('#featured-input').delay(1000).focus();

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


/*
** DOM READY
*/
$(document).ready(function(){

  fadeInOrder( $("#step-1") );

  $('.campaign-form-container h2, .steps').click(function(){
    $('#featured-input').focus();
  });

  setup_search();

  //  Custom Form Styles
  $("select, :radio, :checkbox").uniform();


  //
  // Clear margin-bottom for .fullcontent-right p(last)
  //
  $('.fullcontent-right p').last().css('margin','0');

  $('.row').hover(  function(){ $(this).addClass('row-hover'); },
                    function(){ $(this).removeClass('row-hover'); });

  // Trigger link in the row element, if user clicks on the row
  $('.row').click(function(){
    var url = $(this).find('a').attr('href');
    window.location = url;
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


});


setTimeout(function(){
  $.facebox.settings.closeImage = '/stylesheets/images/closelabel.png';
  $.facebox.settings.loadingImage = '/stylesheets/images/loading.gif';
  //
  $('a[rel*=facebox]').facebox();
}, 100);