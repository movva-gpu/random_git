import gleam/io
pub type AnsiColor {
  Black
  Maroon
  Green
  Olive
  Navy
  Purple
  Teal
  Silver
  Grey
  Gray
  Red
  Lime
  Yellow
  Blue
  Fuchsia
  Aqua
  White
}

pub fn get_ansi_color_code(cl: AnsiColor) -> Int {
  case cl {
    Black -> 0
    Maroon -> 1
    Green -> 2
    Olive -> 3
    Navy -> 4
    Purple -> 5
    Teal -> 6
    Silver -> 7
    Grey -> 8
    Gray -> 8
    Red -> 9
    Lime -> 10
    Yellow -> 11
    Blue -> 12
    Fuchsia -> 13
    Aqua -> 14
    White -> 15
  }
}

pub fn get_darker_color(cl: AnsiColor) -> AnsiColor {
  case cl {
    Black -> Black
    Maroon -> Maroon
    Green -> Green
    Olive -> Olive
    Navy -> Navy
    Purple -> Purple
    Teal -> Teal
    Silver -> Grey
    Grey -> Black
    Gray -> Black
    Red -> Maroon
    Lime -> Green
    Yellow -> Olive
    Blue -> Navy
    Fuchsia -> Purple
    Aqua -> Teal
    White -> Silver
  }
}

pub fn get_darker_color_code(cl: Int) -> Int {
  case cl {
    0 -> 0
    1 -> 1
    2 -> 2
    3 -> 3
    4 -> 4
    5 -> 5
    6 -> 6
    7 -> 8
    8 -> 0
    9 -> 1
    10 -> 2
    11 -> 3
    12 -> 4
    13 -> 5
    14 -> 6
    15 -> 7
    _ -> 15
  }
}

pub fn dim_text(text: String) -> String {
  "\u{001b}[2m" <> text <> "\u{001b}[22m"
}

pub fn print_dim(message: String) -> Nil {
  io.print(dim_text(message))
}
pub fn println_dim(message: String) -> Nil {
  io.println(dim_text(message))
}
