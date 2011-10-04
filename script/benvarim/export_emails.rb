emails = Array.new
emails += User.find(:all, :select => "email").collect do |x| x.email end
emails += Organization.find(:all, :select => "contact_email").collect do |x| x.contact_email end
emails += TmpPayment.find(:all, :select => "email").collect do |x| x.email end
emails += ContactForm.find(:all, :select => "email").collect do |x| x.email end
emails += Bvlog.where("content like '%payer_email%'").select("SUBSTRING(content FROM 'payer_email\"\:\"([A-Za-z0-9._%-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4})') as content").limit(5).collect do |x| x.content end
emails  = emails.uniq
