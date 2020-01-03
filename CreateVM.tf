provider "vsphere" {                                                                 # Calling the "vSphere" Provider
  user           = var.vsphere_user
  password       = var.vsphere_password                                              # Calling the variables defined in var.tf and terraform.tfvars
  vsphere_server = var.vsphere_server

  # If you have a self-signed cert
  allow_unverified_ssl = true
}

data "vsphere_datacenter" "dc" {
  name = "SDDC-Datacenter"                                                           # The "Datacenter" name in my VMC SDDC, where workload will be deployed
}

data "vsphere_datastore" "datastore" {      
  name          = "WorkloadDatastore"                                                # The "Datastore" name in my VMC SDDC, where workload will be deployed
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_resource_pool" "pool" {
  name          = "Puneet-Demo"                                                      # The "Resource Pool" name in my VMC SDDC, where workload will be deployed
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "network" {
  name          = "Puneet-Web/App"                                                   # The "Network Segment" name in my VMC SDDC, where workload will be deployed
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_virtual_machine" "template" {
  name          = "Win2016"                                                          # The "Template" name in my VMC SDDC, used for  workload cloning
  datacenter_id = data.vsphere_datacenter.dc.id
}

resource "vsphere_tag_category" "category" {
  name = "VMC"
  cardinality = "SINGLE"
  associable_types = ["VirtualMachine"]
}                                                                                   # The "Tag Category" and "Tag" created while provisiong of Virtual Machine
 
resource "vsphere_tag" "tag" {
  name        = "Web"
  category_id = vsphere_tag_category.category.id
}

resource "vsphere_virtual_machine" "vm" {
  name             = "VMC-Demo"
  resource_pool_id = data.vsphere_resource_pool.pool.id
  datastore_id     = data.vsphere_datastore.datastore.id
  folder            = "Workloads/Terraform"                                         # The "Folder" name, where the VM will be created
  tags              = [vsphere_tag.tag.id]
  firmware         = "efi"                                                          # The firmware mode changed to "EFI" for Windows. The default is "BIOS"

  num_cpus = 2
  memory   = 4096
  guest_id = data.vsphere_virtual_machine.template.guest_id
  scsi_type = data.vsphere_virtual_machine.template.scsi_type

  network_interface {
    network_id = data.vsphere_network.network.id
    adapter_type = data.vsphere_virtual_machine.template.network_interface_types[0]
  }

  disk {
    label = "disk0"
    size  = data.vsphere_virtual_machine.template.disks.0.size
    eagerly_scrub    = data.vsphere_virtual_machine.template.disks.0.eagerly_scrub
    thin_provisioned = data.vsphere_virtual_machine.template.disks.0.thin_provisioned
  }
  
  clone {
    template_uuid = data.vsphere_virtual_machine.template.id

    customize {
      windows_options {
        computer_name  = "terraform-test"
        workgroup      = "test"
        admin_password = "VMware1!"
      }
    
      network_interface {}                                                          # Leaving this section blank, allows the VM to pick DHCP based IP address.

    }
  }
}
