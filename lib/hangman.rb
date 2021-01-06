require "yaml"

class Game

  def initialize
    @secret = get_secret_word
    @progress = create_blank_array(@secret)
    @incorrect = ""
    @lives = 6
  end

  def to_yaml
    YAML.dump({
      lives: @lives,
      secret: @secret,
      incorrect: @incorrect,
      progress: @progress
    }) 
  end

  def from_yaml(string)
    data = YAML.load(string)
    data
  end

  def choose_random_word
    count = 0
    dict = File.open("5desk.txt") { |f| count = f.read.count("\n") }
    dict = File.readlines("5desk.txt")  

    random = rand(0..count)
    secret = dict[random]
  end

  def clean_word_string(word)
    word.delete_suffix!("\r\n")
    word.downcase!
    word
  end

  def get_secret_word
    bad_word = true
    while bad_word
      secret = choose_random_word
      secret = clean_word_string(secret)
      if secret.length >= 5 && secret.length <= 12
        bad_word = false
      end
    end
    secret
  end

  def get_user_guess
    puts "enter your guess: "
    guess = gets.chomp
    guess.downcase!
    guess
  end

  def check_guess(guess, secret, progress)
    secret_array = secret.split("")

    secret_array.each_with_index do |letter, idx|
      if letter == guess
        progress[idx] = letter
      end
    end
    progress
  end

  def create_blank_array(secret)
    secret_array = secret.split("")
    secret_array.map! { |letter| letter = "_" }
    secret_array.join("")
  end

  def no_progress?(guess, secret)
    !(secret.include?(guess))
  end

  def match?(progress, secret)
    progress == secret
  end

  def ask_to_save_game?
    puts "would you like to save? (y/n)"
    response = gets.chomp
    if response == "y"
      save_game
      return true
    end
    false
  end

  def save_game
    slot = 1

    while File.exist?("save#{slot.to_s}")
      slot += 1
    end
    save_slot = "save#{slot.to_s}"

    File.write(save_slot, self.to_yaml)
    puts "saved as #{save_slot}"
  end

  def ask_to_load_game
    puts "would you like to load game? (y/n)"
    response = gets.chomp
    if response == "y"
      load_game
    end
  end

  def load_game
    puts "enter save name"
    slot = gets.chomp
    reading = File.read(slot)
    data = self.from_yaml(reading)

    @lives = data[:lives]
    @secret = data[:secret]
    @incorrect = data[:incorrect]
    @progress = data[:progress]
    puts "game loaded"
  end

  def play_game
    ask_to_load_game
    puts "word is #{@secret.length} letters"
    puts @secret
    while @lives > 0
      break if ask_to_save_game?

      @guess = get_user_guess
      @progress = check_guess(@guess, @secret, @progress)

      puts "correct: #{@progress}"
      if no_progress?(@guess, @secret)
        @incorrect += "#{@guess} " unless @incorrect.include?(@guess)
        @lives -= 1
      end
      puts "lives: #{@lives}"
      puts "incorrect: #{@incorrect}"

      if match?(@progress, @secret)
        puts "you win"
        break
      end
    end
    puts "you lose" unless @lives > 0
  end
end

game = Game.new
game.play_game
