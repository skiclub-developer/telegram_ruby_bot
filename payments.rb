require './helpers'
require './constants'

def pay_penalty(bot, message, type)
  players_and_numbers = split_message message
  body = {
      "members": players_and_numbers,
      "telegram_user": telegram_user(message),
      "payment_type": type
  }

  response = JSON.parse(Faraday.post("#{HOST}/members/pay", body).body, object_class: OpenStruct)
  response.updated_members.each do |updated_member|
    if type == "beer"
      bot.api.send_message(chat_id: message.chat.id, text: "#{updated_member.name} hat #{updated_member.amount} Kisten geschmissen")
    else
      bot.api.send_message(chat_id: message.chat.id, text: "#{updated_member.name} hat #{updated_member.amount}€ gezahlt")
    end
  end

  respond_member_not_found bot, message, response
end