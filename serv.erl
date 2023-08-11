-module(serv).
-export([start/0, gen_calc/1, calc/1]).
-record(state, {value = 0, mem = 0, gt = 0}).

start() ->
    io:fwrite("server start\n"),
    loop([]).

loop(Procs) ->
    % print_list(Procs),
    [Cmd | Args] = string:tokens(io:get_line(""), " \n"),
    case Cmd of
        "exit" -> 
            % 全てkill
            "Leaving server.";

        "create"  ->
            case length(Args) of
                1 ->
                    gen_calc(lists:nth(1, Args)),
                    loop(lists:sort(lists:append(Procs, [lists:nth(1, Args)])));
                _ -> 
                    io:fwrite("please input new server name\n"
                              "usage: create <servername>\n"),
                    loop(Procs)            
            end;
        % len(arg == 1)もほしい
        "+" ->
            Pid = whereis(list_to_atom(lists:nth(1, Args))),
            Pid ! {"+", list_to_integer(lists:nth(2, Args))},
            loop(Procs);
        "-" ->
            Pid = whereis(list_to_atom(lists:nth(1, Args))),
            Pid ! {"-", list_to_integer(lists:nth(2, Args))},
            loop(Procs);
        "*" ->
            Pid = whereis(list_to_atom(lists:nth(1, Args))),
            Pid ! {"*", list_to_integer(lists:nth(2, Args))},
            loop(Procs);
        "/" ->
            Pid = whereis(list_to_atom(lists:nth(1, Args))),
            Pid ! {"/", list_to_integer(lists:nth(2, Args))},
            loop(Procs);
        "%" ->
            Pid = whereis(list_to_atom(lists:nth(1, Args))),
            Pid ! {"%", list_to_integer(lists:nth(2, Args))},
            loop(Procs);
        "M+" ->
            Pid = whereis(list_to_atom(lists:nth(1, Args))),
            Pid ! {"M+"},
            loop(Procs);
        "M-" ->
            Pid = whereis(list_to_atom(lists:nth(1, Args))),
            Pid ! {"M-"},
            loop(Procs);
        "RM" ->
            Pid = whereis(list_to_atom(lists:nth(1, Args))),
            Pid ! {"RM"},
            loop(Procs);
        _ ->
            io:fwrite(Args ++ "under"),
            loop([])
    end.

gen_calc(Process_name) ->
    % 被ってたら
    Pid = spawn(serv, calc, [#state{value=0}]),
    try register(list_to_atom(Process_name), Pid)  of
        _ -> ok
    catch
        error:badarg -> io:fwrite("name is in use\n")
    end.


calc(State) ->
    receive
        {"+", Num} ->
            Update = State#state.value + Num,
            io:fwrite(integer_to_list(Update) ++ "\n"),
            calc(State#state{value = Update});
        {"-", Num} ->
            Update = State#state.value - Num,
            io:fwrite(integer_to_list(Update) ++ "\n"),
            calc(State#state{value = Update});
        {"*", Num} ->
            Update = State#state.value * Num,
            io:fwrite(integer_to_list(Update) ++ "\n"),
            calc(State#state{value = Update});
        {"/", Num} ->
            Update = State#state.value / Num,
            io:fwrite(integer_to_list(Update) ++ "\n"),
            calc(State#state{value = Update});
        {"%", Num} ->
            Update = State#state.value * Num / 100,
            io:fwrite(integer_to_list(Update) ++ "\n"),
            calc(State#state{value = Update});
        {"M+"} ->
            calc(State#state{mem = State#state.mem + State#state.value});
        {"M-"} ->
            calc(State#state{mem = State#state.mem - State#state.value});
        {"RM"} ->
            io:fwrite(integer_to_list(State#state.mem) ++ "\n"),
            calc(State);
        _ ->
            io:format("No match.~n")
    end.
