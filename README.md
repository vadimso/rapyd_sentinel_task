# Rapyd Sentinel - Proof of Concept

This repository contains a proof-of-concept implementation of Rapyd Sentinel's split architecture, demonstrating secure communication between isolated Gateway and Backend layers using AWS infrastructure.

## Architecture Overview

The architecture consists of two isolated domains:

- **Gateway Layer (Public)**: Internet-facing APIs and proxy services
- **Backend Layer (Private)**: Internal processing and sensitive services

### Infrastructure Components

- **Two AWS VPCs**: `vpc-gateway` (10.0.0.0/16) and `vpc-backend` (10.1.0.0/16)
- **Two EKS Clusters**: `eks-gateway` and `eks-backend`
- **VPC Peering**: Secure cross-VPC communication
- **Security Groups**: Restrictive access controls
- **Network Policies**: Kubernetes-level traffic control

## Prerequisites

- AWS Account with appropriate permissions
- AWS CLI configured
- Terraform >= 1.0
- kubectl
- GitHub repository with Actions enabled

## Quick Start

### 1. Clone the Repository

```bash
git clone <repository-url>
cd rapyd-sentinel-poc
```

### 2. Configure AWS Credentials

Set up your AWS credentials as GitHub secrets:
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`

Or use OIDC federation (recommended for production):

```yaml
# Add to .github/workflows/deploy.yml
- name: Configure AWS credentials
  uses: aws-actions/configure-aws-credentials@v4
  with:
    role-to-assume: arn:aws:iam::ACCOUNT-ID:role/GitHubActionsRole
    aws-region: us-west-2
```

### 3. Deploy Infrastructure

Push to the main branch or manually trigger the GitHub Actions workflow. The pipeline will:

1. Validate Terraform configuration
2. Validate Kubernetes manifests
3. Deploy AWS infrastructure (VPCs, EKS clusters, VPC peering)
4. Deploy applications to respective clusters

### 4. Access the Application

After deployment, find the LoadBalancer URL in the GitHub Actions logs:

```bash
# The workflow outputs the LoadBalancer URL
curl http://<load-balancer-url>
# Expected response: "Hello from backend"
```

## Networking Configuration

### VPC Peering Setup

- Gateway VPC (10.0.0.0/16) ↔ Backend VPC (10.1.0.0/16)
- Routes configured in private subnets for cross-VPC communication
- Security groups allow traffic between EKS node groups

### DNS Resolution

- Internal DNS resolution within clusters
- Cross-cluster communication via VPC peering
- Service discovery using Kubernetes DNS (service.namespace.svc.cluster.local)

### Security Model

**Infrastructure Security:**
- Private subnets only (no public EC2 instances)
- NAT Gateways for outbound traffic from private subnets
- VPC endpoints for AWS services (S3)
- Security groups restrict access to necessary ports only

**Kubernetes Security:**
- Network Policies limit pod-to-pod communication
- Backend services only accessible from Gateway cluster
- RBAC and service accounts for workload identity

**Access Control:**
- EKS clusters have private endpoints only
- No public access to cluster APIs
- SSH access to nodes via security groups (optional)

## CI/CD Pipeline

The GitHub Actions workflow (`deploy.yml`) provides:

### Validation Stage
- Terraform format checking and validation
- Kubernetes manifest validation with kubeval
- Dry-run deployments

### Deployment Stage
- Infrastructure deployment with Terraform
- Application deployment to EKS clusters
- Automated testing of connectivity

### Security Features
- Requires approval for production deployments
- Validates all changes before applying
- Comprehensive logging and error reporting

## Application Architecture

### Backend Service
- Simple Nginx server responding "Hello from backend"
- Deployed in `eks-backend` cluster
- ClusterIP service (internal only)
- NetworkPolicy restricts access to Gateway namespace

### Gateway Proxy
- Nginx reverse proxy forwarding to backend
- Deployed in `eks-gateway` cluster
- LoadBalancer service (internet-facing)
- Routes traffic through VPC peering to backend

## Cost Optimization

### Current Configuration
- t3.medium instances (cost-effective for dev)
- NAT Gateways (required for private subnet outbound)
- EKS managed nodes (no control plane costs)

### Potential Optimizations
- Use spot instances for non-production workloads
- Implement auto-scaling based on traffic
- Use Application Load Balancer instead of Network Load Balancer
- Schedule non-production resources

## Trade-offs and Limitations

### 3-Day Time Limit Constraints
- Simplified VPC peering (Transit Gateway could provide better scalability)
- Basic application (no authentication, TLS, or advanced routing)
- No observability stack (monitoring, logging, tracing)
- Manual cross-cluster DNS resolution

### Security vs. Complexity
- VPC peering chosen over Transit Gateway (simpler but less scalable)
- Network Policies implemented but could be more granular
- No service mesh (Istio/Linkerd) due to time constraints

### Scalability Considerations
- Fixed instance types and counts
- No auto-scaling policies
- Single region deployment

## Next Steps and Improvements

### Immediate Enhancements
1. **TLS/mTLS**: Implement certificate management and mutual TLS
2. **Service Mesh**: Deploy Istio or Linkerd for advanced traffic management
3. **DNS Service Discovery**: Implement cross-cluster service discovery
4. **Observability**: Add Prometheus, Grafana, and ELK stack

### Production Readiness
1. **GitOps**: Implement Flux or ArgoCD for continuous deployment
2. **Ingress Controllers**: Replace LoadBalancer with NGINX Ingress or ALB
3. **Vault Integration**: Secure secret management
4. **Multi-region**: Global deployment with latency-based routing

### Security Hardening
1. **Zero Trust**: Implement network segmentation and identity-aware proxies
2. **Secrets Management**: Integrate AWS Secrets Manager or HashiCorp Vault
3. **Compliance**: Add audit logging and compliance monitoring
4. **Vulnerability Scanning**: Container image scanning and dependency checks

### Performance Optimizations
1. **Caching**: Implement Redis or CloudFront for content delivery
2. **Auto-scaling**: HPA and cluster autoscaling
3. **Database**: Add RDS or DynamoDB for data persistence
4. **CDN**: Global content delivery network

## Troubleshooting

### Common Issues

**VPC Peering Connection Fails:**
- Ensure CIDR blocks don't overlap
- Check security group rules allow cross-VPC traffic

**Kubernetes Deployment Issues:**
- Verify cluster connectivity with `kubectl get nodes`
- Check pod logs with `kubectl logs <pod-name>`

**LoadBalancer Not Accessible:**
- Wait 5-10 minutes for AWS to provision the LoadBalancer
- Check security groups allow inbound traffic on port 80

### Useful Commands

```bash
# Check infrastructure status
terraform output -state=terraform/terraform.tfstate

# Access EKS clusters
aws eks update-kubeconfig --region us-west-2 --name eks-gateway
aws eks update-kubeconfig --region us-west-2 --name eks-backend

# Debug networking
kubectl get svc,deploy,pods -A
kubectl describe svc gateway-proxy
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make changes and test locally
4. Submit a pull request
5. Ensure CI/CD pipeline passes

## License

This project is licensed under the MIT License - see the LICENSE file for details.
