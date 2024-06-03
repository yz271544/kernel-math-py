# Ubuntu 18.04.1 LTS Bionic
ARG BASE_CONTAINER=elyra/kernel-py:3.2.3
FROM $BASE_CONTAINER

USER root
RUN sed -i s@/archive.ubuntu.com/@/mirrors.aliyun.com/@g /etc/apt/sources.list
RUN sed -i s@/security.ubuntu.com/@/mirrors.aliyun.com/@g /etc/apt/sources.list

ENV PATH=$PATH:$CONDA_DIR/bin

RUN conda install --quiet --yes \
    cffi \
    future \
    pycryptodomex && \
    conda clean --all && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER 

# ADD jupyter_enterprise_gateway_kernel_image_files-3.2.3.tar.gz /usr/local/bin/
RUN apt-get clean
RUN apt-get update && apt-get install -yq --no-install-recommends \
    libkrb5-dev \
    && rm -rf /var/lib/apt/lists/*

# 安装HDF5
RUN apt-get update && apt-get install -y \
    libhdf5-dev \
    libnetcdf-dev \
    netcdf-bin \
    && rm -rf /var/lib/apt/lists/*

# 设置HDF5_DIR环境变量，帮助netCDF4的安装过程找到HDF5头文件
ENV HDF5_DIR=/usr/lib/x86_64-linux-gnu/hdf5/serial/
ENV NETCDF4_DIR=/usr/

RUN apt-get update && apt-get install -y portaudio19-dev

RUN apt-get update && apt-get install -y graphviz libgraphviz-dev

RUN apt-get update && apt-get install -y libgeos-dev

RUN apt-get update && apt-get install -y gnupg lsb-release wget ca-certificates


# RUN apt-get update && apt-get install -y -V ca-certificates lsb-release wget && \
#     wget -O- https://apache.jfrog.io/artifactory/arrow/ubuntu/apache-arrow-archive-keyring.gpg | gpg --dearmor > /usr/share/keyrings/apache-arrow-archive-keyring.gpg && \
#     echo "deb [signed-by=/usr/share/keyrings/apache-arrow-archive-keyring.gpg] https://apache.jfrog.io/artifactory/arrow/ubuntu/$(lsb_release -cs) main" > /etc/apt/sources.list.d/apache-arrow.list && \
#     echo "deb-src [signed-by=/usr/share/keyrings/apache-arrow-archive-keyring.gpg] https://apache.jfrog.io/artifactory/arrow/ubuntu/$(lsb_release -cs) main" >> /etc/apt/sources.list.d/apache-arrow.list

# 更新APT索引并安装

RUN apt-get update && apt-get install -y \
    build-essential \
    cmake 
    # libarrow-dev \
    # libarrow-glib-dev \
    # libarrow-dataset-dev \
    # libparquet-dev \
    # libparquet-glib-dev

COPY requirements.yml .
RUN conda config --append channels conda-forge
RUN conda config --append channels defaults
RUN conda config --append channels free
RUN conda env update -n base -f requirements.yml

#RUN pip install --retries 20 -i https://repo.sensetime.com/repository/pypi/simple/ \
#  --no-cache-dir -r requirements.txt

#RUN chown jovyan:users /usr/local/bin/bootstrap-kernel.sh && \
#	chmod 0755 /usr/local/bin/bootstrap-kernel.sh && \
#	chown -R jovyan:users /usr/local/bin/kernel-launchers

USER jovyan
RUN mkdir /mnt/data

RUN chmod 777 /mnt/data

# Disble healthcheck inherited from notebook image
HEALTHCHECK NONE

CMD ["/bin/bash", "-o", "pipefail", "-c", "/usr/local/bin/bootstrap-kernel.sh"]
