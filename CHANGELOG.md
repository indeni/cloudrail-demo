# Changelog
All notable changes to this project will be documented in this file.
## [1.0.110] - (Mar 16, 2021)
### Added
Platform Enhancements (1):
- UI: Support for additional enforcement modes. Cloudrail can ignore rules within policy. It can also enforce only when a new resource will be created from Terraform and is not currently mapped to an existing resource in the cloud![image](https://user-images.githubusercontent.com/71668153/111820780-219c4880-889f-11eb-97f9-ebdbf2c92b10.png)
 
## [1.0.99] - (Mar 14, 2021)
### Added
Rule Added
Non-Context Aware (1):
- [CR-1804] Ensure all resources that can be tagged have at least one tag
Context Aware (1):
- [CR-966] Ensure VPC Endpoint for EC2 is enabled in all VPCs in use

## [1.0.87] - (Mar 11, 2021)
### Added
Platform Enhancements (1):
- UI: Support for searching for scans based on scan "source" ![image](https://user-images.githubusercontent.com/71668153/111819015-15af8700-889d-11eb-9edb-ee163a606f21.png)

## [1.0.77] - (Mar 10, 2021)
### Added
Rule Added
Non-Context Aware (3):
- [CR-1067] Ensure SSM Parameter Store SecureString strings are encrypted at rest with customer-managed CMK
- [CR-1806] Ensure each Lambda function has a non-infinite log retention
Context Aware (1):
- [CR-952] Ensure VPC Endpoint for SQS is enabled in all Availability Zones in use a VPC


## [1.0.56] - (Mar 7, 2021)
### Added
Rule Added
Non-Context Aware (2):
- [CR-806] Ensure ECS task definitions being created are set to encrypt in transit with EFS
Context Aware (1):
- [CR-1500] Ensure VPC Endpoint for SQS is enabled in all VPCs in use

## [1.0.35] - (Mar 2, 2021)
### Added
Rule Added
Context Aware (1):
- [CR-1500] Ensure Neptune database is not publicly accessible

## [1.0.16] - (Mar 25, 2021)
### Added
Rule Added:
Context Aware (1):
- [CR-1660] Ensure IAM entities' policies are managed solely in infrastructure-as-code

## [1.0.9] - (Feb 23, 2021)
### Added
Platform Enhancements (2):
- Officially launched GA of the web console! You can access it here: https://web.cloudrail.app/ 
![image](https://user-images.githubusercontent.com/71668153/111805641-71264880-888e-11eb-8dd2-b493ec4fbdc3.png)
- Added Remediation Steps for each rule
![image](https://user-images.githubusercontent.com/71668153/111804779-9ebec200-888d-11eb-806b-ba3a5f44c25f.png)

For changes made in previous versions:
- [V0.8](https://github.com/indeni/cloudrail-demo/blob/v0.8/CHANGELOG.md)
- [V0.7](https://github.com/indeni/cloudrail-demo/blob/v0.7/CHANGELOG.md)
- [V0.6](https://github.com/indeni/cloudrail-demo/blob/v0.6/CHANGELOG.md)
- [V0.5](https://github.com/indeni/cloudrail-demo/blob/v0.5/CHANGELOG.md)
- [V0.4](https://github.com/indeni/cloudrail-demo/blob/v0.4/CHANGELOG.md)
- [V0.3](https://github.com/indeni/cloudrail-demo/blob/v0.3/CHANGELOG.md)
- [V0.2](https://github.com/indeni/cloudrail-demo/blob/v0.2/CHANGELOG.md)
- [V0.1](https://github.com/indeni/cloudrail-demo/blob/v0.1/CHANGELOG.md)
