/*
** benvarim.com user interactions 
** author: gercek karakus - 2011
**
*/

function fadeInOrder(elem) { 
  elem.fadeIn(500, function() { 
    
    if( $(this).next().length > 0){
      // fadeIn() next element if exists 
      fadeInOrder( $(this).next().delay(1000) ); 
    }
    else{
      // display the campaign form
      $('.campaign-form-container').delay(1000).slideDown('slow');
    }
    
  }); 
}                            


/*
** DOM READY 
*/
$(document).ready(function(){


  //
  // Featured Animation
  //
  $('.steps-loading').fadeOut(500, function(){
    $('.steps').fadeIn('fast',function(){
      
      //var $tmp = $('#step-1');
      fadeInOrder( $("#step-1") );
    });
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
  
  
});









