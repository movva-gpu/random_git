import utils/color

pub type Argument {
  InAngleBrackets(name: String)
  InSquareBrackets(name: String)
  NoBrackets(name: String)
}

pub type Command {
  Command(
    name: String,
    description: String,
    arguments: List(Argument),
    color: color.AnsiColor,
  )
}

pub type GlobalFlag {
  GlobalFlag(name: String, description: String, arguments: List(Argument))
}
