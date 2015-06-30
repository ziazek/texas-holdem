# Texas Hold'em

## About

Best of Ruby Quiz, Chapter 14

Identifying and ranking poker hands. 

Ace is almost always high, but watch for exceptions in the hands. 

Ignore players who did not make it to seven cards. For the rest, we want to declare the hand they ended up with and indicate a winner, or winners in the event of a tie. We should also rearrange named hands so the five used cards are at the front of the listing. 

Listing:
- Royal Flush
- Straight Flush
- Four of a kind
- Full house
- Flush 
- Straight 
- Three of a kind
- Two pair 
- Pair 
- High card

How to break a tie:
- The higher set of cards in the listing always wins
- If still a tie, kickers come into play. If the hand doesn't use all five cards, the remaining cards are compared one at a time to see whether one player has a higher card. 

## Requirements

Ruby 2.2.2

## Usage

run `bundle install`

## Understanding the Question

Possibly useful: spaceship operator to do sorting between hands. each_cons.  

1. Skip if hand is less than 7 cards. 

2. Determine which five cards make the hand. Run down from the top of the listing to see if there is any match. If there is, move the 5 cards to the front of the listing. 

3. If it's a straight, it can't be a four of a kind or a full house

## Results

## Review

## License

This code is released under the [MIT License](http://www.opensource.org/licenses/MIT)


