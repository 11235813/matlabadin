%ROTATION_MODEL calculates the DPS/HPS output of a given rotation from the
%ability weight coefficients (either analytical or genrated with
%rotation_coeff_gen) and the ability damage values calculated in
%ability_model

%load rotation database
rotation_db
rmtmp.f=fittype('poly5');

%identify relevant parameters: GrCr, SD, EG
rmtmp.gc=1+talent.GrandCrusader;
rmtmp.sd=1+talent.SacredDuty;
rmtmp.eg=1+talent.EternalGlory;

%check for inconsistency between talent.* and mdf.*
if mdf.GrCr~=talent.GrandCrusader./10 || mdf.SacDut~=0.25.*talent.SacredDuty || mdf.EG~=0.15.*talent.EternalGlory
    warning('GC, SD, or EG inconsistently defined in talent.* and mdf.*')
end


%initialize structure
%TODO: remove deprecated fields
rot=struct('tag','', ...
           'coeffpvals',[],...
           'cpspvals',[],...
           'inqpvals',[],...
           'inqup',[],...
           'inqmod',[],...
           'acdps',[], ...
           'achps',[], ...
           'actps',[], ...
           'padps',[], ...
           'pahps',[], ...
           'patps',[], ...
           'totdps',[], ...
           'tothps',[], ...
           'tottps',[]);

%% SC9 ("939" or "9C9") framework : SotR>CS>J>AS>Cons>HW (execute range : SotR>CS>J>HoW)
rot(1).tag='SC9';

%this extracts coefficient data from rotdb for every rotation
%TODO: somehow implement sub-20% weighting? May necessitate removing outer
%for loop.
for i=1:length(rotdb);
    %load pvals for the appropiate gc/sd/eg config
    rot(i).coeffpvals(:,:)=rotdb(i).coeffpvals(:,:,rmtmp.gc,rmtmp.sd,rmtmp.eg);
    rot(i).cpspvals(:,:)=rotdb(i).cpspvals(:,:,rmtmp.gc,rmtmp.sd,rmtmp.eg);
    rot(i).inqpvals(:,:)=rotdb(i).inqpvals(:,:,rmtmp.gc,rmtmp.sd,rmtmp.eg);
    
    %generate coefficients
    %for whatever reason, cfit() calls are very, very slow compared to
    %brute-forcing a polynomial.  [RM] runs about 15x faster with the
    %brute-force method, so for now we'll use that.  I'd rather use cfit()
    %in case we want more flexibility in fit types in the future, but for
    %now there seems to be no need to do so.
    
    %% fittype version
    %[RM] profiled time of 15s (1.6 self) via [CW]
    %6s each for loop (i.e. each cfit and cf{}() call)
    
%     %convert these into cfit objects
%     for ii=1:size(rot(i).coeffpvals,1)
%         rot(i).cf{ii}=cfit(rmtmp.f, ...
%             rot(i).coeffpvals(ii,1), ...
%             rot(i).coeffpvals(ii,2), ...
%             rot(i).coeffpvals(ii,3), ...
%             rot(i).coeffpvals(ii,4), ...
%             rot(i).coeffpvals(ii,5), ...
%             rot(i).coeffpvals(ii,6));
%     end
% 
%     %generate coefficients
%     for ii=1:size(rot(i).coeffpvals,1)
%         rot(i).coeff(ii,:)=rot(i).cf{ii}(mdf.mehit)';
%     end

    %% brute force version 
    %[RM] profiled time of 1s (0.456s self) via [CW]
    
    for ii=1:size(rot(i).coeffpvals,1)
        rot(i).coeff(ii,:)=val.ones.*...
                          (rot(i).coeffpvals(ii,1).*mdf.mehit.^5 + ...
                           rot(i).coeffpvals(ii,2).*mdf.mehit.^4 + ...
                           rot(i).coeffpvals(ii,3).*mdf.mehit.^3 + ...
                           rot(i).coeffpvals(ii,4).*mdf.mehit.^2 + ...
                           rot(i).coeffpvals(ii,5).*mdf.mehit.^1 + ...
                           rot(i).coeffpvals(ii,6));
             
        rot(i).cps(ii,:)=  val.ones.*...
                          (rot(i).cpspvals(ii,1).*mdf.mehit.^5 + ...
                           rot(i).cpspvals(ii,2).*mdf.mehit.^4 + ...
                           rot(i).cpspvals(ii,3).*mdf.mehit.^3 + ...
                           rot(i).cpspvals(ii,4).*mdf.mehit.^2 + ...
                           rot(i).cpspvals(ii,5).*mdf.mehit.^1 + ...
                           rot(i).cpspvals(ii,6));
    end
             
    rot(i).inqup(1,:)= val.ones.* ...
        (rot(i).inqpvals(1,1).*mdf.mehit.^5 + ...
        rot(i).inqpvals(1,2).*mdf.mehit.^4 + ...
        rot(i).inqpvals(1,3).*mdf.mehit.^3 + ...
        rot(i).inqpvals(1,4).*mdf.mehit.^2 + ...
        rot(i).inqpvals(1,5).*mdf.mehit.^1 + ...
        rot(i).inqpvals(1,6));
    
    rot(i).inqmod=(1+0.3.*rot(i).inqup);

end


%% output
for i=1:length(rot)
    %calculate damage from 'active' (i.e. simmed) sources
        rot(i).acdps=[sum(rot(i).coeff.*val.pdmg)];
        rot(i).achps=[sum(rot(i).coeff.*val.pheal)];
        rot(i).actps=[sum(rot(i).coeff.*val.pthr)];
        
    %calculate damage from 'passive' (i.e. not simmed) sources
    rot(i).padps=val.zeros;
    rot(i).pahps=val.zeros;
    rot(i).patps=val.zeros;
    
    %If SoT, include Censure Damage
    if strcmpi('Truth',exec.seal)||strcmpi('SoT',exec.seal)
        rot(i).padps=rot(i).padps+dps.Censure.*rot(i).inqmod;
        rot(i).patps=rot(i).patps+tps.Censure.*rot(i).inqmod;
    end
    
    %Include seal procs from auto-attacks
    rot(i).padps=rot(i).padps+dps.Melee+dmg.activeseal.*mdf.mehit./player.wswing.*rot(i).inqmod;
    rot(i).pahps=rot(i).pahps+hps.Melee+heal.activeseal.*mdf.mehit./player.wswing;
    
    %threat depends on whether it's damage or healing due to Inq
    if strcmpi('Insight',exec.seal)||strcmpi('SoI',exec.seal)
        rot(i).patps=rot(i).patps+tps.Melee+threat.activeseal.*mdf.mehit./player.wswing;
    else
        rot(i).patps=rot(i).patps+tps.Melee+threat.activeseal.*mdf.mehit./player.wswing.*rot(i).inqmod;
    end
    
    %Add active and passive sources for total
    rot(i).totdps=rot(i).acdps+rot(i).padps;
    rot(i).tothps=rot(i).achps+rot(i).pahps;
    rot(i).tottps=rot(i).actps+rot(i).patps;
end


clear p q tmprot mmmm P i idx