function [ results ] = sf_extract( txtfile )
%SF_TXTEXTRACT extracts relevant information from a txt simc output file
%arguments: txtfile - file address)
%outputs: results   - a structure containing all of the relevant extracted
%                     info as fields


infile=fopen(txtfile);

results.success=false;

if infile>3
    
    dps_expr='DPS:\s+(?<dps>\d*\.\d*)\s+DPS-Error=(?<dps_error>\d*\.\d*)/(?<dps_pct_error>\d*\.\d*)\%';
    hps_expr='HPS:\s+(?<hps>\d*\.\d*)\s+HPS-Error=(?<hps_error>\d*\.\d*)/(?<hps_pct_error>\d*\.\d*)\%';
    dtps_expr='DTPS:\s+(?<dtps>\d*\.\d*)\s+DTPS-error=(?<dtps_error>\d*\.\d*)/(?<dtps_pct_error>\d*\.\d*)\%';
    tmi_expr='TMI:\s+(?<tmi>\d*.\d*)\s+TMI-error=(?<tmi_error>\d*\.\d*\)/(?<tmi_pct_error>\d*\.\d*)\%  TMI-max=(?<tmi_max>\d*\.\d*)';
    sotr_expr='shield_of_the_righteous.*uptime=\s*(?<sotr_uptime>\d*)\%';
    ef_expr='eternal_flame.*uptime=\s*(?<ef_uptime>\d*)\%';
    ss_expr='sacred_shield.*uptime=\s*(?<ss_uptime>\d*)\%';
    
    current_line=fgetl(infile);
   
    while ischar(current_line)
        %check for DPS
        if ~isfield(results,'dps')
            clear names
            names=regexp(current_line,dps_expr,'names');
            if ~isempty(names)
                results.dps=str2double(names.dps);
                results.dps_error=str2double(names.dps_error);
                results.dps_pct_error=str2double(names.dps_pct_error);
            end            
        end
        %check for HPS
        if ~isfield(results,'hps')
            clear names
            names=regexp(current_line,hps_expr,'names');
            if ~isempty(names)
                results.hps=str2double(names.hps);
                results.hps_error=str2double(names.hps_error);
                results.hps_pct_error=str2double(names.hps_pct_error);
            end
        end
        %check for DTPS
        if ~isfield(results,'dtps')
            clear names
            names=regexp(current_line,dtps_expr,'names');
            if ~isempty(names)
                results.dtps=str2double(names.dtps);
                results.dtps_error=str2double(names.dtps_error);
                results.dtps_pct_error=str2double(names.dtps_pct_error);
            end
        end
        %check for TMI
        if ~isfield(results,'tmi')
            clear names
            names=regexp(current_line,tmi_expr,'names');
            if ~isempty(names)
                results.tmi=str2double(names.tmi);
                results.tmi_error=str2double(names.tmi_error);
                results.tmi_pct_error=str2double(names.tmi_pct_error);
            end
        end
        %check for SotR uptime
        if ~isfield(results,'sotr_uptime')
            clear names
            names=regexp(current_line,sotr_expr,'names');
            if ~isempty(names)
                results.sotr_uptime=str2double(names.sotr_uptime)./100;
            end
        end
        %check for EF/SS uptime
        if ~isfield(results,'ef_uptime') && ~isfield(results,'ss_uptime')
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
        %get next line
        current_line=fgetl(infile);
    end
    
    results.success=1;
    
end


   

end

