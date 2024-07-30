pub const config_file_name = "config.toml"

pub type Field {
  Field(name: String, ftype: FieldType)
  Category(name: String)
}

pub type FieldType {
  StringField
  IntField
  FloatField
  BoolField
}

pub const config_fields = [
  Category(name: "github"), Field(name: "token", ftype: StringField),
  Field(name: "username", ftype: StringField), Category(name: "directories"),
  Field(name: "repos", ftype: StringField), Category(name: "settings"),
  Field(name: "auto_clone", ftype: BoolField),
  Field(name: "forks", ftype: BoolField),
]
