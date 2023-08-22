variable "resource_group_location" {
  default     = "eastus2"
  description = "Resource Group Location"
}

variable "prefix_lab" {
  type        = string
  default     = "RTLAB"
  description = "Prefix - Red Team Lab"
}

#----------------------------------------
# Variables - VM Auto shutdown schedules
#----------------------------------------

variable "autoshutdown_time" {
  type        = string
  default     = "1100"
  description = "Auto-shutdown time for VMs"
}

variable "autoshutdown_timezone" {
  type        = string
  default     = "Pacific Standard Time"
  description = "Timezone for auto-shutdown time"
}

variable "autoshutdown_notification_email" {
  type        = string
  default     = "<EMAIL>"
  description = "Email for auto-shutdown notification alerts"
}

variable "autoshutdown_notification_time" {
  type        = string
  default     = "15"
  description = "Notification time (in minutes) before auto-shutdown"
}