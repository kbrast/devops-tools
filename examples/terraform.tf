# Install Terraform on your server
# wget https://releases.hashicorp.com/terraform/1.0.7/terraform_1.0.7_linux_amd64.zip
# unzip terraform_1.0.7_linux_amd64.zip
# sudo mv terraform /usr/local/bin/

# Create a configuration file that defines your resources
# cat > main.tf << EOF
provider "vsphere" {
  user                 = "admin@vsphere.local"
  password             = "secret"
  vsphere_server       = "192.168.1.100"
  allow_unverified_ssl = true
}

data "vsphere_datacenter" "dc" {
  name = "dc1"
}

data "vsphere_datastore" "datastore" {
  name          = "datastore1"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_resource_pool" "pool" {
  name          = "cluster1/Resources"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "network" {
  name          = "network1"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_virtual_machine" "template" {
  name          = "ubuntu-20.04"
  datacenter_id = data.vsphere_datacenter.dc.id
}

resource "vsphere_virtual_machine" "vm" {
  count            = 3
  name             = "web${count.index + 1}"
  resource_pool_id = data.vsphere_resource_pool.pool.id
  datastore_id     = data.vsphere_datastore.datastore.id

  num_cpus = 2
  memory   = 4096
  guest_id = data.vsphere_virtual_machine.template.guest_id

  network_interface {
    network_id = data.vsphere_network.network.id
  }

  disk {
    label            = "disk0"
    size             = data.vsphere_virtual_machine.template.disks.0.size
    eagerly_scrub    = data.vsphere_virtual_machine.template.disks.0.eagerly_scrub
    thin_provisioned = data.vsphere_virtual_machine.template.disks.0.thin_provisioned
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id

    customize {
      linux_options {
        host_name = "web${count.index + 1}"
        domain    = "local"
      }

      network_interface {
        ipv4_address = "192.168.1.1${count.index + 1}"
        ipv4_netmask = 24
      }

      ipv4_gateway    = "192.168.1.1"
      dns_server_list = ["192.168.1.1"]
    }
  }
}
# EOF

# Initialize Terraform on your server
# terraform init

# Plan your infrastructure changes
# terraform plan

# Apply your infrastructure changes
# terraform apply

# Destroy your infrastructure
# terraform destroy
