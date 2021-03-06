function [data_out] = jjb_round(data_in, dec_place, round_type)
%%% jjb_round.m
%%% usage: [data_out] = jjb_round(data_in, dec_place, round_type)
%%% Where data_in is the original value, 
%%% dec_place specifies the number of decimal places you want it rounded to
%%% (0 means whole number)
%%% round_type can be 'round', 'floor', 'ceil'
%%% 
%%% Created Aug 27, 2010 by JJB

data_out = [];
if nargin == 2
    round_type = 'round';
end

eval(['data_in = data_in.*1e' num2str(dec_place) ';']);
eval(['data_out = ' round_type '(data_in);' ])
eval(['data_out = data_out./1e' num2str(dec_place) ';']);

