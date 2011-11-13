<?php
/*
Plugin Name: Social Share Elite
Description: Get the most advanced solution for social media integration for your business blog and make the most of your online presence.
Author: Rohan Pawale
Author URI: http://techlunatic.com
Plugin URI: http://techlunatic.com/2011/08/social-share-elite-wordpress-plugin/
Version: 1.0.0
License: GPL
*/
/*
    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License version 2, 
    as published by the Free Software Foundation.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.
*/

require_once('sse_admin_page.php');
require_once('sse_display.php');


if (!function_exists('is_admin')) 
{
header('Status: 403 Forbidden');
header('HTTP/1.1 403 Forbidden');
exit();
}

/* Runs when plugin is activated */
register_activation_hook(__FILE__,'rp_twitter_facebook_install'); 

/* Runs on plugin deactivation*/
register_deactivation_hook( __FILE__, 'rp_twitter_facebook_remove' );

function rp_twitter_facebook_install() 
{
/* Do Nothing */
}

function rp_twitter_facebook_remove() {
/* Deletes the database field */
delete_option('twitter_facebook_share');
}

if(is_admin())
{
add_action('admin_menu', 'rp_twitter_facebook_admin_menu');
}
else
{
 add_action('init', 'twitter_facebook_share_init');
 add_shortcode('sse_social_share', 'sse_social_share_shortcode' );
 add_action('wp_head', 'fb_like_thumbnails');
 $option = twitter_facebook_share_get_options_stored();
 if($option['auto'] == true)
 {
  add_filter('the_content', 'rp_twitter_facebook_contents');
  add_filter('the_excerpt', 'rp_twitter_facebook_excerpt');
 } 
}
?>