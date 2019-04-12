# Deploy a MongoDB Replica Set in a DevOps fashion style (Infrastructre as Code)

![](https://cdn-images-1.medium.com/max/2400/1*dd4yphIljlJPWAnxqKMSTQ.png)

Complete code for the article **Deploy a MongoDB Replica Set in a DevOps fashion style (Infrastructre as Code)**
is a walkthrough in how to set up a MongoDB replica set with authentication using docker + Hashicorp tools in AWS.

### Technologies

* Packer v1.3.1 
* Ansible
* Terraform v0.11.10 
* Docker 18.06.0-ce
* MongoDB 4.0.7
* Bash Scripting


![Architecure Diagram](https://cdn-images-1.medium.com/max/2400/1*aKnpmgXcXZFUAcIrTH1uPQ.png)

## Medium article

- [Deploy a MongoDB Replica Set in a DevOps fashion style (Infrastructre as Code)](https://medium.com/@cramirez92/deploy-a-mongodb-replica-set-in-a-devops-fashion-style-infrastructre-as-code-f631d7a0ad80)

### PRE-REQUISITES
This is an intermediate DevOps exercise, so I will assume that people who are going to read this article, has experience on the specs mentioned before, I also made this article the most friendly as possible so that beginners can also understand and follow up.


Note: If you want to followup this exercise as it is, you may need to have an aws account, and the Hashicorp binaries installed locally. This may generate a cost for your aws account, but this can also be done on a free tier account.If you're not using an account that qualifies under the AWS free-tier, you may be charged to run these examples. The charge should only be a few cents, but I will not be responsible if it ends up being more. If you are ready to go and have an aws account you will need also to create an aws key pair so you can use this pem file to ssh to the instances that we are going to create in aws.