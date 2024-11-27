# 🌐 Technical Test: WordPress in HA on Kubernetes 🚀

Welcome to the **technical_test_transparent** repository! 🎉 This project demonstrates how to deploy a highly available (HA) WordPress instance on a Kubernetes cluster in **DigitalOcean**. It combines scalability, reliability, and modern DevOps practices, showcasing both **Terraform** automation and Kubernetes expertise. 💻✨

---

## 📋 Repository Structure

This repository contains two projects:

1. **`manual_approach/`**: 
   - Infrastructure deployed and configured manually with Terraform scripts and Kubernetes YAML manifests.
   - Fully automated for quick deployments.

2. **`helm_approach/`**:
   - WordPress deployment using the **Bitnami Helm chart** for Kubernetes.
   - Focuses on simplicity, but some parts require manual intervention due to time constraints.

---

## ⚠️ IMPORTANT DISCLAIMER ⚠️

❗❗ **The `helm_approach` project is not fully automated.** ❗❗  
🚧 This deployment requires manually reviewing official documentation for certain steps.  
⏳ Due to time constraints, complete automation of the Helm-based deployment has not been implemented.  

### What does this mean for you?  
- 🛠️ Be prepared to edit configuration files like `values.yaml`.
- 📚 Use official Bitnami Helm chart documentation to guide installation: [Bitnami Helm Charts](https://bitnami.com/stack/kubernetes).
- 🧑‍💻 Hands-on intervention is necessary to fully deploy the application.

---

## 🛠️ Features

### For `manual_approach/`:
- **Automated Kubernetes cluster setup with Terraform**:
  - Load balancer and NGINX ingress controller.
  - OpenEBS NFS provisioner for shared storage.
- **Managed Databases**:
  - MySQL for WordPress.
  - Redis for object caching.
- Highly available configuration for WordPress.

### For `helm_approach/`:
- **Helm Deployment**:
  - Bitnami Helm chart for WordPress.
  - Easily customisable through the `values.yaml` file.
- **Potential Enhancements** (not implemented due to time constraints):
  - DNS configuration for NGINX ingress controller.
  - Cert-manager for TLS certificates.
  - Prometheus integration for monitoring.

---

## 🤔 Why Two Approaches?

This repository aims to demonstrate flexibility in Kubernetes deployments:
- **Manual Approach**: Provides in-depth knowledge of Kubernetes resource creation and management.
- **Helm Approach**: Highlights the simplicity of deploying applications with Helm charts while noting the importance of understanding manual configurations.

---

## 📋 Project Overview

This repository is a **Proof of Concept (PoC)** for deploying WordPress in a **high availability (HA)** configuration. Here's what makes this project stand out:

- **Infrastructure as Code (IaC):** Automated setup of the Kubernetes cluster using **Terraform**.
- **High Availability:** WordPress is configured to ensure reliability, even in the face of node failures. You can scale horizontally by increasing replica counts. 🔄
- **Dynamic Storage Provisioning:** Leveraging **OpenEBS NFS provisioner** for scalable and shared storage.
- **Database Management:** Integration with **DigitalOcean Managed Databases** for MySQL and Redis, ensuring optimal performance and reduced maintenance. 💾
- **Load Balancing:** Using DigitalOcean's load balancer to handle external traffic efficiently. ⚖️
- **Secure and Scalable:** Built with modern Kubernetes and cloud-native principles.

---

## 🛠️ Features and Components

### 🔧 Infrastructure Setup
- Fully automated Kubernetes cluster deployment using **Terraform**.
- NGINX Ingress Controller for routing traffic to WordPress Pods.
- Load balancer configuration for external traffic management.

### 🗂️ Kubernetes Resources
- **Namespace:** Isolation of resources for clean organisation.
- **WordPress Deployment:** Configurable replica counts for HA.
- **Persistent Storage:** Using OpenEBS NFS for shared, RWX storage.
- **MySQL Database:** Managed service for reliability and ease of use.
- **Redis Cache:** Managed Redis database to enhance WordPress performance.

### ⚙️ Future Enhancements (Not Implemented in PoC)
- 🛡️ **WAF and Geo-Restrictions:** Add a Web Application Firewall (WAF) and restrict access by geographic location.
- 📈 **Monitoring:** Integrate Prometheus and Grafana for advanced metrics and monitoring.
- 🔒 **TLS Certificates:** Use Cert-Manager for automatic Let's Encrypt SSL certificates.
- 📡 **CDN Integration:** Incorporate a Content Delivery Network for enhanced performance.

---

## 🚀 Getting Started

### Prerequisites
Ensure you have the following tools installed and configured:
- **Terraform** 🏗️
- **Helm** 🛶
- **kubectl** ⛵
- A **DigitalOcean account** with an API token 🔑

### Installation
1. Clone this repository:
   ```bash
   git clone https://github.com/<your-username>/technical_test_transparent.git
   cd technical_test_transparent
   ```

2. Configure your environment variables in `.env`:
   ```
   set -x MYSQL_ROOT_PASSWORD whatevervalue
   ```

---

## 🤔 Why This Project Matters

This repository is more than just a deployment of WordPress – it’s a showcase of practical cloud-native and DevOps skills. It demonstrates:
- **Proficiency in Terraform, Kubernetes, and Helm.**
- **Best practices in security, scalability, and automation.**
- **A hands-on approach to modern infrastructure design.**

---

## 📝 Notes

This PoC demonstrates technical knowledge, but the level of hardening and customisation will depend on specific client requirements. The setup provides a foundation that can be extended to meet production-grade standards.


## 🙌 About

This repository is open-source under the **GPL-3.0 license**. Contributions, feedback, and improvements are welcome! 💬
```
