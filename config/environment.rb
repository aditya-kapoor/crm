# Load the rails application
require File.expand_path('../application', __FILE__)

ThinkingSphinx.suppress_delta_output = true

# Initialize the rails application
Crm::Application.initialize!
