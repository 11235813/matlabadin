function [data] = calc_fsm
% plot some stuff:
mhit=(1-0.065-0.14-0.08):0.005:1.0;
rhit=(1-0.08):0.005:1.0;
mhit=[0.835, 1];
rhit=[0.94, 1];
rotation='WoG>SotR>CS>AS>J>Cons>HW'
mhitArray=repmat(mhit, 1, length(rhit));
rhitArray=repmat(rhit, length(mhit), 1);
rhitArray=rhitArray(:);
% generate data
fsm_gen(rotation, mhitArray, rhitArray, 1, 0, 2, 2, 0);

% populate data array
% TODO use ability_model.m and action2cps.m code instead of duplicating
fsmlabel={'Inq';'Inq(Inq)';'SotR2';'SotR2(SD)';'SotR2(Inq)';'SotR2(SD)(Inq)';'SotR';'SotR(SD)';'SotR(Inq)';'SotR(SD)(Inq)';'WoG';'WoG(Inq)';...
    'CS';'CS(Inq)';'HotR';'HammerNova';'HotR(Inq)';'HammerNova(Inq)';...
    'AS';'AS(Inq)';'Cons';'Cons(Inq)';'HoW';'HoW(Inq)';'HW';'HW(Inq)';'J';'J(Inq)';...
    'seal';'seal(Inq)';...
    'Nothing';'Nothing(Inq)'};
data = horzcat(mhitArray', rhitArray);
% resize array to include output
data(1, length(fsmlabel) + 2)=0;
for i = 1:size(data)[1]
    actionPr = memoized_fsm(rotation, data(i, 1), data(i, 2), 1, 2, 2, 2, 0);
    cps=zeros(size(fsmlabel,1),1);
    %sort actionPr entries into cps
    for m=1:size(actionPr,2)
        idx= strcmp(actionPr{1,m},fsmlabel);
        cps(idx)=actionPr{2,m};    
    end
    data(i, :)=data(i, :) + [0, 0, cps'];
end

%{
[xxmhit,yyrhit]=meshgrid(mhitArray,rhitArray);
mesh(xxmhit, yyrhit, matrixfun2(@(x,y)CS_Pr(x,y), xxmhit, yyrhit))
end
function [z] = CS_Pr(mehit, rhit)
	% base miss = 8%, spmiss not required for fsm
	% soft cap is 6.5% dodge or 26 expertise, and the hard cap is 14% parry or 56 expertise
	%mehit = 1 - 0.08*(1-min(1,hit/960)) - 0.065*(1-min(1, expertise/26)) - 0.14*(1-min(1, expertise/56));
	%rhit = 1 - 0.08*(1-min(1,hit/960));
	actionPr = memoized_fsm(rotation, mehit, rhit, 1, 2, 2, 2, 0); %input order is cons,eg,sd,gc,retT13
	z = actionPr{2, 5} + actionPr{2, 6};
end
function matrixResult = matrixfun2(f, matrix1, matrix2)
	for i = 1:length(matrix1) % for each row
		for j = 1:length(matrix1(i, :))
			matrixResult(i, j) = f(matrix1(i, j), matrix2(i, j));
		end
	end
end
%}
