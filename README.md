﻿# aggregate-container

To build the container, first install docker for windows and switch to windows containers:
https://blog.docker.com/2016/09/build-your-first-docker-windows-server-container/

To build the image, run the following command:
```sh
docker build -t <username>/<imagename> <path-to-dockerfile>
```

For example:
```sh
docker build -t jbeorse/aggregate C:\Users\jbeorse\workspace\aggregate-container\
```
Then run the image with the following command:
```sh
docker run -d -p 80:<port> <username>/<imagename>
```

For example: 
```sh
docker run -d -p 80:80 jbeorse/aggregate
```

