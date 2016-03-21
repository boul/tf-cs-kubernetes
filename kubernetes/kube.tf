provider "cloudstack" {
 api_url   = "https://${var.ms_host}/client/api"
 api_key = "${var.access_key}"
 secret_key = "${var.secret_key}"
}

resource "cloudstack_ssh_keypair" "kubernetes_coreos" {
  name = "kubernetes_coreos"
  
}

resource "cloudstack_network" "Network01" {
    name = "kubernetes-1"
    display_text = "nubernetes-1"
    cidr = "192.168.1.0/24"
    network_offering = "SourceNatNiciraNvpNetwork"
    zone = "${var.cs_zone}"
}



resource "cloudstack_instance" "kube-master-01" {
  zone = "${var.cs_zone}"
  service_offering = "${var.cs_offering}"
  template = "${var.cs_template}"
  name = "kube-master-01"
  network = "${cloudstack_network.Network01.id}"
  expunge = "true"
  ipaddress = "192.168.1.10"
  user_data = "${file("../cloud-config/master.yaml")}"
  keypair = "kubernetes_coreos"

  provisioner "local-exec" {
        command = "cd ../ssl/ && ./generate-keys.sh"
    }
}


resource "null_resource" "provision_master" {

  depends_on = ["cloudstack_port_forward.ssh_api_server"]

  provisioner "remote-exec" {
        inline = ["sudo mkdir -p /etc/kubernetes/ssl"]
        connection {
          host = "${cloudstack_ipaddress.public_ip.ipaddress}"
          user = "core"
          private_key = "${cloudstack_ssh_keypair.kubernetes_coreos.private_key}"

         
     }
    }

  provisioner "file" {
        source = "/tmp/kube-ssl"
        destination = "~/kube-ssl"
        connection {
          host = "${cloudstack_ipaddress.public_ip.ipaddress}"
          user = "core"
          private_key = "${cloudstack_ssh_keypair.kubernetes_coreos.private_key}"



         
     }
    }
provisioner "remote-exec" {
        inline = ["sudo mv ~/kube-ssl/*.pem /etc/kubernetes/ssl",
        "sudo chmod 600 /etc/kubernetes/ssl/*-key.pem",
        "sudo chown root:root /etc/kubernetes/ssl/*-key.pem",
        "sudo systemctl daemon-reload"
        ]
        connection {
          host = "${cloudstack_ipaddress.public_ip.ipaddress}"
          user = "core"
          private_key = "${cloudstack_ssh_keypair.kubernetes_coreos.private_key}"
          
 

  }
}
}

  # provisioner "file" {
  #       source = "../manifests"
  #       destination = "~/manifests"
  #       connection {
  #         host = "${cloudstack_ipaddress.public_ip.ipaddress}"
  #         user = "core"
         
  #    }
  #   }

  # provisioner "file" {
  #       source = "/tmp/apiserver.pem"
  #       destination = "~/apiserver.pem"
  #       connection {
  #         host = "${cloudstack_ipaddress.public_ip.ipaddress}"
  #         user = "core"
          
  #    }
  #   }

  # provisioner "file" {
  #       source = "/tmp/apiserver-key.pem"
  #       destination = "~/apiserver-key.pem"
  #       connection {
  #         host = "${cloudstack_ipaddress.public_ip.ipaddress}"
  #         user = "core"
          
  #    }
  #   }

  


# resource "null_resource" "execute" {

#   depends_on = ["null_resource.provision_certs_manifests"]
#   provisioner "remote-exec" {
#         inline = ["sudo mv ~/kube-ssl/*.pem /etc/kubernetes/ssl",
#         "sudo chmod 600 /etc/kubernetes/ssl/*-key.pem",
#         "sudo chown root:root /etc/kubernetes/ssl/*-key.pem",
#         "sudo systemctl daemon-reload"
#         ]
#         connection {
#           host = "${cloudstack_ipaddress.public_ip.ipaddress}"
#           user = "core"
#           private_key = "${cloudstack_ssh_keypair.kubernetes_coreos}"
          
 

#   }
# }
# }

resource "cloudstack_instance" "kube-worker-01" {
  depends_on = ["cloudstack_instance.kube-master-01"]
  zone = "${var.cs_zone}"
  service_offering = "${var.cs_offering}"
  template = "${var.cs_template}"
  name = "kube-worker-01"
  network = "${cloudstack_network.Network01.id}"
  expunge = "true"
  ipaddress = "192.168.1.11"
  user_data = "${file("../cloud-config/node.yaml")}"
  keypair = "kubernetes_coreos"

 
}

