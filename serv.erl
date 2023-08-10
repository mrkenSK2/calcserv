-module(serv).
-export([start/0, gen_calc/1]).
-record(state, {value}).

start() ->
    io:fwrite("server start\n"),
    loop().

loop() ->
    [Cmd | Args] = string:tokens(io:get_line(""), " \n"),
    io:fwrite(integer_to_list(length(Args)) ++ "\n"),
    case Cmd of
    % spawn(serv, calc, [1]),
        "exit" -> "Leaving server.";

        "create"  ->
            case length(Args) of
                1 -> gen_calc(lists:nth(1, Args));
                _ -> io:fwrite("please input new server name\n")
            end,
            loop();
        "add" ->
            io:fwrite("add cmd");
        _ ->
            io:fwrite(Args),
            loop()
    end.

gen_calc(Process_name) ->
    % 被ってたら
    Pid = spawn(fun() -> 1 end),
    register(list_to_atom(Process_name), Pid).

calc(#state(a, b)) ->
    receive
        {Exit, v}
    af
    0.
