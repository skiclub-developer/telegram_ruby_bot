def get_player_name_and_penalty_number(player)
  done = false
  counter = -1
  while !done do
    if player[counter].numeric?
      counter = counter - 1
    else
      counter = counter + 1
      done = true
    end
  end

  player_name = player[0, player.length - (counter * -1)]
  penalty_number = player[player.length - (counter * -1)]

  {name: player_name, amount: penalty_number}
end

def split_message(message)
  players = message.text.partition(' ').last
  players_with_numbers = players.split(',')
  players_and_numbers = []
  players_with_numbers.each do |player|
    players_and_numbers.push(get_player_name_and_penalty_number(player))
  end

  players_and_numbers
end

def telegram_user(message)
  "#{message.from.first_name} #{message.from.last_name}"
end

def respond_member_not_found(bot, message, response)
  response.members_not_found.each do |member_not_found|
    bot.api.send_message(chat_id: message.chat.id, text: "Der Spieler #{member_not_found} wurde nicht gefunden")
  end
end
