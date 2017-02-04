<%include file="functions.noCreer" />;; ${obj_key}: ${shared['rkt']['format_description'](obj['description'])}
#lang racket

;; DO NOT MODIFY THIS FILE
;; Never try to directly create an instance of this class, or modify its member variables.
;; Instead, you should only be reading its variables and calling its functions.
<% parent_classes = list(obj['parentClasses'])
parent_classes.append('base-game' if obj_key == 'Game' else 'base-game-object')
if obj_key == "Game":
  for game_obj_key in sort_dict_keys(game_objs):
    parent_classes.append(game_obj_key)
%>
(require "../../joueur/client.rkt"
% for parent_class in parent_classes:
  "${('../../joueur/' if parent_class in ['base-game', 'base-game-object'] else '') + hyphenate(parent_class) + ".rkt"}"
% endfor
)


(provide ${hyphenate(obj_key)}%)


${merge(";; ", "require", ";; you can add additional import(s) here", optional=True)}

(define ${hyphenate(obj_key)}%
    (class ${hyphenate(parent_classes[0])}%
      (super-new)
      ;; The class representing the ${obj_key} in the ${game_name} game.
      ;; ${shared['rkt']['format_description'](obj['description'])}
      (field
% for attr_name in obj['attribute_names']:
<% if attr_name in ["id", "gameObjects"]: continue
 attr_parms = obj['attributes'][attr_name] %>
        ;; ${shared['rkt']['type'](attr_parms['type'])} - ${shared['rkt']['format_description'](attr_parms['description'])}
        [${hyphenate(attr_name)} ${shared['rkt']['default'](attr_parms['type'], attr_parms['default'])}]
% endfor
      )

% for function_name in obj['function_names']:
<% function_parms = obj['functions'][function_name]
%>    (define/public (${hyphenate(function_name)} ${shared['rkt']['args'](function_parms['arguments'])})
    ;; ${shared['rkt']['format_description'](function_parms['description'])}
%   if len(function_parms['arguments']) > 0:

    ;; Args:
%   for arg_parms in function_parms['arguments']:
    ;; ${hyphenate(arg_parms['name'])} (${"Optional[" if arg_parms['optional'] else ""}${shared['rkt']['type'](arg_parms['type'])}${"]" if arg_parms['optional'] else ""}): ${shared['rkt']['format_description'](arg_parms['description'])}
% endfor
% endif
%     if function_parms['returns']:
    ;; Returns:
    ;; ${shared['rkt']['type'](function_parms['returns']['type'])}: ${shared['rkt']['format_description'](function_parms['returns']['description'])}
%     endif
      (send client run-on-server this "${function_name}" (make-hash `(
%     for arg_parms in function_parms['arguments']:
        (${arg_parms['name']} . ,${arg_parms['name']})
%     endfor
      ))))

% endfor
% if obj_key == "Game":
    (set-field! game-object-classes this (make-hash `(
%     for game_obj in game_objs:
        ("${game_obj}" . ,${hyphenate(game_obj)}%)
%     endfor
    )))
% endif
))
