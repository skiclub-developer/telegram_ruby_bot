require './helpers'

def show_member_penalties(bot, message)
  members_to_find = message.text.partition(' ').last

  response = JSON.parse(Faraday.get("#{HOST}/members?members=#{members_to_find}").body, object_class: OpenStruct)
  response.found_members.each do |found_member|
    bot.api.send_message(chat_id: message.chat.id, text: "#{found_member.name} muss noch #{found_member.current_money_penalties}€ zahlen.")
    bot.api.send_message(chat_id: message.chat.id, text: "#{found_member.name} muss noch #{found_member.current_beer_penalties} Kisten schmeißen.")
  end

  respond_member_not_found bot, message, response
end

def list_members(bot, message)
  response = JSON.parse(Faraday.get("#{HOST}/members").body, object_class: OpenStruct)
  members = []
  response.each do |member|
    members.push member.name
  end

  bot.api.send_message(chat_id: message.chat.id, text: members.join("\n"))
end

def list_member_payments(bot, message)
  member_to_find = message.text.partition(' ').last
  if member_to_find != ""
    response = JSON.parse(Faraday.get("#{HOST}/members?member=#{member_to_find}").body, object_class: OpenStruct)

    response.money_payments.each do |payment|
      date = DateTime.parse(payment.created_at)
      bot.api.send_message(chat_id: message.chat.id, text: "#{member_to_find} hat am #{date.strftime("%d.%m.%Y")} #{payment.amount}€ gezahlt.")
    end
  else
    bot.api.send_message(chat_id: message.chat.id, text: "Es muss der Name eines Spielers mit angegeben werden")
  end
end

def list_member_beer_payments(bot, message)
  member_to_find = message.text.partition(' ').last
  if member_to_find != ""
    response = JSON.parse(Faraday.get("#{HOST}/members?member=#{member_to_find}").body, object_class: OpenStruct)

    response.beer_payments.each do |payment|
      date = DateTime.parse(payment.created_at)
      bot.api.send_message(chat_id: message.chat.id, text: "#{member_to_find} hat am #{date.strftime("%d.%m.%Y")} #{payment.amount} Kisten geschmissen.")
    end
  else
    bot.api.send_message(chat_id: message.chat.id, text: "Es muss der Name eines Spielers mit angegeben werden")
  end
end

def list_all_member_penalties(bot, message)
  member_to_find = message.text.partition(' ').last
  if member_to_find != ""
    response = JSON.parse(Faraday.get("#{HOST}/member_penalties?name=#{member_to_find}").body, object_class: OpenStruct)
    response.each do |member_penalty|
      date = DateTime.parse(member_penalty.created_at)
      date_string = date.strftime("%d.%m.%Y")
      bot.api.send_message(chat_id: message.chat.id, text: "#{member_to_find} hat am #{date_string} #{member_penalty.amount} mal die Strafe #{member_penalty.penalty.penalty_name.capitalize} erhalten.")
    end
  else
    bot.api.send_message(chat_id: message.chat.id, text: "Es muss der Name eines Spielers mit angegeben werden")
  end
end