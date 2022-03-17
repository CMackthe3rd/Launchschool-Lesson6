require 'pry'
require 'io/console'

# cards #

CARDS = ['Ace', '2', '3', '4', '5', '6', '7', '8', '9', '10',
         'Jack', 'Queen', 'King']
SUITS = ['hearts', 'spades', 'clubs', 'diamonds']

HIT_MSG = <<-MSG

Please press the number that represents your choice: 
1) Hit
2) Stay

MSG

NEW_GAME = <<-MSG
Would you like to play another game? (y/n)
MSG

RULES = <<-MSG
+------------------------------+ The rules are simple! +-------------------------------------+
|  The goal of '21' is to beat the dealer's hand without going over 21.                      |
|  Face cards are worth 10. Aces are worth 1 or 11, whichever makes a better hand.           |
|  Each player starts with two cards, one of the dealer's cards is hidden until the end.     |
|  To 'Hit' is to ask for another card. To 'Stay' is to hold your total and end your turn.   |
|  If you go over 21 you bust, and the dealer wins regardless of the dealer's hand.          |
|  Dealer will hit until his/her cards total 17 or higher.                                   |
+-----------------------------+ Press any key to continue +----------------------------------+
MSG

# maxmin counts #

MAX_VALUE = 21

DEALER_MIN = 17

# GAME MECHANICS METHODS #

def initial_deck # step 1
  CARDS.product(SUITS).shuffle
end

def deal_card(deck, hand)
  hand << deck.pop
end

def deal_initial_hand(deck, player)
  2.times do |_|
    deal_card(deck, player)
  end
end

def total(hand)
  values = hand.map { |card| card[0] }

  sum = 0
  values.each do |value|
    if value == "Ace"
      sum += 11
    elsif value.to_i == 0
      sum += 10
    else
      sum += value.to_i
    end
  end

  values.select { |value| value == "Ace" }.count.times do
    sum -= 10 if sum > 21
  end

  sum
end

# MESSAGE METHODS #

def break_txt
  puts "-----------------"
end

def player_hand_msg(hand)
  break_txt
  puts "You are currently holding:"
  hand.each { |sub| puts "#{sub[0]} of #{sub[1]}."}
  puts "Player's current hand's total is #{total(hand)}."
end

def dealer_hand_msg(hand)
  break_txt
  puts "Dealer is currently holding:"
  puts "#{hand[0][0]} of #{hand[0][1]} and an unknown card."
end

def play_again?
  break_txt
  puts NEW_GAME
  break_txt
end

def win_msg
  break_txt
  puts "You win this hand!"
end

def bust_msg_player(player)
  if bust?(player)
    puts "It's a bust for the player!"
  end
end

def bust_msg_dealer(dealer)
  if bust?(dealer)
    break_txt
    puts "It's a bust for the dealer!"
  end
end

def loss_msg
  break_txt
  puts "The Dealer wins this hand!"
end

def tie_msg
  break_txt
  puts "Your hands are tied!"
end

# GAME LOOP METHODS #

def hit_or_stay?(deck, hand)
  loop do
    player_hand_msg(hand)
    puts HIT_MSG
    answer = gets.chomp.to_i
    deal_card(deck, hand) if answer == 1
    break_txt
    puts "Please select 1 or 2." if ![1, 2].include?(answer)
    break if answer == 2 || bust?(hand)
  end
  # system 'clear'
end

def bust?(hand)
  total(hand) > MAX_VALUE
end

def player_loop(deck, player)
  # player_hand_msg(player)
  hit_or_stay?(deck, player)
  # player_hand_msg(player)
  # bust_msg_player(player) if total(player) > MAX_VALUE
  sleep(2)
end

def win_condition(win, loss)
  total(win) > total(loss) &&
    !bust?(win)
end

def game_end?(p1, p2)
  win_condition(p1, p2)
end

def win_loss_tie(player, computer)
  if win_condition(player, computer) || bust?(computer)
    win_msg
  elsif win_condition(computer, player) || bust?(player)
    loss_msg
  elsif total(computer) == total(player)
    tie_msg
  end
end

def hit_condition(player, computer)
  DEALER_MIN > total(computer) && total(player) > total(computer) ||
    !bust?(computer)
end

def stay_condition(player, computer)
  total(computer) == MAX_VALUE || total(computer) >= total(player) ||
    bust?(player)
end

def dealer_hit?(deck, player, computer)
  loop do
    if hit_condition(player, computer)
      deal_card(deck, computer)
    elsif stay_condition(player, computer)
      total(computer)
      break
    elsif bust?(computer)
      break
    end
  end
end

def computer_loop(deck, player, computer)
  loop do
    system 'clear'
    break if total(computer) >= MAX_VALUE
    break if stay_condition(player, computer)
    dealer_hit?(deck, player, computer)
  end
end

def reveal_deck(player, computer)
  system 'clear'
  puts "You are currently holding:"
  player.each { |sub| puts "#{sub[0]} of #{sub[1]}." }
  puts "Player's current hand's total is #{total(player)}."
  break_txt
  sleep(2)
  puts "The dealer is currently holding:"
  computer.each { |sub| puts "#{sub[0]} of #{sub[1]}." }
  puts "Dealer's current hand's total is #{total(computer)}."
end

def game_loop(deck)
  system 'clear'
  player = []
  computer = []
  loop do
    deal_initial_hand(deck, player)
    deal_initial_hand(deck, computer)
    dealer_hand_msg(computer)
    player_loop(deck, player)
    player_hand_msg(player)
    break if bust?(player)
    computer_loop(deck, player, computer)
    break if bust?(computer)
    break if win_condition(player, computer) || win_condition(computer, player)
  end
  end_game_loop(player, computer)
end

def end_game_loop(player, computer)
  loop do
    break unless bust_msg_player(player)
    break unless bust_msg_dealer(computer)
  end
  reveal_deck(player, computer) if !bust?(player)
  bust_msg_dealer(computer)
  win_loss_tie(player, computer)
end

# METHODS ABOVE THIS LINE #

system 'clear'
puts RULES
STDIN.getch
loop do
  deck = initial_deck
  game_loop(deck)
  play_again?
  answer = gets.chomp
  break unless answer.downcase.start_with?('y')
end

puts "Thanks for playing '21'! Good-bye!"
