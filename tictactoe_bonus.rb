require 'pry'

ROUNDS_NEEDED = 2
INITIAL_MARKER = ' '
PLAYER_MARKER = 'X'
COMPUTER_MARKER = 'O'
WINNING_LINES = [[1, 2, 3], [4, 5, 6], [7, 8, 9]] + # rows
                [[1, 4, 7], [2, 5, 8], [3, 6, 9]] + # cols
                [[1, 5, 9], [3, 5, 7]]              # diagonals


# ==== DISPLAY METHODS ====== #

def prompt(msg)
  puts "=> #{msg}"
end

# rubocop:disable Metrics/AbcSize, Metrics/MethodLength
def display_board(brd)
  system 'clear'
  puts "You're a #{PLAYER_MARKER}. Computer is #{COMPUTER_MARKER}."
  puts ""
  puts "     |     |"
  puts "  #{brd[1]}  |  #{brd[2]}  |  #{brd[3]}"
  puts "     |     |"
  puts "-----+-----+-----"
  puts "     |     |"
  puts "  #{brd[4]}  |  #{brd[5]}  |  #{brd[6]}"
  puts "     |     |"
  puts "-----+-----+-----"
  puts "     |     |"
  puts "  #{brd[7]}  |  #{brd[8]}  |  #{brd[9]}"
  puts "     |     |"
  puts ""
end
# rubocop:enable Metrics/AbcSize, Metrics/MethodLength

def joinor(arr, d1= ', ', d2= 'or')
  join = ''
  return join << arr[0].to_s if arr.size == 1
  arr.map do |el|
    return join << arr[0].to_s + ' ' + d2 + ' ' + arr[1].to_s if arr.size == 2
    join << d2 + ' ' if el == arr.last
    join << el.to_s
    join << d1 unless el == arr.last
  end
  join
end

# ====== BOARD/GAME METHODS ====== #

def initialize_board
  new_board = {}
  (1..9).each { |num| new_board[num] = INITIAL_MARKER }
  new_board
end

def first_player
  prompt "Please decide who should go first: 1) Player. 2) Computer. 3) Random."

  answer = gets.chomp.to_i
  if answer == 1
    'Player'
  elsif answer == 2
    'Computer'
  elsif answer == 3
    ['Player', 'Computer'].sample
  else
    puts "That's not a valid choice. Please try again."
  end

end

def empty_squares(brd)
  brd.keys.select { |num| brd[num] == INITIAL_MARKER }
end

def alternate_player(current_player)
  # current_player == 'Computer' ? 'Computer' : 'Player'

  return 'Player' if current_player == 'Computer'
  return 'Computer' if current_player == 'Player'
end

def place_piece!(brd, player)
  return player_turn!(brd) if player == 'Player'
  return computer_turn!(brd) if player == 'Computer'
end

def player_turn!(brd)
  square = ''
  loop do
    prompt "Choose a position to place a piece: #{joinor(empty_squares(brd))}"
    square = gets.chomp.to_i
    break if empty_squares(brd).include?(square)
    prompt "Sorry, that's not a valid option."
  end
  brd[square] = PLAYER_MARKER
end

def square_risk(line, brd, risk)
  if brd.values_at(*line).count(COMPUTER_MARKER) == 2
    brd.select { |key, value| line.include?(key) && value == " " }.keys.first
  elsif brd.values_at(*line).count(risk) == 2
    brd.select { |key, value| line.include?(key) && value == " " }.keys.first
  end
  nil
end

def computer_turn!(brd)
  square = nil

  WINNING_LINES.each do |line|
    square = square_risk(line, brd, PLAYER_MARKER)
    break if square == true
  end

  if square == nil && brd[5] == INITIAL_MARKER
    square = 5
  end

  if square == nil
    square = empty_squares(brd).sample
  end

  brd[square] = COMPUTER_MARKER
end

def board_full(brd)
  empty_squares(brd).empty?
end

# ===== WINNING/END METHODS ====== #

def detect_winner(brd)
  # binding.pry
  WINNING_LINES.each do |line|
    # if brd[line[0]] == PLAYER_MARKER &&
    #    brd[line[1]] == PLAYER_MARKER &&
    #    brd[line[2]] == PLAYER_MARKER
    #   return 'Player'
    # elsif brd[line[0]] == COMPUTER_MARKER &&
    #       brd[line[1]] == COMPUTER_MARKER &&
    #       brd[line[2]] == COMPUTER_MARKER
    #   return 'Computer'
    # end
    if brd.values_at(*line).count(PLAYER_MARKER) == 3
      return 'Player'
    elsif brd.values_at(*line).count(COMPUTER_MARKER) == 3
      return 'Computer'
    end
  end
  nil
end

def someone_won?(brd)
  !!detect_winner(brd) # !! turns the output into a boolean (true/false)
end

def current_score(arr1, arr2)
  sleep(2)
  prompt "We're playing to the best of #{ROUNDS_NEEDED}!"
  puts " "
  prompt "The current score for the player is #{arr1.size}."
  puts " "
  prompt "The current score for the computer is #{arr2.size}."
  puts " "
  sleep(2)
end

def final_winner(arr1, arr2, constant)
  if arr1.size == constant
    prompt "The Player is the final winner!"
  elsif arr2.size == constant
    prompt "The Computer has defeated you!"
  end
end

def announce_round(brd)
  if someone_won?(brd)
    prompt "#{detect_winner(brd)} won this round!"
    sleep(1)
  elsif board_full(brd)
    prompt "It's a tie!"
    sleep(1)
  end
end

def add_score(brd, a1, a2)
  if detect_winner(brd) == 'Player'
    a1 << 1
  elsif detect_winner(brd) == 'Computer'
    a2 << 1
  end
end

#== GAME LOOP ==#

def game_loop(brd, player)
  loop do
    display_board(brd)
    place_piece!(brd, player)
    player = alternate_player(player)
    announce_round(brd)

    break if board_full(brd) || someone_won?(brd)
  end
end

# methods above this line

loop do

  player_rounds = []
  computer_rounds = []

  loop do

    board = initialize_board
    current_player = first_player

    current_score(player_rounds, computer_rounds)

    game_loop(board, current_player)

    add_score(board, player_rounds, computer_rounds)

    break if computer_rounds.size == ROUNDS_NEEDED
    break if player_rounds.size == ROUNDS_NEEDED

  end

  current_score(player_rounds, computer_rounds)

  final_winner(player_rounds, computer_rounds, ROUNDS_NEEDED)

  prompt "Play again? (y or n)"
  answer = gets.chomp
  break unless answer.downcase.start_with?('y')
end

prompt "Thanks for playing! Good-bye!"
