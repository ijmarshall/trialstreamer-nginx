# Trialstreamer-Nginx
Documentation for deploying production services of Trialstreamer project on a AWS EC2 machine.

After cloning this repository, follow these steps in order to set up Robotreviewer and Trialstreamer services properly for
the production environment.

## Settings 

### Cloning repositories 

1. Clone the repositories robotreviewer, trialstreamer, trialstreamer-demo and trialstreamer-aws
   inside the  `~/prod` folder. 

   ```
   git clone git@github.com:ijmarshall/robotreviewer.git
   git clone git@github.com:ijmarshall/trialstreamer.git
   git clone git@github.com:ijmarshall/trialstreamer-demo.git
   git clone git@github.com:ijmarshall/trialstreamer-nginx.git
   ```

2. Update the submodule ictrp-rerieval repository at `~/prod/trialstreamer/trialstreamer/ictrp-retrieval` by running: 
    ```   
    git submodule init  
    git submodule update 
    ```

3. Update `servername` domains and the proper SSL paths at `trialstreamer-nginx/nginx.conf`.

### GPU support

1. Install Cuda drivers & `nvidia-container-runtime` following instructions from https://docs.docker.com/compose/gpu-support/  

### Services configurations

#### Trialstreamer API 

1. Edit `config.json` and `.env` files.  

2. API Key used by Trialstreamer Demo must be set in the JSON file.  

3. Create a `pubmed-data` folder for updates in a disk with sufficient storage.
   
   This folder is located at `/data/pubmed-data/` in production and was created with: 
   ```
   mkdir -p /data/pubmed-data/updates  
   ```

4. Update the volumes defined at `docker-compose.yml` to be consistent with the folder created at 3. 
    ```
    volumes: 
        - /data/pubmed-data:/var/lib/deploy/pubmed-data 
    ```

#### Trialstreamer-Demo 

1. Edit `.env` file with `VUE_APP_SERVER_URL` directing to external URL for Trialstreamer API and 
   the corresponding `VUE_APP_API_KEY`. 

2. Edit `docker-compose.yml` removing the port exposed by `demo` service if running the Production Proxy. 
 
#### Robotreviewer 

1. Edit `config.json` and `.env` files. 

2. API Key used by Trialstreamer must be set in the `config.json` file.
 

## Running services 

#### Robotreviewer 

At `~/prod/robotreviewer/` run: 
```
docker-compose -f docker-compose.gpu.yml build
docker-compose -f docker-compose.gpu.yml up -d
```
To stop, run: 
```
docker-compose -f dodcker-compose.gpu.yml down --remove-orphans 
```

#### Trialstreamer 

After the network `robotreviewer_default` is available, at `~/prod/trialstreamer/` run: 

```
docker-compose build 
docker-compose up –d 
```
To stop, run: 
```
docker-compose down --remove-orphans 
```

#### Trialstreamer-Demo 

At `~/prod/trialstreamer-demo/` run: 

```
docker-compose build
docker-compose up –d 
```
To stop, run: 
```
docker-compose down --remove-orphans 
```
 
#### Production Proxy

After the networks `robotreviewer_default` and `trialstreamer-demo_default` are available, 
at `~/prod/trialstreamer-nginx/` run:

```
docker-compose build
docker-compose up –d 
```

To stop, run: 
```
docker-compose down --remove-orphans 
```


#### Check status & logs 

Run `docker ps` to check the services status.

Run `docker stats` to check the memory and CPU usage of all services.

The logs of any container can be followed running `docker logs <container_name> -f` 
