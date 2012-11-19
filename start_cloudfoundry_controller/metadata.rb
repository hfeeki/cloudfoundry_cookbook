maintainer       "TELECOM PariTech"
maintainer_email "YOUR_EMAIL"
license          "All rights reserved"
description      "Installs/Configures start_cloudfoundry_component"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.0.1"

%w{ redis cloudfoundry postgresql deployment uaa  service_lifecycle uaadb start_cloudfoundry_component }.each do |cb|
  depends cb
end

