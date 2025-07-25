locals {
  out_path = module.image-build.result.out
  image_path = tolist(fileset("${module.image-build.result.out}", "*"))[0]
}

variable "region" {
  type = string

  nullable = false

  default = "NORTHAMERICA-NORTHEAST2"

  description = "Storage region"
}

variable "storage_class" {
  type = string

  nullable = false

  default = "STANDARD"

  description = "Storage class"
}

module "image-build" {
  source            = "github.com/nix-community/nixos-anywhere//terraform/nix-build"
  attribute         = ".#nixosConfigurations.gce-image.config.system.build.googleComputeImage"
}

resource "random_id" "bucket" {
  byte_length = 8
}

resource "google_storage_bucket" "nixos-images" {
 name = "nixos-images-${random_id.bucket.hex}"
 location = var.region
 storage_class = var.storage_class
}

resource "google_storage_bucket_object" "nixos-installer" {
  name = local.image_path
  source = "${local.out_path}/${local.image_path}"
  bucket = google_storage_bucket.nixos-images.id
  content_type = "application/tar+gzip"
}

resource "google_compute_image" "nixos-installer-image" {
  name     = replace(replace(trimsuffix(local.image_path, "-x86_64-linux.raw.tar.gz"), ".", "-"), "_", "-")
  family   = "nixos"

  raw_disk {
    source = "https://storage.googleapis.com/${google_storage_bucket.nixos-images.name}/${google_storage_bucket_object.nixos-installer.name}"
  }
}

output "gce-image" {
  description = "NixOS GCE Image"

  value = google_compute_image.nixos-installer-image.self_link
}
