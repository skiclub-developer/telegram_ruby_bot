require 'telegram/bot'
require 'json'
require './punishments'
require './payments'
require './show'

class String
  def numeric?
    Float(self) != nil rescue false
  end
end

token = '762317235:AAGAVpEswx5aAuf8ZjueYfAGCkP7bTy9fIQ'

Telegram::Bot::Client.run(token) do |bot|
  bot.listen do |message|
    instruction = message.text.partition(' ').first
    instruction = instruction[1, instruction.length]

    case instruction
    when 'bezahlen'
      pay_penalty bot, message, "money"
    when 'bezahlenkiste'
      pay_penalty bot, message, "beer"
    when 'offen'
      show_member_penalties bot, message
    when 'zeigespieler'
      list_members bot, message
    when 'listeallerzahlungen'
      list_member_payments bot, message
    when 'listeallerbierzahlungen'
      list_member_beer_payments bot, message
    when 'listeallerstrafen'
      list_all_member_penalties bot, message
    when 'pflichtspielverloren'
      lost_game_players bot, message
    when 'betragplus'
      add_penalty bot, message, "money"
    when 'kisteplus'
      add_penalty bot, message, "beer"
    else
      punish_member bot, message
    end
  end
end



