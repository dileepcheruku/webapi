variable "vpc_security_group_id" {
  description = "ID of existing security group whose rules we will manage"
  type        = string
  default     = null
}
