FROM jupyter/scipy-notebook
USER root

# Java
ENV JAVA_VERSION="11"
ENV JAVA_HOME="/usr/lib/jvm/java-${JAVA_VERSION}-openjdk-amd64"
RUN apt-get -y update \
 && apt-get install --no-install-recommends -y "openjdk-${JAVA_VERSION}-jdk-headless" \
 && apt-get clean  \
 && rm -rf /var/lib/apt/lists/*

# Spark & AUT toolkit
ENV APPS_HOME="/home/jovyan/apps"
RUN mkdir -p ${APPS_HOME}

ENV SPARK_VERSION="3.0.0"
ENV HADOOP_VERSION="2.7"
ENV SPARK_HADOOP_VERSION="spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}"
RUN wget "https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/${SPARK_HADOOP_VERSION}.tgz" \
 && tar -xf "${SPARK_HADOOP_VERSION}.tgz" \
 && rm  -rf "${SPARK_HADOOP_VERSION}.tgz" \
 && mv spark-* ${APPS_HOME}

ENV AUT_VERSION="0.91.0"
RUN wget "https://github.com/archivesunleashed/aut/releases/download/aut-${AUT_VERSION}/aut-${AUT_VERSION}.zip" \
 && wget "https://github.com/archivesunleashed/aut/releases/download/aut-${AUT_VERSION}/aut-${AUT_VERSION}-fatjar.jar" \
 && mv aut-* ${APPS_HOME}

# Jupyter config
RUN echo 'c.NotebookApp.allow_origin = "https://colab.research.google.com"' >> /home/jovyan/.jupyter/jupyter_notebook_config.py \
 && echo 'c.NotebookApp.port_retries = 0'     >> /home/jovyan/.jupyter/jupyter_notebook_config.py \
 && echo 'c.NotebookApp.open_browser = False' >> /home/jovyan/.jupyter/jupyter_notebook_config.py \
 && echo 'c.NotebookApp.base_url     = "/"'   >> /home/jovyan/.jupyter/jupyter_notebook_config.py \
 && echo 'c.NotebookApp.ip           = "*"'   >> /home/jovyan/.jupyter/jupyter_notebook_config.py \
 && echo 'c.NotebookApp.token        = ""'    >> /home/jovyan/.jupyter/jupyter_notebook_config.py \
 && echo 'c.NotebookApp.notebook_dir = "/notebook_dir"' >> /home/jovyan/.jupyter/jupyter_notebook_config.py \
 && pip install --upgrade jupyter_http_over_ws>=0.0.7  \
 && jupyter serverextension enable --py jupyter_http_over_ws

# Spacy
RUN pip install -U pip setuptools wheel \
 && pip install -U spacy \
 && python -m spacy download en_core_web_sm

# Python modules
RUN pip install findspark  plotly==5.5.0
