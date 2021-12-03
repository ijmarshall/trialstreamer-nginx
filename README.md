# Trialstreamer-Nginx
Documentation for deploying production services of Trialstreamer project on a AWS EC2 machine with an Nvidia GPU (_g4dn.2xlarge_). 

Follow these steps in order to set up Robotreviewer and Trialstreamer services properly for
the production environment.

## Settings 

### Cloning repositories 

1. Clone the repositories **robotreviewer**, **trialstreamer**, **trialstreamer-demo** and **trialstreamer-nginx**
   inside a `~/prod` folder. 

   ```
   mkdir -p ~/prod
   cd prod
   git clone git@github.com:ijmarshall/robotreviewer.git
   git clone git@github.com:ijmarshall/trialstreamer.git
   git clone git@github.com:ijmarshall/trialstreamer-demo.git
   git clone git@github.com:ijmarshall/trialstreamer-nginx.git
   ```

2. Update the submodule **ictrp-rerieval** repository at `~/prod/trialstreamer/trialstreamer/ictrp-retrieval` by running: 
    ```   
    git submodule init  
    git submodule update 
    ```
### Requirements

- [**Docker**](https://docs.docker.com/engine/install/ubuntu/) (_check installation with `docker info`_)  
- [**docker-compose**](https://docs.docker.com/compose/install/) (_check installation with `docker-compose --version`_)

### Mounting the storage disk

The default storage of the primary disk may not be sufficient for storing all the update files or to keep local Docker images.
The _g4dn.2xlarge_ machine has up to 225GB storage available, but it's secondary disk `/dev/nvme1n1` must be partitioned and mounted to be able to use it.

This process has to be done only once:

- Give a `ext4` format to the disk `sudo mkfs -t ext4 /dev/nvme1n1`
- Mount on `/data` folder with `sudo mount /dev/nvme1n1 /data` and check it appears as mounted with `lsblk`
- Check the disk's UUID with `sudo file -s /dev/nvme1n1` and then add the disk to the file systems table to allow 
  that auto-mount on start:
  ```
  sudo echo "UUID=<disk's uuid> /data ext4 defaults,nofail 0 2" >> /etc/fstab
  ```
- Create the pubmed updates folder with: `mkdir -p /data/pubmed-data/updates`

Once the disk is mounted, if the space is not enough for creating all Docker images, and if it has not been done before,
the Docker folder can be change to the storage disk following [these instructions](https://www.guguweb.com/2019/02/07/how-to-move-docker-data-directory-to-another-location-on-ubuntu/).

### GPU support

Install Cuda drivers & `nvidia-container-runtime` following the instructions from https://docs.docker.com/compose/gpu-support/  

After installing the drivers you may have to reboot the machine to be able to use the GPU resources properly. 

To check that the drivers were successfully installed, you should be able to run the `nvidia-smi` command.

### Services configurations

#### Trialstreamer API 

1. Edit `config.json` and `.env` files.  

2. API Key used by Trialstreamer Demo must be set in the JSON file.  

3. Make sure there is a `pubmed-data/updates` folder available with sufficient capacity (80GB+).

4. Update the volumes defined at `docker-compose.yml` to be consistent with the folder created at 3. 
    ```
    volumes: 
        - /data/pubmed-data:/var/lib/deploy/pubmed-data 
    ```
5. Remove the exposed ports of `api`. In production these services are exposed by Nginx.

#### Trialstreamer-Demo 

1. Edit `.env` file with `VUE_APP_SERVER_URL` directing to external URL for Trialstreamer API and 
   the corresponding `VUE_APP_API_KEY`.

2. Edit `docker-compose.yml` removing the port exposed by `demo` service if running the Production Proxy. 
 
#### Robotreviewer 

1. Edit `config.json` and `.env` files if necessary. 

    **NOTE:** If running with GPU, it is recommended to set `TF_FORCE_GPU_ALLOW_GROWTH='true'`.

2. API Key used by Trialstreamer must be set in the `config.json` file.

3. Remove the exposed ports of `web` and `api`. In production these services are exposed by Nginx.

## Running services 

#### Robotreviewer 

At `~/prod/robotreviewer/` run: 
```
docker-compose -f docker-compose.gpu.yml build
docker-compose -f docker-compose.gpu.yml up -d
```
To stop, run: 
```
docker-compose -f docker-compose.gpu.yml down --remove-orphans 
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
 
#### Production Reverse Proxy

1. Perform any desired changes in the Nginx configuration at `trialstreamer-nginx/nginx.conf`,
   for example, you may want to change:
   - `client_max_body_size 512M;` for the `demo.robotreviewer.net` server, that allows for the PDF uploads up to a 512M body size on the request.

2. After the Docker networks `robotreviewer_default`, `trialstreamer_default` and `trialstreamer-demo_default` are available, 
at `~/prod/trialstreamer-nginx/` run:

```
docker-compose build 
```
* **NOTE:** At this point if you haven't already generated the SSL certificates, you will have to:
   1. Create initial certificates `docker-compose run --rm certbot init`
   2. Start the nginx server: `docker-compose up -d`
   3. Generate the SSL certificates for robotreviewer.net with `docker-compose run --rm certbot create-cert`

```
docker-compose up -d
```


3. To renew the certificates using **certbot** image run:
```
docker-compose run --rm certbot renew
```
This command can be setup as a cronjob in order to be automated.

To stop, run: 
```
docker-compose down --remove-orphans 
```


#### Check status & logs 

Run `docker ps` to check the services status.

Run `docker stats` to check the memory and CPU usage of all services.

The logs of any container can be followed running `docker logs <container_name> -f` 
