# frozen_string_literal: true

require "request_store"
require "fiber_hook"
require_relative "fibers/version"

module RequestStore
  # Make RequestStore work with fibers.
  module Fibers
    class Error < StandardError; end

    def self.init
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

    def self.uninit
      raise Error, "You must init before you can uninit" unless @hook_id

      Fiber.unhook(@hook_id)
      @hook_id = nil
    end
  end
end
