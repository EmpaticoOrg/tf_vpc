# AWS VPC module for Terraform

A lightweight VPC module for Terraform.

## Usage

```hcl
module "vpc" {
  source          = "github.com/empaticoOrg/tf_vpc.git?ref=v0.0.3"
  environment     = "${var.environment}"
  app             = "${var.app}"
  region          = "${var.region}"
  key_name        = "${var.key_name}"
  vpc_cidr        = "${var.vpc_cidr}"
  public_subnets  = ["${var.public_subnets}"]
  private_subnets = ["${var.private_subnets}"]
}
```

See `interface.tf` for additional configurable variables.

## License

MIT

