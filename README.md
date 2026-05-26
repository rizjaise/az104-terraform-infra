# Az104-Terraform-Infra
Azure platform foundation project implementing secure networking, compute, storage, monitoring, backup, governance, and Infrastructure as Code practices.

## Networking
- 3-tier subnet design (web/app/data) to enforce traffic isolation.
- NSGs applied at subnet level to cover all current and future resources.
- VNet peering between primary and secondary VNet using non-overlapping address spaces (10.0.0.0/16 and 192.168.0.0/16).
- Private DNS zone (specterdev.internal) with auto-registration on primary VNet only to avoid DNS conflicts.

## Compute

### Virtual Machines (Planned)
- Architecture: 2 Windows Server 2022 VMs in an Availability Set
- Load Balancer: Standard SKU with HTTP health probe on port 80
- Placement: Web subnet (snet-web) only
- NIC to backend pool association configured via Terraform
- VM size: Standard_B1s

> Note: VM deployment was skipped due to Azure free tier quota restrictions
> on the target subscription. All Terraform code is written and validated
> via terraform plan. Code is available in modules/compute/main.tf

### Key Concepts Covered
- Availability Sets: protect against rack-level hardware failure within 
  a single datacenter (fault domains: 2, update domains: 5)
- Standard Load Balancer chosen over Basic for Availability Zone support
  and mandatory NSG enforcement
- Health probes automatically remove unhealthy VMs from load balancer rotation
- count meta-argument used to deploy identical resources without code repetition

### App Service (Planned)
- App Service Plan: Linux B1 SKU
- Identity: User-assigned Managed Identity (id-specter-appservice)
- App name: globally unique via random string suffix
- Always-on disabled (B1 tier limitation)

> Note: App Service deployment skipped due to Azure free tier quota 
> restrictions. Terraform code written and validated via terraform plan.
> Code available in modules/compute/appservice.tf

### Key Concepts Covered
- User-assigned Managed Identity chosen over system-assigned for 
  reusability across multiple resources
- App name requires global uniqueness — azurewebsites.net is a shared 
  public namespace
- always_on = false required on B1 tier — needs B2 or higher to enable

## Storage
### Resources Deployed
- Storage Account: Standard LRS with TLS 1.2 enforced
- Blob Container: private access (no public exposure)
- Azure File Share: 5GB quota
- Lifecycle Management Policy

### Lifecycle Policy Rules
| Trigger | Action |
|---|---|
| 30 days since last modification | Move blob to Cool tier |
| 90 days since last modification | Move blob to Archive tier |
| 365 days since last modification | Delete blob |
| 30 days since snapshot creation | Delete snapshot |

### Security Configurations
- `container_access_type = "private"` — no anonymous public access
- `min_tls_version = "TLS1_2"` — blocks older insecure TLS versions
- Blob versioning enabled — protects against accidental overwrites
- Soft delete retention: 7 days for blobs and containers

### Key Concepts Covered
- Blob Storage vs Azure Files: Blob accessed via REST API for 
  unstructured data; Azure Files uses SMB/NFS protocol and can be 
  mounted as a network drive for lift-and-shift scenarios
- SAS tokens delegate limited scoped access without exposing 
  storage account keys — scope, permissions and expiry are explicit
- Three SAS types: Account SAS (full account), Service SAS 
  (single service), User Delegation SAS (Entra ID backed, most secure)
- Hot/Cool/Archive tiers balance storage cost against access frequency
