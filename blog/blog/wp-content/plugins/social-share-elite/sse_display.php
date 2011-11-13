<?php 
/*
Core logic to display social share icons at the required positions. 
*/
require_once('sse_admin_page.php');

function twitter_facebook_share_init() {
	// DISABLED IN THE ADMIN PAGES
	if (is_admin()) {
		return;
	}

	//GET ARRAY OF STORED VALUES
	$option = twitter_facebook_share_get_options_stored();

	if ($option['active_buttons']['twitter']==true) {
		wp_enqueue_script('twitter_facebook_share_twitter', 'http://platform.twitter.com/widgets.js','','',$option['jsload']);
	}
	
	if ($option['active_buttons']['Google_plusone']==true) {
		wp_enqueue_script('twitter_facebook_share_google', 'http://apis.google.com/js/plusone.js','','',$option['jsload']);
	}
	if ($option['active_buttons']['linkedin']==true) {
		wp_enqueue_script('twitter_facebook_share_linkedin', 'http://platform.linkedin.com/in.js','','',$option['jsload']);
	}
	if ($option['active_buttons']['buffer']==true) {
		wp_enqueue_script('twitter_facebook_share_buffer', 'http://static.bufferapp.com/js/button.js','','',$option['jsload']);
	}

	wp_enqueue_style('sse_style', '/wp-content/plugins/social-share-elite/sse_style.css');
	
}    

function rp_twitter_facebook_contents($content)
{
	return rp_twitter_facebook($content,'content');
}

function rp_twitter_facebook_excerpt($content)
{
	return rp_twitter_facebook($content,'excerpt');
}

function rp_twitter_facebook($content, $filter)
{
  global $single;
  
  $option = twitter_facebook_share_get_options_stored();
  $custom_disable = get_post_custom_values('disable_social_share');
  if (is_single() && ($option['show_in']['posts']) && ($custom_disable[0] != 'yes')) {
	    $output = rp_social_share('auto');
  		if ($option['position'] == 'above')
        	return  $output . $content;
		if ($option['position'] == 'below')
			return  $content . $output;
		if ($option['position'] == 'left')
			return  $output . $content;
		if ($option['position'] == 'both')
			return  $output . $content . $output;
    } 
	if (is_home() && ($option['show_in']['home_page'])){
        $output = rp_social_share('auto');
		if ($option['position'] == 'above')
        	return  $output . $content;
		if ($option['position'] == 'below')
			return  $content . $output;
		if ($option['position'] == 'left')
			return  $output . $content;
		if ($option['position'] == 'both')
			return  $output . $content . $output;
	}
	if (is_page() && ($option['show_in']['pages']) && ($custom_disable[0] != 'yes')) {
		  $output = rp_social_share('auto');
  		if ($option['position'] == 'above')
        	return  $output . $content;
		if ($option['position'] == 'below')
			return  $content . $output;
		if ($option['position'] == 'left')
			return  $output . $content;
		if ($option['position'] == 'both')
			return  $output . $content . $output;
    }  
	if (is_category() && ($option['show_in']['categories'])) {
		  $output = rp_social_share('auto');
  		if ($option['position'] == 'above')
        	return  $output . $content;
		if ($option['position'] == 'below')
			return  $content . $output;
		if ($option['position'] == 'left')
			return  $output . $content;
		if ($option['position'] == 'both')
			return  $output . $content . $output;
    } 
	if (is_tag() && ($option['show_in']['tags'])) {
		  $output = rp_social_share('auto');
  		if ($option['position'] == 'above')
        	return  $output . $content;
		if ($option['position'] == 'below')
			return  $content . $output;
		if ($option['position'] == 'left')
			return  $output . $content;
		if ($option['position'] == 'both')
			return  $output . $content . $output;
    } 
	if (is_author() && ($option['show_in']['authors'])) {
		  $output = rp_social_share('auto');
  		if ($option['position'] == 'above')
        	return  $output . $content;
		if ($option['position'] == 'below')
			return  $content . $output;
		if ($option['position'] == 'left')
			return  $output . $content;
		if ($option['position'] == 'both')
			return  $output . $content . $output;
    } 
	if (is_search() && ($option['show_in']['search'])) {
		  $output = rp_social_share('auto');
  		if ($option['position'] == 'above')
        	return  $output . $content;
		if ($option['position'] == 'below')
			return  $content . $output;
		if ($option['position'] == 'left')
			return  $output . $content;
		if ($option['position'] == 'both')
			return  $output . $content . $output;
    } 
	if (is_date() && ($option['show_in']['date_arch'])) {
		  $output = rp_social_share('auto');
  		if ($option['position'] == 'above')
        	return  $output . $content;
		if ($option['position'] == 'below')
			return  $content . $output;
		if ($option['position'] == 'left')
			return  $output . $content;
		if ($option['position'] == 'both')
			return  $output . $content . $output;
    } 
	return $content;
}

