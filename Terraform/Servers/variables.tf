variable "instance_type" {
  default     = "t3.medium"
  description = "Type of the instance"
  type        = string
}


variable "default_tags" {
  default = {
    "Owner" = "rgaraween"
    "App"   = "Web"
  }
  type        = map(any)
  description = "Default tags to be appliad to all AWS resources"
}


variable "prefix" {
  default     = "assignment2"
  type        = string
  description = "Name prefix"
}



