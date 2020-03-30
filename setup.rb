# frozen_string_literal: true

require 'sequel'

require_relative './index.rb'
class NicknamerModule
  def join(server, _already)
    send_message "\u001b[96mSet up main module for #{server.id}..."
    
    send_message "\u001b[32mSuccessfully set up example module for #{server.id}!"
  end

  def setup
    @client.create_table? :nicknamer do
      Bignum :server_id
      String :normal_prefix, default: '', text: true
      String :normal_suffix, default: '', text: true
      String :upper_prefix, default: '', text: true
      String :upper_suffix, default: '', text: true
      Bignum :role
    end
  end
end
