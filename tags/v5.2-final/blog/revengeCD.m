function [cd nmean]=revengeCD(A,S,G)

if nargin<1
    %inputs
    G=1.5;
    S=2;
    A=0;
    warning('No inputs, defaulting to 0/2/1.5')
elseif nargin<2
    S=2;
    G=1.5;
    warning('No swing timer provided, defaulting to 2s')
elseif nargin<3
    G=1.5; %no need for warning, this will generally be default
end

%since we want to let A or S be an array, we'll do it element by element. 
%necessary since I used matrices to calculate P - could skip that, but it
%was very useful for debugging.  

%check sizes of S and A - if not identical, make them
if isscalar(A) && ~isscalar(S)
    A=A.*ones(size(S));
elseif ~isscalar(A) && isscalar(S)
    S=S.*ones(size(A));
elseif size(A,1)~=size(S,1) || size(A,2)~=size(S,2)
    error('A and S have different dimensions')
end
    

%pre-allocate arrays for speed (so fast it's probably not neccessary, but
%good habit)
nmean=zeros(size(A));
cd=zeros(size(A));

for i=1:length(A(:))
    a=A(i);
    s=S(i);
    %probability to not avoid = 1-avoidance
    %most of the math is easier in terms of q rather than a
    q=1-a;
    
    %num GCDs, as an array
    n=(1:6)';
    
    %values that depend on G/S/n
    m=floor(G/s);
    N=1+floor(n.*G./s);
    
    %x-values
    x0=(N-m-1).*s-(n-1).*G;
    
    %Generate "V" and "Q".  V is the overlap integral for each situation
    %Q is the probability of triggering a reset for each situation, split into
    %Q1 (probabilty of at least 1 avoid in the current GCD) and
    %Q2 (probability of 0 avoid in the previous GCDs)
    V=[x0 (G-m.*s-x0) ((m+1).*s-G).*ones(size(x0))]./s;
    Q1=repmat([(1-q.^(m+1)) (1-q.^(m+1)) (1-q.^m)],length(n),1);
    Q2=[q.^max(0,N-m-2) q.^(N-m-1) q.^(N-m-1)];
    Q=Q1.*Q2;
    
    %Probability matrix P(n), still split into its four constituent components
    %for debugging.  P(n) is really sum(P,2)
    P=V.*Q;
    
    %weighted average n*P(n)
    nP=n.*sum(P,2);
    
    %fallback terms - these handle if we avoid nothing in N or N-1 attacks
    P6N=(n.*G-(N-1).*s)./s.*q.^N;
    P6Nm1=(N.*s-n.*G)./s.*q.^(N-1);
    
    %mean number of GCDs for Revenge cooldown
    nmean(i)=sum(nP)+6.*P6N(length(n))+6.*P6Nm1(length(n));
    
    %mean Revenge cooldown in terms of seconds
    cd(i)=G.*nmean(i);
    
end %close for loop

end %end function
