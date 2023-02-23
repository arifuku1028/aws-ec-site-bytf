variable "prefix" {
  type = string
}

variable "cache_subnet_ids" {
  type = list(string)
}

variable "cache_sg_ids" {
  type = list(string)
}

variable "node_type" {
  type = string
}

variable "clusters_count" {
  type = number
}
