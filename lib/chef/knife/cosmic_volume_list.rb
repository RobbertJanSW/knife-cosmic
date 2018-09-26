#
# Author:: Sander Botman (<sbotman@schubergphilis.com>)
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

require 'chef/knife'
require 'chef/knife/cosmic_baselist'

module Knifecosmic
  class CosmicVolumeList < Chef::Knife

    include Chef::Knife::KnifecosmicBaseList

    banner "knife cosmic volume list (options)"

    option :listall,
           :long => "--listall",
           :description => "List all volumes",
           :boolean => true

    option :name,
           :long => "--name NAME",
           :description => "Specify volume name to list"

    option :keyword,
           :long => "--keyword KEY",
           :description => "List by keyword"

    option :vmname,
            :long => "--vmname NAME",
            :description => "Virtual machine name to list volumes for"

    def run
      validate_base_options

      columns = [
        'Name    :name',
        'Account :account',
        'Domain  :domain',
        'State   :state',
        'VMName  :vmname',
        'VMState :vmstate'
      ]

      params = { 'command' => "listVolumes" }
      params['filter']  = locate_config_value(:filter)  if locate_config_value(:filter)
      params['listall'] = locate_config_value(:listall) if locate_config_value(:listall)
      params['keyword'] = locate_config_value(:keyword) if locate_config_value(:keyword)
      params['name']    = locate_config_value(:name)    if locate_config_value(:name)
      if locate_config_value(:vmname)
        vm = connection.get_server(locate_config_value(:vmname))
        params['virtualmachineid'] = vm['id']
      end
      
      @volumelist = connection.list_object(params, "volume")
      list_object(columns, @volumelist)
    end

    def volumelist
      @volumelist
    end

  end
end
