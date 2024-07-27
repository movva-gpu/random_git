import gleam/dict
import tom

pub fn main() -> Nil {
  let _ =
    dict.from_list([
      #(
        "dev",
        tom.Table(
          dict.from_list([
            #(
              "lt",
              tom.Time(tom.TimeValue(
                hour: 7,
                minute: 6,
                second: 33,
                millisecond: 0,
              )),
            ),
            #("bool", tom.Bool(True)),
            #("int", tom.Int(123)),
            #("string", tom.String("Works")),
            #("ld", tom.Date(tom.DateValue(year: 1979, month: 5, day: 27))),
            #(
              "array",
              tom.Array([
                tom.String("Works"),
                tom.String("Fine"),
                tom.Array([tom.String("John"), tom.String("Doe"), tom.Int(54)]),
              ]),
            ),
            #(
              "ldt",
              tom.DateTime(tom.DateTimeValue(
                date: tom.DateValue(year: 1979, month: 5, day: 27),
                time: tom.TimeValue(
                  hour: 0,
                  minute: 32,
                  second: 0,
                  millisecond: 999_999,
                ),
                offset: tom.Offset(
                  direction: tom.Positive,
                  hours: 0,
                  minutes: 0,
                ),
              )),
            ),
            #("float", tom.Float(123.456)),
            #(
              "odt",
              tom.DateTime(tom.DateTimeValue(
                date: tom.DateValue(year: 1979, month: 5, day: 27),
                time: tom.TimeValue(
                  hour: 0,
                  minute: 32,
                  second: 0,
                  millisecond: 999_999,
                ),
                offset: tom.Offset(
                  direction: tom.Negative,
                  hours: 7,
                  minutes: 0,
                ),
              )),
            ),
          ]),
        ),
      ),
    ])

  Nil
}
