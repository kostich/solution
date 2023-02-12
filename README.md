# What

This repo contains code that will allow you to run a Golang app on AWS.

## Infrastructure

_diagram goes here_

The application lies inside two private subnets (two different AZs). These subnets can connect to the Internet via the two public subnets (that have the corresponding internet gateway and the NAT gateways). Incoming traffic is routed to the application via an Application Load Balancer.

The app is tolerant of AZ failure, if one AZ goes down, there will be another instance of the app in another AZ (or ECS will start a new instance in another AZ).

The application listens for HTTP traffic on port 80 and gRPC traffic on port 9000. The gRPC bits haven't been tested but they should work.

Data lies in another subnet (the data subnet). Data layer has three subnets in 3 different AZs. PostgreSQL is powered by Aurora Serverless V2 tech that utilizes these 3 AZs to spread the data. In a case of a failure, a well coded app (low DNS TTL, separate read and write mechanisms) should experience only minutes of partial downtime as Aurora reconfigures a Reader instance to become a Writer and as the Aurora writer DNS endpoint gets updated.

The Aurora PostgreSQL database is also automatically scalable.

Resources have corresponding security lists attached that limit access to them. Additionaly, there are Network ACLs configured that further limit how resources in subnets can talk to each other.

The ECS Task hosting the app currently isn't doing the automatic scaling of the app but that's because of the lack of implementation time. It's fairly straightforward to add a couple of cloudwatch metrics and some autoscaling policies that utilize those metrics to upscale or downscale.

A message broker hasn't been implemented but it should be doable to deploy MSK in the same data layer that Aurora PostgreSQL resides and all the traffic should work.

## How to use it

To deploy the infrastructure, consult the [infra/README.md](./infra/README.md) file.

## Monitoring

Due to the lack of time, monitoring isn't implemented. But let's imagine that we use Datadog and PagerDuty. One possible solution to the monitoring would be to:

* feed all AWS metrics and logs (for ALBs, the app, database, message broker) to Datadog,
* configure proper Pagerduty alerting path
* configure Datadog to send important alerts to Pagerduty for some aspects of the stack,
* configure a Datadog->Slack path for alerts that aren't time-sensitive
* create some pretty Datadog dashboard to allow us to quickly see patterns when solving outages (shape of the traffic, application properties, data layer properties)

## CI/CD

A simplest way to implement a CI/CD solution in this repo would be to utilize GitHub Actions and:

* on a new commit, if a commit made a change in the `app` folder, test the code, build and push a docker container, update the app version in the `infra/terraform.tfvars` file and then execute `terraform plan` and `terraform apply`,
* on a new commit, if a commit made a change in the `infra` folder, execute `terraform plan` and `terraform apply`.

In a more real-world situation, we would have multiple environments and the deploy of the app code would be something like:

* every commit (except the one in the `main` branch) goes to a `dev` environment
* if the commit is in the `main` branch, that change would go to a `stage` environment
* tagged commits (maybe named in a specific way) go to the `prod` environment

## Further improvements

Currently it's very hard to have different environments with this approach (except if you don't mind copy-pasting stuff). To change this, the code should be refactored in Terraform modules. Then we would be able to define different environments that use these modules to deploy a specific environment resources (vpc, subnets, database, ecs cluster).

## Who
Marko Kostic
