class NicknamerModule
    def events
        @module_manager.bot.discord.member_update do |event|
            begin
              update_nickname(event.user)
            rescue Exception
            end
        end
    end
end