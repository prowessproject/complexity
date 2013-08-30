% Sorting examples.
-module(example_sorting).
-compile(export_all).
-import(measure, [measure/6]).
-import(timing, [time1/1]).
-include_lib("eqc/include/eqc.hrl").

%% A variety of sorting algorithms.
insertion_sort([]) ->
    [];
insertion_sort([X|Xs]) ->
    ordsets:add_element(X, insertion_sort(Xs)).

naive_qsort([]) ->
    [];
naive_qsort([X|Xs]) ->
    naive_qsort([Y || Y <- Xs, Y < X]) ++
    [X] ++
    naive_qsort([Y || Y <- Xs, Y >= X]).

median_of_three_qsort([]) ->
    [];
median_of_three_qsort([X]) ->
    [X];
median_of_three_qsort([X,Y]) when X > Y ->
    [Y,X];
median_of_three_qsort([X,Y]) ->
    [X,Y];
median_of_three_qsort(Xs) ->
    Pivot = pivot(Xs),
    median_of_three_qsort([X || X <- Xs, X < Pivot]) ++
    [ X || X <- Xs, X == Pivot ] ++
    median_of_three_qsort([X || X <- Xs, X > Pivot]).

pivot(Xs) ->
    Len = length(Xs),
    [_, Pivot, _] =
      lists:sort([lists:nth(1, Xs),
                  lists:nth((1+Len) div 2, Xs),
                  lists:nth(Len, Xs)]),
    Pivot.

merge_sort([]) ->
    [];
merge_sort(Xs=[_]) ->
    Xs;
merge_sort(Xs=[X,Y]) when X =< Y ->
    Xs;
merge_sort([X,Y]) ->
    [Y,X];
merge_sort(Xs) ->
    {Ys, Zs} = split(Xs, [], []),
    merge(merge_sort(Ys), merge_sort(Zs)).

split([], Ys, Zs) ->
    {Ys, Zs};
split([X|Xs], Ys, Zs) ->
    split(Xs, [X|Zs], Ys).

merge(Xs, []) ->
    Xs;
merge([], Ys) ->
    Ys;
merge([X|Xs], Ys=[Y|_]) when X =< Y ->
    [X|merge(Xs, Ys)];
merge(Xs, [Y|Ys]) ->
    [Y|merge(Xs, Ys)].

%% An incremental list generator.
list_gen(Xs) ->
    ?LET(X, resize(100, int()),
    ?LET(Y, elements(non_empty(X,Xs)),
      return(insert_anywhere(X, Xs) ++
             insert_anywhere(Y, Xs)))).

non_empty(X, []) ->
    [X];
non_empty(_X, Xs) ->
    Xs.

splits(Xs) ->
    [ lists:split(N, Xs)
    || N <- lists:seq(0, length(Xs)) ].

insert_anywhere(X, Xs) ->
    [ Ys ++ [X] ++ Zs || {Ys, Zs} <- splits(Xs) ].

measure_sorting_algorithm(Sort) ->
    measure(20, 50, fun length/1, [], fun list_gen/1, time1(Sort)).

measure_sort() ->
    measure_sorting_algorithm(fun lists:sort/1).

measure_insertion_sort() ->
    measure_sorting_algorithm(fun insertion_sort/1).

measure_naive_qsort() ->
    measure_sorting_algorithm(fun naive_qsort/1).

measure_median_of_three_qsort() ->
    measure_sorting_algorithm(fun median_of_three_qsort/1).

measure_msort() ->
    measure_sorting_algorithm(fun merge_sort/1).
