function calc_fsm
% plot some stuff:
1;
% soft cap is 6.5% dodge or 26 expertise, and the hard cap is 14% parry or 56 expertise
function [z] = CS_Pr(hit, expertise)
	mehit = 1 - 0.05*(1-min(1,hit/960)) - 0.065*(1-min(1, expertise/26)) - 0.14*(1-min(1, expertise/56));
	rhit = 1 - 0.05*(1-min(1,hit/960));
	actionPr = memoized_fsm('SotR>CS>J>AS', mehit, rhit, 0, 0.3, 0.5, 0.2); %input order is eg,sd,gc
	z = actionPr{2, 2};
end
function matrixResult = matrixfun2(f, matrix1, matrix2)
	for i = 1:length(matrix1) % for each row
		for j = 1:length(matrix1(i, :))
			matrixResult(i, j) = f(matrix1(i, j), matrix2(i, j));
		end
	end
end
[xxhit,yyexp]=meshgrid(0:80:960,0:4:56);
mesh(xxhit, yyexp, matrixfun2(@(x,y)CS_Pr(x,y), xxhit, yyexp))
end