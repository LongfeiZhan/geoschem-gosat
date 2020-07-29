clear
clc
% tip: ��������Ũ�ȣ�ģʽ�ֲ�Ũ��
load('coastlines.mat');  % ���غ���������
plot(coastlon,coastlat)
% hold on
% usa:lon[-125,-60],lat[27,48]  CN:lon[60,128],lat[18,45]
% aus:lon[113,153],lat[-38,-12]  eu:lon[-10,46],lat[37,71]
info_model = ncinfo('mod\GEOSChem.SpeciesConc.20140101_0000z.nc4');
info_sat = ncinfo('sat\20140101-C3S-L2_GHG-GHG_PRODUCTS-TANSO-GOSAT-OCFP-DAILY-v7.2.nc');

%% ------------------------------------1�·ݱȽ�-----------------------------------
files_sat = dir('sat\*.nc');
files_model = dir('mod\*.nc4');
% ģʽ����
ch4_model = ncread(['mod\',files_model(1).name],'SpeciesConc_CH4'); %  {'mol mol-1 dry'}
lon_model = ncread(['mod\',files_model(1).name],'lon');
lat_model = ncread(['mod\',files_model(1).name],'lat');
lev_model = ncread(['mod\',files_model(1).name],'lev'); % ģʽ������ѹ��
time_model = ncread(['mod\',files_model(1).name],'time');
sat_land1 = [];
for i = 1 : 31   % 1��31���ļ�
    disp(['���ڴ���1��',files_sat(i).name(7:8),'������'])
    lon_sat = ncread(['sat\',files_sat(i).name],'longitude');
    lat_sat = ncread(['sat\',files_sat(i).name],'latitude');
    lev_sat = ncread(['sat\',files_sat(i).name],'pressure_levels'); % sat��ѹ��
    pw_sat = ncread(['sat\',files_sat(i).name],'pressure_weight');
    ch4_pa_sat = ncread(['sat\',files_sat(i).name],'ch4_profile_apriori');
    xch4_ak_sat = ncread(['sat\',files_sat(i).name],'xch4_averaging_kernel');
    xch4_sat = ncread(['sat\',files_sat(i).name],'xch4');  % ��λ��ppb
%     scatter(lon_sat,lat_sat,'ro')
    
    % �Ӹ߶Ȳ�ֵ���ģʽ����ѡȡ�����ǹ۲�λ�õ�����
    [m_lon,m_lat] = meshgrid(lon_model,lat_model);
    for n = 1 : length(lon_sat)
        for yy = 1 : size(m_lon,2)
            if lon_sat(n,1) < lon_model(yy,1)
                position_mark(n,1) = yy;  % ��¼�������ڸ��λ��
                break
            else
                position_mark(n,1) = 144;
            end
        end
    end
    for n = 1 : length(lon_sat)
        for xx = 1 : size(m_lon,1)
            if lat_sat(n,1) < lat_model(xx,1)
                position_mark(n,2) = xx;  % ��¼γ�����ڸ��λ��
                break
            end
        end
    end
    % ת������Ũ��
    for lon_x = 1 : length(lon_model)
        for lat_y = 1 : length(lat_model)
            ch4_interp_model(lon_x,lat_y,:,i) = ...
                interp1(lev_model*1000,squeeze(ch4_model(lon_x,lat_y,:,i)),lev_sat(:,1),'method'); % ��ģʽ�������ݲ�ֵ��ͬ����ͬ��
        end
    end
    for j = 1 : length(xch4_sat) % ÿ��۲�λ����
        for k = 1 : 20
            ch4_slip_model(k,j) = ...
                (ch4_pa_sat(k,j) + (ch4_interp_model(position_mark(j,1),position_mark(j,2),k,i)*10^9 - ch4_pa_sat(k,j)) * xch4_ak_sat(k,j)) * pw_sat(k,j); % תΪ��Ũ��
        end
    end
%     eval(['ch4_column_model',files_sat(i).name(5:8),'= sum(ch4_slip_model,1);']); % ÿ����۲���ģʽ������Ũ��
    ch4_column_model = sum(ch4_slip_model,1);
    ch4_column_model_T = ch4_column_model'; %ת��
    
    % ����--ģʽ���ݱȽ�
%     RMSe1(i,1) = sqrt(sum((ch4_column_model - xch4_sat').^2)/length(xch4_sat));  %RMSE�����������ݵĲ���
    
    % ����½�������Ǻ�ģʽ�۲�ֵ
    [in_sat,on_sat] = inpolygon(lon_sat,lat_sat,coastlon,coastlat);  %�ж��������ݾ�γ���Ƿ���½����
    sat_land_temp = [lon_sat(in_sat),lat_sat(in_sat),xch4_sat(in_sat),ch4_column_model_T(in_sat)];  % ѡ��½���ϵĵ�
    sat_land1 = [sat_land1;sat_land_temp]; % ���յ���    
    clear position_mark ch4_slip_model;
end
% scatter(sat_land1(:,1),sat_land1(:,2),'b+')
sat_land1 = sortrows(sat_land1,2);

usa1 = sat_land1(sat_land1(:,1)>-125 & sat_land1(:,1)<-60 & sat_land1(:,2)>27 & sat_land1(:,2)<48,:);
cn1 = sat_land1(sat_land1(:,1)>60 & sat_land1(:,1)<128 & sat_land1(:,2)>18 & sat_land1(:,2)<45,:);
aus1 = sat_land1(sat_land1(:,1)>113 & sat_land1(:,1)<153 & sat_land1(:,2)>-38 & sat_land1(:,2)<-12,:);
eu1 = sat_land1(sat_land1(:,1)>-10 & sat_land1(:,1)<46 & sat_land1(:,2)>37 & sat_land1(:,2)<71,:);

%% ------------2�±Ƚ�------------
files_sat = dir('sat2\*.nc');
files_model = dir('mod\*.nc4');
% mod
ch4_model = ncread(['mod\',files_model(2).name],'SpeciesConc_CH4'); %  {'mol mol-1 dry'}
lon_model = ncread(['mod\',files_model(2).name],'lon');
lat_model = ncread(['mod\',files_model(2).name],'lat');
lev_model = ncread(['mod\',files_model(2).name],'lev'); % ģʽ������ѹ��
time_model = ncread(['mod\',files_model(2).name],'time');

sat_land2 = [];
for i = 1 : 26   % 1��31���ļ�
    disp(['���ڴ���2��',files_sat(i).name(7:8),'������'])
    lon_sat = ncread(['sat2\',files_sat(i).name],'longitude');
    lat_sat = ncread(['sat2\',files_sat(i).name],'latitude');
    lev_sat = ncread(['sat2\',files_sat(i).name],'pressure_levels'); % ����������ѹ��
    pw_sat = ncread(['sat2\',files_sat(i).name],'pressure_weight');
    ch4_pa_sat = ncread(['sat2\',files_sat(i).name],'ch4_profile_apriori');
    xch4_ak_sat = ncread(['sat2\',files_sat(i).name],'xch4_averaging_kernel');
    xch4_sat = ncread(['sat2\',files_sat(i).name],'xch4');  % ��λ��ppb
    %     scatter(lon_sat,lat_sat)
    [m_lon,m_lat] = meshgrid(lon_model,lat_model);
    % �Ӹ߶Ȳ�ֵ���ģʽ����ѡȡ�����ǹ۲�λ�õ�����
    for n = 1 : length(lon_sat)
        for yy = 1 : size(m_lon,2)
            if lon_sat(n,1) < lon_model(yy,1)
                position_mark(n,1) = yy;  % ��¼�������ڸ��λ��
                break
            else
                position_mark(n,1) = 144;
            end
        end
    end
    for n = 1 : length(lon_sat)
        for xx = 1 : size(m_lon,1)
            if lat_sat(n,1) < lat_model(xx,1)
                position_mark(n,2) = xx;  % ��¼γ�����ڸ��λ��
                break
            end
        end
    end
    % ת������Ũ��
    for lon_x = 1 : length(lon_model)
        for lat_y = 1 : length(lat_model)
            ch4_interp_model(lon_x,lat_y,:,i) = ...
                interp1(lev_model*1000,squeeze(ch4_model(lon_x,lat_y,:,i)),lev_sat(:,1),'method'); % ��ģʽ�������ݲ�ֵ��ͬ����ͬ��
        end
    end
    for j = 1 : length(xch4_sat) % ÿ��۲�λ����
        for k = 1 : 20
            ch4_slip_model(k,j) = ...
                (ch4_pa_sat(k,j) + (ch4_interp_model(position_mark(j,1),position_mark(j,2),k,i)*10^9 - ch4_pa_sat(k,j)) * xch4_ak_sat(k,j)) * pw_sat(k,j); % תΪ��Ũ��
        end
    end
%     eval(['ch4_column_model',files_sat(i).name(5:8),'= sum(ch4_slip_model,1);']); % ÿ����۲���mod��Ũ��
    ch4_column_model = sum(ch4_slip_model,1);
    % ����--mod�Ƚ�
%     RMSe2(i,1) = sqrt(sum((ch4_column_model - xch4_sat').^2)/length(xch4_sat));  %RMSE�����������ݵĲ���
     % ����½�������Ǻ�ģʽ�۲�ֵ
    ch4_column_model_T = ch4_column_model'; %ת��
    [in_sat,on_sat] = inpolygon(lon_sat,lat_sat,coastlon,coastlat);  %�ж��������ݾ�γ���Ƿ���½����
    sat_land_temp = [lon_sat(in_sat),lat_sat(in_sat),xch4_sat(in_sat),ch4_column_model_T(in_sat)];  % ѡ��½���ϵĵ�
    sat_land2 = [sat_land2;sat_land_temp]; % ���յ���   
    clear position_mark ch4_slip_model;
end
sat_land2 = sortrows(sat_land2,2);

usa2 = sat_land2(sat_land2(:,1)>-125 & sat_land2(:,1)<-60 & sat_land2(:,2)>27 & sat_land2(:,2)<48,:);
cn2 = sat_land2(sat_land2(:,1)>60 & sat_land2(:,1)<128 & sat_land2(:,2)>18 & sat_land2(:,2)<45,:);
aus2 = sat_land2(sat_land2(:,1)>113 & sat_land2(:,1)<153 & sat_land2(:,2)>-38 & sat_land2(:,2)<-12,:);
eu2 = sat_land2(sat_land2(:,1)>-10 & sat_land2(:,1)<46 & sat_land2(:,2)>37 & sat_land2(:,2)<71,:);

%% ----------------------------------------3�·ݱȽ�----------------------------------
files_sat = dir('sat3\*.nc');
files_model = dir('mod\*.nc4');
% ģʽ����
ch4_model = ncread(['mod\',files_model(3).name],'SpeciesConc_CH4'); %  {'mol mol-1 dry'}
lon_model = ncread(['mod\',files_model(3).name],'lon');
lat_model = ncread(['mod\',files_model(3).name],'lat');
lev_model = ncread(['mod\',files_model(3).name],'lev'); % ģʽ������ѹ��
time_model = ncread(['mod\',files_model(3).name],'time');
sat_land3 = [];
for i = 1 : 31   % 1��31���ļ�
    disp(['���ڴ���3��',files_sat(i).name(7:8),'������'])
    lon_sat = ncread(['sat3\',files_sat(i).name],'longitude');
    lat_sat = ncread(['sat3\',files_sat(i).name],'latitude');
    lev_sat = ncread(['sat3\',files_sat(i).name],'pressure_levels'); % ����������ѹ��
    pw_sat = ncread(['sat3\',files_sat(i).name],'pressure_weight');
    ch4_pa_sat = ncread(['sat3\',files_sat(i).name],'ch4_profile_apriori');
    xch4_ak_sat = ncread(['sat3\',files_sat(i).name],'xch4_averaging_kernel');
    xch4_sat = ncread(['sat3\',files_sat(i).name],'xch4');  % ��λ��ppb
    %     scatter(lon_sat,lat_sat)
    [m_lon,m_lat] = meshgrid(lon_model,lat_model);
    % �Ӹ߶Ȳ�ֵ���ģʽ����ѡȡ�����ǹ۲�λ�õ�����
    for n = 1 : length(lon_sat)
        for yy = 1 : size(m_lon,2)
            if lon_sat(n,1) < lon_model(yy,1)
                position_mark(n,1) = yy;  % ��¼�������ڸ��λ��
                break
            else
                position_mark(n,1) = 144;
            end
        end
    end
    for n = 1 : length(lon_sat)
        for xx = 1 : size(m_lon,1)
            if lat_sat(n,1) < lat_model(xx,1)
                position_mark(n,2) = xx;  % ��¼γ�����ڸ��λ��
                break
            end
        end
    end
    % ת������Ũ��
    for lon_x = 1 : length(lon_model)
        for lat_y = 1 : length(lat_model)
            ch4_interp_model(lon_x,lat_y,:,i) = ...
                interp1(lev_model*1000,squeeze(ch4_model(lon_x,lat_y,:,i)),lev_sat(:,1),'method'); % ��ģʽ�������ݲ�ֵ��ͬ����ͬ��
        end
    end
    for j = 1 : length(xch4_sat) % ÿ��۲�λ����
        for k = 1 : 20
            ch4_slip_model(k,j) = ...
                (ch4_pa_sat(k,j) + (ch4_interp_model(position_mark(j,1),position_mark(j,2),k,i)*10^9 - ch4_pa_sat(k,j)) * xch4_ak_sat(k,j)) * pw_sat(k,j); % תΪ��Ũ��
        end
    end
%     eval(['ch4_column_model',files_sat(i).name(5:8),'= sum(ch4_slip_model,1);']); % ÿ����۲���ģʽ������Ũ��
    ch4_column_model = sum(ch4_slip_model,1);
    ch4_column_model_T = ch4_column_model'; %ת��
    % ����--ģʽ���ݱȽ�
%     RMSe3(i,1) = sqrt(sum((ch4_column_model - xch4_sat').^2)/length(xch4_sat));  %RMSE�����������ݵĲ���
     % ����½�������Ǻ�ģʽ�۲�ֵ
    [in_sat,on_sat] = inpolygon(lon_sat,lat_sat,coastlon,coastlat);  %�ж��������ݾ�γ���Ƿ���½����
    sat_land_temp = [lon_sat(in_sat),lat_sat(in_sat),xch4_sat(in_sat),ch4_column_model_T(in_sat)];  % ѡ��½���ϵĵ�
    sat_land3 = [sat_land3;sat_land_temp]; % ���յ���   
    clear position_mark ch4_slip_model;
end
sat_land3 = sortrows(sat_land3,2);

usa3 = sat_land3(sat_land3(:,1)>-125 & sat_land3(:,1)<-60 & sat_land3(:,2)>27 & sat_land3(:,2)<48,:);
cn3 = sat_land3(sat_land3(:,1)>60 & sat_land3(:,1)<128 & sat_land3(:,2)>18 & sat_land3(:,2)<45,:);
aus3 = sat_land3(sat_land3(:,1)>113 & sat_land3(:,1)<153 & sat_land3(:,2)>-38 & sat_land3(:,2)<-12,:);
eu3 = sat_land3(sat_land3(:,1)>-10 & sat_land3(:,1)<46 & sat_land3(:,2)>37 & sat_land3(:,2)<71,:);
%% ----------------------------------------4�·ݱȽ�----------------------------------
files_sat = dir('sat4\*.nc');
files_model = dir('mod\*.nc4');
% ģʽ����
ch4_model = ncread(['mod\',files_model(3).name],'SpeciesConc_CH4'); %  {'mol mol-1 dry'}
lon_model = ncread(['mod\',files_model(3).name],'lon');
lat_model = ncread(['mod\',files_model(3).name],'lat');
lev_model = ncread(['mod\',files_model(3).name],'lev'); % ģʽ������ѹ��
time_model = ncread(['mod\',files_model(3).name],'time');
sat_land4 = [];
for i = 1 : 30   % 1��31���ļ�
    disp(['���ڴ���4��',files_sat(i).name(7:8),'������'])
    lon_sat = ncread(['sat4\',files_sat(i).name],'longitude');
    lat_sat = ncread(['sat4\',files_sat(i).name],'latitude');
    lev_sat = ncread(['sat4\',files_sat(i).name],'pressure_levels'); % sat��ѹ��
    pw_sat = ncread(['sat4\',files_sat(i).name],'pressure_weight');
    ch4_pa_sat = ncread(['sat4\',files_sat(i).name],'ch4_profile_apriori');
    xch4_ak_sat = ncread(['sat4\',files_sat(i).name],'xch4_averaging_kernel');
    xch4_sat = ncread(['sat4\',files_sat(i).name],'xch4');  % ��λ��ppb
    %     scatter(lon_sat,lat_sat)
    [m_lon,m_lat] = meshgrid(lon_model,lat_model);
    % �Ӹ߶Ȳ�ֵ���ģʽ����ѡȡ�����ǹ۲�λ�õ�����
    for n = 1 : length(lon_sat)
        for yy = 1 : size(m_lon,2)
            if lon_sat(n,1) < lon_model(yy,1)
                position_mark(n,1) = yy;  % ��¼�������ڸ��λ��
                break
            else
                position_mark(n,1) = 144;
            end
        end
    end
    for n = 1 : length(lon_sat)
        for xx = 1 : size(m_lon,1)
            if lat_sat(n,1) < lat_model(xx,1)
                position_mark(n,2) = xx;  % ��¼γ�����ڸ��λ��
                break
            end
        end
    end
    % ת������Ũ��
    for lon_x = 1 : length(lon_model)
        for lat_y = 1 : length(lat_model)
            ch4_interp_model(lon_x,lat_y,:,i) = ...
                interp1(lev_model*1000,squeeze(ch4_model(lon_x,lat_y,:,i)),lev_sat(:,1),'method'); % ��ģʽ�������ݲ�ֵ��ͬ����ͬ��
        end
    end
    for j = 1 : length(xch4_sat) % ÿ��۲�λ����
        for k = 1 : 20
            ch4_slip_model(k,j) = ...
                (ch4_pa_sat(k,j) + (ch4_interp_model(position_mark(j,1),position_mark(j,2),k,i)*10^9 - ch4_pa_sat(k,j)) * xch4_ak_sat(k,j)) * pw_sat(k,j); % תΪ��Ũ��
        end
    end
%     eval(['ch4_column_model',files_sat(i).name(5:8),'= sum(ch4_slip_model,1);']); % ÿ����۲���ģʽ������Ũ��
    ch4_column_model = sum(ch4_slip_model,1);
    ch4_column_model_T = ch4_column_model'; %ת��
    % ����--ģʽ���ݱȽ�
    RMSe4(i,1) = sqrt(sum((ch4_column_model - xch4_sat').^2)/length(xch4_sat));  %RMSE�����������ݵĲ���
     % ����½�������Ǻ�ģʽ�۲�ֵ
    [in_sat,on_sat] = inpolygon(lon_sat,lat_sat,coastlon,coastlat);  %�ж��������ݾ�γ���Ƿ���½����
    sat_land_temp = [lon_sat(in_sat),lat_sat(in_sat),xch4_sat(in_sat),ch4_column_model_T(in_sat)];  % ѡ��½���ϵĵ�
    sat_land4 = [sat_land4;sat_land_temp]; % ���յ���   
    clear position_mark ch4_slip_model;
end
sat_land4 = sortrows(sat_land4,2);

usa4 = sat_land4(sat_land4(:,1)>-125 & sat_land4(:,1)<-60 & sat_land4(:,2)>27 & sat_land4(:,2)<48,:);
cn4 = sat_land4(sat_land4(:,1)>60 & sat_land4(:,1)<128 & sat_land4(:,2)>18 & sat_land4(:,2)<45,:);
aus4 = sat_land4(sat_land4(:,1)>113 & sat_land4(:,1)<153 & sat_land4(:,2)>-38 & sat_land4(:,2)<-12,:);
eu4 = sat_land4(sat_land4(:,1)>-10 & sat_land4(:,1)<46 & sat_land4(:,2)>37 & sat_land4(:,2)<71,:);
%% ----------------------------------------5�·ݱȽ�----------------------------------
files_sat = dir('sat5\*.nc');
files_model = dir('mod\*.nc4');
% ģʽ����
ch4_model = ncread(['mod\',files_model(5).name],'SpeciesConc_CH4'); %  {'mol mol-1 dry'}
lon_model = ncread(['mod\',files_model(5).name],'lon');
lat_model = ncread(['mod\',files_model(5).name],'lat');
lev_model = ncread(['mod\',files_model(5).name],'lev'); % ģʽ������ѹ��
time_model = ncread(['mod\',files_model(5).name],'time');
sat_land5 = [];
for i = 1 : 25   % 1��31���ļ�
    
    disp(['���ڴ���5��',files_sat(i).name(7:8),'������'])
    lon_sat = ncread(['sat5\',files_sat(i).name],'longitude');
    lat_sat = ncread(['sat5\',files_sat(i).name],'latitude');
    lev_sat = ncread(['sat5\',files_sat(i).name],'pressure_levels'); % sat��ѹ��
    pw_sat = ncread(['sat5\',files_sat(i).name],'pressure_weight');
    ch4_pa_sat = ncread(['sat5\',files_sat(i).name],'ch4_profile_apriori');
    xch4_ak_sat = ncread(['sat5\',files_sat(i).name],'xch4_averaging_kernel');
    xch4_sat = ncread(['sat5\',files_sat(i).name],'xch4');  % ��λ��ppb
    %     scatter(lon_sat,lat_sat)
    [m_lon,m_lat] = meshgrid(lon_model,lat_model);
    % �Ӹ߶Ȳ�ֵ���ģʽ����ѡȡ�����ǹ۲�λ�õ�����
    for n = 1 : length(lon_sat)
        for yy = 1 : size(m_lon,2)
            if lon_sat(n,1) < lon_model(yy,1)
                position_mark(n,1) = yy;  % ��¼�������ڸ��λ��
                break
            else
                position_mark(n,1) = 144;
            end
        end
    end
    for n = 1 : length(lon_sat)
        for xx = 1 : size(m_lon,1)
            if lat_sat(n,1) < lat_model(xx,1)
                position_mark(n,2) = xx;  % ��¼γ�����ڸ��λ��
                break
            end
        end
    end
    % ת������Ũ��
    for lon_x = 1 : length(lon_model)
        for lat_y = 1 : length(lat_model)
            ch4_interp_model(lon_x,lat_y,:,i) = ...
                interp1(lev_model*1000,squeeze(ch4_model(lon_x,lat_y,:,i)),lev_sat(:,1),'method'); % ��ģʽ�������ݲ�ֵ��ͬ����ͬ��
        end
    end
    for j = 1 : length(xch4_sat) % ÿ��۲�λ����
        for k = 1 : 20
            ch4_slip_model(k,j) = ...
                (ch4_pa_sat(k,j) + (ch4_interp_model(position_mark(j,1),position_mark(j,2),k,i)*10^9 - ch4_pa_sat(k,j)) * xch4_ak_sat(k,j)) * pw_sat(k,j); % תΪ��Ũ��
        end
    end
%     eval(['ch4_column_model',files_sat(i).name(5:8),'= sum(ch4_slip_model,1);']); % ÿ����۲���ģʽ������Ũ��
    ch4_column_model = sum(ch4_slip_model,1);
    ch4_column_model_T = ch4_column_model'; %ת��
    % ����--ģʽ���ݱȽ�
%     RMSe5(i,1) = sqrt(sum((ch4_column_model - xch4_sat').^2)/length(xch4_sat));  %RMSE�����������ݵĲ���
     % ����½�������Ǻ�ģʽ�۲�ֵ
    [in_sat,on_sat] = inpolygon(lon_sat,lat_sat,coastlon,coastlat);  %�ж��������ݾ�γ���Ƿ���½����
    sat_land_temp = [lon_sat(in_sat),lat_sat(in_sat),xch4_sat(in_sat),ch4_column_model_T(in_sat)];  % ѡ��½���ϵĵ�
    sat_land5 = [sat_land5;sat_land_temp]; % ���յ���   
    clear position_mark ch4_slip_model;
end
sat_land5 = sortrows(sat_land5,2);

usa5 = sat_land5(sat_land5(:,1)>-125 & sat_land5(:,1)<-60 & sat_land5(:,2)>27 & sat_land5(:,2)<48,:);
cn5 = sat_land5(sat_land5(:,1)>60 & sat_land5(:,1)<128 & sat_land5(:,2)>18 & sat_land5(:,2)<45,:);
aus5 = sat_land5(sat_land5(:,1)>113 & sat_land5(:,1)<153 & sat_land5(:,2)>-38 & sat_land5(:,2)<-12,:);
eu5 = sat_land5(sat_land5(:,1)>-10 & sat_land5(:,1)<46 & sat_land5(:,2)>37 & sat_land5(:,2)<71,:);
%% ----------------------------------------6�·ݱȽ�----------------------------------
files_sat = dir('sat6\*.nc');
files_model = dir('mod\*.nc4');
% mod
ch4_model = ncread(['mod\',files_model(6).name],'SpeciesConc_CH4'); %  {'mol mol-1 dry'}
lon_model = ncread(['mod\',files_model(6).name],'lon');
lat_model = ncread(['mod\',files_model(6).name],'lat');
lev_model = ncread(['mod\',files_model(6).name],'lev'); % ģʽ������ѹ��
time_model = ncread(['mod\',files_model(6).name],'time');
sat_land6 = [];
for i = 1 : 30   % 1��31���ļ�
    disp(['���ڴ���6��',files_sat(i).name(7:8),'������'])
    lon_sat = ncread(['sat6\',files_sat(i).name],'longitude');
    lat_sat = ncread(['sat6\',files_sat(i).name],'latitude');
    lev_sat = ncread(['sat6\',files_sat(i).name],'pressure_levels'); % sat��ѹ��
    pw_sat = ncread(['sat6\',files_sat(i).name],'pressure_weight');
    ch4_pa_sat = ncread(['sat6\',files_sat(i).name],'ch4_profile_apriori');
    xch4_ak_sat = ncread(['sat6\',files_sat(i).name],'xch4_averaging_kernel');
    xch4_sat = ncread(['sat6\',files_sat(i).name],'xch4');  % ��λ��ppb
    %     scatter(lon_sat,lat_sat)
    [m_lon,m_lat] = meshgrid(lon_model,lat_model);
    % �Ӹ߶Ȳ�ֵ���ģʽ����ѡȡ�����ǹ۲�λ�õ�����
    for n = 1 : length(lon_sat)
        for yy = 1 : size(m_lon,2)
            if lon_sat(n,1) < lon_model(yy,1)
                position_mark(n,1) = yy;  % ��¼�������ڸ��λ��
                break
            else
                position_mark(n,1) = 144;
            end
        end
    end
    for n = 1 : length(lon_sat)
        for xx = 1 : size(m_lon,1)
            if lat_sat(n,1) < lat_model(xx,1)
                position_mark(n,2) = xx;  % ��¼γ�����ڸ��λ��
                break
            end
        end
    end
    % ת������Ũ��
    for lon_x = 1 : length(lon_model)
        for lat_y = 1 : length(lat_model)
            ch4_interp_model(lon_x,lat_y,:,i) = ...
                interp1(lev_model*1000,squeeze(ch4_model(lon_x,lat_y,:,i)),lev_sat(:,1),'method'); % ��ģʽ�������ݲ�ֵ��ͬ����ͬ��
        end
    end
    for j = 1 : length(xch4_sat) % ÿ��۲�λ����
        for k = 1 : 20
            ch4_slip_model(k,j) = ...
                (ch4_pa_sat(k,j) + (ch4_interp_model(position_mark(j,1),position_mark(j,2),k,i)*10^9 - ch4_pa_sat(k,j)) * xch4_ak_sat(k,j)) * pw_sat(k,j); % תΪ��Ũ��
        end
    end
%     eval(['ch4_column_model',files_sat(i).name(5:8),'= sum(ch4_slip_model,1);']); % ÿ����۲���ģʽ������Ũ��
    ch4_column_model = sum(ch4_slip_model,1);
    ch4_column_model_T = ch4_column_model'; %ת��
    % ����--ģʽ���ݱȽ�
    RMSe6(i,1) = sqrt(sum((ch4_column_model - xch4_sat').^2)/length(xch4_sat));  %RMSE�����������ݵĲ���
     % ����½�������Ǻ�ģʽ�۲�ֵ
    [in_sat,on_sat] = inpolygon(lon_sat,lat_sat,coastlon,coastlat);  %�ж��������ݾ�γ���Ƿ���½����
    sat_land_temp = [lon_sat(in_sat),lat_sat(in_sat),xch4_sat(in_sat),ch4_column_model_T(in_sat)];  % ѡ��½���ϵĵ�
    sat_land6 = [sat_land6;sat_land_temp]; % ���յ���   
    clear position_mark ch4_slip_model;
end
sat_land6 = sortrows(sat_land6,2);

usa6 = sat_land6(sat_land6(:,1)>-125 & sat_land6(:,1)<-60 & sat_land6(:,2)>27 & sat_land6(:,2)<48,:);
cn6 = sat_land6(sat_land6(:,1)>60 & sat_land6(:,1)<128 & sat_land6(:,2)>18 & sat_land6(:,2)<45,:);
aus6 = sat_land6(sat_land6(:,1)>113 & sat_land6(:,1)<153 & sat_land6(:,2)>-38 & sat_land6(:,2)<-12,:);
eu6 = sat_land6(sat_land6(:,1)>-10 & sat_land6(:,1)<46 & sat_land6(:,2)>37 & sat_land6(:,2)<71,:);

%% ��ͼ
figure(1)
usa_ave_sat = [mean(usa1(:,3));mean(usa2(:,3));mean(usa3(:,3));mean(usa4(:,3));mean(usa5(:,3));mean(usa6(:,3))];
usa_ave_mod = [mean(usa1(:,4));mean(usa2(:,4));mean(usa3(:,4));mean(usa4(:,4));mean(usa5(:,4));mean(usa6(:,4))];
err_sat = [std(usa1(:,3));std(usa2(:,3));std(usa3(:,3));std(usa4(:,3));std(usa5(:,3));std(usa6(:,3));];
err_mod = [std(usa1(:,4));std(usa2(:,4));std(usa3(:,4));std(usa4(:,4));std(usa5(:,4));std(usa6(:,4));];
errorbar(1:6,usa_ave_sat,err_sat)
hold on
errorbar(1:6,usa_ave_mod,err_mod)
xlim([0.5,6.5])
ylim([1775,1850])
legend('sat','mod')
xlabel('�·�')
ylabel('ppb')

figure(2)
cn_ave_sat = [mean(cn1(:,3));mean(cn2(:,3));mean(cn3(:,3));mean(cn4(:,3));mean(cn5(:,3));mean(cn6(:,3))];
cn_ave_mod = [mean(cn1(:,4));mean(cn2(:,4));mean(cn3(:,4));mean(cn4(:,4));mean(cn5(:,4));mean(cn6(:,4))];
err_sat = [std(cn1(:,3));std(cn2(:,3));std(cn3(:,3));std(cn4(:,3));std(cn5(:,3));std(cn6(:,3));];
err_mod = [std(cn1(:,4));std(cn2(:,4));std(cn3(:,4));std(cn4(:,4));std(cn5(:,4));std(cn6(:,4));];
errorbar(1:6,cn_ave_sat,err_sat)
hold on
errorbar(1:6,cn_ave_mod,err_mod)
xlim([0.5,6.5])
legend('sat','mod')
xlabel('�·�')
ylabel('ppb')

figure(3)
aus_ave_sat = [mean(aus1(:,3));mean(aus2(:,3));mean(aus3(:,3));mean(aus4(:,3));mean(aus5(:,3));mean(aus6(:,3))];
aus_ave_mod = [mean(aus1(:,4));mean(aus2(:,4));mean(aus3(:,4));mean(aus4(:,4));mean(aus5(:,4));mean(aus6(:,4))];
err_sat = [std(aus1(:,3));std(aus2(:,3));std(aus3(:,3));std(aus4(:,3));std(aus5(:,3));std(aus6(:,3));];
err_mod = [std(aus1(:,4));std(aus2(:,4));std(aus3(:,4));std(aus4(:,4));std(aus5(:,4));std(aus6(:,4));];
errorbar(1:6,aus_ave_sat,err_sat)
hold on
errorbar(1:6,aus_ave_mod,err_mod)
xlim([0.5,6.5])
legend('sat','mod')
xlabel('�·�')
ylabel('ppb')

figure(4)
eu_ave_sat = [mean(eu1(:,3));mean(eu2(:,3));mean(usa3(:,3));mean(usa4(:,3));mean(usa5(:,3));mean(usa6(:,3))];
eu_ave_mod = [mean(eu1(:,4));mean(eu2(:,4));mean(eu3(:,4));mean(eu4(:,4));mean(eu5(:,4));mean(eu6(:,4))];
err_sat = [std(eu1(:,3));std(eu2(:,3));std(eu3(:,3));std(eu4(:,3));std(eu5(:,3));std(eu6(:,3));];
err_mod = [std(eu1(:,4));std(eu2(:,4));std(eu3(:,4));std(eu4(:,4));std(eu5(:,4));std(eu6(:,4));];
errorbar(1:6,eu_ave_sat,err_sat)
hold on
errorbar(1:6,eu_ave_mod,err_mod)
xlim([0.5,6.5])
legend('sat','mod')
xlabel('�·�')
ylabel('ppb')

disp('������ϣ�����')
