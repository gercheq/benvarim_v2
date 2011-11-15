<?php
get_header();
?>

<!-- Begin #colLeft -->
		<div id="colLeft">
		<?php if (have_posts()) : while (have_posts()) : the_post(); ?>
		<div class="postItem">
				<h1><a href="<?php the_permalink() ?>"><?php the_title(); ?></a></h1> 
				<div class="meta">
							<?php the_time('M j, Y') ?> &nbsp;&nbsp;//&nbsp;&nbsp; Yazar: <span class="author"><?php the_author_link(); ?></span> &nbsp;&nbsp;//&nbsp;&nbsp;  <?php the_category(', ') ?>  &nbsp;//&nbsp;  <?php comments_popup_link('Yorum Yapılmadı', '1 Yorum ', '% Yorum'); ?> 
						</div>
				<?php the_content(__('devamını oku')); ?> 
				
                    <div class="postTags"><?php the_tags(); ?></div>
							
							<div id="shareLinks">
								<a href="#" class="share">[+] Paylaş &amp; Ekle</a>
								<span id="icons">
									<a href="http://twitter.com/home/?status=<?php the_title(); ?> : <?php the_permalink(); ?>" title="Tweetle!">
									<!--<img src="<?php bloginfo('template_directory'); ?>/images/twitter.png" alt="Tweet this!" />-->&#8226; Twitter</a>				
									<a href="http://www.stumbleupon.com/submit?url=<?php the_permalink(); ?>&amp;amp;title=<?php the_title(); ?>" title="StumbleUpon.">
									<!--<img src="<?php bloginfo('template_directory'); ?>/images/stumbleupon.png" alt="StumbleUpon" />-->&#8226; StumbleUpon</a>
									<a href="http://digg.com/submit?phase=2&amp;amp;url=<?php the_permalink(); ?>&amp;amp;title=<?php the_title(); ?>" title="Digg'e ekle!">
									<!--<img src="<?php bloginfo('template_directory'); ?>/images/digg.png" alt="Digg This!" />-->&#8226; Digg</a>				
									<a href="http://del.icio.us/post?url=<?php the_permalink(); ?>&amp;amp;title=<?php the_title(); ?>" title="Delicious'a ekle.">
									<!--<img src="<?php bloginfo('template_directory'); ?>/images/delicious.png" alt="Bookmark on Delicious" />-->&#8226; Delicious</a>
									<a href="http://www.facebook.com/sharer.php?u=<?php the_permalink();?>&amp;amp;t=<?php the_title(); ?>" title="Facebook'ta paylaş.">
									<!--<img src="<?php bloginfo('template_directory'); ?>/images/facebook.png" alt="Share on Facebook" id="sharethis-last" />-->&#8226; Facebook</a>
								</span>
							</div>
		
		
        <?php comments_template(); ?>
			</div>
		<?php endwhile; else: ?>

		<p>Üzgünüm, fakat erişmeye çalıştığınız makale burada değil.</p>

	<?php endif; ?>
		
			</div>
		<!-- End #colLeft -->

<?php get_sidebar(); ?>	

<?php get_footer(); ?>
