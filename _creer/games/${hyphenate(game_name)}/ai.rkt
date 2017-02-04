;; This is where you build your AI for the ${game_name} game.
#lang racket
<%include file="functions.noCreer" />
(require "../../joueur/base-ai.rkt"
         "../../joueur/utilities.rkt"
${merge(";; ", "requires", ";; any additional requires you want can be required here safely between creer runs", optional=True)}
)

(provide ai%)

#|
 ; @class
 ; @classdesc This is the class to play the ${game_name} game. This is where you should build your AI.
|#

(define ai%
 (class base-ai%
  (super-new)

    #|
     ; The reference to the Game instance this AI is playing.
     ;
     ; @member {Game} game
     ; @memberof AI
     ; @instance
     |#

  (inherit-field game settings)

  (field

    #|
     ; The reference to the Player this AI controls in the Game.
     ;
     ; @member {Player} player
     ; @memberof AI
     ; @instance
     |#

   [player null])

  (define/public (set-player player-id)
   (set-field! player this (send game get-game-object player-id))
  )

    #|
     ; This is the name you send to the server so your AI will control the player named this string.
     ;
     ; @memberof AI
     ; @instance
     ; @returns {string} - The name of your Player.
     |#

  (define/override (get-name)
${merge("        ;; ", "getName", '        "' + game_name + ' Racket Player"')}
  )

    #|
     ; This is called once the game starts and your AI knows its playerID and game. You can initialize your AI here.
     ;
     ; @memberof AI
     ; @instance
     |#

  (define/override (start)
${merge("        ;; ", "start", "        #f")}
  )

    #|
     ; This is called every time the game's state updates, so if you are tracking anything you can update it here.
     ;
     ; @memberof AI
     ; @instance
     |#

   (define/override (game-updated)
${merge("        ;; ", "gameUpdated", "        #f")}
   )


    #|
     ; This is called when the game ends, you can clean up your data and dump files here if need be.
     ;
     ; @memberof AI
     ; @instance
     ; @param {boolean} won - True means you won, false means you lost.
     ; @param {string} reason - The human readable string explaining why you won or lost.
     |#

   (define/override (ended won reason)
${merge("        ;; ", "ended", "        #f")}
   )

% for function_name in ai['function_names']:
<%
    function_parms = ai['functions'][function_name]
    argument_string = ""
    argument_names = []
    if 'arguments' in function_parms:
        for arg_parms in function_parms['arguments']:
            argument_names.append(arg_parms['name'])
        argument_string = " ".join(argument_names)
%>
    #|
     ; ${function_parms['description']}
     ;
     ; @memberof AI
     ; @instance
% if 'arguments' in function_parms:
% for arg_parms in function_parms['arguments']:
     ; @param {${shared['rkt']['type'](arg_parms['type'])}} ${arg_parms['name']} - ${arg_parms['description']}
% endfor
% endif
% if function_parms['returns']:
     ; @returns {${shared['rkt']['type'](function_parms['returns']['type'])}} - ${function_parms['returns']['description']}
% endif
     |#

     (define/public (${hyphenate(function_name)} ${argument_string if argument_string != '' else "[args #f]"})
${merge("        ;; ", function_name,
"""        ;; Put your game logic here for {0}
        {1}
""".format(function_name, shared['rkt']['default'](function_parms['returns']['type'], function_parms['returns']['default']) if function_parms['returns'] else "#f")
)}
   )
% endfor

${merge("    ;;", "functions", "    ;; any additional functions you want to add for your AI", optional=True)}
))
