resource "google_service_account" "cicd-test2" {
  account_id   = "nghia-accounttestcicd"
  display_name = "NghiaCICD"
}

#Jenkins sv
resource "google_compute_instance" "jenkins-sv" {
  name         = "jenkins-sv"
  machine_type = "e2-small"
  zone         = "asia-southeast1-a"


  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
    }
  }

  network_interface {
    # A default network is created for all GCP projects
    network = "default"
    access_config {
    }
  }

  network_interface {
    # A default network is created for all GCP projects
    network = "private-network-cicd"
    subnetwork = "private-network-cicd"
  }

  metadata_startup_script = "apt-get update -y"

  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email  = google_service_account.cicd-test2.email
    scopes = ["cloud-platform"]
  }
}

#Jenkins Agent
resource "google_compute_instance" "jenkins-agent" {
  name         = "jenkins-agent"
  machine_type = "e2-small"
  zone         = "asia-southeast1-a"


  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
    }
  }

  network_interface {
    # A default network is created for all GCP projects
    network = "default"
    access_config {
    }
  }

  metadata_startup_script = "apt-get update -y"

  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email  = google_service_account.cicd-test2.email
    scopes = ["cloud-platform"]
  }
}

#SonarQube SV 
resource "google_compute_instance" "sonar-sv" {
  name         = "sonar-sv"
  machine_type = "e2-medium"
  zone         = "asia-southeast1-a"


  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
    }
  }

  network_interface {
    # A default network is created for all GCP projects
    network = "default"
    access_config {
    }
  }

  metadata_startup_script = "apt-get update -y"

  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email  = google_service_account.cicd-test2.email
    scopes = ["cloud-platform"]
  }
}

#Nexus Repository Server
resource "google_compute_instance" "nexus-sv" {
  name         = "nexus-sv"
  machine_type = "e2-small"
  zone         = "asia-east2-a"


  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
    }
  }

  network_interface {
    # A default network is created for all GCP projects
    network = "default"
    access_config {
    }
  }

  metadata_startup_script = "apt-get update -y"

  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email  = google_service_account.cicd-test2.email
    scopes = ["cloud-platform"]
  }
}

resource "google_container_cluster" "cluster" {
  name     = "myk8scluster"
  location = "asia-southeast1-a"

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1
}

resource "google_container_node_pool" "node1" {
  name       = "node1"
  cluster    = google_container_cluster.cluster.id
  node_count = 1

  node_config {
    preemptible  = true
    machine_type = "e2-small"

    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    service_account = google_service_account.cicd-test2.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}