FROM jackfirth/racket:6.6

WORKDIR /src
CMD ["racket", "main.rkt"]

ONBUILD ADD ./info.rkt ./info.rkt
ONBUILD RUN raco pkg install --auto --no-setup
ONBUILD RUN raco setup --no-docs
ONBUILD ADD ./games ./games
ONBUILD ADD ./joueur ./joueur
ONBUILD ADD ./main.rkt ./main.rkt
ONBUILD RUN raco setup --no-docs