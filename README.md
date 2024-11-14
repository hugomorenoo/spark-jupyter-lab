# 🚀 How to connect Jupyter Labs to Spark (Scala & PySpark)

This repository contains a Dockerfile to build a Docker image that connects **Jupyter Lab** with **Apache Spark**, allowing to work with **Scala** and **PySpark** in a Jupyter Notebook enviroment. This configuration is perfect for big data and data analists proyects.

## 📋 Content
- [Features](#-features)
- [Requirements](#-requirements)
- [Dockerfile configuration](#-dockerfile-cpnfiguration)
- [Operating instructions](#-operatinng-instructions)
- [Testing](#-testing)
- [Contributing](#-contributing)
- [License](#-license)



## ✨ Features
- Jupyter Lab with **Python 3.9** support
- Integration with **Apache Spark** (configurable version)
- Support for **Scala** and **PySpark** in **Jupyter Notebooks**
- Includes essential packages like **findspark** and **Apache Toree**

## 🔧 Requirements
- Docker installed in your system. You can get it from the [Docker official website](https://www.docker.com/get-started).

## 🛠 Dockerfile configuration

Here you have the content of the Dockerfile. You can also customize it as you like.


For example, I´ve decided to quit the token authentication in the Jupyter Lab home, but it´s not necessary  

```bash
# Use a base image of Jupyter with Python 3.9
FROM jupyter/base-notebook:python-3.9

# Environment variables
ENV SPARK_VERSION=3.5.3
ENV HADOOP_VERSION=3
ENV SPARK_HOME=/opt/spark
ENV PATH="$SPARK_HOME/bin:$PATH"

# Install dependencies and Java
USER root
RUN apt-get update && \
    apt-get install -y openjdk-11-jdk && \
    apt-get clean

# Download and install Spark
RUN wget https://downloads.apache.org/spark/spark-$SPARK_VERSION/spark-$SPARK_VERSION-bin-hadoop$HADOOP_VERSION.tgz && \
    tar -xzf spark-$SPARK_VERSION-bin-hadoop$HADOOP_VERSION.tgz -C /opt/ && \
    mv /opt/spark-$SPARK_VERSION-bin-hadoop$HADOOP_VERSION $SPARK_HOME && \
    rm spark-$SPARK_VERSION-bin-hadoop$HADOOP_VERSION.tgz

# Install JupyterLab, Apache Toree, and findspark
RUN pip install jupyterlab findspark && \
    pip install toree && \
    jupyter toree install --spark_home=$SPARK_HOME --interpreters=Scala --user

# Create a PySpark kernel in Jupyter
RUN python -m ipykernel install --user --name=pyspark --display-name "PySpark"

# Configure permissions for Jupyter configuration
RUN sudo mkdir -p /home/jovyan/.local/share/jupyter && \
    chown -R $NB_UID:$NB_GID /home/jovyan/.local

# Revert to the original user
USER $NB_UID

# Expose the port for JupyterLab
EXPOSE 8888

# Start JupyterLab
CMD ["jupyter", "lab", "--ip=0.0.0.0", "--port=8888", "--no-browser", "--allow-root", "--NotebookApp.token=''"]

```

## 🚀 Operating instructions

### 1. Build the image
Once you have your Dockerfile ready, you have to build the image. To complete it, you need to have your **Docker Desktop** application running, and then open a powershell in the directory where is located the Dockerfile.

Then, run this:

```bash
docker build -t jupyter-spark .
```

### 2. Run the image

Now, you need to run your image specifying the **8888 port** to launch it as the Jupyter Lab interface:

```bash
docker run --name jupyter-lab -p 8888 jupyter-spark
```

After executing the container, you must have Jupyter Lab in your navigator by visiting this local link:
- http://localhost:8888

## 💻 Testing 

Now, it´s time to test with some simple **Scala** and **PySpark** codes, only to know that it is working properly

### 1.-**Scala**

You must open an **Apache Toree** notebook and then type this in a cell:

```bash
import org.apache.spark.sql.SparkSession
 
val spark = SparkSession.builder.appName("ScalaExample").getOrCreate()
 
val data = Seq(("Ana", 22), ("Pablo", 28), ("Carla", 31))
val columns = Seq("Name", "Age")
val df = spark.createDataFrame(data).toDF(columns: _*)
 
df.show()
 
val filteredDf = df.filter("Age > 25")
filteredDf.show()
 
spark.stop()
```

And then, the solution must return:
```
+-----+---+
| Name|Age|
+-----+---+
|  Ana| 22|
|Pablo| 28|
|Carla| 31|
+-----+---+

+-----+---+
| Name|Age|
+-----+---+
|Pablo| 28|
|Carla| 31|
+-----+---+
```
### 2.-**PySpark**

To try coding with PySpark, we have to open a new notebook with **Python** (any version) and then insert this in a new cell:

```bash
import findspark
findspark.init()

from pyspark.sql import SparkSession

spark = SparkSession.builder.appName("PySparkExample").getOrCreate()

data = [("Juan", 23), ("María", 25), ("Luis", 30)]
columns = ["Name", "Age"]
df = spark.createDataFrame(data, columns)
df.show()
```
And the output must be:

```
+------+---+
|  Name|Age|
+------+---+
|  Juan| 23|
| María| 25|
|  Luis| 30|
+------+---+
```
## 🤝 Contributing
Contributions are welcome! If you’d like to improve this project, please follow these steps:

1. Fork the project.
2. Create a new branch: `git checkout -b feature/your-feature`.
3. Make your changes and commit them: `git commit -m 'Add your feature'`.
4. Push to the branch: `git push origin feature/your-feature`.
5. Open a pull request.

## 📄 License
This project is licensed for educational purposes, with freedom to use in learning environments.

Thank you all for your time! It´s a great pleassure for me 😁😁.
