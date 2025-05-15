resource "google_compute_network" "vpc" {
  name                    = "gallery-vpc"
  auto_create_subnetworks = false 
}

resource "google_compute_subnetwork" "subnet" {
  name          = "gallery-subnet"
  ip_cidr_range = "10.0.0.0/16"
  region        = "us-central1"
  network       = google_compute_network.vpc.id
}

resource "google_compute_firewall" "allow_app_port" {
  name    = "allow-app-port"
  network = google_compute_network.vpc.name
  allow {
    protocol = "tcp"
    ports    = ["8080", "80", "443", "22"]  # Match your app's port
  }
  source_ranges = ["0.0.0.0/0"]
}

resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.vpc.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
}

resource "google_compute_global_address" "private_ip_address" {
  name          = "private-ip-address"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.vpc.id
}

resource "google_sql_database_instance" "mysql" {
  name             = "gallery-db"
  database_version = "MYSQL_8_0"
  region           = "us-central1"

  depends_on = [google_service_networking_connection.private_vpc_connection] # Critical!
  deletion_protection = false

  settings {
    tier = "db-n1-standard-1"
    ip_configuration {
      ipv4_enabled    = true
      private_network = google_compute_network.vpc.self_link
    }
  }
}

resource "google_compute_instance" "vm" {
  name         = "gallery-vpc" # Must match exactly
  machine_type = "e2-standard-2" 
  zone         = "us-central1-a" # Double-check zone
  tags         = ["http-server", "https-server"] # Optional but helpful for firewall rules

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts" # Correct OS image
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.subnet.self_link # Subnet must exist
    access_config {} # Required for public IP
  }

  metadata_startup_script = file("startup-script.sh") # Ensure file exists
}
