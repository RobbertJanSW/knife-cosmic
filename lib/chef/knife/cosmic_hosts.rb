#
# Original knife-cloudstack author:: Ryan Holmes (<rholmes@edmunds.com>)
# Original knife-cloudstack author:: KC Braunschweig (<kcbraunschweig@gmail.com>)
# Copyright:: Copyright (c) 2011 Edmunds, Inc.
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
require 'chef/knife/cosmic_baselist'

module Knifecosmic
  class CosmicHosts < Chef::Knife

    MEGABYTES = 1024 * 1024

    include Chef::Knife::KnifecosmicBase
    include Chef::Knife::KnifecosmicBaseList

    deps do
      require 'knife-cosmic/connection'
      Chef::Knife.load_deps
    end

    banner "knife cosmic hosts"

    def run
      validate_base_options

      host_list = [
          ui.color('#Public IP', :bold),
          ui.color('Host', :bold),
          ui.color('FQDN', :bold)
      ]

      servers = connection.list_servers
      pf_rules = connection.list_port_forwarding_rules
      servers.each do |s|
        host_list << (connection.get_server_public_ip(s, pf_rules) || '#')
        host_list << (s['name'] || '')
        host_list << (connection.get_server_fqdn(s) || '')
      end
      puts ui.list(host_list, :columns_across, 3)

    end
  end
end
