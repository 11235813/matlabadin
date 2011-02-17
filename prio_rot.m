%PRIO_ROT is a wrapper that runs prio_sim for particular rotations.  It's
%the temporary replacement for rotation_model

% queues=[3 11 17];
queues=[3 17];

if exist('queue','var')==0
    queue=queues;
end

N=30000;
dt=1.5;
if exist('c','var')~=1;c=1;end
wb=waitbar(0,['Calculating CFG # ' int2str(c)]);
for k=1:length(queue);
    %% run sim
%     tic
    waitbar(k/length(queue),wb)
    rdata=prio_sim(queue(k),'N',N,'dt',dt);
    cmat=rdata.coeff';

    %% active dps sources
    acdps=0;actps=0;achps=0;
    acdps=cmat*val.pdmg;
    actps=cmat*val.pthr;
    achps=cmat*val.pheal;
    aoedps=cmat*val.admg;

    %% incorporate non-GCD damage sources
    padps=0;patps=0;pahps=0;

    %account for Inq
    Inqmod=sum(rdata.Inq>0)./length(rdata.Inq);

    %assume a 5-stack of SoT (if applicable).
    if strcmpi('Truth',exec.seal)||strcmpi('SoT',exec.seal)
        padps=padps+dps.Censure.*(1+0.3.*Inqmod);
        patps=patps+tps.Censure.*(1+0.3.*Inqmod);
    end

    %aa and seal damage
    padps=padps+dps.Melee+dmg.activeseal.*mdf.mehit.*(1+0.3.*Inqmod)./player.wswing;
    %aa and seal threat and healing
    if strcmpi('Insight',exec.seal)||strcmpi('SoI',exec.seal)
        patps=patps+tps.Melee+threat.activeseal.*mdf.mehit./player.wswing;
        pahps=pahps+heal.activeseal.*mdf.mehit./player.wswing;
    else
        patps=patps+tps.Melee+threat.activeseal.*mdf.mehit.*(1+0.3.*Inqmod)./player.wswing;
    end

    %store outputs
    rot(k).acdps=acdps;
    rot(k).actps=actps;
    rot(k).achps=achps;
    rot(k).padps=padps;
    rot(k).patps=patps;
    rot(k).pahps=pahps;
    rot(k).totdps=acdps+padps;
    rot(k).tottps=actps+patps;
    rot(k).tothps=achps+pahps;
    rot(k).aoedps=aoedps;
end
close(wb)
% toc