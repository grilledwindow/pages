+++
title = "FourX: Better Board and Algorithms"
date = 2025-03-31

[taxonomies]
series = ["fourx"]
tags = ["all", "elixir"]
+++

## The Board
Previously, I used a flat map to represent the Connect Four board.
While implementing some features, I realised that the extra calculations and mental overhead required when using a flatmap representation negates whatever small benefits it brought.
The nested representation felt more intuitive and easier to reason about.

Alright, let's start over... 

\* If you're interested, you can read the previous article about the flatmap representation [here](@/blog/fourx/board.md).

The usual Connect Four board has the dimensions `{ny: 6, nx: 7}`, where `{y: 0, x: 0}` is the start point at the bottom left.
Each position on the board can have one of three states: `nil | 0 | 1`.
1. `nil`: empty slot, displayed as `-`
2. `0`: disc placed by Player 1, displayed as `1`
3. `1`: disc placed by Player 2, displayed as `2`

In this board, Player 1 wins with the following disc positions: `[(0, 1), (1, 2), (2, 3), (3, 4)]`.
```
5   - - - - - - -
4   - - - - - - -
3   - - - - 1 - -
2   - - - 1 2 - -
1   - - 1 1 2 - -
0   - 1 2 2 2 1 -

y/x 0 1 2 3 4 5 6
 ```
\
The board is initiated with all values as `nil` using `Map.new/2`.
It can be thought of as the equivalent of a nested array in other programming languages, i.e. `board[ny][nx]`.
```elixir
def create_board(ny, nx) do
  col = Map.new(0..ny-1, &{&1, nil})
  Map.new(0..nx-1, &{&1, col})
end
```

## Find Adjacent Discs
### Four Ways, Four Deltas
To win in Connect Four, you need to connect four discs in a row, in four possible directions.
Each direction maps to a `delta = {dy, dx}`, which is the difference between any two adjacent pieces in a winning pattern.
Consider this fictitious board with each winning pattern shown:
```
5   - - - 2 2 2 2
4   1 - - - - - -
3   - 1 - 1 - - 2
2   - - 1 - - - 2
1   - 1 - 1 - - 2
0   1 - - - - - 2

y/x 0 1 2 3 4 5 6
```
 1. `vertical`: `(0, 6), (1, 6), (2, 6), (3, 6)`\
 Delta: **`{1, 0}`**, i.e. `(0, 6) -> (1, 6)`
 2. `horizontal`: `(5, 3), (5, 4), (5, 5), (5, 6)`\
 Delta: **`{0, 1}`**, i.e. `(5, 3) -> (5, 4)`
 3. `diagonal_right`: `(0, 0), (1, 1), (2, 2), (3, 3)`\
 Delta: **`{1, 1}`**, i.e. `(0, 0) -> (1, 1)`
 4. `diagonal_left`: `(1, 3), (2, 2), (3, 1), (4, 0)`\
 Delta: **`{1, -1}`**, i.e. `(1, 3) -> (2, 2)`

The start point of our algorithm, `find_adjacent/4`, maps the directions to their respective `delta`s.
It then calls `find_adjacent/3` with the matched `delta` to search for adjacent elements.
```elixir
def find_adjacent(board, player, {ny, nx}, direction) do
  {dy, dx} = case direction do
    :vertical -> {1, 0}
    :horizontal -> {0, 1}
    :diagonal_right -> {1, 1}
    :diagonal_left -> {1, -1}
  end

  find_adjacent({board, player, ny, nx, dy, dx}, {0, 0}, 0)
end
```

### Finding Adjacent Elements
To start things off, let's introduce some new parameters to keep track of a potential winning pattern.
1. `{sy, sx}`: start point of a winning pattern
2. `consecutive`: number of adjacent pieces from `{sy, sx}`\
Additionally, `{ty, tx}` is derived from `{sy, sx}` and refers to the position the next adjacent piece should be in.
I'll elaborate on `{sy, sx}` and `{ty, tx}` later, for now just be aware of what they're used for.
```elixir
def find_adjacent(game={board, player, ny, nx, dy, dx}, {sy, sx}, consecutive) do
  {ty, tx} = {sy + dy * consecutive, sx + dx * consecutive}
  cond do
    (sy == ny - 1 and sx == nx - 1) or consecutive === 4 -> {sy, sx, consecutive}
    sx == nx -> find_adjacent(game, {sy + 1, 0}, 0)
    board[ty][tx] == player -> find_adjacent(game, {sy, sx}, consecutive + 1)
    true -> find_adjacent(game, {sy, sx + 1}, 0)
  end
end
```
\
The algorithm essentially works in this way, using four branches in the `cond` block:
1. Start position is at the end: `(sy == ny - 1 and sx == nx - 1)`, or when a winning pattern is found: `consecutive === 4`
2. Start position has gone beyond the x-axis: `sx == nx`\
Reset `consecutive`, since position is invalid, and restart algorithm at start of the next row `{sy + 1, 0}`
3. An adjacent piece is found: `board[ty][tx]=== player`\
Continue the algorithm by incrementing `consecutive` by 1 and reusing all other values
4. None of the above conditions was met.\
Reset `consecutive` and restart algorithm at the next position `{sy, sx + 1}`

To make things simpler, conditions 2 and 4 work together.
When condition 4 moves the algorithm along the x-axis, it may go out of range.
This is when condition 2 steps in and helps move the algorithm up the y-axis.

My method of finding the `nth` adjacent piece in a winning pattern involves applying `delta * consecutive` to the start position, where the `nth` piece corresponds to `consecutive`: `{ty, tx} = {sy + dy * consecutive, sx + dx * consecutive}`
You might have noticed that I don't replace the `{sy, sx}` parameter when adjacent pieces are found.
This is so that the algorithm can restart properly if the potential winning pattern is found.

Take a look at this board:
```
2   - - - 
1   - 1 - 
0   1 2 - 

y/x 0 1 2 
```
The `diagonal_right` algorithm searching for Player 1's discs starts from `(0, 0)`. Note that `delta = {1, 1}`, and `{ty, tx} = {sy + dy * consecutive, sx + dx * consecutive}`.

Let's go through this board:
1. Start: `{sy = 0, sx = 0}` and `consecutive = 0`. `{ty = 0, tx = 0}`\
  Adjacent piece is found at `{0, 0}`
2. `{sy = 0, sx = 0}` and `consecutive = 1`. `{ty = 1, tx = 1}`\
  Adjacent piece is found at `{1, 1}`
3. `{sy = 0, sx = 0}` and `consecutive = 2`. `{ty = 2, tx = 2}`\
  Adjacent piece is **not** found at `{2, 2}`
4. (*Condition 4*) Restart algorithm at `{sy = 0, sx = 1}`\
  And so on... The algorithm continues until it reaches `(2, 2)` in this case

Notice how after the adjacent piece wasn't found, the algorithm was able to restart at `(0, 1)`, the position after `(0, 0)`?
This is why keeping track of the start position is so important.

## Closing Thoughts
As I wrote this article and explained my solutions, I managed to bridge some gaps in parts of my code that weren't cohseive or didn't make sense.
I'm really happy I managed to find a better solution to the one I originally thought of.
The code is now more intuitive and concise, enhancing readability and maintainability.

