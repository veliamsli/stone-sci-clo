-module(stone_sci_clo_game).
-author('lweiyan@gmail.com').

-export([play/1, play/2]).

play(PlayerAttack) ->
	ComputerAttack = get_computer_attack(),
	case get_result(PlayerAttack, ComputerAttack) of
		{win, _} ->
			[":I chose ", atom_to_list(ComputerAttack), ".you win!"];
		{draw, _} ->	
			[":I chose ", atom_to_list(ComputerAttack), ". it is peace"];
		{lose, _} ->
			[":I chose ", atom_to_list(ComputerAttack), ".I win!"]
	end.

play(Player1, Player2) ->
	get_result(Player1, Player2).
	
get_computer_attack() ->
	Index = random:uniform(3),
	lists:nth(Index, ["stone", "sci", "cloth"]).


get_result(Player1, Player2) ->
    case {Player1, Player2} of
        {"stone", "sci"} -> {win, lose};
        {"stone", "cloth"} -> {lose, win};
        {"sci", "stone"} -> {lose, win};
        {"sci", "cloth"} -> {win, lose};
        {"cloth", "stone"} -> {win, lose};
        {"cloth", "sci"} -> {lose, win};
        {Same, Same} -> {draw, draw};
        {_,_} -> {lose, win}
    end.