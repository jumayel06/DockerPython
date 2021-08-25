* docker build -t myimage1:latest .
* docker run -dit --name mycontainer1 -v /Users/test-docker:/data -p 5000:5000 myimage1:latest
* docker exec -it mycontainer1 bash
* docker rm -f mycontainer1
* docker logs mycontainer1