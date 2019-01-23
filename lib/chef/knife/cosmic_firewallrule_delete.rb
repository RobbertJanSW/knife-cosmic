#
# Original knife-cloudstack author:: Muga Nishizawa (<muga.nishizawa@gmail.com>)
# Copyright:: Copyright (c) 2014 Muga Nishizawa.
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
  class CosmicFirewallruleDelete < Chef::Knife

    include Chef::Knife::KnifecosmicBase

    deps do
      require 'knife-cosmic/connection'
      require 'chef/api_client'
      require 'chef/knife'
      Chef::Knife.load_deps
    end

    banner "knife cosmic firewallrule delete id"

    def run
      validate_base_options

      id = @name_args.shift

      connection.networkacl_delete(id)
      puts "Deleted NETWORKACL"

    end
  end
end
