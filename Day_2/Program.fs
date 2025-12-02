open System

// Figure out - is this ID valid?
let is_invalid_part1 (i:Int64) = 
  let s = i.ToString();
  let pivot = (s.Length/2);
  let l = s[0..(pivot - 1)];
  let r = s[pivot..s.Length];
  l.Equals(r)

// Sum all the invalid IDs
let sum_invalid ((lb, ub): Int64*Int64) f =
  seq { lb .. 1L .. ub }
  |> Seq.filter f
  |> Seq.fold (fun a b -> a+b) 0L
  
// Split input range and parse integers
let get_range (s: string) = 
  s.Split "-"
  |> Array.map Int64.Parse
  |> (fun (a: Int64[]) -> (a[0], a[1] ))

// Split input into list of ranges
let get_ranges (s: string) =
  s.Split ","
  |> Array.map get_range

let input = stdin.ReadLine()

// Run above steps to get the sum of invalid IDs.
let part1 =
  get_ranges input
  |> Array.map (fun rng -> sum_invalid rng is_invalid_part1)
  |> Array.fold (fun a b -> a + b) 0L

printfn "Part 1: %A" part1

// This is probably horrible... but it works!

// Get the factors of a number in the greediest way possible
let factors (i:int) = 
  seq { 2 .. 1 .. i }
  |> Seq.filter (fun d -> i % d = 0)

// Split a string into some number of parts, as an array
let into_parts (s: string) (n: int) =
  let p = s.Length / n;
  seq { 0 .. p .. (s.Length-1) }
  |> Seq.map (fun i -> s[i..(i+p-1)])
  |> Seq.toArray

// Given an array of strings, check if they are all the same
let all_equal (parts: string[]) =
  parts
  |> Seq.fold (fun a c -> a && (c = parts[0])) true

// For a given integer - convert to string and check for runs of equal sequences
let is_invalid_part2 (i: Int64) = 
  let s = i.ToString();
  let invalids = s.Length |> factors |> Seq.filter (fun d -> all_equal (into_parts s d) ) |> Seq.toArray;
  invalids.Length > 0
  
// Sum invalid IDs (using part2 method)
let part2 =
  get_ranges input
  |> Array.map (fun rng -> sum_invalid rng is_invalid_part2)
  |> Array.fold (fun a b -> a + b) 0L

printfn "Part 2: %A" part2
