function Q=shift(P,s)
%Q=shift(P,s)
%
% Shifts elements of a matrix P such that P(0,0) moves to
% P(s(1),s(2)). Truncation and padding with zeros occurs
% to make Q the same size as P.
%
% P	= input matrix
% s	= [rowshift columnshift]
% Q	= shifted matrix

[r c]=size(P);
Q=zeros(size(P));

ridx1=max(1,1-s(1));
ridx2=min(r,r-s(1));
cidx1=max(1,1-s(2));
cidx2=min(c,c-s(2));

Q(max(1,1+s(1)):min(r,r+s(1)),max(1,1+s(2)):min(c,c+s(2)))=P(ridx1:ridx2,cidx1:cidx2);
