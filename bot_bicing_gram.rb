require 'telegram/bot'
require_relative 'data/station_information'
require_relative 'helpers/bot_helper'
require_relative 'bot_message'


TELEGRAM_BOT_TOKEN = "391868557:AAEydTKqwJjD6uYyUuLzEhBFmejqZOk0u9k"
SIZE_OF_CLOSEST_STATIONS = 1

Telegram::Bot::Client.run(TELEGRAM_BOT_TOKEN) do |bot|
  bot.listen do |message|
    case message
      when Telegram::Bot::Types::CallbackQuery
        station = BotHelper.get_stations(message.data, SIZE_OF_CLOSEST_STATIONS.to_i)
        BotMessage.send_station_message(bot, message.from.id, station.reverse!.pop)


      when Telegram::Bot::Types::InlineQuery
        station = BotHelper.get_stations_inline(message, SIZE_OF_CLOSEST_STATIONS.to_i)
        bot.api.answer_inline_query(inline_query_id: message.id, results: [BotHelper.inline_result(station.reverse!.pop)])

      when Telegram::Bot::Types::Message
        if message.venue && message.venue.location
          BotMessage.send_bot_message(bot, message.chat.id, BotHelper.inline_markup,'What would you like to do next?')
        elsif message.location
          BotMessage.send_bot_message(bot, message.chat.id, BotHelper.inline_markup(message.location),'What action over the given location?')
        end

        case message.text
          when '/help'
            BotMessage.send_bot_message(bot, message.chat.id, BotHelper.inline_markup, BOT_HELP_MESSAGE)
          when '/start'
            BotMessage.send_bot_message(bot, message.chat.id, BotHelper.inline_markup)
          else
            unless (message.text.nil? || message.text.start_with?('At'))
              BotMessage.send_bot_message(bot, message.chat.id, BotHelper.bot_markup, BOT_ERROR_MESSAGE)
            end
        end
    end
  end
end


