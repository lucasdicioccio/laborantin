#runner/commands/describe.rb

=begin

This file is part of Laborantin.

Laborantin is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

Laborantin is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Laborantin.  If not, see <http://www.gnu.org/licenses/>.

Copyright (c) 2009, Lucas Di Cioccio

=end

autoload :ERB, 'erb'
module Laborantin
  module Commands
    class Describe < Command
      describe "Gives a summary of what the current Laborantin project is"


      option(:scenarii) do
        describe "comma separated list of scenarios to describe"
        short "-s"
        long "--scenarii=OPTIONAL"
        type Array
        default []
      end

      option(:environments) do
        describe "comma separated list of environments to describe"
        short "-e"
        long "--envs=OPTIONAL"
        type Array
        default []
      end

      option(:analyses) do
        describe "comma separated list of analyses to describe"
        short "-a"
        long "--analyses=OPTIONAL"
        type Array
        default []
      end

      option(:output) do
        describe "print in a file instead of STDOUT"
        short '-o'
        long '--output=OPTIONAL'
        type String
        default ''
      end

      FORMATS = ['default', 'txt', 'html']

      option(:format) do
        describe "format the output in a certain form, among: [#{FORMATS.join(', ')}]"
        short '-f'
        long '--format=OPTIONAL'
        type String
        default 'default'
      end

      def stdout?
        opts[:output].empty?
      end

      def out
        @out ||= if stdout?
                   self #self.puts forward to the runner 
                 else
                   File.open(opts[:output], 'w')
                 end
      end

      def close_out
        @out.close unless stdout?
      end

      def environments
        Environment.all
      end

      def scenarii
        Scenario.all
      end

      def analyses
        Analysis.all
      end


      HTML_TPL = <<ERB
<html>
<head>
</head>
<body>
  <h1>Laborantin's description</h1>
  <p>Project located at: <%= runner.root_dir %> </p>
  <h2>List of environments</h2>
  <ul>
  <% Environment.all.each do |env| %>
    <li><%= env.name %>
    (<%= env.description %>)
    </li>
  <% end %>
  </ul>
  <h2>List of scenarios</h2>
  <ul>
  <% Scenario.all.each do |sc| %>
    <li><%= sc.name %>
    (<%= sc.description %>)
      <ul>
      <% sc.parameters.each_pair do |name, spec| %>
        <li><%= name %></li>
        <li><%= spec.description %></li>
        <li><%= spec.values.inspect %></li>
      <% end %>
      </ul>
    </li>
  <% end %>
  </ul>
  <h2>List of analyses</h2>
  <ul>
  <% Analysis.all.each do |a| %>
    <li><%= a.name %>
    (<%= a.description %>)
    <ul>
    <% a.analyses.each do |hash| %>
      <li>
        <%= hash[:str] %>
      </li>
    <% end %>
    </ul>
    </li>
  <% end %>
  </ul>
</body>
</html>
ERB

    TXT_TPL = <<ERB
Available environments:
<% Environment.all.each do |env| %>
  * <%= env.name %> (<%= env.description %>)
<% end %>
Available scenarios:
<% Scenario.all.each do |sc| %>
  * <%= sc.name %> (<%= sc.description %>)
    <% sc.parameters.each_pair do |name, spec| %>
    + <%= name %> (<%= spec.description %>) | <%= spec.values.inspect %>
    <% end %>
  <% end %>
Available analyses:
<% Analysis.all.each do |a| %>
  * <%= a.name %> (<%= a.description %>)
    <% a.analyses.each do |hash| %>
    <% if hash[:params][:type] %>
    + <%= hash[:str] %> (<%= hash[:params][:type] %>)
    <% else %>
    + <%= hash[:str] %> 
    <% end %>
    <% end %>
<% end %>
ERB

      def html_format
        ERB.new(HTML_TPL).result(binding)
      end

      def txt_format
        ERB.new(TXT_TPL).result(binding).lines.reject{|l| l =~/^\s*$/}.join
      end

      def show?(klass, sym)
        opts[sym].empty? or opts[sym].include?(klass.name.duck_case)
      end

      alias :default_format :txt_format

      def format_str
        case opts[:format]
        when 'html'
          html_format
        else
          default_format
        end
      end

      execute do
        begin
          out.puts format_str
        ensure
          close_out
        end
      end
    end
  end
end
