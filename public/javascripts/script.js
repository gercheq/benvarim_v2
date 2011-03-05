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


/*
** DOM READY
*/
$(document).ready(function(){

  fadeInOrder( $("#step-1") );

  $('.campaign-form-container h2, .steps').click(function(){
    $('#featured-input').focus();
  });


  //
  // Search Focus & Blur
  //
  var searchDefaultText = $(".clear-on-focus").attr("value");

  $(".clear-on-focus").focus(function(){
    if($(this).attr("value") == searchDefaultText) $(this).attr("value", "");
  });
  $(".clear-on-focus").blur(function(){
     if($(this).attr("value") == "") $(this).attr("value", searchDefaultText);
  });

  //
  // Form Custom Styles
  //
  $("select, :radio, :checkbox").uniform();


  //
  // Clear margin-bottom for .fullcontent-right p(last)
  //
  $('.fullcontent-right p').last().css('margin','0');


  $('.row').hover(  function(){ $(this).addClass('row-hover'); },
                    function(){ $(this).removeClass('row-hover'); });


  $('.comment-bubble').append('<div class="comment-arrow"></div>');


  var availableOrganizations = [
		"Nesin Vakfı",
		"Heybeliada Gönüllüleri Derneği",
		"Kızılay - Adalar Şubesi",
		"Heybeliada Ilm-i Musiki Derneği",
		"Adalar Vakfı",
		"Kültür Konseyi Derneği",
		"İlke Eğitim ve Sağlık Vakfı",
		"Pertevniyal Eğitim Vakfı",
		"Çamlıca Kültür ve Yardım Vakfı"
	];
	$( "#featured-input" ).autocomplete({
		source: availableOrganizations
	});

});


setTimeout(function(){
  $.facebox.settings.closeImage = '/stylesheets/images/closelabel.png';
  $.facebox.settings.loadingImage = '/stylesheets/images/loading.gif';
  //
  $('a[rel*=facebox]').facebox();
}, 100);