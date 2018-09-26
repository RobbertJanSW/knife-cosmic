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
  class CosmicOstypeList < Chef::Knife

    include Chef::Knife::KnifecosmicBaseList
    
    banner "knife cosmic ostype list (options)"

    option :keyword,
           :long => "--keyword KEY",
           :description => "List by keyword"

    def run
      validate_base_options

      columns = [
        'Description     :description',
        'ID              :id',
        'OS Categorie ID :oscategoryid'
      ]

      params = { 'command' => "listOsTypes" }
      params['filter']  = locate_config_value(:filter)  if locate_config_value(:filter)
      params['listall'] = locate_config_value(:listall) if locate_config_value(:listall)
      params['keyword'] = locate_config_value(:keyword) if locate_config_value(:keyword)
      
      result = connection.list_object(params, "ostype")
      list_object(columns, result)
    end

  end
end
