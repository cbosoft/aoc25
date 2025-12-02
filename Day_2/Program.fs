open System

// Figure out - is this ID valid?
let is_invalid (i:Int64) = 
  let s = i.ToString();
  let pivot = (s.Length/2);
  let l = s[0..(pivot - 1)];
  let r = s[pivot..s.Length];
  l.Equals(r)

// Sum all the invalid IDs
let sum_invalid ((lb, ub): Int64*Int64) =
  seq { lb .. 1L .. ub }
  |> Seq.filter is_invalid
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

// Run above steps to get the sum of invalid IDs.
let data =
  stdin.ReadLine()
  |> get_ranges
  |> Array.map sum_invalid
  |> Array.fold (fun a b -> a + b) 0L

printfn "Part 1: %A" data
