# Instructions to deploy a KOBE experiment

## Prerequisites

The experiments are executed using the KOBE benchmarking engine.
For instructions on how to install KOBE in your system please visit the
[GitHub page](https://github.com/semagrow/kobe/) or the [KOBE User Guide](https://semagrow.github.io/kobe/). 

## How to run a query

In the following, we show the steps for deploying an experiment on geofedbench benchmark that comprises queries over a Semagrow federation of Strabon endpoints.
For example to run **Q1** on **geo-poly-27** dataset setup follow the commands below.

First, apply the template for Strabon and Semagrow:
```bash
kubectl apply -f strabontemplate.yaml
kubectl apply -f experiments/semagrow-templates-27/semagrowtemplate-geo-poly.yaml
```

Then, apply the benchmark:
```bash
kubectl apply -f benchmarks/gssbench-27/gssbench-27-q1.yaml
```

Before running the experiment, you should verify that the datasets are loaded. 
Use the following command:
```bash
kubectl -n gssbench get pods
```

When the datasets are loaded, you should get the following output:
```bash
NAME  			STATUS
adm1-pod		Running
invekos1-pod		Running
snow1-pod		Running
```
for all 9 adm pods, 9 invekos pods and 9 snow pods (or 7 snog pods, in the case of 25 dataset setup).

Check if the data are actually stored, for each pod.
For invekos1-pod, for example, use the following command:
```bash
kubectl -n gssbench logs invekos1-pod -c maincontainer | grep "Data Stored Successfully"
```
"Data Stored Successfully" should be printed in the output.

Proceed now with the execution of the experiment:
```bash
kubectl apply -f experiments/exp-gssbench.yaml
```

As previously, you can review the state of the experiment with the following command:
```bash
kubectl -n gssbench get pods
```

Before you run another query, delete all specifications as follows:
```bash
kubectl delete experiments.kobe.semagrow.org exp-gssbench
kubectl delete benchmarks.kobe.semagrow.org gssbench
kubectl delete federatortemplates.kobe.semagrow.org semagrowtemplate
kubectl delete datasettemplates.kobe.semagrow.org strabontemplate
```
and then redo the steps from the beginning for the other query.
