# # FROM nvidia/cuda:10.2-base

# # WORKDIR /app

# # COPY . .

# # CMD nvidia-smi
# # #set up environment
# # RUN apt-get update && apt-get install --no-install-recommends --no-install-suggests -y curl
# # RUN apt-get install unzip
# # # RUN apt-get -y install python3
# # # RUN apt-get -y install python3-pip
# # RUN apt install software-properties-common -y
# # RUN add-apt-repository ppa:deadsnakes/ppa
# # RUN apt install python3.8 -y

# # RUN pip3 install -r requirements.txt

# # # RUN ln -s /usr/bin/pip3 /usr/bin/pip
# # # RUN ln -s /usr/bin/python3.8 /usr/bin/python
# # # RUN pip3 install jupyterlab keras sklearn seaborn pandas numpy matplotlib tensorflow torch torchvision torchaudio

# # # Add Tini. Tini operates as a process subreaper for jupyter. This prevents kernel crashes.
# # ENV TINI_VERSION v0.6.0
# # ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /usr/bin/tini
# # RUN chmod +x /usr/bin/tini
# # ENTRYPOINT ["/usr/bin/tini", "--"]

# # CMD ["jupyter", "lab", "--port=8888", "--no-browser", "--ip=0.0.0.0", "--allow-root"]


# FROM nvidia/cuda:10.2-runtime AS jupyter-base

# WORKDIR /app

# COPY . .

# # Install Python and its tools
# RUN apt update && apt install -y --no-install-recommends \
#     git \
#     build-essential \
#     python3-dev \
#     python3-pip \
#     python3-setuptools \
#     nvidia-cuda-toolkit
# RUN pip3 -q install pip --upgrade
# # Install all basic packages
# RUN pip3 install \
#     # Jupyter itself
#     jupyterlab \
#     # Numpy and Pandas are required a-priori
#     numpy pandas \
#     # PyTorch with CUDA 10.2 support and Torchvision
#     torch torchvision \
#     # Upgraded version of Tensorboard with more features
#     tensorboardX

# # RUN tar -xvzf cudnn-10.1-linux-ppc64le-v8.0.5.39.tgz
# RUN cp cuda/include/cudnn.h /usr/lib/cuda/include/
# RUN cp cuda/lib64/libcudnn* /usr/lib/cuda/lib64/
# RUN chmod a+r /usr/lib/cuda/include/cudnn.h /usr/lib/cuda/lib64/libcudnn*

# RUN echo 'export LD_LIBRARY_PATH=/usr/lib/cuda/lib64:$LD_LIBRARY_PATH' >> ~/.bashrc
# RUN echo 'export LD_LIBRARY_PATH=/usr/lib/cuda/include:$LD_LIBRARY_PATH' >> ~/.bashrc

# CMD ["nvcc", "-V"]

# # RUN export PATH=/usr/local/cuda/bin:$PATH
# # RUN export LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH

# # Here we use a base image by its name - "jupyter-base"
# FROM jupyter-base
# # Install additional packages
# RUN pip3 install \
#     # Hugging Face Transformers
#     transformers \
#     # Progress bar to track experiments
#     barbar

# # Add Tini. Tini operates as a process subreaper for jupyter. This prevents kernel crashes.
# ENV TINI_VERSION v0.6.0
# ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /usr/bin/tini
# RUN chmod +x /usr/bin/tini
# ENTRYPOINT ["/usr/bin/tini", "--"]

# CMD ["jupyter", "lab", "--port=8888", "--no-browser", "--ip=0.0.0.0", "--allow-root"]


FROM nvidia/cuda:10.2-cudnn7-devel-ubuntu18.04 AS jupyter-base


WORKDIR /app

COPY ./notebook .
COPY ./requirements.txt .

# Install Python and its tools
RUN apt update && apt install -y --no-install-recommends \
    git \
    build-essential \
    python3-dev \
    python3-pip \
    python3-setuptools
RUN pip3 -q install pip --upgrade
# Install all basic packages
RUN pip3 install \
    # Jupyter itself
    jupyterlab \
    # Numpy and Pandas are required a-priori
    numpy pandas \
    # PyTorch with CUDA 10.2 support and Torchvision
    torch torchvision \
    # Upgraded version of Tensorboard with more features
    tensorboardX

# Here we use a base image by its name - "jupyter-base"
FROM jupyter-base
# Install additional packages
RUN pip3 install \
    # Hugging Face Transformers
    transformers \
    # Progress bar to track experiments
    barbar

# Add Tini. Tini operates as a process subreaper for jupyter. This prevents kernel crashes.
ENV TINI_VERSION v0.6.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /usr/bin/tini
RUN chmod +x /usr/bin/tini
ENTRYPOINT ["/usr/bin/tini", "--"]

CMD ["jupyter", "lab", "--port=8888", "--no-browser", "--ip=0.0.0.0", "--allow-root"]