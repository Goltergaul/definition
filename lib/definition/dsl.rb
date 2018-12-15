require "definition/types"

module Definition
  module Dsl
    def Keys(name, &block)
      Types::Keys.new(name).tap do |instance|
        instance.instance_exec(&block)
      end
    end
  end
end
