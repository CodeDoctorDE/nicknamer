# frozen_string_literal: true

require 'sequel'

require_relative './index.rb'
class ExampleModule
  def join(server, _already)
    send_message "\u001b[96mSet up main module for #{server.id}..."
    
    send_message "\u001b[32mSuccessfully set up example module for #{server.id}!"
  end

  def setup; end
end
