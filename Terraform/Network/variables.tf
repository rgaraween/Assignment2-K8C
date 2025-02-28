
variable "default_tags" {
  default = {
    "Owner" = "rgarawen"
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


variable "cidr_block" {
  default     = "172.31.96.0/24"
  type        = string
  description = "Subnet CIDR"
}


