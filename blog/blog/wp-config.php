<?php
/**
 * The base configurations of the WordPress.
 *
 * This file has the following configurations: MySQL settings, Table Prefix,
 * Secret Keys, WordPress Language, and ABSPATH. You can find more information
 * by visiting {@link http://codex.wordpress.org/Editing_wp-config.php Editing
 * wp-config.php} Codex page. You can get the MySQL settings from your web host.
 *
 * This file is used by the wp-config.php creation script during the
 * installation. You don't have to use the web site, you can just copy this file
 * to "wp-config.php" and fill in the values.
 *
 * @package WordPress
 */

// ** MySQL settings - You can get this info from your web host ** //
/** The name of the database for WordPress */
define('DB_NAME', 'benvarimblog');

/** MySQL database username */
define('DB_USER', 'benvarimblog');

/** MySQL database password */
define('DB_PASSWORD', 'YigitGercek@21');

/** MySQL hostname */
define('DB_HOST', 'benvarimblog.db.3490720.hostedresource.com');

/** Database Charset to use in creating database tables. */
define('DB_CHARSET', 'utf8');

/** The Database Collate type. Don't change this if in doubt. */
define('DB_COLLATE', '');

/**#@+
 * Authentication Unique Keys and Salts.
 *
 * Change these to different unique phrases!
 * You can generate these using the {@link https://api.wordpress.org/secret-key/1.1/salt/ WordPress.org secret-key service}
 * You can change these at any point in time to invalidate all existing cookies. This will force all users to have to log in again.
 *
 * @since 2.6.0
 */
define('AUTH_KEY',         '=ks+n_r!pq[s(wTpL3:DfgSw/f;[-+;QH^Vl0k{|k5 e9%4T?<[/RRhtY.]9<] ?');
define('SECURE_AUTH_KEY',  '1Qj<S-gagOLon7*qS-[ni->+vq;s{}G.--L[_;q8#lSm7M@rGXQT |+L|)c7~)W+');
define('LOGGED_IN_KEY',    '@+OwWT9l-sjA3l$pqUce,Bg2gb7ShOV=z3D2#(fUwPQzN Cd:^M Yqjf2Q&s<1jn');
define('NONCE_KEY',        'F0j0XjddCc4N>lMeqpgsXgc)CKoSYp(_u~n6r.^69XuJnYY+Iul9k~El7(J=P1<v');
define('AUTH_SALT',        '%F`-MlU+4uv6W VU[6/UHnuA0|no#M%Vgv8c3fq;ybq={q$p)Wv6|+M|~&%0_f>f');
define('SECURE_AUTH_SALT', 'B,K#J3,?+7FSjohES@,>O0J-u`O-TGt9)z4t%/#&|W|dr-9gA?bQ)?&`27hQF]R+');
define('LOGGED_IN_SALT',   'c+!oad|N6L||Db6`w$-#:-}d95I.^W!VbXV12V^xu>=H+?`?D3M=Ton:4Z+n%04J');
define('NONCE_SALT',       'Ev#[}w]DX|JrE^^4@6|G{Rsh`><g-;?+l<JslC/~kRZmZ]F;uY4te_mH`9NS_q#3');

/**#@-*/

/**
 * WordPress Database Table prefix.
 *
 * You can have multiple installations in one database if you give each a unique
 * prefix. Only numbers, letters, and underscores please!
 */
$table_prefix  = 'wp_';

/**
 * WordPress Localized Language, defaults to English.
 *
 * Change this to localize WordPress. A corresponding MO file for the chosen
 * language must be installed to wp-content/languages. For example, install
 * de_DE.mo to wp-content/languages and set WPLANG to 'de_DE' to enable German
 * language support.
 */
define('WPLANG', '');

/**
 * For developers: WordPress debugging mode.
 *
 * Change this to true to enable the display of notices during development.
 * It is strongly recommended that plugin and theme developers use WP_DEBUG
 * in their development environments.
 */
define('WP_DEBUG', false);

/* That's all, stop editing! Happy blogging. */

/** Absolute path to the WordPress directory. */
if ( !defined('ABSPATH') )
	define('ABSPATH', dirname(__FILE__) . '/');

/** Sets up WordPress vars and included files. */
require_once(ABSPATH . 'wp-settings.php');
