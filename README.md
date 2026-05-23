# Az104-Terraform-Infra
Azure platform foundation project implementing secure networking, compute, storage, monitoring, backup, governance, and Infrastructure as Code practices.

## Networking
- 3-tier subnet design (web/app/data) to enforce traffic isolation.
- NSGs applied at subnet level to cover all current and future resources.
- VNet peering between primary and secondary VNet using non-overlapping address spaces (10.0.0.0/16 and 192.168.0.0/16).
- Private DNS zone (specterdev.internal) with auto-registration on primary VNet only to avoid DNS conflicts.
