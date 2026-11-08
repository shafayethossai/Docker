# 🐳 Docker Notes + Node.js Test App

> My handwritten Docker course notes (pages 1–12), converted to a README so I can quickly revise anytime.
> The `docker-testapp` Node.js project from the course lives in this repo and is used in the examples.

---

## 📑 Table of Contents

| # | Topic | Note page |
|---|-------|-----------|
| 1 | [What is Docker? (Why + Benefits)](#1--what-is-docker) | 1 |
| 2 | [Basic Docker Commands](#2--basic-docker-commands) | 2 |
| 3 | [Pull images, Attach vs Detach, Environment variables](#3--pull-images-detach-vs-attach-environment-variables) | 3 |
| 4 | [Port Binding + Troubleshooting](#4--port-binding) | 4 |
| 5 | [Docker vs VM, Docker Network, Run MongoDB](#5--docker-vs-vm) | 5 |
| 6 | [Run Mongo-Express](#6--run-mongo-express) | 6 |
| 7 | [Restart Docker daemon + Docker Compose](#7--restart-docker-daemon--docker-compose) | 7 |
| 8 | [Remove network + Dockerizing our app (Dockerfile)](#8--dockerizing-our-app-dockerfile) | 8 |
| 9 | [Creating and pushing images](#9--creating--pushing-images) | 9 |
| 10 | [Docker Volumes](#10--docker-volumes) | 10 |
| 11 | [Types of Volumes](#11--types-of-volumes) | 11 |
| 12 | [Prune volumes + Network drivers](#12--prune-volumes--network-drivers) | 12 |
| 🎯 | [Full project flow (Node app + Mongo + Mongo-Express)](#-full-project-flow) | – |
| 🛠️ | [Mistakes I made & fixes](#️-mistakes-i-made--fixes) | – |
| ⚡ | [Quick cheat sheet](#-quick-cheat-sheet) | – |

---

## 1. 🧠 What is Docker?

**The problem:** My app works on my machine, but not on my teammate's.

```
  Mine (Linux)                      Teammate (macOS)
 ┌───────────────┐                 ┌───────────────┐
 │     App       │  ───────────▶   │     App       │
 └───────────────┘                 └───────────────┘
  node v16                          node v20
  mongo v4.2                        mongo v6
                                    └─ he downloads different versions → manual errors ❌
```

**The solution:** Package the **App + Dependencies** together using a **Dockerfile**.

```
 Mac A                                        Mac B
 ┌───────────────────────┐                   ┌───────────────────────┐
 │ Dockerfile            │ ───────────────▶  │ App + Dependencies    │
 │ [App + Dependencies]  │   (Docker Image)  │ (can run ✅)          │
 └───────────────────────┘                   └───────────────────────┘
```

### Image vs Container (Class vs Object)

```
                 Docker Image  (= Class)
                       │
        ┌──────────────┼──────────────┐
        ▼              ▼              ▼
   Container C1   Container C2   Container C3   ← Containers (= Objects)
     (obj1)         (obj2)         (obj3)
```

- **Image** = blueprint / template (like a *class*)
- **Container** = running instance of an image (like an *object*)
- One image → many containers

### ✅ Benefits

1. **Portable** – runs the same everywhere
2. **Lightweight** – much lighter than a virtual machine

---

## 2. 🔧 Basic Docker Commands

### Check version / help
```bash
docker -v                      # check Docker version
docker                         # list all commands
```

### Pull & run images
```bash
docker pull <image_name>       # download a full image
docker pull hello-world        # example

docker run <image_name>        # create a container from the image
docker run hello-world         # example → prints "Hello from Docker!"

docker pull ubuntu             # download the ubuntu image
docker run -it ubuntu          # interactive mode of ubuntu
```

> 💡 **`-it` before the image name** means "open from *inside* the container" (interactive + terminal).

Inside the ubuntu container you can use normal Linux commands:
```bash
root@4d43db5257e1:/# ls
root@4d43db5257e1:/# mkdir shafa
root@4d43db5257e1:/# exit          # leave the container
```

### List containers & images
```bash
docker ps                      # all RUNNING containers
docker ps -a                   # all containers (running + stopped)
docker images                  # all downloaded images
```

### Start / stop / remove
```bash
docker start <container_name_or_id>    # start a stopped container
docker stop  <container_name_or_id>    # stop a running container
docker rm    <container_name_or_id>    # remove a container
docker rmi   <image_name_or_id>        # remove an image
```

| Command | Works on | Meaning |
|---------|----------|---------|
| `docker rm` | **container** | delete container (must be stopped first) |
| `docker rmi` | **image** | delete image (no container should use it) |

> ⚠️ `rm` is for **c**ontainers, `rm`**i** is for **i**mages.

---

## 3. 📥 Pull Images, Detach vs Attach, Environment Variables

### Pull with a version (tag)
```bash
docker pull <image_name>:<version>

docker pull mysql              # downloads LATEST version of mysql
docker pull mysql:8.0          # downloads version 8.0 of mysql
```

> For **two separate MySQL versions**, we can create **separate containers**.

### Detach vs Attach mode

| 🔗 Attach mode (default) | 🔓 Detach mode (`-d`) |
|---|---|
| Runs in **my PC terminal** | Runs **behind the screen** (background) |
| Until I stop it, I **can't write anything** in that terminal | Terminal is free to use |
| If I delete the terminal, container **stops** | If I delete the terminal, it **keeps running** |
| Good for **debugging / watching live output** | Good for **databases, web servers** |

```bash
docker run -d <image>          # detach mode
```

### Environment variable for database

Some images (like MySQL) **need** an environment variable to start. Use `-e`.

```bash
docker run -d -e MYSQL_ROOT_PASSWORD=secret mysql
```

Give the container a name with `--name`, and run a specific version:
```bash
docker run -d -e MYSQL_ROOT_PASSWORD=secret --name mysql-older mysql:8.0
```

| Flag | Meaning |
|------|---------|
| `-d` | detach (run in background) |
| `-e KEY=VALUE` | set an environment variable |
| `--name` | give the container a name |

---

## 4. 🔌 Port Binding

Two containers can both use port `3306` **inside**, but the **host port** must be different. We **map** a host port → container port.

```bash
docker run -p <HOST_PORT>:<CONTAINER_PORT> <image_name>
docker run -p 8080:3306 <image_name>
```

```
                 HOST PORTS
              8080         5000
               │ mapping    │ mapping
        ┌──────▼─────┐ ┌────▼───────┐
        │   3306     │ │   3306     │   ← container port (same inside)
        │ mysql:8.0  │ │ mysql      │
        │  (Older)   │ │  (Latest)  │
        └────────────┘ └────────────┘
```

### Remove previous containers and create again with port binding

```bash
# Older version (8.0) → host port 8080
docker run -d -e MYSQL_ROOT_PASSWORD=secret --name mysql-older -p 8080:3306 mysql:8.0

# Latest version → host port 5000
docker run -d -e MYSQL_ROOT_PASSWORD=secret --name mysql-latest -p 5000:3306 mysql
```

### 🔍 Troubleshoot commands

```bash
docker logs mysql-latest
# → can check the ROOT CAUSE of problems

docker exec -it <container_name> /bin/bash
# → we can enter INSIDE this container,
#   we work and then we exit from here. The container KEEPS RUNNING.
```

> 📌 **My real example:** my container exited immediately. `docker logs` told me why:
> `Database is uninitialized and password option is not specified` → I had typed `MYSQL-ROOT-PASSWORD` (dash) instead of `MYSQL_ROOT_PASSWORD` (underscore). 😅

> 📌 `docker exec` **only works on a running container**. If the container exited you'll get `container ... is not running`.

---

## 5. 🆚 Docker vs VM

```
  Gmail, Google Chrome ...
 ┌──────────────────────┐
 │  Application Layer   │   ← Docker virtualizes ONLY this
 └──────────┬───────────┘
 ┌──────────▼───────────┐
 │   Host OS Kernel     │   ← VM virtualizes this too
 └──────────┬───────────┘
 ┌──────────▼───────────┐
 │      Hardware        │
 └──────────────────────┘
```

- **Docker** uses the **host OS kernel** and virtualizes only the **Application layer** → fast & light.
- **VM** virtualizes the **Application layer AND the host OS kernel** → heavy & slow.

---

### 🌐 Docker Network

Containers in the **same network** can talk to each other **by container name**.

```bash
docker network ls                       # check all networks
docker network create <network_name>    # create a docker network
docker network create mongo-network     # example
```

Default networks:
```
NETWORK ID     NAME            DRIVER    SCOPE
daba8c29b3fb   bridge          bridge    local
e6fb04d55a24   host            host      local
e476673e5b64   none            null      local
```

### 🍃 Run MongoDB

```bash
docker run -d \
  -p 27017:27017 \
  --name mongo \
  --network mongo-network \
  -e MONGO_INITDB_ROOT_USERNAME=admin \
  -e MONGO_INITDB_ROOT_PASSWORD=qwerty \
  mongo
```

| Part | Meaning |
|------|---------|
| `-d` | detach mode |
| `-p 27017:27017` | port binding |
| `--name mongo` | set name of container |
| `--network mongo-network` | select network |
| `-e MONGO_INITDB_ROOT_USERNAME=admin` | environment variable |
| `-e MONGO_INITDB_ROOT_PASSWORD=qwerty` | environment variable |
| `mongo` | image name |

---

## 6. 🖥️ Run Mongo-Express

Mongo-Express = a **web UI** to see/manage MongoDB.

```bash
docker run -d \
  -p 8081:8081 \
  --name mongo-express \
  --network mongo-network \
  -e ME_CONFIG_MONGODB_ADMINUSERNAME=admin \
  -e ME_CONFIG_MONGODB_ADMINPASSWORD=qwerty \
  -e ME_CONFIG_MONGODB_URL="mongodb://admin:qwerty@mongo:27017" \
  mongo-express
```

| Part | Meaning |
|------|---------|
| `-d` | detach |
| `-p 8081:8081` | port binding |
| `--name mongo-express` | set name |
| `--network mongo-network` | select network (**same network as mongo!**) |
| `-e ME_CONFIG_MONGODB_ADMINUSERNAME` / `...ADMINPASSWORD` | DB login |
| `-e ME_CONFIG_MONGODB_URL` | `mongodb://<user>:<pass>@<mongo container name>:27017` |

🌍 We can enter into mongo-express at: **`localhost:8081`** (username/password from the express login).

> 💡 In the URL, `mongo` is the **container name** of MongoDB. That works because both containers are on `mongo-network`.

---

## 7. ♻️ Restart Docker daemon + Docker Compose

### Force-stop running containers (Snap Docker)

When `docker stop` / `docker rm -f` gives **`permission denied`**, restart the daemon:

```bash
sudo snap restart docker
```

### 📦 Docker Compose

```bash
docker compose -f <fileName>.yaml up -d     # run the yaml file
docker compose -f <fileName>.yaml down      # remove all running containers (and network)
```

Example (from the project):
```bash
docker compose -f mongodb.yaml up -d
docker compose -f mongodb.yaml down
```

**Why Compose?**

> Before: we **manually** pulled `mongo`, `mongo-express` images, then created containers with **port binding, setting name, selecting network, environment variables**.
>
> With **Docker Compose** we can do **all these things in one YAML file** → just `up` and `down`.
> So we remove the manually created images/containers (previous mongo, mongo-express, database), and run `up` and set again.

---

## 8. 📝 Dockerizing Our App (Dockerfile)

### Remove Docker network
```bash
docker network rm <network_name>
```

### Dockerfile keywords

| Keyword | Meaning |
|---------|---------|
| `FROM` | **Base image** |
| `WORKDIR` | working directory path |
| `COPY` | copy **Host → image** |
| `RUN` | run an instruction **inside the container/image** (at build time) |
| `CMD` | command for **running the application** |
| `EXPOSE` | expose the port |
| `ENV` | define variables |

### Dockerfile (from my notes)

```dockerfile
FROM node

ENV MONGO_DB_USERNAME=admin \
    MONGO_DB_PWD=qwerty

RUN mkdir -p /testapp

COPY . /testapp

CMD ["node", "/testapp/server.js"]
```

> 🔄 **Later improvement I made in practice** (pinned Node version + `WORKDIR`):
> ```dockerfile
> FROM node:18
> ENV MONGO_DB_USERNAME=admin \
>     MONGO_DB_PWD=qwerty
> WORKDIR /testapp
> COPY . .
> CMD ["node", "server.js"]
> ```

---

## 9. 📦 Creating & Pushing Images

### Creating an image

```bash
docker build -t testapp:1.0 .
#                 └─ give name:tag      └─ "." = current folder (where Dockerfile is)
```

Then **check Docker images** → it **created an image**:
```bash
docker images
```

### Run it

```bash
docker run -it testapp:1.0 /bin/bash
# then check the files inside
```

### 🚀 Pushing images to Docker Hub

1. **Sign up** at <https://hub.docker.com>
2. **Create repo** (they give a name, like `username/reponame`)
3. **Build image for pushing with the given name**
   ```bash
   docker build -t shafayat53/testapp .
   ```
4. **Logout, then login** to your account
   ```bash
   docker logout
   docker login
   ```
5. **Push image**
   ```bash
   docker push shafayat53/testapp
   ```

> 💡 The image name must be `<dockerhub-username>/<repo-name>`, otherwise push is denied.

---

## 10. 💾 Docker Volumes

**Docker volumes store the container data into the host machine.**

```
 ┌────────────────────────────────────────────┐
 │  ubuntu container            host machine  │
 │  ┌───────────┐              ┌───────────┐  │
 │  │ /test/data│ ◀──────────▶ │  storage  │  │
 │  └───────────┘              └───────────┘  │
 └────────────────────────────────────────────┘
```

1. If the ubuntu container's data is **removed**, the data **stays in host machine storage**.
2. When we **start ubuntu again**, the data **comes back** to `/test/data`.

```bash
docker run -it -v <host_path>:<container_path> ubuntu
```

### Volume commands

```bash
docker volume ls                       # ① list docker volumes
docker volume create <vol_name>        # ② create a volume
docker volume rm <vol_name>            # ③ remove a volume
```

🐧 **Linux location:** `/var/lib/docker/volumes`

> ⚠️ If the path has **spaces** (like `/media/shafayet/Shafayet Hossain3/...`), wrap it in **double quotes**:
> ```bash
> docker run -it -v "/media/shafayet/Shafayet Hossain3/Docker/data:/test/data" ubuntu
> ```
> Otherwise you get: `invalid reference format: repository name (Docker/data) must be lowercase`.

---

## 11. 🗂️ Types of Volumes

### ① Named Volumes

```bash
docker run -v <vol_name>:<container_dir> <image>
```

- After creating any custom volume, then running the above command using the `vol_name` **creates the connection**.
- If the volume is **not created**, Docker will **create it first**.

### ② Anonymous Volumes

```bash
docker run -v <container_path> <image>
```

- For **temporary** volume (Docker gives it a random long name).

### ③ Bind Mount

```bash
docker run -v <host_dir>:<container_dir> <image>
```

- You choose the **exact folder on your host machine**.

### Alternative syntax (`--mount`)

```bash
docker run --mount type=volume,src=<vol_name>,dst=<mount_path> <image>
```

| Type | Command | Use |
|------|---------|-----|
| Named | `-v vol_name:/cont_dir` | permanent data managed by Docker |
| Anonymous | `-v /cont_dir` | temporary |
| Bind mount | `-v /host_dir:/cont_dir` | my own host folder |

---

## 12. 🧹 Prune Volumes + Network Drivers

### Removing anonymous (unused) volumes

```bash
docker volume prune
# WARNING! This will remove anonymous local volumes not used by at least one container.
```

### 🌉 Docker Network: **Bridge**

- Types: **Default** bridge and **Custom** bridge.
- When we create a network, its **driver is set to bridge**. It means it can **interact with other bridge drivers in the host machine, also the outside world**.

```
 ┌──────────────────────────────────┐
 │  ┌─────────────┐ ┌─────────────┐ │
 │  │ Container A │ │ Container B │ │
 │  └──────┬──────┘ └──────┬──────┘ │
 │         ▼               ▼        │
 │       ┌─────────────────┐        │
 │       │     Bridge      │        │
 │       └─────────────────┘        │
 └──────────────────────────────────┘
```

### 🖥️ Docker Network: **Host**

- Container lives **inside the host machine** itself.
- **No need for port mapping.**

```bash
docker run --network host <image>
```

### 🚫 Docker Network: **Null**

- Use **only for offline tasks** (no network at all).

```bash
docker run --network none <image>
```

| Driver | Description |
|--------|-------------|
| `bridge` | default; containers talk via a virtual bridge, need `-p` for host access |
| `host` | uses host network directly; no port mapping needed |
| `none` (null) | no networking; offline tasks only |

---

# 🎯 Full Project Flow

Project: **`docker-testapp`** – a Node.js app (`server.js`) that connects to **MongoDB**, with **Mongo-Express** as the DB UI.

### 📁 Structure

```
docker-testapp/
├── Dockerfile          # how to build the node app image
├── mongodb.yaml        # docker compose file (testapp + mongo + mongo-express)
├── package.json
├── package-lock.json
├── public/             # frontend files
├── server.js           # node app entry
└── README.md           # (this file)
```

### 🧩 Example `mongodb.yaml`

> Adjust names/values to match your own file. Ports used in my practice: app `5050`, mongo-express `8081`, mongo `27017`.

```yaml
services:
  testapp:
    image: testapp:1.0
    ports:
      - "5050:5050"
    depends_on:
      - mongo

  mongo:
    image: mongo
    ports:
      - "27017:27017"
    environment:
      - MONGO_INITDB_ROOT_USERNAME=admin
      - MONGO_INITDB_ROOT_PASSWORD=qwerty
    volumes:
      - mongo-data:/data/db        # keep DB data even after `down`

  mongo-express:
    image: mongo-express
    ports:
      - "8081:8081"
    environment:
      - ME_CONFIG_MONGODB_ADMINUSERNAME=admin
      - ME_CONFIG_MONGODB_ADMINPASSWORD=qwerty
      - ME_CONFIG_MONGODB_URL=mongodb://admin:qwerty@mongo:27017
    depends_on:
      - mongo

volumes:
  mongo-data:
```

> ℹ️ Docker Compose automatically creates a network (e.g. `docker-testapp_default`) and puts all services in it, so I don't need `docker network create` manually. The `version:` key is obsolete – leave it out.

### ▶️ Step by step

```bash
# 1. Go to the project
cd docker-testapp

# 2. Build the app image
docker build -t testapp:1.0 .

# 3. Start everything (app + mongo + mongo-express)
docker compose -f mongodb.yaml up -d

# 4. Check
docker ps
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# 5. Open in the browser
#    App            → http://localhost:5050
#    Mongo-Express  → http://localhost:8081

# 6. See logs if something is wrong
docker logs docker-testapp-testapp-1
docker logs docker-testapp-mongo-1 --tail 20

# 7. Stop & remove everything
docker compose -f mongodb.yaml down

# 8. Stop & remove everything INCLUDING volumes
docker compose -f mongodb.yaml down -v
```

### 🔁 After changing code → rebuild

```bash
docker build -t testapp:1.0 .
docker compose -f mongodb.yaml up -d --force-recreate testapp
```

### ☁️ Push to Docker Hub

```bash
docker build -t shafayat53/testapp .
docker logout
docker login
docker push shafayat53/testapp
```

---

# 🛠️ Mistakes I Made & Fixes

| ❌ Problem | 🔎 Cause | ✅ Fix |
|-----------|---------|--------|
| `docker build -t testapp:1.0` → *requires 1 argument* | forgot the `.` at the end | `docker build -t testapp:1.0 .` |
| `docker built ...` → *not a docker command* | typo (`built`) | `docker build` |
| MySQL container **Exited (1)** right after start | wrote `MYSQL-ROOT-PASSWORD` (dash) | use `MYSQL_ROOT_PASSWORD` (underscore); check with `docker logs <name>` |
| `docker exec` → *container is not running* | container already exited | fix the error first (`docker logs`), recreate, then `exec` |
| `docker exec -it mysql-latest/bin/bash` → *requires at least 2 arguments* | missing space | `docker exec -it mysql-latest /bin/bash` |
| `docker stop` / `rm -f` → **permission denied** | Snap docker daemon problem | `sudo snap restart docker`, then `docker rm ...` |
| `docker rm` → *container is running* | trying to remove a running container | `docker stop` first (or `docker rm -f`) |
| Mongo exited: *No space left on device* | disk full from many images/volumes | `docker rmi ...`, `docker volume prune`, free disk space |
| `-v /media/.../Shafayet Hossain3/...` → *must be lowercase* | **space** in the path | wrap the whole `-v` value in `"double quotes"` |
| App port `5050` already in use | another process using the port | `sudo fuser -k 5050/tcp`, then `docker compose ... up -d` |
| `docker stop <id>` printed only the ID | that's normal | it means success ✅ |

---

# ⚡ Quick Cheat Sheet

### Images
```bash
docker pull <image>[:tag]          # download image
docker images                      # list images
docker rmi <image|id>              # remove image
docker build -t name:tag .         # build image from Dockerfile
docker push user/repo              # push to Docker Hub
docker login / docker logout
```

### Containers
```bash
docker run -d -p H:C --name N -e K=V <image>   # run in background
docker run -it <image> /bin/bash                # interactive
docker ps / docker ps -a                        # list containers
docker start|stop|rm <name|id>                  # manage
docker logs <name>                              # debug
docker exec -it <name> /bin/bash                # enter running container
```

### Network
```bash
docker network ls
docker network create <name>
docker network rm <name>
```

### Volumes
```bash
docker volume ls
docker volume create <name>
docker volume rm <name>
docker volume prune                 # remove unused anonymous volumes
docker run -v name:/path ...        # named
docker run -v /path ...             # anonymous
docker run -v /host:/path ...       # bind mount
```

### Compose
```bash
docker compose -f file.yaml up -d
docker compose -f file.yaml down
docker compose -f file.yaml down -v
```

### Fixes
```bash
sudo snap restart docker            # permission denied while stopping
```

---

## 🙌 Done!

Docker course ✅ — *Learn → Note → Practice → Revise.*
