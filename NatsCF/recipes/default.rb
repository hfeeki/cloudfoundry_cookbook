#
# Cookbook Name:: NatsCF
# Recipe:: default
#
# Copyright 2012, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#




 template "/root/cloudfoundry/vcap/dev_setup/deployments/nats.yml" do
        source "./templates/default/nats.yml.erb"
	variables(
	"nats_server" => node.set['nats_server']['deploymentname']	
	)	
        action :create 
 end

 bash 'start nats server ' do
  user "root" 
  cwd "/tmp" 
  code <<-EOH
  /root/cloudfoundry/vcap/dev_setup/bin/vcap_dev_setup -d /root/cloudfoundry -c /root/cloudfoundry/vcap/dev_setup/deployments/nats.yml
  EOH
 end 

