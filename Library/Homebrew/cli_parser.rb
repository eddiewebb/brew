require "optparse"
require "ostruct"

module Homebrew
  module CLI
    class Parser
      def self.parse(&block)
        new(&block).parse
      end

      def initialize(&block)
        @parser = OptionParser.new
        @parsed_args = OpenStruct.new
        # undefine tap to allow --tap argument
        @parsed_args.instance_eval { undef tap }
        instance_eval(&block)
      end

      def switch(*names, description: nil, env: nil)
        description = option_to_description(*names) if description.nil?
        names, env = common_switch(*names) if names.first.is_a?(Symbol)
        @parser.on(*names, description) do
          enable_switch(*names)
        end
        enable_switch(*names) if !env.nil? && !ENV["HOMEBREW_#{env.to_s.upcase}"].nil?
      end

      def comma_array(name, description: nil)
        description = option_to_description(name) if description.nil?
        @parser.on(name, OptionParser::REQUIRED_ARGUMENT, Array, description) do |list|
          @parsed_args[option_to_name(name)] = list
        end
      end

      def flag(name, description: nil, required: false)
        if required
          option_required = OptionParser::REQUIRED_ARGUMENT
        else
          option_required = OptionParser::OPTIONAL_ARGUMENT
        end
        description = option_to_description(name) if description.nil?
        @parser.on(name, description, option_required) do |option_value|
          @parsed_args[option_to_name(name)] = option_value
        end
      end

      def option_to_name(name)
        name.sub(/\A--?/, "").tr("-", "_")
      end

      def option_to_description(*names)
        names.map { |name| name.to_s.sub(/\A--?/, "").tr("-", " ") }.sort.last
      end

      def parse(cmdline_args = ARGV)
        @parser.parse!(cmdline_args)
        @parsed_args
      end

      private

      def enable_switch(*names)
        names.each do |name|
          @parsed_args["#{option_to_name(name)}?"] = true
        end
      end

      def common_switch(name)
        case name
        when :quiet   then [["-q", "--quiet"], :quiet]
        when :verbose then [["-v", "--verbose"], :verbose]
        when :debug   then [["-d", "--debug"], :debug]
        else name
        end
      end
    end
  end
end
