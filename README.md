# Simple Time Service 

- SimpleTimeService is a lightweight Java-based microservice that returns the current timestamp and the public IP address of the client.


### Repository Structure 

```
.
├── app/            # Spring Boot application and Dockerfile
├── terraform/      # Terraform infrastructure code (ECS, ALB, VPC)
├── .github/
│   └── workflows/  # CI/CD pipeline configuration Git Actions
└── README.md
```

#### How to run the application
> ##### 1. Running the Application Locally 
> - Install Docker
> - Run the public image using :-
> 	- `docker run -p 9000:9000 ryuga64/simple-timeservice:latest`
> - Open the endpoint in browser :-
> 	- http://localhost:9000
> ##### 2. AWS Deployment using Terraform 
> - Install AWS CLI on the machine
> - Install terraform on the machine
> - Add your AWS account using `aws configure` to configure your AWS account on the machine
> ALTERNATIVELY
> - You can manually (temporarily) set AWS credentials through environment variables :-
> ```
> export AWS_ACCESS_KEY_ID=your_key
> export AWS_SECRET_ACCESS_KEY=your_secret
> export AWS_DEFAULT_REGION=ap-south-1
> ```
> - Go into terraform directory `cd terraform`
> - Run the following commands to build the infrastructure :-
> 	- `terraform init`
> 	- `terraform plan`
> 	- `terraform apply`
> - You will receive the DNS for the Load Balancer which you can you use as endpoint to use the service or map it behind a CNAME to make it work with your own DNS.
> - For cleanup you can use `terraform destroy` to remove the built infrastructure for the application.
> ##### 3.CI/CD Pipeline (Github Actions)
> - The project has a complete CI/CD pipeline which can :-
> 	- Build the Docker Image
> 	- Push the latest built image to DockerHub
> 	- Deploys the infrastructure using terraform on AWS
> - Fork the Repository
> - Go to **Settings** --> **Secrets** --> **Actions**
> - Add the following secrets :-

| Secret Name             | Purpose                |
| ----------------------- | ---------------------- |
| `DOCKERHUB_USERNAME`    | DockerHub username     |
| `DOCKERHUB_TOKEN`       | DockerHub access token |
| `AWS_ACCESS_KEY_ID`     | AWS access key         |
| `AWS_SECRET_ACCESS_KEY` | AWS secret key         |
 > - Every push to the main branch will automatically trigger the pipeline
 
