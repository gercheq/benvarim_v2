<?php
/*
The main admin page for this plugin. The logic for different user input and form submittion is written here. 
*/

function rp_twitter_facebook_admin_menu() {
add_options_page('Social Share Elite', 'Social Share Elite', 'administrator',
'rp-social-share', 'rp_twitter_facebook_admin_page');
}

function rp_twitter_facebook_admin_page() {

	$option_name = 'twitter_facebook_share';
if (!current_user_can('manage_options'))  {
		wp_die( __('You do not have sufficient permissions to access this page.') );
	}

$active_buttons = array(
		'facebook_like'=>'Facebook like',
		'twitter'=>'Twitter',
		'stumbleupon'=>'Stumbleupon',
		'Google_plusone'=>'Google PlusOne',
		'linkedin'=>'LinkedIn',
		'buffer'=>'Buffer'
	);	

$show_in = array(
		'posts'=>'Single posts',
		'pages'=>'Pages',
		'home_page'=>'Home page',
		'tags'=>'Tags',
		'categories'=>'Categories',
		'authors'=>'Author archives',
		'search'=>'Search results',
		'date_arch'=>'Archives'
	);
	
	$out = '';
	
	if( isset($_POST['twitter_facebook_share_position'])) {
		$option = array();
		
		$option['auto'] = (isset($_POST['twitter_facebook_share_auto_display']) and $_POST['twitter_facebook_share_auto_display']=='on') ? true : false;

		foreach (array_keys($active_buttons) as $item) {
			$option['active_buttons'][$item] = (isset($_POST['twitter_facebook_share_active_'.$item]) and $_POST['twitter_facebook_share_active_'.$item]=='on') ? true : false;
		}	
		foreach (array_keys($show_in) as $item) {
			$option['show_in'][$item] = (isset($_POST['twitter_facebook_share_show_'.$item]) and $_POST['twitter_facebook_share_show_'.$item]=='on') ? true : false;
		}
		$option['position'] = esc_html($_POST['twitter_facebook_share_position']);
		$option['border'] = esc_html($_POST['twitter_facebook_share_border']);
		
		$option['bkcolor'] = (isset($_POST['twitter_facebook_share_background_color']) and $_POST['twitter_facebook_share_background_color']=='on') ? true : false;
		
		$option['bkcolor_value'] = esc_html($_POST['twitter_facebook_share_bkcolor_value']);
		$option['jsload'] = (isset($_POST['twitter_facebook_share_javascript_load']) and $_POST['twitter_facebook_share_javascript_load']=='on') ? true : false;

		$option['twitter_id'] = esc_html($_POST['twitter_facebook_share_twitter_id']);		
		$option['left_space'] = esc_html($_POST['twitter_facebook_share_left_space']);
		$option['bottom_space'] = esc_html($_POST['twitter_facebook_share_bottom_space']);
		$option['float_position'] = esc_html($_POST['twitter_facebook_share_float_position']);
		$option['twitter_count'] = (isset($_POST['twitter_facebook_share_twitter_count']) and $_POST['twitter_facebook_share_twitter_count']=='on') ? true : false;
		$option['buffer_count'] = (isset($_POST['twitter_facebook_share_buffer_count']) and $_POST['twitter_facebook_share_buffer_count']=='on') ? true : false;
		$option['google_count'] = (isset($_POST['twitter_facebook_share_google_count']) and $_POST['twitter_facebook_share_google_count']=='on') ? true : false;
		$option['linkedin_count'] = (isset($_POST['twitter_facebook_share_linkedin_count']) and $_POST['twitter_facebook_share_linkedin_count']=='on') ? true : false;
		$option['google_width'] = esc_html($_POST['twitter_facebook_share_google_width']);
		$option['facebook_like_width'] = esc_html($_POST['twitter_facebook_share_facebook_like_width']);
		$option['twitter_width'] = esc_html($_POST['twitter_facebook_share_twitter_width']);
		$option['linkedin_width'] = esc_html($_POST['twitter_facebook_share_linkedin_width']);
		$option['buffer_width'] = esc_html($_POST['twitter_facebook_share_buffer_width']);
		$option['stumbleupon_width'] = esc_html($_POST['twitter_facebook_share_stumbleupon_width']);
		update_option($option_name, $option);
		// Put a settings updated message on the screen
		$out .= '<div class="updated"><p><strong>'.__('Settings saved.', 'menu-test' ).'</strong></p></div>';
	}
	
	//GET ARRAY OF STORED VALUES
	$option = twitter_facebook_share_get_options_stored();
	
	$sel_above = ($option['position']=='above') ? 'selected="selected"' : '';
	$sel_below = ($option['position']=='below') ? 'selected="selected"' : '';
	$sel_both  = ($option['position']=='both' ) ? 'selected="selected"' : '';
	$sel_left  = ($option['position']=='left' ) ? 'selected="selected"' : '';
	
	$sel_flat = ($option['border']=='flat') ? 'selected="selected"' : '';
	$sel_round = ($option['border']=='round') ? 'selected="selected"' : '';
	$sel_none  = ($option['border']=='none' ) ? 'selected="selected"' : '';
	
	$sel_fixed = ($option['float_position']=='fixed') ? 'selected="selected"' : '';
	$sel_absolute = ($option['float_position']=='absolute') ? 'selected="selected"' : '';
	
	$bkcolor = ($option['bkcolor']) ? 'checked="checked"' : '';
	$jsload =  ($option['jsload']) ? 'checked="checked"' : '';
	$auto =    ($option['auto']) ? 'checked="checked"' : '';
	$google_count = ($option['google_count']) ? 'checked="checked"' : '';
	$twitter_count = ($option['twitter_count']) ? 'checked="checked"' : '';
	$buffer_count = ($option['buffer_count']) ? 'checked="checked"' : '';
	$linkedin_count = ($option['linkedin_count']) ? 'checked="checked"' : '';
	
	$out .= '
	<div class="wrap">

	<h2>'.__( 'Facebook and Twitter share buttons', 'menu-test' ).'</h2>
	<div id="poststuff" style="padding-top:10px; position:relative;">
		<div style="float:left; width:74%; padding-right:1%;">
	<form name="form1" method="post" action="">
	<div class="postbox">
	<h3>'.__("General options", 'menu-test' ).'</h3>
	<div class="inside">
	<table>
	<tr><td style="padding-bottom:20px;" valign="top">'.__("Auto Display", 'menu-test' ).':</td>
	<td style="padding-bottom:20px;">
		<input type="checkbox" name="twitter_facebook_share_auto_display" '.$auto.' />
		<span class="description">'.__("Enable Auto display of Social Share buttons at specified postion", 'menu-test' ).'</span>
	</td></tr>
	
	<tr><td style="padding-bottom:20px;" valign="top">'.__("Code for Manual Display", 'menu-test' ).':</td>
	<td style="padding-bottom:20px;">
	<code>&lt;?php if(function_exists(&#39;rp_add_social_share&#39;)) rp_add_social_share(); ?&gt;</code>
	</td></tr>

	<tr><td valign="top" style="width:130px;">'.__("Active share buttons", 'menu-test' ).':</td>
	<td style="padding-bottom:30px;">';
	
	foreach ($active_buttons as $name => $text) {
		$checked = ($option['active_buttons'][$name]) ? 'checked="checked"' : '';
		$out .= '<div style="width:150px; float:left;">
				<input type="checkbox" name="twitter_facebook_share_active_'.$name.'" '.$checked.' /> '
				. __($text, 'menu-test' ).' &nbsp;&nbsp;</div>';

	}
	
	
	$out .= '</td></tr>
			<tr><td valign="top" style="width:130px;">'.__("Show buttons in these pages", 'menu-test' ).':</td>
			<td style="padding-bottom:20px;">';

			foreach ($show_in as $name => $text) {
				$checked = ($option['show_in'][$name]) ? 'checked="checked"' : '';
				$out .= '<div style="width:150px; float:left;">
						<input type="checkbox" name="twitter_facebook_share_show_'.$name.'" '.$checked.' /> '
						. __($text, 'menu-test' ).' &nbsp;&nbsp;</div>';
			}

	$out .= '</td></tr>';
	$out .= '<tr><td style="padding-bottom:20px;" valign="top">'.__("Note", 'menu-test' ).':</td>
	<td style="padding-bottom:20px;">
	<span class="description">'.__("Left Floating is available only for single post and Static pages. By Default the bar will be displayed above the post.", 'menu-test' ).'</span>';
	$out .= '</td></tr>	
	<tr><td style="padding-bottom:20px;" valign="top">'.__("Position", 'menu-test' ).':</td>
	<td style="padding-bottom:20px;"><select name="twitter_facebook_share_position">
		<option value="above" '.$sel_above.' > '.__('Above the post', 'menu-test' ).'</option>
		<option value="below" '.$sel_below.' > '.__('Below the post', 'menu-test' ).'</option>
		<option value="both"  '.$sel_both.'  > '.__('Above and Below the post', 'menu-test' ).'</option>
		<option value="left"  '.$sel_left.'  > '.__('Left Side of the post', 'menu-test' ).'</option>
		</select>
	</td></tr>
	
	<tr><td style="padding-bottom:20px;" valign="top">'.__("Border Style", 'menu-test' ).':</td>
	<td style="padding-bottom:20px;"><select name="twitter_facebook_share_border">
		<option value="flat"  '.$sel_flat.' > '.__('Flat Border', 'menu-test' ).'</option>
		<option value="round" '.$sel_round.' > '.__('Round Border', 'menu-test' ).'</option>
		<option value="none"  '.$sel_none.'  > '.__('No Border', 'menu-test' ).'</option>
		</select>
	</td></tr>
	
	<tr><td style="padding-bottom:20px;" valign="top">'.__("Show Background Color", 'menu-test' ).':</td>
	<td style="padding-bottom:20px;">
		<input type="checkbox" name="twitter_facebook_share_background_color" '.$bkcolor.' />
	</td></tr>
	
	<tr><td style="padding-bottom:20px;" valign="top">'.__("Background Color", 'menu-test' ).':</td>
	<td style="padding-bottom:20px;">
	<input type="text" name="twitter_facebook_share_bkcolor_value" value="'.$option['bkcolor_value'].'" size="10">  
		 <span class="description">'.__("Default Color wont disappoint you", 'menu-test' ).'</span>
	</td></tr> 
	
	<tr><td style="padding-bottom:20px;" valign="top">'.__("Load Javascript in Footer", 'menu-test' ).':</td>
	<td style="padding-bottom:20px;">
		<input type="checkbox" name="twitter_facebook_share_javascript_load" '.$jsload.' />
		<span class="description">'.__("(Recommended, else loaded in header)", 'menu-test' ).'</span>
	</td></tr>
	<tr><td style="padding-bottom:20px;" valign="top">'.__("Your Twitter ID", 'menu-test' ).':</td>
	<td style="padding-bottom:20px;">
	<input type="text" name="twitter_facebook_share_twitter_id" value="'.$option['twitter_id'].'" size="30">  
		 <span class="description">'.__("Specify your twitter id without @", 'menu-test' ).'</span>
	</td></tr> 
	</table>
	</div>
	</div>
	
	<div class="postbox">
	<h3>'.__("Left Side Floating Specific Options", 'menu-test' ).'</h3>
	<div class="inside">
	<table>
		
	<tr><td style="padding-bottom:20px;" valign="top">'.__("Left Side Spacing", 'menu-test' ).':</td>
	<td style="padding-bottom:20px;">
	<input type="text" name="twitter_facebook_share_left_space" value="'.$option['left_space'].'" size="10">  
		 <span class="description">'.__("Spacing from Left Side of Margin", 'menu-test' ).'</span>
	</td></tr> 
	
	<tr><td style="padding-bottom:20px;" valign="top">'.__("Top Spacing", 'menu-test' ).':</td>
	<td style="padding-bottom:20px;">
	<input type="text" name="twitter_facebook_share_bottom_space" value="'.$option['bottom_space'].'" size="10">  
		 <span class="description">'.__("Spacing from Top of the page", 'menu-test' ).'</span>
	</td></tr> 
	
	<tr><td style="padding-bottom:20px;" valign="top">'.__("Float Bar Position", 'menu-test' ).':</td>
	<td style="padding-bottom:20px;"><select name="twitter_facebook_share_float_position">
		<option value="fixed" '.$sel_fixed.' > '.__('Fixed Position', 'menu-test' ).'</option>
		<option value="absolute" '.$sel_absolute.' > '.__('Absolute Position', 'menu-test' ).'</option>
		</select>
	</td></tr>
	</table>
	</div>
	</div>
	
	<div class="postbox">
	<h3>'.__("Adjust Width and Count Display", 'menu-test' ).'</h3>
	<div class="inside">
		<table>
		<tr><td style="padding-bottom:20px; padding-right:10px;" valign="top">'.__("Facebook Button width", 'menu-test' ).':</td>
			<td style="padding-bottom:20px;">
				<input type="text" name="twitter_facebook_share_facebook_like_width" value="'.stripslashes($option['facebook_like_width']).'" size="5">px<br />
			</td>
			<td style="padding-bottom:20px; padding-left:50px; padding-right:10px;" valign="top">'.__("Google +1 Button width", 'menu-test' ).':</td>
			<td style="padding-bottom:20px;">
				<input type="text" name="twitter_facebook_share_google_width" value="'.stripslashes($option['google_width']).'" size="5">px<br />
			</td>
			<td style="padding-bottom:20px; padding-right:10px;" valign="top">'.__("Stumbleupon Button width", 'menu-test' ).':</td>
			<td style="padding-bottom:20px;">
				<input type="text" name="twitter_facebook_share_stumbleupon_width" value="'.stripslashes($option['stumbleupon_width']).'" size="10"> px <br />
			</td>	
		</tr>
		<tr><td style="padding-bottom:20px; padding-right:10px;" valign="top">'.__("Twitter Button width", 'menu-test' ).':</td>
			<td style="padding-bottom:20px;">
				<input type="text" name="twitter_facebook_share_twitter_width" value="'.stripslashes($option['twitter_width']).'" size="5"> px <br />
			</td>
			<td style="padding-bottom:20px; padding-left:50px; padding-right:10px;" valign="top">'.__("Linkedin Button width", 'menu-test' ).':</td>
			<td style="padding-bottom:20px;">
				<input type="text" name="twitter_facebook_share_linkedin_width" value="'.stripslashes($option['linkedin_width']).'" size="5"> px <br />
			</td>	
			<td style="padding-bottom:20px; padding-left:50px; padding-right:10px;" valign="top">'.__("Buffer Button width", 'menu-test' ).':</td>
			<td style="padding-bottom:20px;">
				<input type="text" name="twitter_facebook_share_buffer_width" value="'.stripslashes($option['buffer_width']).'" size="5"> px <br />
			</td>	
		</tr>
		<tr><td style="padding-bottom:20px; padding-right:10px;" valign="top">'.__("Google +1 counter", 'menu-test' ).':</td>
			<td style="padding-bottom:20px;">
				<input type="checkbox" name="twitter_facebook_share_google_count" '.$google_count.' />
			</td>
			<td style="padding-bottom:20px; padding-right:10px;" valign="top">'.__("LinkedIn counter", 'menu-test' ).':</td>
			<td style="padding-bottom:20px;">
				<input type="checkbox" name="twitter_facebook_share_linkedin_count" '.$linkedin_count.' />
			</td>	
		</tr>
		<tr><td style="padding-bottom:20px; padding-right:10px;" valign="top">'.__("Twitter counter", 'menu-test' ).':</td>
			<td style="padding-bottom:20px;">
				<input type="checkbox" name="twitter_facebook_share_twitter_count" '.$twitter_count.' />
			</td>
			<td style="padding-bottom:20px; padding-right:10px;" valign="top">'.__("Buffer counter", 'menu-test' ).':</td>
			<td style="padding-bottom:20px;">
				<input type="checkbox" name="twitter_facebook_share_buffer_count" '.$buffer_count.' />
			</td>	
		</tr>
		</table>
	</div>
	</div>
	
	<tr><td valign="top" colspan="2">
	<p class="submit">
		<input type="submit" name="Submit" class="button-primary" value="'.esc_attr('Save Changes').'" />
	</p>
	</td></tr>
	</form>
	</div>
	
	<div style="float:right; width:25%;">
	<div class="postbox">
	<h3>'.__("Support The Author", 'menu-test' ).'</h3>
	<div class="inside">
	<table>
	<tr><td  align="justify">
	<p >If you liked the plugin and was useful to your site then please support to keep this project up and running. Maintenance and enhancement do cost. Show your appreciation and love.</p> </td></tr>
	<tr>
	<td align="center">
	<form action="https://www.paypal.com/cgi-bin/webscr" method="post">
	<input type="hidden" name="cmd" value="_s-xclick">
	<input type="hidden" name="hosted_button_id" value="MRTE2A5M7JKUG">
	<table>
	<tr><td><input type="hidden" name="on0" value="Help The Developer">Help The Developer</td></tr><tr><td><select name="os0">
		<option value="Donate">Donate $5.00</option>
		<option value="Donate">Donate $10.00</option>
		<option value="Donate">Donate $15.00</option>
	</select> </td></tr>
	</table>
	<input type="hidden" name="currency_code" value="USD">
	<input type="image" src="https://www.paypalobjects.com/en_GB/i/btn/btn_paynowCC_LG.gif" border="0" name="submit" alt="PayPal - The safer, easier way to pay online.">
	<img alt="" border="0" src="https://www.paypalobjects.com/en_GB/i/scr/pixel.gif" width="1" height="1">
	</form>	</td>
	</tr>
	</table>
	</div>
	</div>
	<div class="postbox">
	<h3>'.__("Additional Info", 'menu-test' ).'</h3>
	<div class="inside">
	<table>
	<tr><td  align="justify">
	<ul>
	<li>Shortcode <strong>[sse_social_share]</strong> to add the social share bar to specific pages.</li> 
	<li>Custom field "<strong>disable_social_share</strong>" with value "yes" to exclude specific post or pages.</li>
	</td></tr>
	</tr>
	</table>
	</div>
	</div>

	</div>
	';
	echo $out; 
}


// PRIVATE FUNCTIONS

function twitter_facebook_share_get_options_stored () {
	//GET ARRAY OF STORED VALUES
	$option = get_option('twitter_facebook_share');
	 
	if ($option===false) {
		//OPTION NOT IN DATABASE, SO WE INSERT DEFAULT VALUES
		$option = twitter_facebook_share_get_options_default();
		add_option('twitter_facebook_share', $option);
	} else if ($option=='above' or $option=='below') {
		// Versions below 1.2.0 compatibility
		$option = twitter_facebook_share_get_options_default($option);
	} else if(!is_array($option)) {
		// Versions below 1.2.2 compatibility
		$option = json_decode($option, true);
	}
	
	// Versions below 1.5.1 compatibility
	if (!isset($option['bkcolor'])) {
		$option['bkcolor'] = true;
	}
	
	if (!isset($option['auto'])) {
		$option['auto'] = true;
	}
	// Versions below 1.4.1 compatibility
	if (!isset($option['bkcolor_value'])) {
		$option['bkcolor_value'] = '#F0F4F9';
	}
	if (!isset($option['left_space'])) {
		$option['left_space'] = '60px';
	}
	if (!isset($option['bottom_space'])) {
		$option['bottom_space'] = '20%';
	}
	
	if (!isset($option['jsload'])) {
		$option['jsload'] = true;
	}
	
	if (!isset($option['facebook_like_width'])) {
		$option['facebook_like_width'] = '45';
	}
	if (!isset($option['twitter_width'])) {
		$option['twitter_width'] = '91';
	}
	if (!isset($option['google_width'])) {
		$option['google_width'] = '54';
	}
	if (!isset($option['linkedin_width'])) {
		$option['linkedin_width'] = '55';
	}
	if (!isset($option['buffer_width'])) {
		$option['buffer_width'] = '70';
	}
	if (!isset($option['stumbleupon_width'])) {
		$option['stumbleupon_width'] = '70';
	}
	if (!isset($option['twitter_count'])) {
		$option['twitter_count'] = true;
	}
	if (!isset($option['buffer_count'])) {
		$option['buffer_count'] = true;
	}
	if (!isset($option['linkedin_count'])) {
		$option['linkedin_count'] = true;
	}
	if (!isset($option['google_count'])) {
		$option['google_count'] = true;
	}	
	return $option;
}

function twitter_facebook_share_get_options_default ($position='above', $border='flat', $color='#F0F4F9',$left_space='60px',$bottom_space='40%', $float_position='fixed') {
	$option = array();
	$option['auto'] = true;
	$option['active_buttons'] = array('facebook_like'=>true, 'twitter'=>true, 'stumbleupon'=>true, 'Google_plusone'=>true, 'linkedin'=>true, 'buffer'=>true);
	$option['show_in'] = array('posts'=>true, 'pages'=>true, 'home_page'=>true, 'tags'=>true, 'categories'=>true,  'authors'=>true, 'search'=>true,'date_arch'=>true);
	$option['position'] = $position;
	$option['border'] = $border;
	$option['bkcolor'] = true;
	$option['bkcolor_value'] = $color;
	$option['jsload'] = true;
	$option['left_space'] = $left_space;
	$option['bottom_space'] = $bottom_space;
	$option['float_position'] = $float_position;
	$option['facebook_like_width'] = '45';
	$option['twitter_width'] = '91';
	$option['buffer_width'] = '70';
	$option['linkedin_width'] = '55';
	$option['stumbleupon_width'] = '70';
	$option['google_width'] = '54';
	$option['google_count'] = true;
	$option['twitter_count'] = true;
	$option['buffer_count'] = true;
	$option['linkedin_count'] = true;
	return $option;
}
?>