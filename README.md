# GeoFedBench

GeoFedBench is a benchmark for evaluating federated linked geospatial data query processors.
The benchmark uses datasets and queries from two practical use cases from the agroenvironmental domain.
It comprises two suites:

* **GSSBench suite**:
  It is derived from the practical use-case of linking land usage data with water availability data for food security.
  The federation contains 3 data layers (namely Administrative, Snow cover, and Crop-type data),
  and each layer is also divided geospatially. Thus, each endpoint contains only one thematic layer and
  refers to a specific area. This suite is used mainly to evaluate the effectiveness of the source selection
  mechanism of a federation engine, and, in particular, if the source selector is aware of the geospatial nature
  of the source endpoints.

* **GDOBench suite**:
  It is derived from the practical use-case of linking land usage data with ground observations for the purpose of
  estimating crop type accuracy. The query load of the suite contains difficult query characteristics (usually
  not found in current SPARQL benchmarks, such as inner SELECT queries and negation through FILTER NOT EXISTS).
  Moreover, the bottleneck of the evaluation is the federated geospatial within-distance operator, which is
  considered a difficult operation since it cannot be evaluated fast using a spatial index (as it is the case for
  the spatial relationships such as contains, within, etc.)

The dump files can be found in [http://rdf.iit.demokritos.gr/dumps/](http://rdf.iit.demokritos.gr/dumps/)

## Prerequisites

The experiments are executed using the KOBE benchmarking engine.
For instructions on how to install KOBE in your system please visit the
[GitHub page](https://github.com/semagrow/kobe/) or the [KOBE User Guide](https://semagrow.github.io/kobe/). 

## How to run an experiment from the GSSBench suite

In the following, we show the steps for deploying an experiment.
For example, to run the query load that corresponds to the **Q1** query template
over the **geo-poly-27** dataset setup follow the commands below.

First, apply the template for Strabon:
```bash
kubectl apply -f strabontemplate.yaml
```

Then, apply the benchmark that corresponds with the query load of **Q1** in the **27**-dataset setup:
```bash
kubectl apply -f benchmarks/gssbench-27/gssbench-27-q1.yaml
```
Check the `benchmarks/gssbench-27` and `benchmarks/gssbench-25` directories
for the remaining query loads from the 27-dataset (resp. 25-dataset) setup.
Do not apply any of the remaning specifications though - apply only one part of
the query load at a time.

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

Then, apply the template for Semagrow **geo-poly-27**:
```bash
kubectl apply -f experiments/gssbench/semagrow-templates-27/semagrowtemplate-geo-poly.yaml
```
In total, there are 8 templates for Semagrow, one for each dataset setup (25 or 27)
and one for each source selection method (geo-poly, geo-appr, geo-mbb, and them).
The templates can be found in the directories
`experiments/gssbench/semagrow-templates-25/` and
`experiments/gssbench/semagrow-templates-27/`.

Proceed now with the execution of the experiment
(notice that there is only one specification for all experiments of GSSBench):
```bash
kubectl apply -f experiments/gssbench/exp-gssbench.yaml
```

As previously, you can review the state of the experiment with the following command:
```bash
kubectl -n gssbench get pods
```
To view the results, check the logs of the containers or check the Kibana
dashboards offered by KOBE (check the KOBE User Guide for more details).

Before you run another query, delete all specifications as follows:
```bash
kubectl delete experiments.kobe.semagrow.org exp-gssbench
kubectl delete benchmarks.kobe.semagrow.org gssbench
kubectl delete federatortemplates.kobe.semagrow.org semagrowtemplate
kubectl delete datasettemplates.kobe.semagrow.org strabontemplate
```
and then redo the steps from the beginning for the other query.

## How to run an experiment from the GDOBench suite

In the following, we show the steps for deploying an experiment.
For example, to run the query load that corresponds to the **Q4** query template
follow the commands below.

First, apply the template for Strabon:
```bash
kubectl apply -f strabontemplate.yaml
```

Then, apply the benchmark that corresponds with the query load of **Q4**:
```bash
kubectl apply -f benchmarks/gdobench/gdobench-q4.yaml
```
Check the `benchmarks/gdobench/` and `benchmarks/gdobench/validation-task` directories
for the remaining query loads of the suite. 'gdobench-q1-2-3.yaml' contains a selection
of the queries from the templates Q1, Q2, Q3.
Do not apply any of the remaning specifications though - apply only one part of
the query load at a time.

Before running the experiment, you should verify that the datasets are loaded. 
Use the following command:
```bash
kubectl -n gdobench get pods
```

When the datasets are loaded, you should get the following output:
```bash
NAME  			STATUS
lucas-all-pod		Running
invekos-all-pod		Running
```

Check if the data are actually stored, for each pod.
For lucas-all-pod, for example, use the following command:
```bash
kubectl -n gssbench logs lucas-all-pod -c maincontainer | grep "Data Stored Successfully"
```
"Data Stored Successfully" should be printed in the output.

Then, apply the semagrow templates (for unoptimized and optimized versions):
```bash
kubectl apply -f experiments/gdobench/semagrowtemplate-gdo-orig.yaml
kubectl apply -f experiments/gdobench/semagrowtemplate-gdo-dopt.yaml
```

Proceed now with the execution of the first experiment (unoptimized Semagrow):
```bash
kubectl apply -f experiments/gdobench/exp-gdo-orig.yaml
```

As previously, you can review the state of the experiment with the following command:
```bash
kubectl -n gdobench get pods
```
To view the results, check the logs of the containers or check the Kibana
dashboards offered by KOBE (check the KOBE User Guide for more details).

After the first experiment ends, then proceed with the second experiment (optimized Semagrow):
```bash
kubectl apply -f experiments/gdobench/exp-gdo-dopt.yaml
```

Before you run another query, delete all specifications as follows:
```bash
kubectl delete experiments.kobe.semagrow.org exp-gdo-orig exp-gdo-dopt
kubectl delete benchmarks.kobe.semagrow.org gdobench
kubectl delete federatortemplates.kobe.semagrow.org semagrowtemplate-gdo-dopt semagrowtemplate-gdo-orig
kubectl delete datasettemplates.kobe.semagrow.org strabontemplate
```
and then redo the steps from the beginning for the other queries.

## How to build the Docker images yourself (optional step)

As you wil notice, all Semagrow templates use Docker images in their specification.
Each Semagrow template looks like this:

```yaml
apiVersion: kobe.semagrow.org/v1alpha1
kind: FederatorTemplate
metadata:
  name: semagrowtemplate
spec:
  containers:
    - name: maincontainer 
      image: semagrow/semagrow:TAG
      ports:
      - containerPort: 8080
  port: 8080
  path: /SemaGrow/sparql
  confFromFileImage: alpine:3
  inputDumpDir: /semagrow/input
  outputDumpDir: /semagrow/output
  confImage: SEMAGROW_INIT_IMAGE
  inputDir: /input
  outputDir: /output
  fedConfDir: /etc/default/semagrow
```
In order to build the main Semagrow image yourself (namely `semagrow/semagrow:TAG`)
clone the [Semagrow repository](https://github.com/semagrow/semagrow),
checkout the version (or tag, or branch) that refers to the specific TAG,
and follow the instructions there to build your image.

In order to build the image that initializes Semagrow yourself (namely `SEMAGROW_INIT_IMAGE`),
just build the corresponding Dockerfile that appears in the same directory as that of the
template of Semagrow. For instance, the Docker image that initializes Semagrow in the template
`experiments/gssbench/semagrow-templates-27/semagrowtemplate-geo-poly.yaml` can be found in
`experiments/gssbench/semagrow-templates-27/semagrow-init-geo-poly`.


## Further reading

* Antonis Troumpoukis, Stasinos Konstantopoulos, Giannis Mouchakis,
  Nefeli Prokopaki-Kostopoulou, Claudia Paris, Lorenzo Bruzzone, Despina-Athanasia Pantazi,
  and Manolis Koubarakis.
  *GeoFedBench: A benchmark for federated GeoSPARQL query processors.*
  In Proceedings of the Posters and Demos Session of the 19th International Semantic Web
  Conference (ISWC 2020), 2-6 November 2020, 2020.

* Antonis Troumpoukis et al.:
  *Evaluation framework for linked geospatial data systems.*
  Technical Report Public Deliverable D3.5, ExtremeEarth Project, December 2021.
  
