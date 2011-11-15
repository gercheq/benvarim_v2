<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<title><?php if (is_home() || is_front_page()) { echo bloginfo('name'); } else { echo wp_title(''); } ?></title>

<link rel="alternate" type="application/rss+xml" title="<?php bloginfo('name'); ?> RSS Feed" href="<?php echo (themify_check('setting-custom_feed_url')) ? themify_get('setting-custom_feed_url') : bloginfo('rss2_url'); ?>">

<?php if(!themify_check('setting-shortcode_css')){ ?>
	<link rel="stylesheet" href="<?php echo get_template_directory_uri(); ?>/themify/css/shortcodes.css" type="text/css" media="screen" />
<?php } ?>

<link rel="stylesheet" href="<?php bloginfo('stylesheet_url'); ?>" type="text/css" media="screen" />

<!-- jquery -->
<script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.5/jquery.min.js"></script>

<!-- media-queries.js -->
<!--[if lt IE 9]>
	<script src="http://css3-mediaqueries-js.googlecode.com/svn/trunk/css3-mediaqueries.js"></script>
<![endif]-->
<link rel="stylesheet" href="<?php echo get_template_directory_uri(); ?>/media-queries.css" type="text/css" media="screen" />

<!-- comment-reply js -->
<?php if ( is_single() || is_page() ) wp_enqueue_script( 'comment-reply' ); ?>

<!-- wp_header -->
<?php wp_head(); ?>

</head>

<body <?php body_class($class); ?>>
<div id="wrapper">
  <div id="header" class="pagewidth">
    <div class="container">
      <div id="header-logo">
        <a href="/">blog.benvarim.com</a>
      </div>
      <div id="partner-logo"></div>
      <div id="site-nav">
        <ul class="clearfix">
          <li><a href="http://benvarim.com" class="rc-top" id="nav-anasayfa">Nedir?</a></li>
          <li>
            <a href="http://benvarim.com/nasil_calisir" class="rc-top " id="nav-nasil">Nasıl Çalışır?</a>
          </li>
          <li><a href="http://blog.benvarim.com/" class="rc-top selected">Blog</a></li>
          <li>
            <a href="http://benvarim.com/hakkimizda" class="rc-top " id="nav-hakkimizda">Hakkımızda</a>
          </li>
          <li>
            <a href="http://benvarim.com/iletisim/yeni" class="rc-top " id="nav-iletisim">iletişim</a>
          </li>
        </ul>
      </div>

      <div id="utility-nav" class="rc-bottom">
        <div class="un-search">

          <form id="un-search-form" action="http://blog.benvarim.com/">
            <input type="text" class="rc ui-autocomplete-input" name="s" id="search_query" value="" placeholder="Blog içi arama..." autocomplete="off" role="textbox" aria-autocomplete="list" aria-haspopup="true">
          </form>

        </div>
        <div class="un-login-registration">
          	<a href="http://benvarim.com/gonullu/giris">Giriş</a> |	<a href="http://benvarim.com/users/sign_up">Kayıt</a>
        </div>
      </div>

    </div>
  </div>

  <div id="page-content" class="clearfix">
    <div class="container">




