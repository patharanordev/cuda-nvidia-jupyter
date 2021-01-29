# **cuda-nvidia-jupyter**

To supoort dockerized JupyterLab on GPU.

## **Usage**

```bash
$ docker run -d --gpus all \
-p "8888:8888" \
-v notebook:/app/notebook \
--restart always \
--name=cuda-jupyter \
patharanor/cuda-nvidia-jupyter:0.1.0
```

Before open jupyter-lab via web browser, you need to check jupyter's token first by:

```bash
$ docker logs cuda-jupyter
```

Enjoy on :

```
YOUR_HOST_IP:8888/?token=TOKEN_ID
```

## **Storage**

The service bind volume from `/app/notebook` in the container to current directory of host machine `./notebook`. So you can get any files via `./notebook`.

-----------------------------------
## **[Optional] Preparing Env for CUDA on Huawei Cloud**

> **CentOS based**

### **Prerequisites**

```bash
$ sudo yum update -y
$ sudo yum install pciutils wget epel-release dkms -y
$ sudo yum install -y python3
$ sudo yum install -y yum-utils

# verify gpu device
$ lspci | grep -i nvidia
# gcc compiler is required for development using the cuda toolkit.
$ gcc --version
```

### **Install Docker**

```bash
$ sudo yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo
$ sudo yum install docker-ce docker-ce-cli containerd.io
$ sudo systemctl start docker
```

### **Set NVIDIA Driver path**

```bash
# setup your paths
$ echo 'export PATH=/usr/local/cuda/bin:$PATH' >> ~/.bashrc
$ echo 'export LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH'

# Checking
$ nvidia-smi
$ nvcc -V
```

### **Install NVIDIA Container Toolkit**

```bash
$ distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
$ curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.repo | sudo tee /etc/yum.repos.d/nvidia-docker.repo

# install nvidia-container-toolkit
$ sudo yum install -y nvidia-container-toolkit
$ sudo systemctl restart docker

# run docker with gpu options
$ docker run --gpus all nvidia/cuda:10.0-base nvidia-smi

+-----------------------------------------------------------------------------+
| NVIDIA-SMI 440.33.01    Driver Version: 440.33.01    CUDA Version: 11.0     |
|-------------------------------+----------------------+----------------------+
| GPU  Name        Persistence-M| Bus-Id        Disp.A | Volatile Uncorr. ECC |
| Fan  Temp  Perf  Pwr:Usage/Cap|         Memory-Usage | GPU-Util  Compute M. |
|===============================+======================+======================|
|   0  Tesla T4            Off  | 00000000:21:01.0 Off |                    0 |
| N/A   41C    P0    26W /  70W |      0MiB / 15109MiB |      0%      Default |
+-------------------------------+----------------------+----------------------+
|   1  Tesla T4            Off  | 00000000:21:02.0 Off |                    0 |
| N/A   39C    P0    26W /  70W |      0MiB / 15109MiB |      0%      Default |
+-------------------------------+----------------------+----------------------+
|   2  Tesla T4            Off  | 00000000:21:03.0 Off |                    0 |
| N/A   38C    P0    26W /  70W |      0MiB / 15109MiB |      0%      Default |
+-------------------------------+----------------------+----------------------+
|   3  Tesla T4            Off  | 00000000:21:04.0 Off |                    0 |
| N/A   40C    P0    27W /  70W |      0MiB / 15109MiB |      5%      Default |
+-------------------------------+----------------------+----------------------+
                                                                               
+-----------------------------------------------------------------------------+
| Processes:                                                       GPU Memory |
|  GPU       PID   Type   Process name                             Usage      |
|=============================================================================|
|  No running processes found                                                 |
+-----------------------------------------------------------------------------+
```

### **Install Nvidia container runtime**

```bash
$ distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
$ curl -s -L https://nvidia.github.io/nvidia-container-runtime/$distribution/nvidia-container-runtime.repo | \
  sudo tee /etc/yum.repos.d/nvidia-container-runtime.repo
```

For pre-releases, you need to enable the experimental repos of all dependencies:

```bash
$ sudo yum-config-manager --enable libnvidia-container-experimental
$ sudo yum-config-manager --enable nvidia-container-experimental
```

To later disable the experimental repos of all dependencies, you can run:

```bash
$ sudo yum-config-manager --disable libnvidia-container-experimental
$ sudo yum-config-manager --disable nvidia-container-runtime-experimental
```

**Updating repository keys**

In order to update the nvidia-container-runtime repository key for your distribution, follow the instructions below.

```bash
$ DIST=$(sed -n 's/releasever=//p' /etc/yum.conf)
$ DIST=${DIST:-$(. /etc/os-release; echo $VERSION_ID)}
$ sudo rpm -e gpg-pubkey-f796ecb0
$ sudo gpg --homedir /var/lib/yum/repos/$(uname -m)/$DIST/nvidia-container-runtime/gpgdir --delete-key f796ecb0
$ sudo yum makecache
```

### **Set Docker daemon to support CUDA**

In `/etc/docker/daemon.json`:

```json
{
  "default-runtime": "nvidia",
  "runtimes": {
    "nvidia": {
      "path": "/usr/bin/nvidia-container-runtime",
      "runtimeArgs": []
    }
  }
}
```

then :

```bash
$ sudo systemctl start docker
```

Ref.:
 - Nvidia container runtime - https://nvidia.github.io/nvidia-container-runtime/

-----------------------------------

## **Issues**

**GPU's memory doesn't release after train model**

Let's try `numba`.

Ref : https://stackoverflow.com/questions/39758094/clearing-tensorflow-gpu-memory-after-model-execution

```py
from numba import cuda 
device = cuda.get_current_device()
device.reset()
```

## **Contributing**

```bash
# Build image
$ docker build -f dev.Dockerfile -t patharanor/cuda-nvidia-jupyter:0.1.0 .

# Push image to DockerHub
$ docker push patharanor/cuda-nvidia-jupyter:0.1.0
```

## **License**

MIT