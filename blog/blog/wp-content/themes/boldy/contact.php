<?php
/*
Template Name: Contact
*/
?>

<?php get_header(); ?>
 <script type="text/javascript">
		 $(document).ready(function(){
			  $('#contact').ajaxForm(function(data) {
				 if (data==1){
					 $('#success').fadeIn("slow");
					 $('#bademail').fadeOut("slow");
					 $('#badserver').fadeOut("slow");
					 $('#contact').resetForm();
					 }
				 else if (data==2){
						 $('#badserver').fadeIn("slow");
					  }
				 else if (data==3)
					{
					 $('#bademail').fadeIn("slow");
					}
					});
				 });
		</script>
<!-- begin colLeft -->
	<div id="colLeft">

			<h1>İletişim</h1>
			<p><?php echo stripslashes(stripslashes(get_option('boldy_contact_text')))?></p>
			
			<p id="success" class="successmsg" style="display:none;">E-postanız gönderildi! Teşekkür ederiz!</p>

			<p id="bademail" class="errormsg" style="display:none;">Lütfen isminizi, mesajınızı ve geçerli bir e-posta adresinizi girin.</p>
			<p id="badserver" class="errormsg" style="display:none;">E-postanız gönderilemedi. Daha sonra tekrar deneyin.</p>

			<form id="contact" action="<?php bloginfo('template_url'); ?>/sendmail.php" method="post">
			<label for="name">İsminiz: *</label>
				<input type="text" id="nameinput" name="name" value=""/>
			<label for="email">E-postanız: *</label>

				<input type="text" id="emailinput" name="email" value=""/>
			<label for="comment">Mesajınız: *</label>
				<textarea cols="20" rows="7" id="commentinput" name="comment"></textarea><br />
			<input type="submit" id="submitinput" name="submit" class="submit" value="MESAJI GÖNDER"/>
			<input type="hidden" id="receiver" name="receiver" value="<?php echo get_option('boldy_contact_email')?>"/>
			</form>
			
	</div>
	<!-- end colleft -->

			<?php get_sidebar(); ?>	

<?php get_footer(); ?>


