variable "rgname" {
  type = string
  description = "resource group name"
  default = "projet-log8100"
}

variable "location" {
  type = string
  default = "canadacentral"
}

variable "subscription_id" {
  
}

variable "service_principle_id" {
  
}
variable "service_principle_key" {
  
}

variable "tenant_id" {
  
}

variable "kubernetes_version" {
  type = string
  default = "1.28.5"
}

variable "ssh_key" {
  
}