resource "null_resource" "provision-worker-01"{
  depends_on = ["cloudstack_instance.kube-worker-01"]
  depends_on = ["cloudstack_port_forward.ssh_api_server"]
   
   provisioner "remote-exec" {
        inline = ["sudo mkdir -p /etc/kubernetes/ssl"]
        connection {
          host = "${cloudstack_ipaddress.public_ip.ipaddress}"
          user = "core"
          port = 2222
          private_key = "${cloudstack_ssh_keypair.kubernetes_coreos.private_key}"

         
     }
    }

  provisioner "file" {
        source = "/tmp/kube-ssl"
        destination = "~/kube-ssl"
        connection {
          host = "${cloudstack_ipaddress.public_ip.ipaddress}"
          user = "core"
          port = 2222
          private_key = "${cloudstack_ssh_keypair.kubernetes_coreos.private_key}"



         
     }
    }
provisioner "remote-exec" {
        inline = ["sudo mv ~/kube-ssl/*.pem /etc/kubernetes/ssl",
        "sudo chmod 600 /etc/kubernetes/ssl/*-key.pem",
        "sudo chown root:root /etc/kubernetes/ssl/*-key.pem",
        "cd /etc/kubernetes/ssl/ && sudo ln -s kube-worker-1-worker.pem worker.pem && sudo ln -s kube-worker-1-worker-key.pem worker-key.pem",
        "sudo systemctl daemon-reload"
        ]
        connection {
          host = "${cloudstack_ipaddress.public_ip.ipaddress}"
          user = "core"
          port = 2222
          private_key = "${cloudstack_ssh_keypair.kubernetes_coreos.private_key}"
          
 

  }
}
}


resource "cloudstack_instance" "kube-worker-02" {
  depends_on =["cloudstack_instance.kube-master-01"]
  zone = "${var.cs_zone}"
  service_offering = "${var.cs_offering}"
  template = "${var.cs_template}"
  name = "kube-worker-02"
  network = "${cloudstack_network.Network01.id}"
  expunge = "true"
  ipaddress = "192.168.1.12"
  user_data = "${file("../cloud-config/node.yaml")}"
  keypair = "kubernetes_coreos"

  
}

resource "null_resource" "provision-worker-02" {
  depends_on = ["cloudstack_instance.kube-worker-02"]
  depends_on = ["cloudstack_port_forward.ssh_api_server"]
 
  provisioner "remote-exec" {
        inline = ["sudo mkdir -p /etc/kubernetes/ssl"]
        connection {
          host = "${cloudstack_ipaddress.public_ip.ipaddress}"
          user = "core"
          port = 3222
          private_key = "${cloudstack_ssh_keypair.kubernetes_coreos.private_key}"

         
     }
    }

  provisioner "file" {
        source = "/tmp/kube-ssl"
        destination = "~/kube-ssl"
        connection {
          host = "${cloudstack_ipaddress.public_ip.ipaddress}"
          user = "core"
          port = 3222
          private_key = "${cloudstack_ssh_keypair.kubernetes_coreos.private_key}"



         
     }
    }
provisioner "remote-exec" {
        inline = ["sudo mv ~/kube-ssl/*.pem /etc/kubernetes/ssl",
        "sudo chmod 600 /etc/kubernetes/ssl/*-key.pem",
        "sudo chown root:root /etc/kubernetes/ssl/*-key.pem",
        "cd /etc/kubernetes/ssl/ && sudo ln -s kube-worker-2-worker.pem worker.pem && sudo ln -s kube-worker-2-worker-key.pem worker-key.pem",
        "sudo systemctl daemon-reload"
        ]
        connection {
          host = "${cloudstack_ipaddress.public_ip.ipaddress}"
          user = "core"
          port = 3222
          private_key = "${cloudstack_ssh_keypair.kubernetes_coreos.private_key}"
          
 

  }
}
}

resource "cloudstack_ipaddress" "public_ip" {
  network = "${cloudstack_network.Network01.id}"
  depends_on = ["cloudstack_instance.kube-master-01"]
}

resource "cloudstack_firewall" "public_ip" {
  ipaddress = "${cloudstack_ipaddress.public_ip.id}"

  rule {
    source_cidr = "84.105.28.192/32"
    protocol = "tcp"
    ports = ["1222","2222","3222", "80","8080","30831","22","6443"]
  }

   rule {
    source_cidr = "195.66.90.65/24"
    protocol = "tcp"
    ports = ["1222","2222","3222", "80","8080","30831","22","6443"]
  }
}

resource "cloudstack_egress_firewall" "egress1" {
  network = "kubernetes-1"

  rule {
    source_cidr = "0.0.0.0/0"
    protocol = "tcp"
    ports = ["1-65535"]
  }
  rule {
    source_cidr = "0.0.0.0/0"
    protocol = "udp"
    ports = ["1-65535"]
  }
  rule {
    source_cidr = "0.0.0.0/0"
    protocol = "icmp"
  }
}


resource "cloudstack_port_forward" "ssh_api_server" {
  ipaddress = "${cloudstack_ipaddress.public_ip.id}"
  depends_on = ["cloudstack_firewall.public_ip"]
  depends_on = ["cloudstack_instance.kube-master-01"]
  depends_on = ["cloudstack_instance.kube-worker-01"]
  depends_on = ["cloudstack_instance.kube-worker-02"]


  forward {
    protocol = "tcp"
    private_port = "22"
    public_port = "1222"
    virtual_machine = "kube-master-01"
  }


  forward {
    protocol = "tcp"
    private_port = "22"
    public_port = "22"
    virtual_machine = "kube-master-01"
  }

  forward {
    protocol = "tcp"
    private_port = "22"
    public_port = "2222"
    virtual_machine = "kube-worker-01"
  }

  forward {
    protocol = "tcp"
    private_port = "22"
    public_port = "3222"
    virtual_machine = "kube-worker-02"
  }

  forward {
    protocol = "tcp"
    private_port = "8080"
    public_port = "8080"
    virtual_machine = "kube-master-01"
  }
  forward {
    protocol = "tcp"
    private_port = "6443"
    public_port = "6443"
    virtual_machine = "kube-master-01"
  }
}


