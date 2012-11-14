#
# Cookbook Name:: test_vcaps
# Recipe:: default
#
# Copyright 2012, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
#service "cloud_controller" do
#  service_name "cloud_controller"
#  start_command "/root/cloudfoundry/vcap/dev_setup/bin/vcap_dev -n cloud_controller-health_manager start"
#  stop_command  "/root/cloudfoundry/vcap/dev_setup/bin/vcap_dev -n cloud_controller-health_manager stop"
#  status_command "/root/cloudfoundry/vcap/dev_setup/bin/vcap_dev -n cloud_controller-health_manager status"
#  restart_command  "/root/cloudfoundry/vcap/dev_setup/bin/vcap_dev -n cloud_controller-health_manager restart"
#  supports :status => true, :restart => true, :reload => true
#  action [ :enable, :restart ]
#end

bash "start " + node['deployment']['name']  do
  user "root" 
  cwd "/tmp" 
  code <<-EOH
  /root/cloudfoundry/vcap/dev_setup/bin/vcap_dev -n nats_server start 
  EOH
end



