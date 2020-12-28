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