# frozen_string_literal: true

require_relative './user-commands.rb'
require_relative './console-commands.rb'
require_relative './setup.rb'
class ExampleModule include CodeDoBo::BotModule
  def initialize(app_class, module_manager)
    @module_manager = module_manager
    @app_class = app_class
    send_message "\u001b[96mStarting example module..."
    @language = CodeDoBo::Language.new module_manager.client, __dir__ + '/language'
    setup
    send_message "\u001b[32mSuccessfully started example module!"
  end
  def on_enable
    register_console_commands
    register_user_commands
  end
end
