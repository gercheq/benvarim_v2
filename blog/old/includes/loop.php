<?php if(!is_single()) : global $more; $more = 0; endif; //enable more link ?>

<?php global $post_query_category, $post_layout, $display_content, $hide_title, $unlink_title, $unlink_image, $hide_meta, $hide_date, $hide_image, $image_width, $image_height, $height, $width; ?>
	
<div id="post-<?php the_ID(); ?>" <?php post_class('clearfix'); ?>>
	
	<?php $link = themify_get('external_link'); ?>
	<?php if ($link == ''): ?>
		<?php $link = get_permalink(); ?>
	<?php endif; ?>
	
	<?php if(is_single()): ?>
		<?php if($hide_image != "yes"): ?>
			<?php if($unlink_image == "yes"):  ?>
				<?php themify_image("field_name=post_image, image, wp_thumb&setting=image_post_single&w=".$width."&h=".$height."&before=<p class='post-image ".themify_get('setting-image_post_single_align')."'>&after=</p>"); ?>
			<?php else: ?>
				<?php themify_image("field_name=post_image, image, wp_thumb&setting=image_post_single&w=".$width."&h=".$height."&before=<p class='post-image ".themify_get('setting-image_post_single_align')."'><a href='".urlencode($link)."'>&after=</a></p>"); ?>
			<?php endif; ?>   
		<?php endif; ?>
	<?php elseif($post_query_category != ""): ?>
		<?php if($hide_image != "yes"): ?>
			<?php if($unlink_image == "yes"):  ?>
				<?php themify_image("field_name=post_image, image, wp_thumb&w=".$width."&h=".$height."&before=<p class='post-image'>&after=</p>"); ?>
			<?php else: ?>
				<?php themify_image("field_name=post_image, image, wp_thumb&w=".$width."&h=".$height."&before=<p class='post-image'><a href='".urlencode($link)."'>&after=</a></p>"); ?>
			<?php endif; ?>   
		<?php endif; ?>
	<?php else: ?>
		<?php if($hide_image != "yes"): ?>
			<?php if($unlink_image == "yes"):  ?>
				<?php themify_image("field_name=post_image, image, wp_thumb&setting=image_post&w=".$width."&h=".$height."&before=<p class='post-image ".themify_get('setting-image_post_align')."'>&after=</p>"); ?>
			<?php else: ?>
				<?php themify_image("field_name=post_image, image, wp_thumb&setting=image_post&w=".$width."&h=".$height."&before=<p class='post-image ".themify_get('setting-image_post_align')."'><a href='".urlencode($link)."'>&after=</a></p>"); ?>
			<?php endif; ?>   
		<?php endif; ?>
	<?php endif; ?>

	<div class="post-content">
		<?php if($hide_date != "yes"): ?>
			<p class="post-date">
				<span class="month"><?php the_time('M') ?></span>
				<span class="day"><?php the_time('j') ?></span>
				<span class="year"><?php the_time('Y') ?></span>
			</p>
		<?php endif; ?>
	
		<?php if($hide_title != "yes"): ?>

			<?php if(is_single()): ?>
				<?php if($unlink_title == "yes"): ?>
					<h1 class="post-title"><?php the_title(); ?></h1>
				<?php else: ?>
					<h1 class="post-title"><a href="<?php the_permalink(); ?>"><?php the_title(); ?></a></h1>
				<?php endif; //unlink post title ?> 
			<?php else: ?>
				<?php if($unlink_title == "yes"): ?>
					<h2 class="post-title"><?php the_title(); ?></h2>
				<?php else: ?>
					<h2 class="post-title"><a href="<?php the_permalink() ?>" title="<?php the_title_attribute(); ?>"><?php the_title(); ?></a></h2>
				<?php endif; //unlink post title ?> 
			<?php endif; ?>

		<?php endif; ?>    
		
		<?php if($display_content == 'excerpt'): ?>
			<?php the_excerpt(); ?>
		<?php elseif($display_content == 'none'): ?>
		<?php else: ?>
			<?php the_content(__((themify_check('setting-default_more_text')) ? themify_get('setting-default_more_text') : 'More &rarr;','themify')); ?>
		<?php endif; ?>
	
		<?php if($hide_meta != 'yes'): ?>
			<p class="post-meta"> 
				<span class="post-author"><?php _e( 'By', 'themify' ); ?> <?php the_author() ?>  &bull;</span>
				<span class="post-category"><?php the_category(', ') ?>  &bull;</span>
				<?php if(comments_open()) : ?>
					<span class="post-comment"><?php comments_popup_link('0', '1', '%'); ?></span>
				<?php endif; //post comment ?>
				<?php the_tags(__(' <span class="post-tag">&bull; Tags: ','themify'), ', ', '</span>'); ?>
			</p>
		<?php endif; ?>    

		<?php edit_post_link('Edit', '[', ']'); ?>

	</div>
	<!-- /.post-content -->		
	
</div>
<!--/post -->