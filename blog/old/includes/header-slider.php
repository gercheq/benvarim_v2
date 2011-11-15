<?php if(themify_check('setting-header_slider_enabled')){ ?>
	<div id="header-slider" class="slider">
			
		<ul class="slides clearfix">
    		<?php 
			if(themify_check('setting-header_slider_posts_category')){
				$cat = "&cat=".themify_get('setting-header_slider_posts_category');	
			} else {
				$cat = "";
			}
			if(themify_check('setting-header_slider_posts_slides')){
				$num_posts = "showposts=".themify_get('setting-header_slider_posts_slides')."&";
			} else {
				$num_posts = "showposts=5&";	
			}
			if(themify_check('setting-header_slider_display') && themify_get('setting-header_slider_display') == "images"){ 
        		
				$options = array("one","two","three","four","five","six","seven","eight","nine","ten");
				foreach($options as $option){
					if(themify_check('setting-header_slider_images_'.$option.'_image')){
						echo "<li>";
							if(themify_check('setting-header_slider_images_'.$option.'_link')){ 
								
								$title = (themify_check('setting-header_slider_images_'.$option.'_title')) ? '<h3 class="feature-post-title">'.themify_get('setting-header_slider_images_'.$option.'_title').'</h3>' : '';
								$link = themify_get('setting-header_slider_images_'.$option.'_link');
								$image = themify_get('setting-header_slider_images_'.$option.'_image');
								themify_image("src=".$image."&setting=header_slider&ignore=true&w=145&h=120&before=<a href='".urlencode($link)."' title='".urlencode($link)."'>&after=</a>&alt=".urlencode($link)."&class=feature-img");
								echo $title;
								
							} else {
								
								$image = themify_get('setting-header_slider_images_'.$option.'_image');
								themify_image("src=".$image."&setting=header_slider&ignore=true&w=145&h=120&alt=".$image."&class=feature-img");
								echo $title;

							}
						echo "</li>";
					}
				}
			} else { 
				
				query_posts($num_posts.$cat); 
				
				if( have_posts() ) {
					
					while ( have_posts() ) : the_post();
						?>                
                    	<li>
                       		<?php themify_image("field_name=feature_image, post_image, image, wp_thumb&before=<a href='".get_permalink()."'>&after=</a>&ignore=true&setting=header_slider&class=feature-img&w=145&h=120"); ?>
                        	<h3 class="feature-post-title"><a href="<?php the_permalink(); ?>"><?php the_title(); ?></a></h3>
                 		</li>
               			<?php 
					endwhile; 
				}
				
				wp_reset_query();
				
			} 
			?>
		</ul>

		<div class="slider-nav">
			<a href="#" class="prev-slide">Previous</a>
			<a href="#" class="next-slide">Next</a>
		</div>
	  
	</div>
	<!--/slider -->
<?php } ?>