// Copyright 2025 International Digital Economy Academy
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

///|
pub(all) struct AllThree {
  ints : Array[Int]
  floats : Array[Double]
  strings : Array[String]
} derive(Eq, Show)

///|
fn[T] array_to_json(arr : Array[T], f~ : (T) -> Json) -> Json {
  Json::array(arr.map(f))
}

///|
fn to_json(self : AllThree) -> Json {
  let { ints, floats, strings } = self
  {
    "ints": ints |> array_to_json(f=x => Json::number(x.to_double())),
    "floats": floats |> array_to_json(f=Json::number(_)),
    "strings": strings |> array_to_json(f=Json::string(_)),
  }
}

///|
suberror DecodeError {
  DecodeError(String)
} derive(Eq, Show)

///|
fn of_json(jv : Json) -> AllThree raise DecodeError {
  match jv {
    {
      "ints": Array(ints),
      "floats": Array(floats),
      "strings": Array(strings),
      ..
    } => {
      let ints_result = []
      let floats_result = []
      let strings_result = []
      for n in ints {
        match n {
          Number(n, ..) => ints_result.push(n.to_int())
          _ => () // error handling here
        }
      }
      for n in floats {
        match n {
          Number(n, ..) => floats_result.push(n)
          _ => () // error handling here
        }
      }
      for s in strings {
        match s {
          String(s) => strings_result.push(s)
          _ => () // error handling here
        }
      }
      { ints: ints_result, floats: floats_result, strings: strings_result }
    }
    _ => raise DecodeError("Expected an object of ints, floats, and strings")
  }
}

///|
test {
  let all_three = AllThree::{
    ints: [1, 2, 3],
    floats: [1.0, 2.0, 3.0],
    strings: ["a", "b", "c"],
  }
  let json = all_three.to_json()
  inspect(
    try? of_json(json),
    content=(
      #|Ok({ints: [1, 2, 3], floats: [1, 2, 3], strings: ["a", "b", "c"]})
    ),
  )
  // FIXME:
  // note try? `body_no_error` is confusing
  //   Warning: [0023]
  //      │
  //  100 │     try? of_json?(json),
  //      │     ─┬─  
  //      │      ╰─── Warning: The body of this try expression never raises any error.
  // ─────╯
  // Error: [4018]
  //      │
  //  100 │     try? of_json?(json),
  //      │     ─────────┬─────────  
  //      │              ╰─────────── Type Error does not implement trait Show: package @moonbitlang/core/error is not imported, so its methods cannot be used.
  //   note: this constraint is required by `impl` of Show for type Result at moonbitlang/core/builtin/show.mbt:191:1
  // ─────╯
}
