class LineBotController < ApplicationController
    require 'line/bot'
    protect_from_forgery :except => [:receive]

    def client
        @client ||= Line::Bot::Client.new {|config|
            config.channel_secret = Rails.application.credentials.line[:line_channel_id]
            config.channel_token  = Rails.application.credentials.line[:line_channel_secret]
        }
    end

    def receive
        body = request.body.read
        events = client.parse_events_from(body)
        events.each do |event|
            userId = event['source']['userId']
            puts "userId" + userId
        end
    end

    def push_message(text)


    end
end
