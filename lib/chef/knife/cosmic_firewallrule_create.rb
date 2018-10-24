#
# Original knife-cloudstack author:: Sander Botman (<sbotman@schubergphilis.com>)
# Copyright:: Copyright (c) 2013 Sander Botman.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'chef/knife/cosmic_base'

module Knifecosmic
  class CosmicFirewallruleCreate < Chef::Knife

    include Chef::Knife::KnifecosmicBase

    def initialize()
      @rules_created = []
    end

    deps do
      require 'knife-cosmic/connection'
      Chef::Knife.load_deps
    end

    banner "knife cosmic firewallrule create hostname 8080:8090:TCP:10.0.0.0/24"

    option :syncrequest,
           :long => "--sync",
           :description => "Execute command as sync request",
           :boolean => true

    option :public_ip,
           :long => "--public_ip IP_ADDRESS",
           :description => "Provide the public IP adrress. This makes it possible to create rules on VPCosmic"

    def run

      @hostname = @name_args.shift
      unless /^[a-zA-Z0-9][a-zA-Z0-9-]*$/.match @hostname then
       ui.error "Invalid hostname. Please specify a short hostname, not an fqdn (e.g. 'myhost' instead of 'myhost.domain.com')."
        exit 1
      end

      params = {}
      locate_config_value(:openfirewall) ? params['openfirewall'] = 'true' : params['openfirewall'] = 'false'

      # Lookup all server objects.
      params_for_list_object = { 'command' => 'listVirtualMachines' }
      connection_result = connection.list_object(params_for_list_object, "virtualmachine")

      # Lookup the hostname in the connection result
      server = {}
      connection_result.map { |n| server = n if n['name'].upcase == @hostname.upcase }
     
      if server['name'].nil?
        ui.error "Cannot find hostname: #{@hostname}."
        exit 1
      end

      # Lookup the public ip address of the server
      if config[:public_ip].nil?
        server_public_address = connection.get_server_public_ip(server)
        ip_address = connection.get_public_ip_address(server_public_address)
      else
        ip_address = connection.get_public_ip_address(config[:public_ip])
      end
  
      if ip_address.nil? || ip_address['id'].nil?
        ui.error "Cannot find public ip address for hostname: #{@hostname}."
        exit 1
      end

      @name_args.each do |rule|
        @rules_created << create_port_forwarding_rule(ip_address, server['id'], rule, connection, params)
      end
    end
 
    def create_port_forwarding_rule(ip_address, server_id, rule, connection, other_params)
      args = rule.split(':')
      startport = args[0]
      endport   = args[1] || args[0]
      protocol  = args[2] || "TCP"
      cidrlist  = args[3] || "0.0.0.0/0"

      # Required parameters
      params = {
        'ipaddressId' => ip_address['id'],
        'protocol' => protocol
      }
      
      if config[:public_ip].nil?
        params['command'] = 'createFirewallRule'
      else
        params['command'] = 'createNetworkACL'
        # Random rule number; will be temp and hopefully wont hit collision
        params['number'] = (0...4).map { [rand(10)] }.join
        params['action'] = 'Allow'
        params['traffictype'] = 'Ingress'
        # To keep the def backwards compatible..
        @hostname

        server = connection.get_server(@hostname)
        server_nic_default = connection.get_server_default_nic(server)
        networkid = server_nic_default['networkid']
        params['aclid'] = connection.get_network(networkid)['aclid']
      end

      # Optional parameters
      opt_params = {
        'startport' => startport,
        'endport' => endport,
        'cidrlist' => cidrlist
      }

      params.merge!(opt_params)
 
      Chef::Log.debug("Creating Firewall Rule for
        #{ip_address['ipaddress']} with protocol: #{protocol}, start: #{startport} end: #{endport} cidr: #{cidrlist}")

      if locate_config_value(:syncrequest) 
        result = connection.send_request(params)
        Chef::Log.debug("JobResult: #{result}")
        result
      else
        result = connection.send_async_request(params)
        Chef::Log.debug("AsyncJobResult: #{result}")
      end
    end

    def rules_created()
      @rules_created
    end

  end
end
