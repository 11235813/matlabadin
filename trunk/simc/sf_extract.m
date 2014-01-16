function [ results ] = sf_extract( txtfile )
%SF_TXTEXTRACT extracts relevant information from a txt simc output file
%arguments: txtfile - file address)
%outputs: results   - a structure containing all of the relevant extracted
%                     info as fields


infile=fopen(txtfile);

%initialize all possible fields, this also prevents weird field mismatch
%errors due to having dissimilar result structures
results.success=false;
results.dps=-1;results.dps_error=-1;results.dps_pct_error=-1;
results.hps=-1;results.hps_error=-1;results.hps_pct_error=-1;
results.dtps=-1;results.dtps_error=-1;results.dtps_pct_error=-1;
results.tmi=-1;results.tmi_error=-1;results.tmi_pct_error=-1;
results.ef_uptime=0;
results.ss_uptime=0;
results.sotr_uptime=0;
results.waiting=0;

if infile>2
    
    dps_expr='DPS:\s+(?<dps>\d*\.\d*)\s+DPS-Error=(?<dps_error>\d*\.\d*)/(?<dps_pct_error>\d*\.\d*)\%';
    hps_expr='HPS:\s+(?<hps>\d*\.\d*)\s+HPS-Error=(?<hps_error>\d*\.\d*)/(?<hps_pct_error>\d*\.\d*)\%';
    dtps_expr='DTPS:\s+(?<dtps>\d*\.\d*)\s+DTPS-error=(?<dtps_error>\d*\.\d*)/(?<dtps_pct_error>\d*\.\d*)\%';
    tmi_expr='TMI:\s+(?<tmi>\d*.\d*)\s+TMI-error=(?<tmi_error>\d*\.\d*)/(?<tmi_pct_error>\d*\.\d*)\%\s+TMI-min=(?<tmi_min>\d*\.\d*)\s+TMI-max=(?<tmi_max>\d*\.\d*)';
    sotr_expr='shield_of_the_righteous.*uptime=\s*(?<sotr_uptime>\d*\.\d*)\%';
    ef_expr='eternal_flame.*uptime=\s*(?<ef_uptime>\d*\.\d*)\%';
    ss_expr='sacred_shield.*uptime=\s*(?<ss_uptime>\d*\.\d*)\%';
    wait_expr='Waiting:\s*(?<waiting>\d*\.\d*)\%';
    
    current_line=fgetl(infile);
   
    while ischar(current_line)
        %check for DPS
        if results.dps<0
            clear names
            names=regexp(current_line,dps_expr,'names');
            if ~isempty(names)
                results.dps=str2double(names.dps);
                results.dps_error=str2double(names.dps_error);
                results.dps_pct_error=str2double(names.dps_pct_error);
            end            
        end
        %check for HPS
        if results.hps<0
            clear names
            names=regexp(current_line,hps_expr,'names');
            if ~isempty(names)
                results.hps=str2double(names.hps);
                results.hps_error=str2double(names.hps_error);
                results.hps_pct_error=str2double(names.hps_pct_error);
            end
        end
        %check for DTPS
        if results.dtps<0
            clear names
            names=regexp(current_line,dtps_expr,'names');
            if ~isempty(names)
                results.dtps=str2double(names.dtps);
                results.dtps_error=str2double(names.dtps_error);
                results.dtps_pct_error=str2double(names.dtps_pct_error);
            end
        end
        %check for TMI
        if results.tmi<0
            clear names
            names=regexp(current_line,tmi_expr,'names');
            if ~isempty(names)
                results.tmi=str2double(names.tmi);
                results.tmi_error=str2double(names.tmi_error);
                results.tmi_pct_error=str2double(names.tmi_pct_error);
            end
        end
        %check for SotR uptime
        if results.sotr_uptime==0
            clear names
            names=regexp(current_line,sotr_expr,'names');
            if ~isempty(names)
                results.sotr_uptime=str2double(names.sotr_uptime)./100;
            end
        end
        %check for EF/SS uptime
        if results.ef_uptime==0 && results.ss_uptime==0
            clear names
            names=regexp(current_line,ef_expr,'names');
            if ~isempty(names)
                results.ef_uptime=str2double(names.ef_uptime)./100;
                results.ss_uptime=0;
            end
            clear names
            names=regexp(current_line,ss_expr,'names');
            if ~isempty(names)
                results.ef_uptime=0;
                results.ss_uptime=str2double(names.ss_uptime)./100;
            end
        end
        %check for time spent waiting
        if results.waiting==0
            clear names
            names=regexp(current_line,wait_expr,'names');
            if ~isempty(names)
                results.waiting=str2double(names.waiting)./100;
            end
        end
        %get next line
        current_line=fgetl(infile);
    end
    
    results.success=1;
    
end


   

end

