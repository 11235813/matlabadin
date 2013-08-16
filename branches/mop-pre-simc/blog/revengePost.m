a=linspace(0,1,10000);
rcda=revengeCD(a);

figure(1);
plot(a.*100,rcda)
set(gca,'XGrid','on','YGrid','on')
xlabel('Avoidance (%)')
ylabel('Revenge CD (s)')
title('Revenge Cooldown vs. Avoidance')

s=linspace(1.5,2.5,10000);
rcds=revengeCD(0.2,s);

figure(2)
plot(s,rcds,'.','MarkerSize',4)
set(gca,'XGrid','on','YGrid','on')
xlabel('Swing Timer (s)')
ylabel('Revenge CD (s)')
title('Revenge Cooldown vs. Swing Timer')

s=linspace(0,2.5,10000);
rcds=revengeCD(0.2,s);

figure(3)
plot(s,rcds,'.','MarkerSize',4)
set(gca,'XGrid','on','YGrid','on')
xlabel('Swing Timer (s)')
ylabel('Revenge CD (s)')
title('Revenge Cooldown vs. Swing Timer')

%% Table
[S A]=meshgrid(0.5:0.25:2.5,0:0.01:0.3);
rcdt=revengeCD(A,S);

li=DataTable();
li{1,1}=' ';
temp=cellstr([num2str(S(1,:)','%1.2f') repmat('s',size(S,2),1)]);
li{1,2:(1+size(S,2))}=temp';
temp=cellstr([num2str(A(:,1).*100,'%2.0f') repmat('%',size(A,1),1)]);
li{2:(1+size(A,1)),1}=temp;
li{2:(1+size(rcdt,1)),2:(1+size(rcdt,2))}=rcdt;
li.setColumnFormat(1+(1:size(rcdt,2)),'%1.3f')
li.toText()