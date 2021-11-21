# frozen_string_literal: true

require "request_store"
require "fiber_hook"
require_relative "fibers/version"

module RequestStore
  # Make RequestStore work with fibers.
  module Fibers
    class Error < StandardError; end

    def self.hook_up
      @hook_id = Fiber.hook(
        new: -> { [RequestStore.store, RequestStore.active?] },
        resume: ->(value) {
          RequestStore.store = value[0]
          if value[1]
            RequestStore.begin!
          else
            RequestStore.end!
          end
        }
      )
    end

    def self.unhook
      raise Error, "You must hook before you can unhook" unless @hook_id

      Fiber.unhook(@hook_id)
      @hook_id = nil
    end
  end
end
