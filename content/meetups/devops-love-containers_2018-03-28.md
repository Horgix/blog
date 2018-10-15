+++
title = "Modern Infrastructure"
venue = "Algolia"

[meetupevent]
  group = "devops-containers"
  id = "248992205"
+++

https://www.eventbrite.com/e/infrastructure-meetup-by-leaseweb-algolia-tickets-44023270788


# Real-time Data Processing Rolling Upgrade with no downtime /w ((Terraform && Cloud) || (Docker && BareMetal))

## Speaker

- Pierre Padrixe, Devops - Linkfluence
- @undefd
- @linklabs

## Linkfluence

Social Media Intelligence

NLP analysis and ML for data enrichment based on social media (mainly russia
and china doubtful networks...)

## Infra

- Hybrid : mix of baremetals and VMs
- mix of providers : baremetal Leaseweb, OVH, AWS, Alibaba Cloud, ...

---

- ~50M new docs every day
- ~70 billion docs
- ~200 ES nodes in total

---

- Data processing stack: Hadoop, Storm, Spark, Hbase
- Dev stack : clojure microservices, scala backend

---

Monitoring :

- Cauchy
- Riemann

---

cloud-init that does everything

"OVh was down but our ES cluster was spread across OVH & Alibaba Cloud so we
were still up and running"

Dockerstein : dev env for storm topologies based on DOcker

Questions :

- ES clusters spread : latency?
- Collins for invnetory ? (tumblr)

No idea

- Inventory source ? hit baremetal APIs ?

providers API + register in cloud init


# Kubernetes: Should you use it for your next project?

## Speakers

Anthony Seure, Software Engineer - Algolia

Contenders: Swarm & Mesos. No Nomad :D
K8s won.

"All the Docker services are dying one by one" :D

search API = bare metal:

- builder + nginx module
- 1200 servers across 70 datacenters
- Available in 16 regions

user faceing = VMs + buckets:

- website
- dashboard
- blog
- documentation
- status page

Backend services = VMs + k8s:

- log collection
- analytics pipeline v1 and v2
- usage pipeline
- ??

- "The schema is really the way we are thinking about our infrastructure, k8s
- takes care of the details"
- "not thinking about security patches" meh :(
- "K8s is not really well known for its backward compatibility" :D
- custom metrics based autoscaling recently

questions :

"ok custom metrics are usefull, on which ones are you scaling up or down ?"

"you still have to think about the infrastructure'
"troubleshooting is harder, you can't just SSH and try stuff"


## Questions

Custom metrics autoscaling ?

Nope :(
Maybe Pub/Sub queue sizes

---

etcd topology / master nodes?

No idea, "I'm really happy to not know about that", GCP x)

---

Image scanning?

"Google does that for us"

# You are not in the business of running a CI infrastructure unless your business is CI infrastructure

## Speaker

Nico Di Rocco, Scrum Master, Bare Metal Team Management - Leaseweb

## A need for CI

- At some point a company needs this
- "a system to tell you about dumb mistakes that you do"
- apt get install, fill out forms, tada x)

More projects :

1. More projects over time (microservices)
2. Linear growth of projects and jenkins jobs
3. Where to define build steps? Jenkins UI vs repo?

give access to many people...

problems

- valuable time of people go into maintaining Jenkins
- more and more jenkins experts
- bla
- jenkins shared libraries
