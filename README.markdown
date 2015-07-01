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
`$ ./texas.rb hand.txt`

Don't forget `chmod +x texas.rb`

## Understanding the Question

Possibly useful: spaceship operator to do sorting between hands. each_cons.  

1. Skip if hand is less than 7 cards. 

2. Determine which five cards make the hand. Run down from the top of the listing to see if there is any match. If there is, move the 5 cards to the front of the listing. 

3. If it's a straight, it can't be a four of a kind or a full house

4. Need to sort the Two Pair such that the higher pair is in front. 

5. Use Comparable mixin for comparisons between CardSets

## Notes

`cons` in the code refers to consecutive sets of cards pumped in by `each_cons`

Ruby-like commenting is enabled for source files. Just put a `#` on any line that should be ignored.

## Results

```
Kc Ks Kd 9s 9d 6d 3c Full House (Winner)
Kd Ks 9c 9d Ah 6d 3c Two Pair
Ac Qc Ks Kd 9d 3c
9h 5s
Kd 9d 6d 4d 2d Ks 3c Flush
7s Ts Ks Kd 9d
  0.000000   0.000000   0.000000 (  0.001515)
```

```
6h 5h 4h 3h 2h Qh 2c Straight Flush
7c 7h 7d 7s Th 4d 2d Four of a Kind
3h 3c 3s 4h 4d Qc Th Full House
8s 8h 8d Ah Tc 4s 2d Three of a Kind
Kh Qh 8h 5h 2h Tc 3s Flush
Qc Qh
7d 6c 5c 4s 3h As Kh Straight
8c 8d 7h 7d Tc 9h 2c Two Pair
7h 7d Tc 9h 8c 3d 2c Pair
Tc 9h 8c 7d 5h 3d 2c High Card
Ac Kc Qc Jc Tc Ts 6d Royal Flush (Winner)
  0.000000   0.000000   0.000000 (  0.001923)
```

## Review

- replace variable `another` with instance variable `@another` to make it DRY

## License

This code is released under the [MIT License](http://www.opensource.org/licenses/MIT)


