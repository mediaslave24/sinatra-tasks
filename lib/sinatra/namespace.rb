module Sinatra
  class Namespace
    def initialize(namespace, scope)
      @namespace = namespace
      @scope = scope
    end
    %w{get post put delete patch options link unlink}.each do |mtd|
      define_method(mtd) do |*args, &block|
        args[0] = ['/', @namespace, "/", args[0]].join
        @scope.send(mtd, *args, &block)
      end
    end
  end

  class Base
    def self.namespace(name, &block)
      Namespace.new(name, self).instance_eval(&block)
    end
  end
end
