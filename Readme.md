Criar a imagem localmente
run ./create_server-and-run.sh

Subir servidor a partir da imagem
sudo docker run -d -it -p 25565:25565 --name minedocker minedocker

Obter shell no container:
	docker exec -i -t minedocker /bin/bash
    
Admin Console of server:
    docker attach minecraft
ctrl-p, ctrl-q to exit, or "stop" to shutdown minecraft server and docker container

Parar servidor:
    docker stop minecraft

Iniciar servidor:
    docker start minecraft


