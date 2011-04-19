function calc_fsm
% plot some stuff:
[xxhit,yyexp]=meshgrid(0:80:960,0:4:56);
mesh(xxhit, yyexp, matrixfun2(@(x,y)CS_Pr(x,y), xxhit, yyexp))
end
function [z] = CS_Pr(hit, expertise)
	% base miss = 8%, spmiss not required for fsm
	% soft cap is 6.5% dodge or 26 expertise, and the hard cap is 14% parry or 56 expertise
	mehit = 1 - 0.08*(1-min(1,hit/960)) - 0.065*(1-min(1, expertise/26)) - 0.14*(1-min(1, expertise/56));
	rhit = 1 - 0.08*(1-min(1,hit/960));
	actionPr = memoized_fsm('SotR>AS''>CS>J>AS', mehit, rhit, 1, 2, 2, 2); %input order is eg,sd,gc
	z = actionPr{2, 5} + actionPr{2, 6};
end
function matrixResult = matrixfun2(f, matrix1, matrix2)
	for i = 1:length(matrix1) % for each row
		for j = 1:length(matrix1(i, :))
			matrixResult(i, j) = f(matrix1(i, j), matrix2(i, j));
		end
	end
end
