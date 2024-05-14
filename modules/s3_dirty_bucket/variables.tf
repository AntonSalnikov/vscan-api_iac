variable "dirty_access_logs_bucket_name" {
  description = "Name of S3 bucket for dirty bucket access logs"
  type        = string
}

variable "storage_dirty_bucket_name" {
  description = "Name of S3 bucket for dirty data"
  type        = string
}

variable "tags" {
    description = "Map of tags to add"
    type        = map
    default     = null
}
