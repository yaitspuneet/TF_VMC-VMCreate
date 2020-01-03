# TF_VMC-VMCreate

The repo contains 2 files
    a. CreateVM.tf : This is the main terraform code configuration file
    b. vars.tf: This is the file where you declare the variables used in the main terraform code.

Besides the above 2 files, you would also need to self create a terraform.tfvars, which contains the credentials for the variables.
example for terraform.tfvars
    
    vsphere_user= "abc@vmc.local"
    vsphere_password= "vsphere password"
    vsphere_server= "VMC vCenter FQDN or IP address"
