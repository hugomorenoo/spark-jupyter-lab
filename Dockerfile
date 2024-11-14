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
