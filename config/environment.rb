# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Benvarim::Application.initialize!
Benvarim::Application.configure do
   config.gem "jammit"
end
