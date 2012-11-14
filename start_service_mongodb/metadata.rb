maintainer       "YOUR_COMPANY_NAME"
maintainer_email "YOUR_EMAIL"
license          "All rights reserved"
description      "Installs/Configures start_service_mysql"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.0.1"

 


%w{  cloudfoundry deployment backup service_lifecycle  }.each do |cb|
  depends cb
end

depends "backup"
depends "service_lifecycle"
