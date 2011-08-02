emails = Array.new
emails += User.find(:all, :select => "email").collect do |x| x.email end
emails += Organization.find(:all, :select => "contact_email").collect do |x| x.contact_email end
emails += TmpPayment.find(:all, :select => "email").collect do |x| x.email end
emails += ContactForm.find(:all, :select => "email").collect do |x| x.email end
emails += Bvlog.where("content like '%payer_email%'").collect {|x| (ActiveSupport::JSON.decode x.content)["payer_email"].sub("\n","")}
