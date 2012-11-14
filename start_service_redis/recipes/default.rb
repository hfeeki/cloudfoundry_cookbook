#
# Cookbook Name:: start_service_redis
# Recipe:: default
#
# Copyright 2012, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
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

    configs = ["redis_backup", "redis_worker", "redis_gateway", "redis_node"]
    configs.each do |config|
     template File.join(node[:deployment][:config_path],config ) do
      source "#{config}.yml.erb"
      owner node[:deployment][:user]
      mode "0644"
      action :create
     end
    end 

    confs = ["services_redis.conf", "redis_backup.cron"]
    
    confs.each do |config|
     template File.join(node[:deployment][:config_path],config ) do
      source "#{config}.erb"
      owner node[:deployment][:user]
      mode "0644"
      action :create
     end
    end

  template File.join(node[:redis][:path], "etc", "redis.conf") do
    source "redis.conf.erb"
    owner "root"
    group "root"
    mode "0600"
#    notifies :restart, "service[redis]"
  end

#  service "redis" do
#    supports :status => true, :restart => true, :reload => true
#    action [ :enable, :start ]
#  end

else
  Chef::Log.error("Installation of redis not supported on this platform.")
end




bash "start Redis Service"   do
  user "root" 
  cwd "/tmp" 
  code <<-EOH
  /root/cloudfoundry/vcap/dev_setup/bin/vcap_dev -n redis_service start 
  EOH
end
