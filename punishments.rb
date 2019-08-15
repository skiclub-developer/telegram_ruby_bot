require './helpers'

def punish_member(bot, message)
  players_and_numbers = split_message(message)
  penalty_name = message.text.partition(' ').first
  penalty_name = penalty_name[1, penalty_name.length]

  body = {
      "members": players_and_numbers,
      "penalty_name": penalty_name,
      "telegram_user": telegram_user(message)
  }

  response = JSON.parse(Faraday.post("http://api:3000/api/v1/members/punish", body).body, object_class: OpenStruct)

  if response.error != nil
    bot.api.send_message(chat_id: message.chat.id, text: response.error)
  else
    response.updated_members.each do |updated_member|
      bot.api.send_message(chat_id: message.chat.id, text: "Die Strafen von #{updated_member.name} wurden um #{updated_member.cost}€ erhöht")
    end

    respond_member_not_found bot, message, response
  end
end

def lost_game_players(bot, message)
  response = Faraday.patch("http://api:3000/api/v1/members")
  body = {
      "telegram_user": telegram_user(message)
  }
  payment_response = Faraday.post("http://api:3000/api/v1/member_penalties", body)

  if response.status && payment_response.status == 201
    bot.api.send_message(chat_id: message.chat.id, text: "Für jeden Spieler wurde ein verlorenes Pflichtspiel hinzugefüght")
  else
    error = JSON.parse(response.body, object_class: OpenStruct)
    bot.api.send_message(chat_id: message.chat.id, text: error.error)
  end
end

def add_penalty(bot, message, type)
  players_and_numbers = split_message(message)

  body = {
      "members": players_and_numbers,
      "telegram_user": telegram_user(message),
      "payment_type": type
  }

  response = JSON.parse(Faraday.patch("http://api:3000/api/v1/members", body).body, object_class: OpenStruct)
  response.updated_members.each do |updated_member|
    if type == "beer"
      text = "Dem Spieler #{updated_member.name} wurden #{updated_member.amount} Kisten hinzugefügt"
    else
      text = "Dem Spieler #{updated_member.name} wurden #{updated_member.amount}€ hinzugefügt"
    end
    bot.api.send_message(chat_id: message.chat.id, text: text)
  end

  respond_member_not_found bot, message, response
end

