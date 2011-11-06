<?php if(function_exists('themify_pagenav')){ ?>
	<?php themify_pagenav(); ?> 
<?php } else { ?>
	<div class="post-nav">
		<span class="prev"><?php next_posts_link(__('&laquo; Older Entries', 'themify')) ?></span>
		<span class="next"><?php previous_posts_link(__('Newer Entries &raquo;', 'themify')) ?></span>
	</div>
<?php } ?>