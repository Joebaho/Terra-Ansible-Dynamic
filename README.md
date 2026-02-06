# 🌍 Terraform × Ansible Dynamic Project

This project — **terra-ansible-Dynamic** — demonstrates how to use **Terraform** and **Ansible** together to provision and configure EC2 instances across multiple environments (**Dev**, **Stage**, and **Prod**).

Terraform handles the **infrastructure provisioning**, while Ansible automates **configuration management** — It will use the AWS plugin to detect all EC2 instances and connect to them via SSH. The realization of this project will make it easy for understanding how both tools collaborate in a real-world DevOps workflow.

---

## 🚀 Project Overview

### What this project does:
- Provision **1 EC2 instance** (Called the controller).
- Provisions **6 EC2 instances** (2 per environment: `dev`, `stage`, and `prod`).
- Creates a **keypair** and will keep both public and private keys securely in controller.
- Use a **controller userdata** that will install ansible on the controller and **node userdata** to ensure 'python3' installation on nodes.
- Create **controller security group** and **node security group**with rules for SSH (22) and HTTP (80).
- Uses **Ansible** to configure web servers on each instance.
- Deploys environment-specific `index.html` pages:
  - `dev` → Minimal UI with a developer theme.
  - `stage` → Modern preview UI.
  - `prod` → Portfolio UI with achievements, skills, certifications, socials, and image.

### Why it’s awesome:
- Full Infrastructure as Code (IaC) workflow.
- Dynamic inventory generation after `terraform apply`.
- Environment-based configuration using Ansible variables.
- Simple to extend to multi-region or autoscaling setups.

---

## 🧱 Project Structure

```

terra-ansible-Dynamic/
├── terra-config/
│   ├── iam-role.tf
│   ├── main.tf
|   |-- outputs.tf 
│   ├── variables.tf
│   ├── providers.tf
    ├── userdata-controller.sh
│   └── userdata-node.sh
│
├── ansible/
│   ├── ansible.cfg
│   ├── playbook.yml
│   ├── requirements.yml
│   ├── inventory/
│   │   └── aws_ec2.yml  
│   └── roles/
│       └── webserver/
│           ├── tasks/
│           │   └── main.yml
            ├── handlers/
│           │   └── main.yml
│           └── templates/
│               ├── dev.html
│               ├── stage.html
│               └── prod.html
│
|--- deploy.sh
│
|--- destroy.sh
|
└── README.md

```

---

## ⚙️ Setup Instructions

### 1. Clone the repo
```bash
git clone https://github.com/Joebaho/Terra-Ansible-Dynamic.git
cd Terra-Ansible-Dynamic
```

### 2. One-Click Deployment

To automate the full flow (Terraform → Inventory → Ansible):

```bash
chmod +x deploy.sh
```

```bash
./deploy.sh
```

This script:

1. Runs `terraform apply`
2. Generates inventory
3. Executes the Ansible playbook
   All in one command ⚡️

---

### 3. One-Click Destroy

To automate the destroyment of all project

```bash
chmod +x destroy.sh
```

```bash
./destroy.sh
```

This script:

1. Runs `terraform reconfiguration`
2. Destroy the entire configuration and all files All in one command ⚡️

---

## 🧰 Tools & Technologies

* **Terraform** — Infrastructure provisioning
* **Ansible** — Configuration management
* **AWS EC2** — Compute service
* **Nginx** — Web server
* **Python** — Used for generating inventory file

---

## 🌐 Environments Overview

| Environment | Instances | Description                                           |
| ----------- | --------- | ----------------------------------------------------- |
| `dev`       | 2         | Lightweight static pages for development              |
| `stage`     | 2         | Preview deployment before production                  |
| `prod`      | 2         | Final portfolio version with achievements and socials |

---

## 👨‍💻 Author

**Joseph Mbatchou**

• DevOps / Cloud / Platform  Engineer   
• Content Creator / AWS Builder

## 🔗 Connect With Me

🌐 Website: [https://platform.joebahocloud.com](https://platform.joebahocloud.com)

💼 LinkedIn: [https://www.linkedin.com/in/josephmbatchou/](https://www.linkedin.com/in/josephmbatchou/)

🐦 X/Twitter: [https://www.twitter.com/Joebaho237](https://www.twitter.com/Joebaho237)

▶️ YouTube: [https://www.youtube.com/@josephmbatchou5596](https://www.youtube.com/@josephmbatchou5596)

🔗 Github: [https://github.com/Joebaho](https://github.com/Joebaho)

📦 Dockerhub: [https://hub.docker.com/u/joebaho2](https://hub.docker.com/u/joebaho2)

---

## 📄 License

This project is licensed under the MIT License — see the LICENSE file for details.
