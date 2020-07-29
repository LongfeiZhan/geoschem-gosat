clear
clc
% tip: ��������Ũ�ȣ�ģʽ�ֲ�Ũ��
load('coastlines.mat');  % ���غ���������
plot(coastlon,coastlat)
% hold on
% usa:lon[-125,-60],lat[27,48]  CN:lon[60,128],lat[18,45]
% aus:lon[113,153],lat[-38,-12]  eu:lon[-10,46],lat[37,71]
info_model = ncinfo('mod\GEOSChem.SpeciesConc.20140101_0000z.nc4');

%% ------------------------------------1-6�·�-----------------------------------
files_sat = dir('sat\*.nc');
files_model = dir('mod\*.nc4');
% ģʽ����
usa_temp = [];
cn_temp = [];
aus_temp = [];
eu_temp = [];
for ii = 1 : 6
    ch4_model = ncread(['mod\',files_model(ii).name],'SpeciesConc_CH4'); %  {'mol mol-1 dry'}
    lon_model = ncread(['mod\',files_model(ii).name],'lon');
    lat_model = ncread(['mod\',files_model(ii).name],'lat');
    lev_model = ncread(['mod\',files_model(ii).name],'lev'); % ģʽ������ѹ��
    time_model = ncread(['mod\',files_model(ii).name],'time');
    
    [mlon,mlat] = meshgrid(lon_model,lat_model);
    mlat = flipud(mlat);
    r = 1;
    for i = 1 : 91
        for j = 1 : 144
            xy(r,1) = mlon(i,j);
            xy(r,2) = mlat(i,j);
            xy(r,3:length(time_model)+2) = ch4_model(j,i,1,1:length(time_model)); % surface����Ũ��ֵ
            r = r + 1;
        end
    end
    [in_sat,on_sat] = inpolygon(xy(:,1),xy(:,2),coastlon,coastlat);  %�ж�ģʽ���ݾ�γ���Ƿ���½����
    land_data = xy(in_sat,:); % ��ȡ��½������������
    % ��������ȡ����
    usa = land_data(land_data(:,1)>-125 & land_data(:,1)<-60 & land_data(:,2)>27 & land_data(:,2)<48,:);
    cn = land_data(land_data(:,1)>60 & land_data(:,1)<128 & land_data(:,2)>18 & land_data(:,2)<45,:);
    aus = land_data(land_data(:,1)>113 & land_data(:,1)<153 & land_data(:,2)>-38 & land_data(:,2)<-12,:);
    eu = land_data(land_data(:,1)>-10 & land_data(:,1)<46 & land_data(:,2)>37 & land_data(:,2)<71,:);
    % ����ƽ�����ϲ�
    usa_ave = mean(usa(:,3:length(time_model)+2),'all');
    usa_temp = [usa_temp;usa_ave];
    cn_ave = mean(cn(:,3:length(time_model)+2),'all');
    cn_temp = [cn_temp;cn_ave];
    aus_ave = mean(aus(:,3:length(time_model)+2),'all');
    aus_temp = [aus_temp;aus_ave];
    eu_ave = mean(eu(:,3:length(time_model)+2),'all');
    eu_temp = [eu_temp;eu_ave];
    
end

%% ��ͼ
figure(1)
plot(1:6,usa_temp,'b')
hold on
plot(1:6,cn_temp,'r')
plot(1:6,aus_temp,'k')
plot(1:6,eu_temp,'g')
xlim([0.5,6.5])
ylim([1775,1850])
legend('USA','CN','AUS','EU','Location','best')
xlabel('�·�')
ylabel('mol mol-1 dry')

