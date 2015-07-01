#!/usr/bin/env ruby

# require 'pry-byebug'
require 'benchmark'

LIST = ["Royal Flush", "Straight Flush", "Four of a Kind", "Full House", "Flush", "Straight", "Three of a Kind", "Two Pair", "Pair", "High Card", ""]
VALUES = "AKQJT98765432".chars
SUITS = "shdc".chars

class Texas
  def initialize(sets_of_cards)
    @sets_of_cards = sets_of_cards 
    @parsed_sets = []
    @sets_of_cards.collect do |cards|
      @parsed_sets << CardSet.new(cards)
    end
    mark_winner
  end

  def render
    @parsed_sets.each do |card_set|
      puts card_set.render
    end
  end

  private 

  def mark_winner
    # use the spaceship operator to compare between CardSets?
    sorted = @parsed_sets.sort
    top_sets = sorted.take_while { |next_top| next_top == sorted.first }
    top_sets.map(&:mark_winner)
  end
end

class CardSet
  include Comparable
  attr_accessor :cards, :name

  def initialize(cards)
    @cards = cards.split(' ')
    @name = ""
    find_hand
  end

  def render
    ary = cards.push(name)
    ary.push("(Winner)") if @winner
    ary.join(' ')
  end

  def mark_winner
    @winner = true
  end

  def <=>(another)
    @another = another
    if LIST.index(name) != LIST.index(@another.name)
      # hands are different type
      return LIST.index(name) <=> LIST.index(@another.name)
    else
      # hands are of the same type
      case LIST.index(name)
      when 0, 1, 5 # straights have no kicker - just compare high card
        return compare_first_card
      when 2 # four of a kind have one kicker - compare the fours first.
        if !first_card_eql?
          # fours are different value, compare fours
          return compare_first_card
        else
          # compare kicker
          return compare_kickers { |c| c.slice(4,1) }
        end
      when 3 # full house, no kicker. Compare threes then pair
        if !first_card_eql?
          # threes are different value, compare threes
          return compare_first_card
        else
          # compare pair
          return VALUES.index(cards[3][0]) <=> VALUES.index(@another.cards[3][0])
        end 
      when 4 # flush
        return compare_kickers { |c| c.take(5) }
      when 6 # three of a kind. compare threes then the 2 kickers
        if !first_card_eql?
          return compare_first_card
        else
          return compare_kickers { |c| c.slice(3, 2) }
        end
      when 7 # two pair. compare first pair, then second pair, then kicker
        if !first_card_eql?
          return compare_first_card
        elsif VALUES.index(cards[2][0]) != VALUES.index(@another.cards[2][0])
          return VALUES.index(cards[2][0]) <=> VALUES.index(@another.cards[2][0])
        else
          return compare_kickers { |c| c.slice(4, 1) }
        end
      when 8 # pair. compare first pair, then 3 kickers
        if !first_card_eql?
          return compare_first_card
        else
          return compare_kickers { |c| c.slice(2, 3) }
        end
      else
        return compare_kickers { |c| c.take(5) }
      end 
    end
  end

  private

  def first_card_eql?
    VALUES.index(cards.first[0]) == VALUES.index(@another.cards.first[0])
  end

  def compare_first_card
    VALUES.index(cards.first[0]) <=> VALUES.index(@another.cards.first[0])
  end

  def compare_kickers
    # compare card by card until one is higher than the other. Only compare 5 cards.
    ary = yield(self.cards)
    another_ary = yield(@another.cards)
    # puts "#{ary}, #{another_ary}"
    ary.zip(another_ary).each_with_index do |card_pair, i|
      return VALUES.index(card_pair.first[0]) <=> VALUES.index(card_pair.last[0]) unless i < (ary.size-1) && VALUES.index(card_pair.first[0]) == VALUES.index(card_pair.last[0]) 
      # if it reaches the last pair of cards, just return the spaceship.
    end
  end

  def find_hand
    return cards if cards.size < 7
    check_straight # @sorted, @straight calculated here
    if is_royal_flush
      self.name = LIST[0]
    elsif is_straight_flush
      self.name = LIST[1]
    elsif is_four_of_a_kind
      self.name = LIST[2]
    elsif is_full_house # @threes calculated here
      self.name = LIST[3] 
    elsif is_flush
      self.name = LIST[4]
    elsif is_straight
      self.name = LIST[5] 
    elsif is_three_of_a_kind
      self.name = LIST[6] 
    elsif is_two_pair
      self.name = LIST[7]
    elsif is_pair
      self.name = LIST[8]
    else # is High Card
      self.cards = @sorted
      self.name = LIST[9]
    end
    cards
  end

  def check_straight
    @sorted = sort(self.cards) # find the value - e.g. "Kc" returns 1, which is the position of K in VALUES array
    # sorted must be unique by value
    unique_by_val = @sorted.uniq { |e| e[0] }
    unique_by_val.each_cons(5) do |cons|
      if find_difference_between(cons).all? { |d| d == 1 }
        # move straight to the front of the order
        @straight = cons
        return self.cards = cons + (@sorted - cons)
      end
    end 
    false
  end

  def is_royal_flush
    @straight && flush?(@straight) && ace?(@straight.first)
  end

  def is_straight_flush
    @straight && flush?(@straight)
  end

  def is_four_of_a_kind
    @sorted.each_cons(4) do |cons|
      if find_difference_between(cons).all? { |d| d == 0 }
        return self.cards = cons + (@sorted - cons)
      end
    end
    false
  end

  def is_full_house
    # find threes
    # set the remainder in a variable, or return false
    # find pair
    rem = nil
    @sorted.each_cons(3) do |cons|
      if find_difference_between(cons).all? { |d| d == 0 }
        @threes = cons
        rem = @sorted - @threes
        self.cards = @threes + (@sorted - @threes) 
        # in case there is no full house, this puts the cards in order for Three of a Kind
      end
    end
    return false unless @threes

    rem.each_cons(2) do |cons|
      if find_difference_between(cons).all? { |d| d == 0 }
        @pair = cons
        return self.cards = @threes + @pair + (rem - @pair)
      end
    end
    false
  end

  def is_flush
    sorted_by_suit = cards.sort_by { |c| c[1] }
    sorted_by_suit.each_cons(5) do |cons|
      if find_difference_between_suit(cons).all? { |d| d == 0 }
        return self.cards = sort(cons) + sort(sorted_by_suit - cons) 
        # we sort the flush so that the highest card is first, and also the kickers
      end
    end
    false
  end

  def is_straight
    @straight
  end

  def is_three_of_a_kind
    @threes
  end

  def is_two_pair
    rem = nil
    @sorted.each_cons(2) do |cons|
      if find_difference_between(cons).all? { |d| d == 0 }
        @pair = cons
        rem = @sorted - @pair
        self.cards = @pair + (@sorted - @pair)
        # in case there is no Two Pair, this puts the cards in order for Pair
      end
    end

    return false unless @pair

    rem.each_cons(2) do |cons|
      if find_difference_between(cons).all? { |d| d == 0 }
        @pair2 = cons
        # sort the Two Pair such that the higher pair is first in order
        sorted_pairs = [@pair, @pair2].sort_by { |arr| VALUES.index(arr.first[0]) }
        return self.cards = sorted_pairs.flatten + (rem - @pair2)
      end
    end    
    false
  end

  def is_pair
    @pair
  end

  def flush?(sequence)
    return false unless sequence.length == 5
    sequence.uniq { |e| e[1] }.length == 1
  end

  def ace?(card)
    card[0] == "A"
  end

  def find_difference_between(cons)
    diffs = []
    cons.each_cons(2) { |x, y| diffs << (VALUES.index(y[0]) - VALUES.index(x[0])) } 
    diffs
  end

  def find_difference_between_suit(cons)
    diffs = []
    cons.each_cons(2) { |x, y| diffs << (SUITS.index(y[1]) - SUITS.index(x[1])) } 
    diffs
  end

  def sort(card_set)
    card_set.sort_by { |c| VALUES.index(c[0]) }
  end
end

unless ARGV.length == 1 && test(?e, ARGV[0])
  puts "Usage: #{$PROGRAM_NAME} hand.txt"
  exit
end

puts Benchmark.measure {
  game = Texas.new(ARGF.readlines.map(&:chomp).reject { |l| l.include?("#") || l.empty? })
  game.render
}