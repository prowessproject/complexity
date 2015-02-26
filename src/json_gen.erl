-module(json_gen).

-include_lib("eqc/include/eqc.hrl").
-include("measure.hrl").

-compile(export_all).



%% Generates a name that doesn't exists in the
%% provided list of names.
name(Names) ->
  ?SUCHTHAT(Name,
            ?LET(Name, non_empty(list(elements(lists:seq($a, $z)))), binary:list_to_bin(Name)),
            not(lists:member(Name, Names))).


%% Generates a field value.
value() ->
  int().  


%% Returns an empty structure.
empty() ->
  [].


%% Returns a list of all paths to the elements
%% (both arrays and fields) in the structure.
paths(Lst) when is_list(Lst) ->
  [[]] ++ lists:concat([ paths([], X) || X <- Lst ]).

paths(Path, {Name, {value, _}}) ->
  [Path ++ [Name]];
paths(Path, {Name, Lst}) when is_list(Lst) ->
  Path2 = Path ++ [Name],
  [Path2] ++ lists:concat([ paths(Path2, X) || X <- Lst ]).


%% Extends the array or fields with the provided path.
extend([], {value, X}) ->
  [{name([]), {value, X}}];
extend([], Lst) when is_list(Lst) ->
  Names = [ Name || {Name, _} <- Lst ],
  X = {name(Names), {value, value()}}, 
  Lst ++ [X];
extend([ Name | Path], Lst) when is_list(Lst) ->
  [ if Name == XName -> {Name, extend(Path, X)};
       true -> {XName, X}
    end || {XName, X} <- Lst ]. 


%% Grows the structure by extending of of its elements.
grow(X) ->
  vector(10,
    ?LET(Path, elements(paths(X)), extend(Path, X))).
 