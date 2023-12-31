-module(serv).
-export([start/0, gen_calc/1, calc/1]).
-record(state, {value = 0, mem = 0, gt = 0}).

start() ->
    io:fwrite("server start\n"),
    loop([]).

loop(Procs) ->
    [Cmd | Args] = string:tokens(io:get_line(""), " \n"),
    case Cmd of
        "exit" -> 
            % 全てkill
            kill_proclist(Procs),
            "Leaving server.";
        "show" ->
            print_list(Procs),
            loop(Procs);
        "create"  ->
            case length(Args) of
                1 ->
                    try gen_calc(lists:nth(1, Args)) of
                        _ -> loop(lists:sort(lists:append(Procs, [lists:nth(1, Args)])))
                    catch
                        Throw ->
                            loop(Procs)
                    end;
                _ -> 
                    io:fwrite("please input new server name\n"
                              "usage: create <servername>\n"),
                    loop(Procs)            
            end;
        "stop"  ->
            case length(Args) of
                0 ->
                    io:fwrite("please input server name you wish to stop\n"
                              "usage: stop <servername>...\n"),
                    loop(Procs);
                _ ->
                    kill_proclist(Args),
                    loop(delete_elements(Args, Procs))        
            end;
        % len(arg == 1)もほしい
        _ ->
            case Pid = whereis(list_to_atom(lists:nth(1, Args))) of
                undefined -> 
                    io:fwrite("such proc not exist\n"),
                    loop(Procs);
                _ ->
                    case Cmd of
                    "+" ->
                        Pid ! {"+", list_to_integer(lists:nth(2, Args))},
                        loop(Procs);
                    "-" ->
                        Pid ! {"-", list_to_integer(lists:nth(2, Args))},
                        loop(Procs);
                    "*" ->
                        Pid ! {"*", list_to_integer(lists:nth(2, Args))},
                        loop(Procs);
                    "/" ->
                        Pid ! {"/", list_to_integer(lists:nth(2, Args))},
                        loop(Procs);
                    "%" ->
                        Pid ! {"%", list_to_integer(lists:nth(2, Args))},
                        loop(Procs);
                    "M+" ->
                        Pid ! {"M+"},
                        loop(Procs);
                    "M-" ->
                        Pid ! {"M-"},
                        loop(Procs);
                    "RM" ->
                        Pid ! {"RM"},
                        loop(Procs);
                    "CM" ->
                        Pid ! {"CM"},
                        loop(Procs);
                    _ ->
                        io:fwrite(Args ++ "under"),
                        loop(Procs)
            end
        end
    end.

gen_calc(Process_name) ->
    % 被ってたら
    Pid = spawn(serv, calc, [#state{value=0}]),
    try register(list_to_atom(Process_name), Pid)  of
        _ -> ok
    catch
        error:badarg -> 
            io:fwrite("name is in use\n"),
            throw(fail)
    end.

calc(State) ->
    receive
        {"+", Num} ->
            Update = State#state.value + Num,
            io:fwrite(number_to_list(Update) ++ "\n"),
            calc(State#state{value = Update});
        {"-", Num} ->
            Update = State#state.value - Num,
            io:fwrite(number_to_list(Update) ++ "\n"),
            calc(State#state{value = Update});
        {"*", Num} ->
            Update = State#state.value * Num,
            io:fwrite(number_to_list(Update) ++ "\n"),
            calc(State#state{value = Update});
        {"/", Num} ->
            try Update = State#state.value / Num of
                _ -> 
                    io:fwrite(number_to_list(Update) ++ "\n"),
                    calc(State#state{value = Update})
            catch
                error:badarith -> io:fwrite("division by zero\n"),
                calc(State)
            end;
        {"%", Num} ->
            Update = State#state.value * Num / 100,
            io:fwrite(number_to_list(Update) ++ "\n"),
            calc(State#state{value = Update});
        {"M+"} ->
            calc(State#state{mem = State#state.mem + State#state.value});
        {"M-"} ->
            calc(State#state{mem = State#state.mem - State#state.value});
        {"RM"} ->
            io:fwrite(number_to_list(State#state.mem) ++ "\n"),
            calc(State);
        {"CM"} ->
            calc(State#state{mem = 0});
        {kill} ->
            exit(success);
        _ ->
            io:format("No match.~n")
    end.

print_list([]) ->
    io:fwrite("no data in list\n");
print_list([Head]) ->
    io:fwrite(Head ++ "\n");
print_list([Head | Tail]) ->
    io:fwrite(Head ++ " "),
    print_list(Tail).

number_to_list(Num) when is_integer(Num) ->
    integer_to_list(Num);
number_to_list(Num) when is_float(Num) ->
    float_to_list(Num).

kill_proclist([]) ->
    ok;
kill_proclist([Head | Tail]) ->
    Pid = whereis(list_to_atom(Head)),
    Pid ! {kill},
    kill_proclist(Tail).

delete_elements([], List) ->
    List;
delete_elements(Elements, List) ->
    NewList = lists:delete(hd(Elements), List),
    delete_elements(tl(Elements), NewList).
