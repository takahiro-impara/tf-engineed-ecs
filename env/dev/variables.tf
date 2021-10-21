variable "assume_role" {
  default = "arn:aws:iam::974783918237:role/EngineedExam00122"
}

variable "username" {
  sensitive = true
  default   = "admin"
}

variable "password" {
  sensitive = true
  default   = "PassW0rd!"
}
