# Hadoop on Docker
Use this to get a quick version of Hadoop to run on Docker.

1. Install Docker on your host PC
<br>
 i).  For linux(ubuntu ) 

  ```bash
 
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

 Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
```

--To install the latest version, run following command :

```bash
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

--Verify that the Docker Engine installation is successful by running below command :(This command downloads a test image and runs it in a container. When the container runs, it prints a confirmation message and exits.) You have now successfully installed and started Docker Engine.
```bash
sudo docker run hello-world
```


2. Clone your platform specific branch of this repository
```bash
# Windows
git clone -b windows --single-branch https://github.com/silicoflare/docker-hadoop

# Mac
git clone -b mac --single-branch https://github.com/silicoflare/docker-hadoop

# Linux
git clone -b linux --single-branch https://github.com/silicoflare/docker-hadoop
```
<br>

3. Navigate to the directory
```bash
cd docker-hadoop
```
<br>

4. Build the docker image (you may need to use sudo)
```bash
docker build -t hadoop .
```
<br>

5. Wait for the build to finish
<br>

6. Create a new container using the newly created image
```bash
docker run -it -p 9870:9870 -p 8088:8088 -p 9864:9864 --name anyname hadoop bash
```
<br>

7. Once the prompt appears, execute the following command to initialize everything:
```bash
init
```
<br>

8. From the next time, just run this to open the prompt. Use the same name that you used to create the container.
```bash
docker start anyname
docker exec -it anyname bash
```

Once in, execute:
```bash
restart
```
