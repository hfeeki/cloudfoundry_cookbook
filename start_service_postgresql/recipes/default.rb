#
# Cookbook Name:: postgresql
# Recipe:: default
#
# Copyright 2011, VMware
#
#
#

if Chef::Config[:solo]
        Chef::Log.warn("This recipe uses search. Chef Solo does not support search.")
else
        cf_id_node = node['cf_session']['cf_id']
        m_nodes_nats = search(:node, "role:cloudfoundry_nats_server_ng AND cf_id:#{cf_id_node}")
       while m_nodes_nats.count < 1
        Chef::Log.warn("Waiting for nats .... I am sleeping 7 sec")
        sleep 7
        m_nodes_nats = search(:node, "role:cloudfoundry_nats_server_ng AND cf_id:#{cf_id_node}")
       end
       m_nodes_nats.each {|k|
        if (k['cf_session']['cf_id'] == node['cf_session']['cf_id']) then
              node.set['nats_server']['user']= k['nats_server']['user']
              node.set['nats_server']['password']= k['nats_server']['password']
              node.set['nats_server']['host']= k['ipaddress']
              node.set['nats_server']['port']= k['nats_server']['port']
        end
       }


        cf_id_node = node['cf_session']['cf_id']
        m_nodes_cc = search(:node, "role:cloudfoundry_controller_nv AND cf_id:#{cf_id_node}")
       while m_nodes_cc.count < 1
        Chef::Log.warn("Waiting for cc .... I am sleeping 7 sec")
        sleep 7
        m_nodes_cc = search(:node, "role:cloudfoundry_controller_nv AND cf_id:#{cf_id_node}")
       end
       m_nodes_cc.each {|k|
        if (k['cf_session']['cf_id'] == node['cf_session']['cf_id']) then
              node.set['cloud_controller']['service_api_uri'] =  k['cloud_controller']['service_api_uri']
        end
       }

end


case node['platform']
when "ubuntu"

    configs = ["postgresql_node", "postgresql_backup", "postgresql_worker", "postgresql_gateway"]
    configs.each do |config|
     template File.join(node[:deployment][:config_path],config ) do
      source "#{config}.yml.erb"
      owner node[:deployment][:user]
      mode "0644"
      action :create
     end
    end 

    confs = ["postgresql_backup.cron"]
    
    confs.each do |config|
     template File.join(node[:deployment][:config_path],config ) do
      source "#{config}.erb"
      owner node[:deployment][:user]
      mode "0644"
      action :create
     end
    end


  service "postgresql" do
    notifies :restart, "service[postgresql]"
  end
    supports :status => true, :restart => true, :reload => true
    action [ :enable, :start ]
  end

else
  Chef::Log.error("Installation of postgresql not supported on this platform.")
end




bash "start Postgresql Service"   do
  user "root" 
  cwd "/tmp" 
  code <<-EOH
  /root/cloudfoundry/vcap/dev_setup/bin/vcap_dev -n postgresql_service start 
  EOH
end
