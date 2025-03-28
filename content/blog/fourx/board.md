+++
title = "FourX: The Board and Winning Positions"
date = 2025-03-28

[taxonomies]
series = ["fourx"]
tags = ["all", "elixir"]
+++

## The Board
In this article, I go through how I implemented the board structure and algorithms for finding winning positions, aka four connecting discs.
Interestingly, Elixir doesn't have arrays as a native data type. `List` exists as a linked list implementation, which means O(n) access time.
Hence, I opted to use a map instead.

To make calculations easier, I represent the board as a flat map.
The length of the map is `n = nx * ny`, where `nx` is the number of elements in each row and `ny` is the number of elements in each column.
Every `nx` number of elements is a new row.
The usual Connect Four board has the dimensions `{nx: 7, ny: 6}`, with the following visual representation:
```
  0  1  2  3  4  5  6
  7  8  9 10 11 12 13
 14 15 16 17 18 19 20
 21 22 23 24 25 26 27
 28 29 30 31 32 33 34
 35 36 37 38 39 40 41
 ```
\
Each position on the board can have one of three states: `nil | 0 | 1`.
1. `nil`: slot is empty
2. `0`: disc placed by Player 1
3. `1`: disc placed by Player 2

The board is initiated with all values as `nil`:
```elixir
def create_board(nx, ny) do
  len = nx * ny - 1
  Map.new(0..len, &{&1, nil})
end
```

## Find Adjacent Discs
### Four Ways to Win
There are four directions/ways discs can be connected: `vertical`, `horizontal`, `diagonal_right`, and `diagonal_left`.
To check if two discs `{curr, next}` are adjacent in a specified direction, a simple condition can be used: `curr + diff === next` where `diff` is defined by which direction we're checking.

To visualise it better, consider this fictitious board with four winning positions in different directions:
```
  -  -  -  3  4  5  6
  -  8  -  -  -  -  -
 14  - 16  -  -  - 20 
 21  -  - 24  - 26  -
 28  -  -  - 32  -  -
 35  -  - 38  -  -  -
 ```

 1. `vertical`: `[14, 21, 28, 35]`. The difference between each element is `nx = 7`
 2. `horizontal`: `[3, 4, 5, 6]`. The difference between each element is `1`
 3. `diagonal_right`: `[8, 16, 24, 32]`. The difference between each element is `nx + 1 = 8`
 4. `diagonal_left`: `[20, 26, 32, 38]`. The difference between each element is `nx - 1 = 6`

The start point of our algorithm, the function `find_adjacent/3`, matches the directions accordingly:
```elixir
def find_adjacent(map, nx, direction) do
  diff = case direction do
    :vertical -> nx
    :horizontal -> 1
    :diagonal_right -> nx + 1
    :diagonal_left -> nx - 1
  end

  find_adjacent(Map.keys(map), nx, diff, 0, 1)
end
```
\
Adjacent discs must be exactly one row apart, with the exception of `horizontal` where discs must be on the same row.
This is important to check as there would be broken patterns otherwise.
Consider the following board of calculated winning positions with no consideration of row number:
```
  -  -  -  -  -  -  6
  7  8  9  - 11  -  -
  -  -  -  -  - 19  - 
  -  - 23  -  -  - 27
  - 29  -  -  -  -  -
 35  -  -  -  -  - 41
 ```
 1. `horizontal`: `[6, 7, 8, 9]`. The difference between each element is `1`
 2. `diagonal_right`: `[11, 19, 27, 35]`. The difference between each element is `nx + 1 = 8`, but `27` and `35` are two rows apart
 3. `diagonal_left`: `[23, 29, 35, 31]`. The difference between each element is `nx - 1 = 6`, but `35` and `41` are on the same row (zero rows apart)

I implemented a simple recursive `get_row/2` function to get the row number of a given position.
Each time it calls itself, it adds 1 and subtracts `diff` from `x` until it becomes negative.
```elixir
# 1-indexed
defp get_row(x, diff) do
  if x < 0 do 0 else 1 + get_row(x - diff, diff) end
end
```

### Finding Adjacent Elements
It's finally time to jump to the main part of the algorithm.
Take a look at the following code:
```elixir
def find_adjacent(values, nx, diff, start_index, consecutive) do
  start = Enum.at(values, start_index)
  adj = Enum.find(values, fn x ->
    row_diff = if diff === 1 do 0 else consecutive end
    next = start + consecutive * diff
    next === x and get_row(next, nx) - get_row(start, nx) === row_diff
  end)

  cond do
    consecutive === 4 -> {start, consecutive}
    adj !== nil -> find_adjacent(values, nx, diff, start_index, consecutive + 1)
    true -> find_adjacent(values, nx, diff, start_index + 1, 1)
  end
end
```

Note: `values` refers to an `Enumerable` containing positions of a player's discs.
Currently, it is retrieved by using `Map.filter(fn {_k, v} -> v === player end)`.

The `start_index` parameter is used to track the current element being checked, referred to as `start`.
`consecutive` is used to track how many adjacent elements we are away from `start`.
We check for adjacent elements using `Enum.find/2`.
Upon successful match, the function calls itself while incrementing `consecutive` by `1` so it knows to check the next spot in the next recursion.

The conditions for an element, `next` to be considered adjacent are as follows:
1. `next === start + consecutive * diff`
2. `get_row(next, nx) - get_row(start, nx) === row_diff`, where `row_diff = 1` for all directions except for `horizontal` where `row_diff = 0`

If `consecutive` reaches the value `4`, it means that `find_adjacent/5` has found a winning position and returns.
If no adjacent element is found, `find_adjacent/5` goes to the next element on the board by calling itself with `start_index + 1` and restarts the `consecutive` counter.

### End Case
You may have noticed that I didn't cover the scenario where `find_adjacent/5` didn't manage to find any winning posiitons.
For that, I created a separate `find_adjacent/5` function with a guard checking if `start_index` is at the end.
Technically I could just do this in the main function, but I didn't want to pollute it.
In a future refactor, perhaps.
 
```elixir
def find_adjacent(values, _nx, _diff, start_index, consecutive) when
  length(values) <= start_index + 1
do
  {Enum.at(values, start_index), consecutive}
end
```

## Closing Thoughts
It was fun implementing the board and `find_adjacent` algorithm with new constraints due to the nature of functional programming.
I learned to think about state in a different manner and was forced to pick up recursion again... *sigh*
The code might not be the most efficient, but I'm glad I managed to write it and hope to learn how to optimise it as I continue exploring :)

