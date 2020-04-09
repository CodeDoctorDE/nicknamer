# frozen_string_literal: true

require_relative './user-commands.rb'
require_relative './console-commands.rb'
require_relative './setup.rb'
require_relative './events.rb'
class NicknamerModule include CodeDoBo::BotModule
  def initialize(app_class, module_manager)
    @module_manager = module_manager
    @app_class = app_class
    @client = module_manager.client
    send_message "\u001b[96mStarting nicknamer module..."
    @language = CodeDoBo::Language.new module_manager.client, __dir__ + '/language'
    setup
    events
    send_message "\u001b[32mSuccessfully started nicknamer module!"
  end
  def on_enable
    register_console_commands
    register_user_commands
  end

  #
  # Get the nickname of a member
  #
  # @param [Discordrb::Member] member
  #
  # @return [String]
  #
  def get_nickname(member)
    nickname = ""
    entry = @client[:nicknamer].first(server_id: member.server.id, role: member.colour_role.id)
    if entry
      nickname += (entry[:upper_prefix] || "") + " "
    end 

    nickname += member.roles.map {|role| 
      role_entry = @client[:nicknamer].first(server_id: role.server.id, role: role.id)
      role_entry[:normal_prefix] if role_entry
    }.join(" ")
    nickname += member.name + " "
    
    nickname += member.roles.map {|role| 
      role_entry = @client[:nicknamer].first(server_id: role.server.id, role: role.id)
      role_entry[:normal_suffix] if role_entry
    }.join(" ")

    if entry
      nickname += (entry[:upper_suffix] || "")
    end 
    nickname
  end

  #
  # Update the nickname of the user
  #
  # @param [Discordrb::Member] member
  #
  # @return [void]
  #
  def update_nickname(member)
    nickname = get_nickname(member)
    if member.display_name != nickname
      member.set_nick nickname
    end
  end
end
