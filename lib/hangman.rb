# frozen_string_literal: true

require 'rainbow'
require 'yaml'

# Creates a new game
class Game
  def initialize
    @word = Word.new
    @counter = 10
  end

  def looper
    while @answer.blanks.include?('_') && @counter.positive?
      if @answer.incorrects.include?(@guess = gets.chomp)
        puts 'You already guessed that letter'
        puts "\n#{@answer.update(@guess)}   #{@counter}   #{@answer.incorrects_displayed.join(' ')}"
        next
      elsif @guess.downcase == 'save'
        break
      end
      print "\n#{@answer.update(@guess)}   "
      @counter -= 1 if @answer.corrects.empty? && @answer.valid?(@guess)
      puts "#{@counter}   #{@answer.incorrects_displayed.join(' ')}"
    end
  end

  def play
    puts 'Press 1 to start a new game, or 2 to load a game'
    input = gets.chomp
    if input == '1'
      word = @word.choose
      @answer = Answer.new(word)
      blanks = @answer.show
    elsif input == '2'
      contents = self.deserialize
      @answer = contents[:answer]
      @counter = contents[:counter]
      blanks = @answer.blanks
    end

    puts "\n#{blanks}   #{@counter}"
    self.looper

    if @guess.downcase == 'save'
      contents = { answer: @answer, counter: @counter }
      serialize(contents)
      return
    end

    if @counter.zero?
      puts "\nYou lose! The word was #{word}"
    elsif @counter.positive?
      puts "\nYou win! Yaysies!"
    end
  end

  def serialize(contents)
    puts 'What would you like to name your game?'
    filename = gets.chomp
    Dir.mkdir('saved') unless Dir.exist?('saved')
    File.open("./saved/#{filename}.yml", 'w') { |file| file.write(YAML.dump(contents)) }
    puts 'Successfully saved'
  end

  def deserialize
    return unless Dir.exist?('saved')

    puts 'Which game would you like to load?'
    filename = gets.chomp
    File.open("saved/#{filename}.yml", 'r') { |file| YAML.load(file) }
  end

  # Creates words using the dictionary
  class Word
    attr_accessor :chosen

    def initialize
      @dictionary = File.readlines('5desk.txt').map(&:chomp)
      @chosen = ''
    end

    def choose
      until @chosen.length >= 5 && @chosen.length <= 12
        index = rand(0..@dictionary.length - 1)
        @chosen = @dictionary[index]
      end
      @chosen
    end
  end

  # Contains functionality to display the blanks/answer and to allow the player to make guesses
  class Answer
    attr_accessor :blanks, :corrects, :incorrects, :incorrects_displayed

    def initialize(answer)
      @answer = answer.downcase
      @length = answer.length
      @corrects = []
      @corrects_letters = []
      @incorrects_displayed = []
      @incorrects = []
    end

    def show
      @blanks = ''.rjust(@length, '_')
    end

    def valid?(guess)
      guess.length == 1 && ('a'..'z').to_a.include?(guess) ? true : false
    end

    def give_error(guess)
      puts 'Invalid input. Please input one letter' unless valid?(guess)
    end

    def update(guess)
      guess.downcase!
      give_error(guess)

      @corrects = @answer.each_char.with_index.map { |letter, index| index if letter == guess }
      @corrects.compact!

      @incorrects.push(guess) unless @incorrects.include?(guess)
      if @corrects.empty?
        @incorrects_displayed.push(Rainbow(guess).red) unless incorrects_displayed.include?(Rainbow(guess).red)
      else
        @incorrects_displayed.push(Rainbow(guess).green) unless incorrects_displayed.include?(Rainbow(guess).green)
      end

      @corrects.each { |index| @blanks[index] = guess }
      @blanks
    end
  end
end

Game.new.play
