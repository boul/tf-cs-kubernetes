variable "access_key" { 
 description = "CS API key"
}

variable "secret_key" { 
 description = "CS secret key"
}

variable "ms_host" { 
 description = "Management Server IP"
}

variable "cs_offering" {
	description = "Cloudstack compute offering"
	default = "mcc_v1.1vCPU.4GB.SBP1"
}

variable "cs_template" {
	decription = "Cloudstack CoreOS template"
	default = "coreos-cs-boul-1"
}

variable "cs_zone" {
	description = "Cloudstack Zone"
	default = "BETA-SBP-DC-1"
}
