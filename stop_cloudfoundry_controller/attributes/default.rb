include_attribute "deployment"
include_attribute "postgresql"
include_attributes "uaa"
include_attributes "service_lifecycle"
include_attribute "cloudfoundry"
include_attribute "deployment"
include_attributes "uaadb"
include_attributes "redis"

########################################### DEPLOYMENT  ###########################################################
include_attribute "cloudfoundry"
default[:deployment][:name] = "cloud_controller-health_manager"
default[:deployment][:user] = ENV["USER"]
default[:deployment][:group] = "vcap"
default[:cloudfoundry][:home] =  "/root/cloudfoundry"
default[:deployment][:home] = File.join(node[:cloudfoundry][:home], ".deployments", deployment[:name])
default[:deployment][:config_path] = File.join(deployment[:home], "config")
default[:deployment][:info_file] = File.join(deployment[:config_path], "deployment_info.json")
default[:deployment][:domain] = "vcap.me"
default[:deployment][:log_path] = File.join(deployment[:home], "log")
default[:deployment][:profile] = File.expand_path(File.join(ENV["HOME"], ".cloudfoundry_deployment_profile"))
default[:deployment][:local_run_profile] = File.expand_path(File.join(ENV["HOME"], ".cloudfoundry_deployment_local"))
default[:deployment][:setup_cache] = File.join("", "var", "cache", "dev_setup")

########################################### COMMON  ###########################################################
default['cloudfoundry_common']['vcap']['ruby_version'] = "/root/cloudfoundry/.deployments/rubynode/deploy/rubies/ruby-1.9.2-p180/bin/ruby"

default['cloudfoundry_common']['vcap']['bin_path'] = "/root/cloudfoundry/vcap/dev_setup/bin/vcap" 

default['cloudfoundry_common']['vcap']['component_name'] = "" 

default['cloudfoundry_common']['vcap']['deplyment_path'] = "/root/cloudfoundry/.deployments" 

default['cloudfoundry_common']['vcap']['install_path'] = "/root/cloudfoundry/vcap"  

default['cloudfoundry_common']['vcap']['logs'] = "/root/cloudfoundry/.deployments/rubynode/log"

########################################### Cloud Controller  ###########################################################

default[:deployment][:welcome] = "VMware's Cloud Application Platform"

default[:cloud_controller][:config_file] = "cloud_controller.yml"
default[:cloud_controller][:service_api_uri] = "http://api.#{node[:deployment][:domain]}"

default[:cloud_controller][:local_route] = nil
default[:cloud_controller][:admins] = ["dev@cloudfoundry.org"]
default[:cloud_controller][:runtimes_file] = "runtimes.yml"

# Staging  
default[:cloud_controller][:staging][:grails] = "grails.yml"
default[:cloud_controller][:staging][:lift] = "lift.yml"
default[:cloud_controller][:staging][:node] = "node.yml"
default[:cloud_controller][:staging][:otp_rebar] = "otp_rebar.yml"
default[:cloud_controller][:staging][:rack] = "rack.yml"
default[:cloud_controller][:staging][:rails3] = "rails3.yml"
default[:cloud_controller][:staging][:sinatra] = "sinatra.yml"
default[:cloud_controller][:staging][:spring] = "spring.yml"
default[:cloud_controller][:staging][:java_web] = "java_web.yml"
default[:cloud_controller][:staging][:php] = "php.yml"
default[:cloud_controller][:staging][:django] = "django.yml"
default[:cloud_controller][:staging][:wsgi] = "wsgi.yml"
default[:cloud_controller][:staging][:standalone] = "standalone.yml"
default[:cloud_controller][:staging][:play] = "play.yml"

# Default builtin services
default[:cloud_controller][:builtin_services] = ["redis", "mongodb", "mysql", "neo4j", "rabbitmq", "postgresql", "vblob", "memcached", "filesystem", "elasticsearch", "couchdb", "echo"]

# Default capacity
default[:capacity][:max_uris] = 4
default[:capacity][:max_services] = 16
default[:capacity][:max_apps] = 20

default[:vcap_redis][:port] = "5454"
default[:vcap_redis][:password] = "PoIxbL98RWpwBuUJvKNojnpIcRb1ot2"


########################################### CCDB  ###########################################################

default[:ccdb][:user] = node[:postgresql][:server_root_user]
default[:ccdb][:password] = node[:postgresql][:server_root_password]
default[:ccdb][:database] = "cloud_controller"
default[:ccdb][:port] = node[:postgresql][:system_port]
default[:ccdb][:adapter] = "postgresql"
default[:ccdb][:data_dir] = File.join(node[:deployment][:home], "ccdb_data_dir")


########################################### Health Manager ###########################################################


default[:health_manager][:config_file] = "health_manager.yml"
default[:health_manager][:database][:username] = node[:postgresql][:server_root_user]
default[:health_manager][:database][:password] = node[:postgresql][:server_root_password]
default[:health_manager][:local_route] = nil


########################################### UAA  ###########################################################

default[:uaadb][:host] = "localhost"

default[:uaa][:jwt_secret] = "uaa_jwt_secret"

default[:uaa][:batch][:username] = "batch_user"
default[:uaa][:batch][:password] = "batch_password"

# uaa client registration bootstrap
default[:uaa][:admin][:password] = "adminsecret"
default[:uaa][:cloud_controller][:password] = "cloudcontrollersecret"


########################################### UAADB  ###########################################################

default[:uaadb][:user] = node[:postgresql][:server_root_user]
default[:uaadb][:password] = node[:postgresql][:server_root_password]
default[:uaadb][:database] = "uaa"
default[:uaadb][:port] = node[:postgresql][:system_port]
default[:uaadb][:adapter] = "postgresql"
default[:uaadb][:data_dir] = File.join(node[:deployment][:home], "uaadb_data_dir")




default['cf_session']['cf_id'] = '13'
