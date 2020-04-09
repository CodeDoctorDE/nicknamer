# frozen_string_literal: true

require 'discordrb'

class NicknamerModule
  def register_user_commands
    nicknamer_commands
  end

  def nicknamer_commands
    @app_class.register_user_cmd(:nicknamer, %w[nicknamer nickname nick]) do |_command, args, event|
      language = @language.get_json(event.server.id)['commands']
      if event.author.permission? :manage_server
        if args.length <= 0
          help(event.user, event.channel)
        elsif args[0].casecmp('prefix').zero?
          prefix_command(args.drop(1), event)
        elsif args[0].casecmp('suffix').zero?
          suffix_commands(args.drop(1), event)
        elsif args[0].casecmp('update').zero?
          update_command(args.drop(1), event)
        elsif args[0].casecmp('list').zero?
          list_command(args.drop(1), event)
        elsif args[0].casecmp('info').zero?
          info_command(args.drop(1), event)
        elsif args[0].casecmp('get').zero?
          get_command(args.drop(1), event)
        else
          event.send_message language['usage']
        end
      else
        event.send_message language['nopermission']
      end
    end
  end

  def prefix_command(args, event)
    language = @language.get_json(event.server.id)['commands']['prefix']
    if args.length < 2
      event.send_message language['usage']
      return
    end
    upper = args[0].downcase
    unless %w[yes no].include? upper
      event.send_message language['invalid']['upper']
      return
    end
    role = args[1]
    if event.server.role(role).nil?
      event.send_message language['invalid']['role']
      return
    end
    entry = @client[:nicknamer].where(server_id: event.server.id, role: role)
    if args.length == 2
      unless entry.all.empty?
        if upper == 'yes'
          if entry.first[:normal_prefix].strip.empty?
            entry.delete
          else
            entry.update(upper_prefix: '')
          end
        else
          if entry.first[:upper_prefix].strip.empty?
            entry.delete
          else
            entry.update(normal_prefix: '')
          end
        end
      end
      event.send_message language['remove'][upper]
    else
      if entry.all.empty?
        if upper == 'yes'
          @client[:nicknamer].insert(server_id: event.server.id, role: role, upper_prefix: args.drop(2).join(' '))
        else
          @client[:nicknamer].insert(server_id: event.server.id, role: role, normal_prefix: args.drop(2).join(' '))
        end
      else
        if upper == 'yes'
          entry.update(upper_prefix: args.drop(2).join(' '))
        else
          entry.update(normal_prefix: args.drop(2).join(' '))
        end
      end
      event.send_message(language['success'][upper])
    end
  end

  def suffix_commands(args, event)
    language = @language.get_json(event.server.id)['commands']['suffix']
    if args.length < 2
      event.send_message language['usage']
      return
    end
    upper = args[0].downcase
    unless %w[yes no].include? upper
      event.send_message language['invalid']['upper']
      return
    end
    role = args[1]
    if event.server.role(role).nil?
      event.send_message language['invalid']['role']
      return
    end
    entry = @client[:nicknamer].where(server_id: event.server.id, role: role)
    if args.length == 2
      unless entry.all.empty?
        if upper == 'yes'
          if entry.first[:normal_suffix].strip.empty?
            entry.delete
          else
            entry.update(upper_suffix: '')
          end
        else
          if entry.first[:upper_suffix].strip.empty?
            entry.delete
          else
            entry.update(normal_suffix: '')
          end
        end
      end
      event.send_message language['remove'][upper]
    else
      if entry.all.empty?
        if upper == 'yes'
          @client[:nicknamer].insert(server_id: event.server.id, role: role, upper_suffix: args.drop(2).join(' '))
        else
          @client[:nicknamer].insert(server_id: event.server.id, role: role, normal_suffix: args.drop(2).join(' '))
        end
      else
        if upper == 'yes'
          entry.update(upper_suffix: args.drop(2).join(' '))
        else
          entry.update(normal_suffix: args.drop(2).join(' '))
        end
      end
      event.send_message(language['success'][upper])
    end
  end

  def list_command(args, event)
    language = @language.get_json(event.server.id)['commands']['list']
    if args.empty?
      event.channel.send_embed do |embed|
        embed.title = language['title']
        entries = @client[:nicknamer].where(server_id: event.server.id).map { |entry| event.server.role(entry[:role]).mention }.join(language['delimiter'])
        embed.description = format(language['description'], e: entries)
      end
    else
      event.send_message(language['usage'])
    end
  end

  def info_command(args, event)
    language = @language.get_json(event.server.id)['commands']['info']
    if args.length == 1
      role = event.server.role(args[0])
      entry = @client[:nicknamer].first(server_id: event.server.id, role: role&.id)
      if role && entry
        event.channel.send_embed do |embed|
          embed.title = format(language['title'], n: role.name, i: role.id)
          embed.description = format(language['description'], r: role.mention, up: entry[:upper_prefix], us: entry[:upper_suffix], np: entry[:normal_prefix], ns: entry[:normal_suffix])
        end
      else
        event.send_message(language['invalid'])
      end
    else
      event.send_message(language['usage'])
    end
  end

  def update_command(args, event)
    language = @language.get_json(event.server.id)['commands']['update']
    if args.length == 1
      user = event.server.member(args[0])
      unless user.nil?
        update_nickname(user)
        event.send_message(language['success'])
      else
        event.send_message(language['invalid'])
    end
    else
      event.send_message(language['usage'])
    end
  end

  def get_command(args, event)
    language = @language.get_json(event.server.id)['commands']['get']
    if args.length == 1
      user = event.server.member(args[0])
      unless user.nil?
        event.send_message(format(language['get'], n: get_nickname(user)))
      else
        event.send_message(language['invalid'])
    end
    else
      event.send_message(language['usage'])
    end
  end


  def help(_user, channel)
    command_language = @language.get_json(channel.server.id)['commands']['help']
    channel.send_embed do |embed|
      embed.title = command_language['title']
      embed.description = command_language['description']
      embed.timestamp = Time.now
      embed.color = command_language['color']
    end
  end
end
