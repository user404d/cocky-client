# Racket MegaMiner Joueur Client

ヽ༼ຈل͜ຈ༽ﾉ ヽ༼ຈل͜ຈ༽ﾉ ヽ༼ຈل͜ຈ༽ﾉ ヽ༼ຈل͜ຈ༽ﾉ

xD

ヽ༼ຈل͜ຈ༽ﾉ ヽ༼ຈل͜ຈ༽ﾉ ヽ༼ຈل͜ຈ༽ﾉ ヽ༼ຈل͜ຈ༽ﾉ

```shell
$ make -j
$ ./run -s r99acm.device.mst.edu -p {correct port number} Saloon
```

Saloon is the only game supported atm. It will be necessary to supply the appropriate port number.
The game server should supply an appropriate session id. (Feel free to change the ai behavior if you're
brave enough).

```shell
$ docker build -t "siggame/joueur.rkt-onbuild:latest" --file onbuild.Dockerfile .
$ docker build -t "siggame/joueur.rkt:latest" --file joueur.Dockerfile .
$ docker run --rm siggame/joueur.rkt racket main.rkt -s {game server ip}:{correct port} {game name}
```
