function [sw, w] = mcm_sapflow_params(site, year)

%% Main Function
switch site
    case 'TP39'
        switch year
            case '2010'
        %%% (Manual) sapwood area of tree at 1.3m above ground (m^2): As,1) = 0.0815*DBH^2.2254
        sw = NaN.*ones(25,1);
        sw(1,1) = 0.024279102;  sw(2,1) = 0.011680066;  sw(3,1) = 0.025178724;  sw(4,1) = 0.043490419;
        sw(5,1) = 0.032418783;  sw(6,1) = 0.03591098;   sw(7,1) = 0.025942199;  sw(8,1) = 0.020183307;
        sw(9,1) = 0.016862082;  sw(10,1) = 0.029948972; sw(11,1) = 0.017599402; sw(12,1) = 0.026251109;
        sw(13,1) = 0.059368954; sw(14,1) = 0.038348817; sw(15,1) = 0.02405701;  sw(16,1) = 0.036465737;
        sw(17,1) = 0.040480665; sw(18,1) = 0.022963379; sw(19,1) = 0.027825924; sw(20,1) = 0.025330415;
        sw(21,1) = NaN;         sw(22,1) = 0.013541385; sw(23,1) = 0.030619543;
        %%% (Manual) Total wood area of tree at 1.3m above ground (m^2)
        w = NaN.*ones(25,1);
        
        w(1,1) = 0.104062027;   w(2,1) = 0.053912826; w(3,1) = 0.107520918;   w(4,1) = 0.175716197;
        w(5,1) = 0.135004458;   w(6,1) = 0.147934332; w(7,1) = 0.110446523;   w(8,1) = 0.088141234;
        w(9,1) = 0.074990539;   w(10,1) = 0.1256636;  w(11,1) = 0.077931067;  w(12,1) = 0.110446523;
        w(13,1) = 0.232427395;  w(14,1) = 0.156929489;w(15,1) = 0.103263089;  w(16,1) = 0.149986575;
        w(17,1) = 0.159608983;  w(18,1) = 0.09897972; w(19,1) = 0.117628198;  w(20,1) = 0.108102897;
        w(21,1) = NaN;          w(22,1) = 0.061575164;w(23,1) = 0.128189438;
            case '2011'
                
        end

    case 'TP74'
        
        
        
        
end