// Function to manually display related posts.
function rp_add_social_share()
{
 $output = rp_social_share('manual');
 echo $output;
}



function rp_social_share($source)
{
	//GET ARRAY OF STORED VALUES
	$option = twitter_facebook_share_get_options_stored();
	if (empty($option['bkcolor_value']))
		$option['bkcolor_value'] = '#F0F4F9';
	$border ='';
 	if ($option['border'] == 'flat') 
		$border = 'border:1px solid #808080;';
	else if ($option['border'] == 'round')
	    $border = 'border:1px solid #808080; border-radius:5px 5px 5px 5px; box-shadow:2px 2px 5px rgba(0,0,0,0.3);';
		
	if ($option['bkcolor'] == true)
		$bkcolor = 'background-color:' . $option['bkcolor_value']. ';'; 
	else
		$bkcolor = '';

 	$post_link = get_permalink();
	$post_title = get_the_title();
	if ($option['position'] == 'left' && ( !is_single() && !is_page()))
		if (($source != 'manual') || ($source != 'shortcode')) 
			$option['position'] = 'above';

	if ($option['position'] == 'left'){
		$output = '<div id="leftcontainerBox" style="' .$border. $bkcolor. 'position:' .$option['float_position']. '; top:' .$option['bottom_space']. '; left:' .$option['left_space']. ';">';
		if ($option['active_buttons']['facebook_like']==true) {
		$output .= '
			<div class="buttons">
			<iframe src="http://www.facebook.com/plugins/like.php?href=' . urlencode($post_link) . '&amp;layout=box_count&amp;show_faces=false&amp;action=like&amp;font=verdana&amp;colorscheme=light" scrolling="no" frameborder="0" style="border:none; overflow:hidden; width:50px; height:60px;" allowTransparency="true"></iframe>
			</div>';
		}
		
		if ($option['active_buttons']['twitter']==true) {
		if ($option['twitter_id'] != ''){
		$output .= '
			<div class="buttons">
			<a href="http://twitter.com/share" class="twitter-share-button" data-url="'. $post_link .'"  data-text="'. $post_title . '" data-count="vertical" data-via="'. $option['twitter_id'] . '">Tweet</a>
			</div>';
		} else {
		$output .= '
			<div class="buttons">
			<a href="http://twitter.com/share" class="twitter-share-button" data-url="'. $post_link .'"  data-text="'. $post_title . '" data-count="vertical">Tweet</a>
			</div>';
		}
		}
		
		if ($option['active_buttons']['Google_plusone']==true) {
		$output .= '
			<div class="buttons">
			<g:plusone size="tall" href="'. $post_link .'"></g:plusone>
			</div>';
		}
		
		if ($option['active_buttons']['stumbleupon']==true) {
		$output .= '
			<div class="buttons"><script src="http://www.stumbleupon.com/hostedbadge.php?s=5&amp;r='.$post_link.'"></script></div>';
		}
		if ($option['active_buttons']['linkedin']==true) {
		$output .= '<div class="buttons" style="padding-left:0px;"><script type="in/share" data-url="' . $post_link . '" data-counter="top"></script></div>';
		}
		if ($option['active_buttons']['buffer']==true) {
		$counter = ($option['buffer_count']) ? 'vertical' : '';
		$output .= '<div class="buttons" style="padding-left:0px;"><a rel="nofollow" href="http://bufferapp.com/add" class="buffer-add-button" data-text="' . $post_title . '" data-url="' . $post_link . '" data-via="'. $option['twitter_id'] . '" data-count="' . $counter . '">Buffer</a></div>';
		}
		
		$output .= '</div><div style="clear:both"></div>';
		return $output;
	}

		
	if (($option['position'] == 'below') || ($option['position'] == 'above') || ($option['position'] == 'both'))
	{
		$output = '<div class="bottomcontainerBox" style="' .$border. $bkcolor. '">';
		if ($option['active_buttons']['facebook_like']==true) {
		$output .= '
			<div style="float:left; width:' .$option['facebook_like_width']. 'px;padding-right:10px; margin:4px 4px 4px 4px;height:30px;">
			<iframe src="http://www.facebook.com/plugins/like.php?href=' . urlencode($post_link) . '&amp;layout=button_count&amp;show_faces=false&amp;width='.$option['facebook_like_width'].'&amp;action=like&amp;font=verdana&amp;colorscheme=light&amp;height=21" scrolling="no" frameborder="0" style="border:none; overflow:hidden; width='.$option['facebook_like_width'].'px; height:21px;" allowTransparency="true"></iframe></div>';
		}

		if ($option['active_buttons']['Google_plusone']==true) {
		$data_count = ($option['google_count']) ? '' : 'count="false"';
		$output .= '
			<div style="float:left; width:' .$option['google_width']. 'px;padding-right:10px; margin:4px 4px 4px 4px;height:30px;">
			<g:plusone size="medium" href="' . $post_link . '"'.$data_count.'></g:plusone>
			</div>';
		}
		
		if ($option['active_buttons']['twitter']==true) {
		$data_count = ($option['twitter_count']) ? 'horizontal' : 'none';
		if ($option['twitter_id'] != ''){
		$output .= '
			<div style="float:left; width:' .$option['twitter_width']. 'px;padding-right:10px; margin:4px 4px 4px 4px;height:30px;">
			<a href="http://twitter.com/share" class="twitter-share-button" data-url="'. $post_link .'"  data-text="'. $post_title . '" data-count="'.$data_count.'" data-via="'. $option['twitter_id'] . '">Tweet</a>
			</div>';
		} else {
		$output .= '
			<div style="float:left; width:' .$option['twitter_width']. 'px;padding-right:10px; margin:4px 4px 4px 4px;height:30px;">
			<a href="http://twitter.com/share" class="twitter-share-button" data-url="'. $post_link .'"  data-text="'. $post_title . '" data-count="'.$data_count.'">Tweet</a>
			</div>';
		}
		}
		if ($option['active_buttons']['linkedin']==true) {
		$counter = ($option['linkedin_count']) ? 'right' : '';
		$output .= '<div style="float:left; width:' .$option['linkedin_width']. 'px;padding-right:10px; margin:4px 4px 4px 4px;height:30px;"><script type="in/share" data-url="' . $post_link . '" data-counter="' .$counter. '"></script></div>';
		}
		if ($option['active_buttons']['stumbleupon']==true) {
		$output .= '			
			<div style="float:left; width:' .$option['stumbleupon_width']. 'px;padding-right:10px; margin:4px 4px 4px 4px;height:30px;"><script src="http://www.stumbleupon.com/hostedbadge.php?s=1&amp;r='.$post_link.'"></script></div>';
		}
		if ($option['active_buttons']['buffer']==true) {
		$counter = ($option['buffer_count']) ? 'horizontal' : '';
		$output .= '<div style="float:left; width:' .$option['buffer_width']. 'px;padding-right:10px; margin:4px 4px 4px 4px;height:30px;"><a rel="nofollow" href="http://bufferapp.com/add" class="buffer-add-button" data-text="' . $post_title . '" data-url="' . $post_link . '" data-via="'. $option['twitter_id'] . '" data-count="' . $counter . '">Buffer</a></div>';
		}
		
		$output .= '			
			</div><div style="clear:both"></div><div style="padding-bottom:4px;"></div>';
			
		return $output;
	}
}

function sse_social_share_shortcode () {
	$output = rp_social_share('shortcode');
	echo $output;
}

function fb_like_thumbnails()
{
global $posts;
$default = '';
$content = $posts[0]->post_content; // $posts is an array, fetch the first element
$output = preg_match_all( '/<img.+src=[\'"]([^\'"]+)[\'"].*>/i', $content, $matches);
if ( $output > 0 ) {
$thumb = $matches[1][0];
echo "\n\n<!-- Thumbnail for facebook like -->\n<link rel=\"image_src\" href=\"$thumb\" />\n\n";
}
else
$thumb = $default;
}
?>